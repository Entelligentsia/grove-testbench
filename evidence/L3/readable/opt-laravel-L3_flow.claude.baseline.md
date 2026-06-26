# transcript: I need to trace the exact method call chain in the Laravel framework's HTTP request handling, from `Router::dispatch` through to where the controller action ...


💬 I'll read the key source files in parallel to trace the full call chain.
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Foundation/Http/Kernel.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Routing/Router.php)

💬 Now let me read the Router's dispatch methods and the Route's run method.
  ▸ Bash(grep -n "function dispatch\|function dispatchToRoute\|function findRoute\|function runRoute\|function prepareResponse\|function toResponse\|function gatherRo...)
  ▸ Bash(grep -n "function run\|function runCallable\|function runController\|function getCallable\|function dispatch\|function isControllerAction\|function resolveMi...)
  ▸ Agent(Trace Laravel HTTP request dispatch methods)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Routing/Router.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Routing/Route.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Routing/ControllerDispatcher.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Routing/Pipeline.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Routing/RouteCollection.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Routing/AbstractRouteCollection.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Pipeline/Pipeline.php)

💬 Here is the complete method trace, in call order, with file locations:  ---  ## Laravel HTTP Request: `Kernel::handle` → controller action  ### Phase 1 — Fou...

──────── RESULT (success, 107284ms, 6 turns) ────────
Here is the complete method trace, in call order, with file locations:

---

## Laravel HTTP Request: `Kernel::handle` → controller action

### Phase 1 — Foundation HTTP Kernel

**`Foundation/Http/Kernel::handle`** `:137`
- Calls `$request->enableHttpMethodParameterOverride()`, then:

**`Foundation/Http/Kernel::sendRequestThroughRouter`** `:164`
- Binds the request in the container, calls `$this->bootstrap()` (runs the six bootstrappers), then builds a `Pipeline` and calls `.then($this->dispatchToRouter())`.

**`Foundation/Http/Kernel::dispatchToRouter`** `:195`
- Returns a `Closure` that calls `$this->router->dispatch($request)`. This closure is the pipeline's *destination* — it only fires after all global middleware have run.

The `Pipeline` (global middleware stack) is `Illuminate\Routing\Pipeline` backed by `Illuminate\Pipeline\Pipeline`. It calls each middleware's `handle($request, $next)` in order, then invokes the destination closure.

---

### Phase 2 — Router dispatch

**`Routing/Router::dispatch`** `:749`
```
→ dispatchToRoute($request)
```

**`Routing/Router::dispatchToRoute`** `:762`
```
→ runRoute($request, findRoute($request))
```

**`Routing/Router::findRoute`** `:773`
- Fires the `Routing` event, then calls:

**`Routing/RouteCollection::match`** `:198`
- Calls `$this->matchAgainstRoutes($routes, $request)`

**`Routing/AbstractRouteCollection::matchAgainstRoutes`** `:79`
- Iterates routes, calls `$route->matches($request)` on each until one succeeds (fallback routes deferred).

Back in `findRoute`: sets `$this->current`, calls `$route->setContainer()`, binds `Route::class` in the container, returns the matched `Route`.

---

### Phase 3 — Running the matched route

**`Routing/Router::runRoute`** `:793`
- Sets the route resolver on the request via `$request->setRouteResolver(fn () => $route)`.
- Fires the `RouteMatched` event.
- Calls `runRouteWithinStack`, wraps result in `prepareResponse`.

**`Routing/Router::runRouteWithinStack`** `:811`
- Calls `gatherRouteMiddleware($route)` to collect route-level middleware.

**`Routing/Router::gatherRouteMiddleware`** `:832`
```
→ resolveMiddleware($route->gatherMiddleware(), $route->excludedMiddleware())
```
`resolveMiddleware` expands groups, resolves aliases, deduplicates, then calls `sortMiddleware` to apply `$middlewarePriority` ordering.

**`Routing/Router::runRouteWithinStack`** (continued)
- Builds a second `Pipeline` (route middleware stack), sends the request through it; the destination closure calls **`$route->run()`**.

---

### Phase 4 — Route execution

**`Routing/Route::run`** `:209`
```php
if ($this->isControllerAction()) {
    return $this->runController();
}
return $this->runCallable();
```

**`Routing/Route::isControllerAction`** `:229`
- Returns `true` when `$action['uses']` is a plain string (not a serialized closure).

#### Controller path:

**`Routing/Route::runController`** `:273`
```
→ $this->controllerDispatcher()->dispatch($this, $this->getController(), $this->getControllerMethod())
```

**`Routing/Route::getController`** `:287`
- Parses `ClassName@method`, resolves the class via `$this->container->make(ClassName)`.

**`Routing/ControllerDispatcher::dispatch`** `:38`
```php
$parameters = $this->resolveParameters($route, $controller, $method);

if (method_exists($controller, 'callAction')) {
    return $controller->callAction($method, $parameters);  // base Controller trait
}

return $controller->{$method}(...array_values($parameters));
```

**`Routing/ControllerDispatcher::resolveParameters`** `:57`
- Calls `resolveClassMethodDependencies` (from `RouteDependencyResolverTrait`) — matches route parameters and type-hinted constructor/method dependencies via the container.

**`Controller::callAction`** (in `Routing/Controller.php`)
- Simply calls `$this->{$method}(...array_values($parameters))` — the actual controller method.

#### Closure/callable path (when no controller):

**`Routing/Route::runCallable`** `:239`
- Unserializes if a `SerializableClosure`, then calls:

**`Routing/CallableDispatcher::dispatch`** — resolves the closure's type-hinted parameters from the container and invokes it.

---

### Phase 5 — Response wrapping

The return value bubbles back up through:

**`Routing/Router::prepareResponse`** `:902` → **`Router::toResponse`** `:918`  
- Normalizes the return value: `Responsable` → `toResponse()`, PSR-7 → convert, Eloquent newly-created → 201 JSON, array/Jsonable → JSON, plain string → HTML `Response`, Symfony response → pass through.
- Calls `$response->prepare($request)` (sets Content-Type, Content-Length headers per HTTP spec).

The normalized `SymfonyResponse` travels back up through the route-middleware pipeline (response phase of each middleware), then back through the global-middleware pipeline (response phase), and is returned from `Kernel::handle`.

---

### Condensed call chain

```
Kernel::handle
  └─ sendRequestThroughRouter
       ├─ bootstrap
       └─ Pipeline[global middleware]::then → dispatchToRouter closure
            └─ Router::dispatch
                 └─ dispatchToRoute
                      ├─ findRoute
                      │    └─ RouteCollection::match
                      │         └─ AbstractRouteCollection::matchAgainstRoutes
                      │              └─ Route::matches (per route)
                      └─ runRoute
                           ├─ setRouteResolver / fires RouteMatched
                           └─ runRouteWithinStack
                                ├─ gatherRouteMiddleware → resolveMiddleware → sortMiddleware
                                └─ Pipeline[route middleware]::then → Route::run
                                     ├─ [closure] runCallable → CallableDispatcher::dispatch
                                     └─ [controller] runController
                                          ├─ getController  (container::make)
                                          ├─ getControllerMethod
                                          └─ ControllerDispatcher::dispatch
                                               ├─ resolveParameters (DI resolution)
                                               └─ Controller::callAction → $controller->$method(...)
```

Two pipeline passes are the key structural fact: global middleware wrap the entire router call; route middleware wrap only `Route::run()`. The controller is finally invoked inside the innermost pipeline's destination closure via `ControllerDispatcher::dispatch`.
