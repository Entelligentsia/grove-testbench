# transcript: Give a complete architectural walkthrough of Laravel's full HTTP request lifecycle from public/index.php to a sent response — the cross-cutting request archi...


💬 I'll trace the full request lifecycle using grove's semantic tools. Let me load the schemas and then map each subsystem in order.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__map,mcp__grove__callers,mcp__grove__definition)

💬 Now let me fan out across all the major subsystems simultaneously.
  ▸ mcp__grove__outline({"file":"src/Illuminate/Foundation/Http/Kernel.php"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Foundation/Application.php","detail":0})
  ▸ mcp__grove__map({"dir":"src/Illuminate/Foundation/Bootstrap"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Routing/Router.php","detail":0})

💬 Now let me pull the critical method bodies in parallel — the hot path from entry to response.
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#handle@137"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#sendRequestThroughRouter@164"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Application.php#bootstrapWith@335"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#dispatch@749"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#runRouteWithinStack@811"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#dispatchToRoute@762"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#runRoute@793"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#findRoute@773"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#dispatchToRouter@195"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Application.php#handleRequest@1216"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Pipeline/Pipeline.php"})
  ▸ mcp__grove__symbols({"dir":"src/Illuminate/Routing","kind":"function","name":"run"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Container/Container.php","detail":0})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#bootstrap@183"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Pipeline/Pipeline.php#then@128"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Pipeline/Pipeline.php#carry@192"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Route.php#run@209"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolve@904"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#build@1109"})
  ▸ mcp__grove__symbols({"dir":"src/Illuminate/Routing","kind":"function","name":"runController"})
  ▸ mcp__grove__symbols({"dir":"src/Illuminate/Routing","kind":"class","name":"ControllerDispatcher"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Application.php#__construct@216"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Application.php#boot@1120"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#terminate@211"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Route.php#runController@273"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Routing/ControllerDispatcher.php"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Application.php#registerBaseBindings@280"})
  ▸ mcp__grove__symbols({"dir":"src/Illuminate/Routing","kind":"function","name":"match"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Application.php#registerBaseServiceProviders@299"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/ControllerDispatcher.php#dispatch@38"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/RouteCollection.php#match@198"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#prepareResponse@902"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolveDependencies@1215"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Foundation/Http/Kernel.php#__construct@123"})

💬 Last two pieces — the bootstrapper list and route middleware gathering:
  ▸ mcp__grove__source({"file":"src/Illuminate/Foundation/Http/Kernel.php","name":"bootstrappers"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#gatherRouteMiddleware@832"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#toResponse@918"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Routing/Router.php#substituteBindings@958"})

💬 I now have every method body I need. Here is the complete walkthrough.  ---  # Laravel HTTP Request Lifecycle — Full Architecture Walkthrough  ---  ## 0. Bef...

──────── RESULT (success, 225606ms, 44 turns) ────────
I now have every method body I need. Here is the complete walkthrough.

---

# Laravel HTTP Request Lifecycle — Full Architecture Walkthrough

---

## 0. Before the First PHP Line

PHP-FPM (or nginx+php-fpm) receives the TCP connection, resolves `public/index.php` as the script root, and invokes the PHP interpreter. Everything below happens inside that single PHP process.

---

## 1. Entry Point — `public/index.php`

```
public/index.php  (application skeleton, not in framework repo)
```

```php
define('LARAVEL_START', microtime(true));

// Maintenance mode short-circuit
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

require __DIR__.'/../vendor/autoload.php';

$app = require_once __DIR__.'/../bootstrap/app.php';   // creates Application

Illuminate\Http\Request::capture()
    |> $app->handleRequest($request);                  // Application::handleRequest
```

`Request::capture()` wraps the PHP superglobals (`$_GET`, `$_POST`, `$_SERVER`, …) into an `Illuminate\Http\Request` (a Symfony `Request` subclass).

`bootstrap/app.php` is where the application instance is built — either the modern fluent builder (Laravel 11+) or a direct `new Application(...)` call.

---

## 2. Application Construction — `Application::__construct`

**`src/Illuminate/Foundation/Application.php:216`**

```
__construct($basePath)
  ├─ setBasePath($basePath)          → bindPathsInContainer()      :415
  ├─ registerBaseBindings()                                         :280
  │     setInstance($this)           → static singleton
  │     instance('app', $this)
  │     instance(Container::class, $this)
  │     singleton(PackageManifest)
  ├─ registerBaseServiceProviders()                                  :299
  │     register(EventServiceProvider)
  │     register(LogServiceProvider)
  │     register(ContextServiceProvider)
  │     register(RoutingServiceProvider)   ← binds Router, UrlGenerator, Redirector, …
  └─ registerCoreContainerAliases()                                  :1636
        'app' → Application, Container, …
        'router' → Router
        'request' → Request
        … ~40 aliases
```

`Application` itself **is** the container — it extends `Illuminate\Container\Container`. Every alias registered here is what makes `app('router')` or `resolve(Request::class)` work throughout the framework.

---

## 3. HTTP Kernel Resolution

**`src/Illuminate/Foundation/Application.php:1216`** — `handleRequest`

```php
public function handleRequest(Request $request)
{
    $kernel = $this->make(HttpKernelContract::class);   // Container::resolve
    $response = $kernel->handle($request)->send();
    $kernel->terminate($request, $response);
}
```

`$this->make(HttpKernelContract::class)` triggers the full container resolution cycle (§7 below). The concrete class bound to `Illuminate\Contracts\Http\Kernel` is the application's `App\Http\Kernel`, which extends `Illuminate\Foundation\Http\Kernel`.

**`src/Illuminate/Foundation/Http/Kernel.php:123`** — `__construct`

```php
public function __construct(Application $app, Router $router)
{
    $this->app    = $app;
    $this->router = $router;
    $this->syncMiddlewareToRouter();   // copies $middlewareGroups / $middlewareAliases → Router
}
```

Both `Application` and `Router` are injected by the container. `syncMiddlewareToRouter()` (:521) pushes every middleware group and alias declared in the kernel into the `Router` instance so route-level middleware resolution can find them.

---

## 4. `Kernel::handle` — Top of the Request Stack

**`src/Illuminate/Foundation/Http/Kernel.php:137`**

```php
public function handle($request)
{
    $this->requestStartedAt = Carbon::now();

    try {
        $request->enableHttpMethodParameterOverride();        // honours X-HTTP-Method-Override
        $response = $this->sendRequestThroughRouter($request);
    } catch (Throwable $e) {
        $this->reportException($e);                           // → ExceptionHandler::report
        $response = $this->renderException($request, $e);    // → ExceptionHandler::render
    }

    $this->app['events']->dispatch(new RequestHandled($request, $response));

    return $response;
}
```

`requestStartedAt` is the clock used later by `whenRequestLifecycleIsLongerThan` callbacks (:272). The try/catch here is the outermost exception boundary for the entire request; anything that escapes the pipeline lands here.

---

## 5. `sendRequestThroughRouter` — Bootstrap + Global Pipeline

**`src/Illuminate/Foundation/Http/Kernel.php:164`**

```php
protected function sendRequestThroughRouter($request)
{
    $this->app->instance('request', $request);   // re-bind fresh request into container
    Request::clearResolvedInstance();             // invalidate facade cache

    $this->bootstrap();                           // ← §6

    return (new Pipeline($this->app))
        ->send($request)
        ->through($this->app->shouldSkipMiddleware() ? [] : $this->middleware)
        ->then($this->dispatchToRouter());        // ← terminal closure
}
```

Three things happen here in order:

1. The live `$request` replaces the placeholder in the container.
2. Framework bootstrapping runs (once per process).
3. The **global middleware pipeline** is constructed and executed.

---

## 6. Framework Bootstrap — `Application::bootstrapWith`

**`src/Illuminate/Foundation/Http/Kernel.php:183`**

```php
public function bootstrap()
{
    if (! $this->app->hasBeenBootstrapped()) {
        $this->app->bootstrapWith($this->bootstrappers());
    }
}
```

The bootstrapper list, in order (**`Kernel.php:43`**):

```
LoadEnvironmentVariables   → Dotenv::safeLoad(), populates $_ENV / $_SERVER
LoadConfiguration          → loads config/*.php into Repository, sets timezone/locale
HandleExceptions           → set_error_handler + set_exception_handler
RegisterFacades            → AliasLoader::getInstance()->register() — class_alias for every Facade
RegisterProviders          → Application::registerConfiguredProviders() — registers all app providers
BootProviders              → Application::boot()
```

**`src/Illuminate/Foundation/Application.php:335`** — `bootstrapWith`

```php
public function bootstrapWith(array $bootstrappers)
{
    $this->hasBeenBootstrapped = true;
    foreach ($bootstrappers as $bootstrapper) {
        $this['events']->dispatch('bootstrapping: '.$bootstrapper, [$this]);
        $this->make($bootstrapper)->bootstrap($this);          // container instantiates + runs
        $this['events']->dispatch('bootstrapped: '.$bootstrapper, [$this]);
    }
}
```

`BootProviders::bootstrap` calls **`Application::boot`** (:1120):

```php
public function boot()
{
    $this->fireAppCallbacks($this->bootingCallbacks);
    array_walk($this->serviceProviders, fn($p) => $this->bootProvider($p));
    $this->booted = true;
    $this->fireAppCallbacks($this->bootedCallbacks);
}
```

Every registered service provider's `boot()` method runs here, in registration order. This is when `Route::get(...)` calls in `RouteServiceProvider::boot` populate the `RouteCollection`.

---

## 7. The Service Container — `Container::resolve` / `build`

This runs constantly throughout the lifecycle — every `make()`, every middleware instantiation, every controller construction passes through here.

**`src/Illuminate/Container/Container.php:904`** — `resolve`

```
resolve($abstract, $parameters, $raiseEvents)
  ├─ getAlias($abstract)               → walk alias chain to concrete name
  ├─ fireBeforeResolvingCallbacks()
  ├─ getContextualConcrete($abstract)  → check contextual bindings (when()->needs()->give())
  ├─ if instances[$abstract] exists → return singleton cache   ← most common fast path
  ├─ getConcrete($abstract)            → look up bindings[] closure or use class name directly
  ├─ isBuildable($concrete) ?
  │     build($concrete)               → §7a
  │   : make($concrete)                → recurse (concrete is itself an abstract alias)
  ├─ apply getExtenders()              → decorator chain
  ├─ if isShared() → cache in instances[]
  ├─ fireResolvingCallbacks()
  └─ resolved[$abstract] = true
```

**`src/Illuminate/Container/Container.php:1109`** — `build`

```
build($concrete)
  ├─ if Closure → execute closure($container, $overrides), return
  ├─ ReflectionClass($concrete)
  ├─ if !isInstantiable() → notInstantiable() exception
  ├─ getConstructor() → null? → new $concrete, return
  ├─ resolveDependencies($constructor->getParameters())   → §7b
  └─ new $concrete(...$instances)
```

**`src/Illuminate/Container/Container.php:1215`** — `resolveDependencies`

For each constructor parameter:
- Check `$parameters` override array first.
- Check PHP 8 `#[Attribute]` bindings via `resolveFromAttribute`.
- If typed class → `resolveClass()` → recurse through `make()`.
- If primitive → `resolvePrimitive()` → check contextual binding, else use default.

This is the recursive DI engine. A deep object graph like `Controller → Service → Repository → Connection` is resolved in one `make()` call by recursing the parameter list at each level.

---

## 8. Global Middleware Pipeline — `Pipeline`

**`src/Illuminate/Pipeline/Pipeline.php`**

After `bootstrap()`, control returns to `sendRequestThroughRouter` and the pipeline executes:

```php
(new Pipeline($this->app))
    ->send($request)
    ->through($this->middleware)      // e.g. [TrustProxies, PreventRequestsDuringMaintenance,
                                      //        ValidateCsrfToken, HandleCors, …]
    ->then($this->dispatchToRouter())
```

**`Pipeline::then` (:128)**:

```php
public function then(Closure $destination)
{
    $pipeline = array_reduce(
        array_reverse($this->pipes()),
        $this->carry(),
        $this->prepareDestination($destination)
    );
    return $pipeline($this->passable);
}
```

`array_reverse` + `array_reduce` wraps each middleware around the next like Russian dolls. The innermost callable is `$destination` — `dispatchToRouter()`. The outermost callable is the first middleware.

**`Pipeline::carry` (:192)** — the reducer function:

```php
return function ($stack, $pipe) {
    return function ($passable) use ($stack, $pipe) {
        if (is_callable($pipe)) {
            return $pipe($passable, $stack);
        } elseif (! is_object($pipe)) {
            [$name, $parameters] = $this->parsePipeString($pipe);
            $pipe = $this->getContainer()->make($name);        // container resolves middleware
            $parameters = array_merge([$passable, $stack], $parameters);
        } else {
            $parameters = [$passable, $stack];
        }
        $carry = method_exists($pipe, $this->method)
            ? $pipe->{$this->method}(...$parameters)           // $pipe->handle($request, $next)
            : $pipe(...$parameters);
        return $this->handleCarry($carry);
    };
};
```

Each middleware class is resolved from the container at call time (not upfront), receives `($request, $next)`, and must call `$next($request)` to continue. Middleware can modify `$request` before passing it on and modify `$response` on the way back out.

---

## 9. `dispatchToRouter` — Pipeline Terminal

**`src/Illuminate/Foundation/Http/Kernel.php:195`**

```php
protected function dispatchToRouter()
{
    return function ($request) {
        $this->app->instance('request', $request);   // re-bind post-middleware request
        return $this->router->dispatch($request);
    };
}
```

This closure is the `$destination` passed to `Pipeline::then`. When every global middleware has called `$next($request)`, execution arrives here.

---

## 10. Routing — `Router::dispatch` → `findRoute` → `RouteCollection::match`

**`src/Illuminate/Routing/Router.php:749`**

```php
public function dispatch(Request $request)
{
    $this->currentRequest = $request;
    return $this->dispatchToRoute($request);
}
```

**`Router::dispatchToRoute` (:762)**

```php
public function dispatchToRoute(Request $request)
{
    return $this->runRoute($request, $this->findRoute($request));
}
```

**`Router::findRoute` (:773)**

```php
protected function findRoute($request)
{
    $this->events->dispatch(new Routing($request));          // fires Routing event

    $this->current = $route = $this->routes->match($request);   // RouteCollection::match

    $route->setContainer($this->container);
    $this->container->instance(Route::class, $route);        // bind matched route in container

    return $route;
}
```

**`RouteCollection::match` (`src/Illuminate/Routing/RouteCollection.php:198`)**

```php
public function match(Request $request)
{
    $routes = $this->get($request->getMethod());       // narrow by HTTP verb
    $route  = $this->matchAgainstRoutes($routes, $request);
    return $this->handleMatchedRoute($request, $route);
}
```

`matchAgainstRoutes` iterates the verb-keyed route list, calling `Route::matches($request)` on each until one passes its compiled Symfony `CompiledRoute` regex. If the verb matches but the URI doesn't, it checks other verbs for a 405. No match at all → `NotFoundHttpException`.

---

## 11. Route Middleware + Binding — `runRoute` → `runRouteWithinStack`

**`Router::runRoute` (:793)**

```php
protected function runRoute(Request $request, Route $route)
{
    $request->setRouteResolver(fn () => $route);           // request knows its route

    $this->events->dispatch(new RouteMatched($route, $request));

    return $this->prepareResponse($request,
        $this->runRouteWithinStack($route, $request)
    );
}
```

**`Router::runRouteWithinStack` (:811)**

```php
protected function runRouteWithinStack(Route $route, Request $request)
{
    $shouldSkipMiddleware = $this->container->bound('middleware.disable') &&
                            $this->container->make('middleware.disable') === true;

    $middleware = $shouldSkipMiddleware ? [] : $this->gatherRouteMiddleware($route);

    return (new Pipeline($this->container))
        ->send($request)
        ->through($middleware)                             // second, inner pipeline
        ->then(fn ($request) => $this->prepareResponse(
            $request, $route->run()                        // ← controller dispatch
        ));
}
```

**`Router::gatherRouteMiddleware` (:832)**

```php
public function gatherRouteMiddleware(Route $route)
{
    return $this->resolveMiddleware(
        $route->gatherMiddleware(),       // merges group + route-level middleware names
        $route->excludedMiddleware()
    );
}
```

`resolveMiddleware` (:844) expands group names → individual class names, strips excluded ones, and sorts by `$middlewarePriority`. The result is a flat, ordered list like:

```
[SubstituteBindings, Authenticate, ThrottleRequests, ValidatePostSize, …]
```

A **second `Pipeline`** is constructed here — identical mechanics to §8, but carrying only route-scoped middleware. `SubstituteBindings` (a built-in middleware) calls `Router::substituteBindings` (:958) and `substituteImplicitBindings` (:978) to resolve route model bindings (`{user}` → `User::findOrFail($id)`).

---

## 12. Controller Dispatch — `Route::run` → `ControllerDispatcher`

**`src/Illuminate/Routing/Route.php:209`** — `run`

```php
public function run()
{
    $this->container = $this->container ?: new Container;

    try {
        if ($this->isControllerAction()) {
            return $this->runController();
        }
        return $this->runCallable();
    } catch (HttpResponseException $e) {
        return $e->getResponse();
    }
}
```

**`Route::runController` (:273)**

```php
protected function runController()
{
    return $this->controllerDispatcher()->dispatch(
        $this, $this->getController(), $this->getControllerMethod()
    );
}
```

`getController()` calls `$this->container->make(ControllerClass)`, which runs the full container resolution cycle — constructor-injecting every type-hinted service into the controller.

**`ControllerDispatcher::dispatch` (`src/Illuminate/Routing/ControllerDispatcher.php:38`)**

```php
public function dispatch(Route $route, $controller, $method)
{
    $parameters = $this->resolveParameters($route, $controller, $method);

    if (method_exists($controller, 'callAction')) {
        return $controller->callAction($method, $parameters);
    }

    return $controller->{$method}(...array_values($parameters));
}
```

`resolveParameters` uses `Container::call()`, which reflects the controller method's parameter list and merges route parameters (already bound by `SubstituteBindings`) with any remaining type-hinted dependencies resolved from the container. The controller method is then called with the fully resolved argument list.

For closure routes, `Route::runCallable` calls `$this->container->call($this->action['uses'])` directly.

---

## 13. Response Preparation — `Router::prepareResponse` → `toResponse`

**`src/Illuminate/Routing/Router.php:902`** — `prepareResponse`

```php
public function prepareResponse($request, $response)
{
    $this->events->dispatch(new PreparingResponse($request, $response));

    return tap(static::toResponse($request, $response), function ($response) use ($request) {
        $this->events->dispatch(new ResponsePrepared($request, $response));
    });
}
```

**`Router::toResponse` (static, :918)** normalises any return type into a `SymfonyResponse`:

| Controller returns | Becomes |
|---|---|
| `Responsable` | calls `->toResponse($request)` |
| PSR-7 `ResponseInterface` | `HttpFoundationFactory::createResponse()` |
| Eloquent `Model` (wasRecentlyCreated) | `JsonResponse($model, 201)` |
| `Stringable` | `Response($str, 200)` |
| `array`, `Arrayable`, `Jsonable`, `stdClass` | `JsonResponse($data)` |
| bare string | `Response($str, 200, ['Content-Type' => 'text/html'])` |
| already `SymfonyResponse` | pass-through |

Then calls `$response->prepare($request)` — Symfony's method that sets `Content-Length`, handles `HEAD` requests, strips body on 204/304, etc.

This normalised response bubbles back out through the **inner pipeline** (route middleware, each seeing it on the way out), then back through the **outer pipeline** (global middleware), and returns to `Kernel::handle`.

---

## 14. Sending the Response

Back in **`Application::handleRequest` (:1216)**:

```php
$response = $kernel->handle($request)->send();
```

`SymfonyResponse::send()` calls:
1. `sendHeaders()` — `header()` for status line and each header
2. `sendContent()` — `echo $this->content`

Then:

```php
$kernel->terminate($request, $response);
```

---

## 15. Termination — `Kernel::terminate`

**`src/Illuminate/Foundation/Http/Kernel.php:211`**

```php
public function terminate($request, $response)
{
    $this->app['events']->dispatch(new Terminating);

    $this->terminateMiddleware($request, $response);   // calls terminate() on stateful middleware

    $this->app->terminate();                           // fires app terminating callbacks

    // check requestLifecycleDurationHandlers …
}
```

`terminateMiddleware` (:243) walks the global `$middleware` list and the route's gathered middleware. For each class that implements `TerminableMiddleware` (defines `terminate($request, $response)`), it resolves the instance from the container and calls `terminate()`. This is where session flushing and cookie queuing happen.

`Application::terminate` (:1461) runs all callbacks registered via `app()->terminating(fn () => …)`.

Finally PHP-FPM reclaims the worker or keeps it alive for the next request.

---

## Unified Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  public/index.php                                                            │
│  Request::capture()  →  $app->handleRequest($request)                       │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  Application::__construct                                │
                    │  registerBaseBindings()       ← self + Container bound  │
                    │  registerBaseServiceProviders() ← Event/Log/Routing SPs │
                    │  registerCoreContainerAliases() ← ~40 aliases           │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  Application::handleRequest                              │
                    │  make(HttpKernelContract) ← Container resolves Kernel   │
                    │    Kernel::__construct(app, router)                      │
                    │    syncMiddlewareToRouter()                              │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  Kernel::handle()       Foundation/Http/Kernel.php:137  │
                    │  requestStartedAt = now()                                │
                    │  request->enableHttpMethodParameterOverride()            │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  sendRequestThroughRouter()                    :164      │
                    │  app->instance('request', $request)                      │
                    │  bootstrap()  ──────────────────────────────────────┐   │
                    └───────────┬────────────┘                            │   │
                                │                            ┌────────────▼─┐ │
                                │                            │  bootstrapWith│ │
                                │                            │  Application  │ │
                                │                            │  .php:335     │ │
                                │                            │               │ │
                                │                            │ 1 LoadEnvVars │ │
                                │                            │ 2 LoadConfig  │ │
                                │                            │ 3 HandleExc.  │ │
                                │                            │ 4 RegFacades  │ │
                                │                            │ 5 RegProviders│ │
                                │                            │ 6 BootProviders│ │
                                │                            │   └ boot() all│ │
                                │                            │     providers │ │
                                │                            └───────────────┘ │
                                │
          ┌─────────────────────▼──────────────────────────────────────┐
          │              GLOBAL MIDDLEWARE PIPELINE                     │
          │              Pipeline::then()  Pipeline.php:128            │
          │                                                             │
          │  ┌──────────────────────────────────────────────────────┐  │
          │  │ array_reverse + array_reduce (carry closure) :192    │  │
          │  │                                                       │  │
          │  │  Middleware N  handle($req, $next)                   │  │
          │  │    Middleware N-1  handle($req, $next)               │  │
          │  │      …                                               │  │
          │  │        Middleware 1  handle($req, $next)             │  │
          │  │          └─ $next($req) ──► dispatchToRouter()      │  │
          │  └──────────────────────────────────────────────────────┘  │
          └─────────────────────┬──────────────────────────────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  Router::dispatch()     Routing/Router.php:749           │
                    │  dispatchToRoute()                             :762      │
                    │  findRoute()                                   :773      │
                    │    events->dispatch(new Routing)                         │
                    │    RouteCollection::match($request)            :198      │
                    │      get($method) → matchAgainstRoutes()                 │
                    │      → Route regex match (Symfony CompiledRoute)         │
                    │    container->instance(Route::class, $route)             │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  Router::runRoute()                            :793      │
                    │  request->setRouteResolver(fn()=>$route)                 │
                    │  events->dispatch(new RouteMatched)                      │
                    └───────────┬────────────┘
                                │
          ┌─────────────────────▼──────────────────────────────────────┐
          │              ROUTE MIDDLEWARE PIPELINE                      │
          │              runRouteWithinStack()  Router.php:811         │
          │                                                             │
          │  gatherRouteMiddleware()  ← expand groups, sort priority   │
          │                                                             │
          │  ┌──────────────────────────────────────────────────────┐  │
          │  │  SubstituteBindings  handle($req, $next)             │  │
          │  │    Router::substituteBindings()  (explicit)          │  │
          │  │    Router::substituteImplicitBindings() (model bind) │  │
          │  │  Authenticate        handle($req, $next)             │  │
          │  │  ThrottleRequests    handle($req, $next)             │  │
          │  │  …                                                    │  │
          │  │    └─ $next($req) ──► Route::run()                   │  │
          │  └──────────────────────────────────────────────────────┘  │
          └─────────────────────┬──────────────────────────────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  Route::run()           Routing/Route.php:209            │
                    │  isControllerAction()?                                   │
                    │    runController()                              :273      │
                    │      container->make(ControllerClass)  ◄── DI           │
                    │      ControllerDispatcher::dispatch()  :38               │
                    │        resolveParameters()  ← merge route params + DI   │
                    │        controller->callAction($method, $params)          │
                    │    or runCallable() → container->call($closure)          │
                    └───────────┬────────────┘
                                │  raw return value
                    ┌───────────▼────────────┐
                    │  Router::prepareResponse()                     :902      │
                    │  Router::toResponse()   (static)               :918      │
                    │    Responsable → toResponse($request)                    │
                    │    array/Arrayable → JsonResponse                        │
                    │    string → Response(200, text/html)                     │
                    │    Model (201) → JsonResponse                            │
                    │    …                                                      │
                    │  SymfonyResponse::prepare($request)                      │
                    │    sets Content-Length, handles HEAD/304                 │
                    └───────────┬────────────┘
                                │  SymfonyResponse
                                │  ← bubbles back through route middleware
                                │  ← bubbles back through global middleware
                                │
                    ┌───────────▼────────────┐
                    │  SymfonyResponse::send()                                 │
                    │    sendHeaders() → header()                              │
                    │    sendContent() → echo                                  │
                    └───────────┬────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  Kernel::terminate()                           :211      │
                    │  events->dispatch(new Terminating)                       │
                    │  terminateMiddleware()  → middleware::terminate()        │
                    │  Application::terminate() → terminating callbacks        │
                    │  duration handlers (slow request logging)                │
                    └────────────────────────┘
```

---

## Call Order Summary Table

| # | Function | File | Line | Role |
|---|---|---|---|---|
| 1 | `Request::capture` | `Http/Request.php` | — | Wrap superglobals |
| 2 | `Application::__construct` | `Foundation/Application.php` | 216 | Container bootstrap |
| 3 | `Application::registerBaseBindings` | `Foundation/Application.php` | 280 | Bind self + core types |
| 4 | `Application::registerBaseServiceProviders` | `Foundation/Application.php` | 299 | Event/Log/Routing SPs |
| 5 | `Application::registerCoreContainerAliases` | `Foundation/Application.php` | 1636 | ~40 string→class aliases |
| 6 | `Application::handleRequest` | `Foundation/Application.php` | 1216 | Make kernel, drive loop |
| 7 | `Container::resolve` / `build` | `Container/Container.php` | 904 / 1109 | DI resolution engine |
| 8 | `Kernel::__construct` | `Foundation/Http/Kernel.php` | 123 | Wire app+router, sync middleware |
| 9 | `Kernel::handle` | `Foundation/Http/Kernel.php` | 137 | Outermost try/catch |
| 10 | `Kernel::sendRequestThroughRouter` | `Foundation/Http/Kernel.php` | 164 | Bind request, bootstrap, outer pipeline |
| 11 | `Kernel::bootstrap` → `Application::bootstrapWith` | `Kernel.php:183` / `Application.php:335` | — | 6-step framework boot |
| 12 | `Pipeline::then` / `carry` | `Pipeline/Pipeline.php` | 128 / 192 | Onion middleware execution |
| 13 | `Kernel::dispatchToRouter` | `Foundation/Http/Kernel.php` | 195 | Pipeline terminal closure |
| 14 | `Router::dispatch` | `Routing/Router.php` | 749 | Entry into routing subsystem |
| 15 | `Router::findRoute` | `Routing/Router.php` | 773 | Fire Routing event, match route |
| 16 | `RouteCollection::match` | `Routing/RouteCollection.php` | 198 | Verb filter + regex match |
| 17 | `Router::runRoute` | `Routing/Router.php` | 793 | Set resolver, fire RouteMatched |
| 18 | `Router::runRouteWithinStack` | `Routing/Router.php` | 811 | Gather route middleware, inner pipeline |
| 19 | `Router::gatherRouteMiddleware` | `Routing/Router.php` | 832 | Expand groups, sort by priority |
| 20 | `Route::run` | `Routing/Route.php` | 209 | Branch: controller vs closure |
| 21 | `Route::runController` | `Routing/Route.php` | 273 | Make controller class via container |
| 22 | `ControllerDispatcher::dispatch` | `Routing/ControllerDispatcher.php` | 38 | Resolve method params, call action |
| 23 | `Container::resolveDependencies` | `Container/Container.php` | 1215 | Recursive param injection |
| 24 | `Router::prepareResponse` / `toResponse` | `Routing/Router.php` | 902 / 918 | Normalise to SymfonyResponse |
| 25 | `SymfonyResponse::send` | (Symfony) | — | `header()` + `echo` |
| 26 | `Kernel::terminate` | `Foundation/Http/Kernel.php` | 211 | Post-send cleanup |
| 27 | `Kernel::terminateMiddleware` | `Foundation/Http/Kernel.php` | 243 | `TerminableMiddleware::terminate()` |
| 28 | `Application::terminate` | `Foundation/Application.php` | 1461 | App-level shutdown callbacks |

---

## Key Architectural Invariants

**Two nested pipelines, not one.** The global pipeline (`$kernel->middleware`) runs unconditionally and cannot be short-circuited by routes. The route pipeline (`$route->gatherMiddleware()`) runs only after a route is matched. This is why `PreventRequestsDuringMaintenance` and `HandleCors` must be global — they run before routing even begins.

**The container is the skeleton.** Every crossing of a subsystem boundary — kernel construction, bootstrapper instantiation, middleware resolution, controller instantiation, method parameter injection — goes through `Container::resolve`. The container's singleton cache means providers, connections, and services are paid for once per process.

**Bootstrap is idempotent.** `Kernel::bootstrap` is guarded by `hasBeenBootstrapped`. In Octane (long-lived process) or test suites, the same process handles many requests; bootstrapping only runs once per process start, not per request.

**`$response` flows backward through both pipelines.** Every middleware layer that called `$next($request)` receives the return value of `$next` — which eventually resolves to the prepared `SymfonyResponse`. Middleware can transform it on the way out (e.g., `EncryptCookies` modifies response headers after the controller returns).
