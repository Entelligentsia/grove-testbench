# transcript: Trace how Laravel handles an incoming HTTP request through the framework HTTP kernel: name every method it passes through, in order, from `Http\Kernel::handl...


💬 Let me load the grove tools first, then trace the request flow.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me start tracing from `Http\Kernel::handle`. I'll look at Foundation's HTTP Kernel first, then follow the chain in parallel where possible.
  ▸ mcp__grove__source({"file":"src/Illuminate/Foundation/Http/Kernel.php","name":"handle"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Foundation/Http/Kernel.php","detail":1})

💬 Good. `handle` calls `sendRequestThroughRouter` and `dispatchToRouter`. Let me fetch those, plus get the Router's `dispatch` chain — all in parallel.
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#sendRequestThroughRouter@164"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#dispatchToRouter@195"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Routing/Router.php","kind":"function","detail":1})

💬 Now I'll fetch the key Router dispatch chain methods all in parallel.
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#dispatch@749"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#dispatchToRoute@762"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#findRoute@773"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#runRoute@793"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#runRouteWithinStack@811"})

💬 The pipeline ends with `$route->run()`. Now let me fetch that and the `RouteCollection::match` method in parallel.
  ▸ mcp__grove__source({"file":"src/Illuminate/Routing/Route.php","name":"run"})
  ▸ mcp__grove__symbols({"dir":"src/Illuminate/Routing","name":"match","kind":"function"})

💬 Now I need `Route::runController`, `Route::isControllerAction`, and both `RouteCollection::match` implementations in parallel.
  ▸ mcp__grove__source({"file":"src/Illuminate/Routing/Route.php","name":"runController"})
  ▸ mcp__grove__source({"file":"src/Illuminate/Routing/Route.php","name":"isControllerAction"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/RouteCollection.php#match@198"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/CompiledRouteCollection.php#match@116"})

💬 Finally, let me fetch `ControllerDispatcher::dispatch` and `Route::controllerDispatcher` together.
  ▸ mcp__grove__source({"file":"src/Illuminate/Routing/Route.php","name":"controllerDispatcher"})
  ▸ mcp__grove__source({"file":"src/Illuminate/Routing/ControllerDispatcher.php","name":"dispatch"})

💬 I have the full picture. Here is the complete call chain, in order, from `Kernel::handle` to the moment the controller method fires:  ---  ## Laravel HTTP Re...

──────── RESULT (success, 86871ms, 20 turns) ────────
I have the full picture. Here is the complete call chain, in order, from `Kernel::handle` to the moment the controller method fires:

---

## Laravel HTTP Request Dispatch Chain

### 1. `Foundation\Http\Kernel::handle($request)` — `Foundation/Http/Kernel.php:137`
Records `requestStartedAt`, calls `$request->enableHttpMethodParameterOverride()` (allows `_method` field to override the HTTP verb), then calls:

### 2. `Kernel::sendRequestThroughRouter($request)` — `Kernel.php:164`
- Binds `$request` into the container as `'request'`.
- Clears the `Request` facade's resolved instance.
- Calls `$this->bootstrap()` → runs all bootstrappers (loads env, config, registers facades, registers and boots service providers, etc.).
- Constructs a `Pipeline`, `.send($request)`, `.through($this->middleware)` (global kernel middleware), then `.then($this->dispatchToRouter())` as the final destination.

### 3. `Kernel::dispatchToRouter()` — `Kernel.php:195`
Returns a closure that re-binds the (possibly mutated) request to the container and calls:

### 4. `Router::dispatch(Request $request)` — `Routing/Router.php:749`
Sets `$this->currentRequest`, then calls:

### 5. `Router::dispatchToRoute(Request $request)` — `Router.php:762`
Single expression: calls `findRoute` and passes its result to `runRoute`:

### 6. `Router::findRoute($request)` — `Router.php:773`
- Fires the `Illuminate\Routing\Events\Routing` event.
- Calls **`$this->routes->match($request)`** on whichever collection is active:
  - **`CompiledRouteCollection::match`** (`CompiledRouteCollection.php:116`) — primary path: wraps request in a Symfony `RequestContext`, delegates to Symfony's `CompiledUrlMatcher::matchRequest()`, looks up the named route, falls back to `RouteCollection::match` on miss/fallback.
  - **`RouteCollection::match`** (`RouteCollection.php:198`) — secondary/fallback: calls `$this->get($request->getMethod())` to retrieve verb-indexed routes, then `$this->matchAgainstRoutes()` (iterates routes calling `Route::matches()`), then `$this->handleMatchedRoute()`.
- Stores matched route in `$this->current`, sets its container, registers it as `Route::class` in the container.

### 7. `Router::runRoute(Request $request, Route $route)` — `Router.php:793`
- Attaches a route-resolver closure to the request via `$request->setRouteResolver()`.
- Fires the `Illuminate\Routing\Events\RouteMatched` event.
- Calls `runRouteWithinStack`, wraps the result in `$this->prepareResponse()`.

### 8. `Router::runRouteWithinStack(Route $route, Request $request)` — `Router.php:811`
- Calls `$this->gatherRouteMiddleware($route)` → collects + resolves + sorts the route's middleware stack (controller middleware, `middleware()` calls, group middleware, etc.).
- Constructs a second `Pipeline`, `.send($request)`, `.through($middleware)` (route-level middleware), then `.then(fn => $route->run())`.

### 9. `Route::run()` — `Routing/Route.php:209`
Dispatches on action type:
- **Controller action** (`isControllerAction()` → action `uses` is a plain string like `FooController@bar`): calls `runController()`.
- **Closure action**: calls `runCallable()` (container call, then done — no further steps below apply).

### 10. `Route::runController()` — `Route.php:273`
Resolves the controller dispatcher (from container binding `ControllerDispatcherContract`, or `new ControllerDispatcher`), then calls:

### 11. `ControllerDispatcher::dispatch(Route $route, $controller, $method)` — `Routing/ControllerDispatcher.php:38`
- Calls **`$this->resolveParameters($route, $controller, $method)`** — uses the container to inject typed dependencies and applies route model bindings to the action's parameter list.
- If the controller has a `callAction` method (all controllers extending `Illuminate\Routing\Controller` do): calls **`$controller->callAction($method, $parameters)`**, which simply delegates to `$this->{$method}(...array_values($parameters))`.
- Otherwise calls **`$controller->{$method}(...array_values($parameters))`** directly.

**The controller method executes here.**

---

### Summary diagram

```
Kernel::handle
 └─ Kernel::sendRequestThroughRouter
     ├─ Kernel::bootstrap              (bootstrappers)
     └─ Pipeline [global middleware]
         └─ Kernel::dispatchToRouter (closure)
             └─ Router::dispatch
                 └─ Router::dispatchToRoute
                     ├─ Router::findRoute
                     │   └─ CompiledRouteCollection::match  (or RouteCollection::match)
                     └─ Router::runRoute
                         ├─ (fires RouteMatched event)
                         └─ Router::runRouteWithinStack
                             └─ Pipeline [route middleware]
                                 └─ Route::run
                                     └─ Route::runController
                                         └─ ControllerDispatcher::dispatch
                                             ├─ resolveParameters   (DI + model binding)
                                             └─ Controller::callAction  →  $controller->$method(...)
```

Two `Pipeline` passes — one for **global middleware** (in `sendRequestThroughRouter`) and one for **route middleware** (in `runRouteWithinStack`) — bracket the route-matching and controller dispatch in the middle. Route model bindings are resolved inside `ControllerDispatcher::resolveParameters`, just before the action method is called.
