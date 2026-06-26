# transcript: Give the complete end-to-end picture of Laravel's service container as a subsystem: how bindings are registered (bind / singleton), how make / resolve builds...


💬 I'll load the grove tools first, then map the Container subsystem systematically.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me map the Container directory and outline the main Container class in parallel.
  ▸ mcp__grove__map({"dir":"src/Illuminate/Container"})
  ▸ mcp__grove__outline({"file":"src/Illuminate/Container/Container.php","detail":1})

💬 Now I'll fetch the bodies of all the key methods in parallel to trace the exact paths.
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#bind@358"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#singleton@501"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolve@904"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#getConcrete@975"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#getContextualConcrete@1055"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#build@1109"})

💬 Now the remaining critical methods in parallel.
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolveDependencies@1215"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolveClass@1323"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolvePrimitive@1295"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolveFromAttribute@1381"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#findInContextualBindings@1081"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#getClosure@403"})

💬 A few more methods to complete the picture.
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#make@862"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#addContextualBinding@474"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#isShared@274"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#fireResolvingCallbacks@1539"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#getConcreteBindingFromAttributes@998"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#resolveVariadicClass@1361"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/Container.php#when@210"})
  ▸ mcp__grove__source({"id":"php:src/Illuminate/Container/ContextualBindingBuilder.php#give@62"})

💬 I now have everything needed. Here is the complete picture.  ---  # Laravel Service Container — End-to-End Reference  **Primary file:** `src/Illuminate/Conta...

──────── RESULT (success, 242359ms, 24 turns) ────────
I now have everything needed. Here is the complete picture.

---

# Laravel Service Container — End-to-End Reference

**Primary file:** `src/Illuminate/Container/Container.php` (~1850 lines)  
**Supporting files:**
- `src/Illuminate/Container/ContextualBindingBuilder.php`
- `src/Illuminate/Container/BoundMethod.php`
- `src/Illuminate/Container/Util.php`
- `src/Illuminate/Container/Attributes/` (PHP 8 attribute classes)

---

## 1. State: What the Container Holds

Every operation reads or writes these properties on `Container`:

| Field | Line | Purpose |
|---|---|---|
| `$bindings` | 48 | `[abstract => ['concrete' => Closure, 'shared' => bool]]` — all `bind()`/`singleton()` registrations |
| `$instances` | 62 | `[abstract => object]` — singleton cache (already-built shared instances) |
| `$scopedInstances` | 69 | `[abstract]` — list of scoped abstracts; cleared by `forgetScopedInstances()` |
| `$aliases` | 76 | `[alias => abstract]` — one-directional alias map |
| `$abstractAliases` | 83 | `[abstract => [alias, ...]]` — reverse; used in contextual alias scanning |
| `$contextual` | 118 | `[outerClass][abstract => impl]` — contextual overrides keyed by the **building** class |
| `$contextualAttributes` | 125 | `[attributeName => handler]` — PHP-attribute–based overrides |
| `$buildStack` | 104 | Currently-building class stack; top element is what `findInContextualBindings()` keys on |
| `$with` | 111 | Stack of `$parameters` arrays pushed per `resolve()` call; popped when done |
| `$extenders` | 90 | `[abstract => [Closure, ...]]` — post-build decorators |
| `$resolved` | 41 | `[abstract => true]` — tracks what has been resolved at least once |
| `$tags` | 97 | `[tag => [abstracts]]` — for `tagged()` |
| `$reboundCallbacks` | 146 | Callbacks fired when a binding is re-registered after first resolution |
| `$globalResolvingCallbacks` | 160 | Callbacks fired on every resolution |
| `$resolvingCallbacks` | 181 | `[abstract => [Closure, ...]]` — type-specific resolving hooks |
| `$afterResolvingCallbacks` | 188 | Same, fired after the object is fully constructed |
| `$afterResolvingAttributeCallbacks` | 195 | Fired per PHP attribute on resolved objects |

---

## 2. Registration Path: `bind()` / `singleton()`

```
singleton($abstract, $concrete)          Container.php:501
  └─ bind($abstract, $concrete, shared=true)
```

### `singleton()` — L501
A one-liner: calls `bind($abstract, $concrete, $shared=true)`.

### `bind($abstract, $concrete, $shared)` — L358

1. **Closure-abstract shortcut** — if `$abstract` is itself a Closure, delegates to `bindBasedOnClosureReturnTypes()` (L556), which introspects return types and calls `bind()` for each.
2. `dropStaleInstances($abstract)` (L1688) — removes any cached instance and extenders for this abstract so re-binding takes effect.
3. **Self-binding default** — if `$concrete === null`, sets `$concrete = $abstract`. This is what makes unregistered classes auto-resolvable.
4. **Wrap string in Closure** — if `$concrete` is a plain class name string (not a Closure), calls `getClosure($abstract, $concrete)` (L403) to produce a normalised factory Closure.
5. **Store** — `$this->bindings[$abstract] = ['concrete' => $closure, 'shared' => $shared]`.
6. **Rebound notification** — if `$this->resolved[$abstract]` is already `true`, calls `rebound($abstract)` (L741), which calls `make($abstract)` again and fires all `$reboundCallbacks`.

### `getClosure($abstract, $concrete)` — L403

Returns the normalised factory closure stored in `$bindings`. Its logic:
- If `$abstract === $concrete` (self-binding): the closure calls `$container->build($concrete)` directly — skipping the full resolve loop to avoid infinite recursion.
- Otherwise (binding `Interface` to `ConcreteClass`): the closure calls `$container->resolve($concrete, $parameters, raiseEvents: false)` — so the concrete class is itself fully resolved, with its own bindings, singletons, and dependency injection applied.

### `scoped($abstract, $concrete)` — L527
Calls `singleton()` and additionally registers `$abstract` in `$scopedInstances`. `forgetScopedInstances()` (L1719) clears these on scope end (e.g., between HTTP requests).

---

## 3. Resolution Path: `make()` → `resolve()` → `build()`

```
make($abstract, $parameters=[])          Container.php:862
  └─ resolve($abstract, $parameters, raiseEvents=true)
        ├─ getAlias($abstract)           :1653  (alias → canonical name)
        ├─ fireBeforeResolvingCallbacks  :1507
        ├─ getContextualConcrete         :1055  (contextual override?)
        ├─ [return $instances[$abstract] if cached singleton]
        ├─ getConcrete($abstract)        :975   (look up binding or auto-detect)
        ├─ isBuildable($concrete,$abs)   :1093
        │     ├─ YES → build($concrete)  :1109
        │     └─ NO  → make($concrete)  :862   (recurse: concrete is itself abstract)
        ├─ [apply extenders]
        ├─ [cache in $instances if isShared]
        ├─ fireResolvingCallbacks        :1539
        └─ [return object]
```

### `make($abstract, $parameters=[])` — L862
Public entry point. Simply calls `resolve($abstract, $parameters)`.

Also accessible as: `$container[$abstract]` via `offsetGet()` (L1808), `$container->get($abstract)` (PSR-11, L878), and `$container->$abstract` via `__get()` (L1840) — all converge on `make()`.

### `resolve($abstract, $parameters=[], $raiseEvents=true)` — L904

Step-by-step:

1. **`getAlias($abstract)`** (L1653) — walks `$this->aliases` recursively until no further alias is found. `alias('db', 'Illuminate\Database\DatabaseManager')` means `resolve('db')` becomes `resolve('Illuminate\Database\DatabaseManager')`.

2. **`fireBeforeResolvingCallbacks($abstract, $parameters)`** (L1507) — fires `$globalBeforeResolvingCallbacks` and then type-specific `$beforeResolvingCallbacks[$abstract]`, passing the abstract name and parameters. No object yet.

3. **`getContextualConcrete($abstract)`** (L1055) — checks if the class currently being built (top of `$buildStack`) has registered a contextual override for this abstract. Returns a concrete or `null`.

4. **Singleton short-circuit** — if `$instances[$abstract]` is already set **and** `$needsContextualBuild` is false (no parameter overrides, no contextual concrete), the cached object is returned immediately. This is the entire singleton performance guarantee.

5. **`getConcrete($abstract)`** (L975) — if no contextual override was found:
   - If `$bindings[$abstract]` exists → returns its `'concrete'` closure.
   - If no binding and class has `#[Bind]` attribute → `getConcreteBindingFromAttributes($abstract)` (L998) reads the attribute, calls `bind()`/`singleton()`/`scoped()` automatically, returns the resulting closure.
   - Otherwise → returns `$abstract` itself (the class name string), enabling auto-resolution.

6. **`isBuildable($concrete, $abstract)`** (L1093) — returns `true` if `$concrete === $abstract` (self-binding or bare class name) or `$concrete instanceof Closure` (explicit factory). Returns `false` if `$concrete` is a different string (abstract name), causing a recursive `make($concrete)`.

7. **`build($concrete)`** — see next section.

8. **Extenders** — `getExtenders($abstract)` (L1666) returns `$extenders[$abstract]`, each a Closure `fn($object, $container)`. These are applied in registration order to decorate or replace the built object.

9. **Singleton caching** — `isShared($abstract)` (L274):
   - True if `$instances[$abstract]` already exists.
   - True if `$bindings[$abstract]['shared'] === true` (registered via `singleton()`).
   - True if the class carries `#[Singleton]` or `#[Scoped]` PHP attribute (detected by `getScopedTyped()` L307, which uses `ReflectionClass::getAttributes()`).
   - If true and `!$needsContextualBuild` → stores in `$this->instances[$abstract]`.

10. **`fireResolvingCallbacks($abstract, $object)`** (L1539):
    - `fireCallbackArray($object, $globalResolvingCallbacks)` — every registered global callback.
    - `fireCallbackArray($object, getCallbacksForType(..., $resolvingCallbacks))` — type-matched callbacks (checks `instanceof` for object vs abstract string).
    - Then calls `fireAfterResolvingCallbacks($abstract, $object)` (L1557) — same two-step pattern for `$globalAfterResolvingCallbacks` and `$afterResolvingCallbacks`.

11. **Mark resolved** — `$this->resolved[$abstract] = true` (skipped when `$needsContextualBuild`).

12. **Pop `$this->with`** — removes the parameter override frame pushed at step 5's preamble.

---

## 4. Instantiation: `build()`

### `build($concrete)` — L1109

**Branch A — Closure concrete:**
```
build(Closure)
  push spl_object_hash onto $buildStack
  $concrete($this, getLastParameterOverride())   ← factory receives container + overrides
  pop $buildStack
```
The Closure was created by `getClosure()` (or by the user). It receives the container and any override parameters.

**Branch B — Class name string:**

1. `new ReflectionClass($concrete)` — throws `BindingResolutionException` if class doesn't exist.
2. `$reflector->isInstantiable()` — false for abstract classes and interfaces → `notInstantiable()` throws with a message listing the build stack for debugging.
3. **SelfBuilding check** — if the class implements `SelfBuilding` (a marker interface) and is not already in `$buildStack`: calls `buildSelfBuildingInstance($concrete, $reflector)` (L1188), which invokes `$concrete::build($this)` (the class provides its own construction logic). Attribute callbacks are still fired.
4. Push `$concrete` onto `$this->buildStack` (makes contextual binding lookup work for this class's dependencies).
5. `$constructor = $reflector->getConstructor()`:
   - If `null` (no constructor): pop stack, `fireAfterResolvingAttributeCallbacks(classAttributes, new $concrete)`, return.
6. `$dependencies = $constructor->getParameters()` — `ReflectionParameter[]`.
7. **`resolveDependencies($dependencies)`** — see next section. Wrapped in `finally { array_pop($this->buildStack) }`.
8. `fireAfterResolvingAttributeCallbacks($reflector->getAttributes(), $instance = new $concrete(...$instances))`.
9. Return `$instance`.

---

## 5. Dependency Resolution: `resolveDependencies()`

### `resolveDependencies(array $dependencies)` — L1215

For each `ReflectionParameter $dependency`:

```
resolveDependencies([ReflectionParameter, ...])
  for each $dependency:
    1. hasParameterOverride?  → getParameterOverride()         (explicit $with[] value)
    2. getContextualAttributeFromDependency($dependency)?       (PHP attribute on param)
         → resolveFromAttribute($attribute, $dependency)
    3. getParameterClassName($dependency) == null?
         → resolvePrimitive($dependency)
       else:
         → resolveClass($dependency, $className)
    4. fireAfterResolvingAttributeCallbacks($dependency->getAttributes(), $result)
    5. variadic? → array_merge; else → append
```

**Step 1 — Parameter overrides** (`hasParameterOverride` L1260, `getParameterOverride` L1273):  
`$this->with` is a stack of arrays; `getLastParameterOverride()` (L1283) returns the top frame. A match by parameter name or positional index bypasses all other resolution.

**Step 2 — `Util::getContextualAttributeFromDependency($dependency)`** (Util.php L83):  
Calls `$dependency->getAttributes()` and returns the first `ReflectionAttribute` whose name either exists as a key in `$this->contextualAttributes` or whose instantiated class has a `resolve()` method.

**Step 3a — `resolvePrimitive(ReflectionParameter)`** (L1295):  
For non-class-typed parameters (int, string, bool, untyped):
1. `getContextualConcrete('$'.$param->getName())` — looks for a named primitive binding like `->needs('$timeout')->give(30)`.
2. If found: `Util::unwrapIfClosure($concrete, $this)` — invokes it if it's a Closure, returns value otherwise.
3. Default value → return it.
4. Variadic → `[]`.
5. Nullable type → `null`.
6. Otherwise → `unresolvablePrimitive()` throws.

**Step 3b — `resolveClass(ReflectionParameter, ?string $className)`** (L1323):  
For class-typed parameters:
1. If parameter has a default value **and** the class is not explicitly bound **and** there is no contextual binding → return the default value (avoids overriding optional dependencies).
2. If variadic → `resolveVariadicClass($parameter)` (L1361): gets contextual concrete; if it's an array of abstracts, resolves each; otherwise just `make($className)`.
3. Otherwise → `make($className)` — fully recursive resolution of the dependency.
4. On `BindingResolutionException` for a variadic param → returns `[]`.

### `resolveFromAttribute(ReflectionAttribute, ReflectionParameter)` — L1381

1. Look up handler: `$this->contextualAttributes[$attribute->getName()] ?? null`.
2. Instantiate attribute: `$attribute->newInstance()`.
3. If no registered handler but the instance has a `resolve()` method → use `$instance->resolve(...)` as handler.
4. If still no handler → throw `BindingResolutionException`.
5. Call `$handler($instance, $this, $parameter)` → returns resolved value.

Built-in attribute classes in `src/Illuminate/Container/Attributes/` that implement this interface: `Auth`, `Authenticated`, `Cache`, `Config`, `Context`, `Database`, `Give`, `Log`, `RouteParameter`, `Storage`, `Tag`. Each has `public static function resolve(self $attribute, Container $container)`.

---

## 6. Contextual Binding

### Registration
```
$container->when(ConcreteA::class)       Container.php:210
           ->needs(InterfaceB::class)    ContextualBindingBuilder.php:49
           ->give(ConcreteB::class)      ContextualBindingBuilder.php:62
               └─ addContextualBinding(ConcreteA, InterfaceB, ConcreteB)
                                         Container.php:474
                    $this->contextual[ConcreteA][$alias(InterfaceB)] = ConcreteB
```

`when($concrete)` (L210) — resolves aliases for each concrete, returns a `ContextualBindingBuilder`.  
`needs($abstract)` (CBB:49) — records which abstract this override applies to.  
`give($implementation)` (CBB:62) — calls `addContextualBinding()` for each concrete class.  
`addContextualBinding($concrete, $abstract, $implementation)` (L474) — writes `$this->contextual[$concrete][$alias] = $implementation`.

### Lookup During Resolution

`getContextualConcrete($abstract)` (L1055):
1. `findInContextualBindings($abstract)` (L1081) — returns `$this->contextual[end($this->buildStack)][$abstract] ?? null`. The key `end($this->buildStack)` is the class currently being built, i.e., the **outer** class whose constructor is being dependency-injected.
2. If not found, iterates `$this->abstractAliases[$abstract]` and tries each alias with `findInContextualBindings()`.

When a contextual concrete is returned, `resolve()` sets `$needsContextualBuild = true`, which:
- Prevents the singleton cache from being read (`$instances` is bypassed).
- Prevents the result from being written back to `$instances` — so each outer-class build gets its own instance.

### Named Primitive Contextual Binding
```
->when(ConcreteA::class)->needs('$timeout')->give(30)
```
Stored as `$contextual[ConcreteA::class]['$timeout'] = 30`.  
Retrieved in `resolvePrimitive()` (L1295) via `getContextualConcrete('$'.$param->getName())`.

---

## 7. Method Injection: `call()`

```
Container::call($callback, $parameters, $defaultMethod)     Container.php:785
  └─ BoundMethod::call($container, $callback, $parameters, $defaultMethod)
                                                            BoundMethod.php:25
        ├─ isCallableWithAtSign?  → callClass()             :51
        │     └─ make() the class, then call() the method
        ├─ callBoundMethod()                                 :81
        │     ├─ normalizeMethod($callback)                  :105
        │     └─ hasMethodBinding? → callMethodBinding()
        └─ getMethodDependencies($container, $callback, $parameters)   :122
              ├─ getCallReflector($callback)                 :141
              │     → ReflectionFunction or ReflectionMethod
              └─ for each parameter:
                    addDependencyForCallParameter()          :165
                      (same attribute + class + primitive resolution as constructor)
        → call $callback(...$dependencies)
```

`addDependencyForCallParameter()` (BoundMethod.php:165) mirrors `resolveDependencies()`: checks attributes, class type, primitive fallback, then fires `fireAfterResolvingAttributeCallbacks`.

---

## 8. Unified Call Graph

```
┌─────────────────────────── REGISTRATION ───────────────────────────────┐
│                                                                         │
│  singleton(abs, con)  ──────────────────────────────────────────────── │
│  scoped(abs, con)     → bind(abs, con, shared)          :501 / :527    │
│  bind(abs, con, sh)                                      :358           │
│      │                                                                  │
│      ├─ dropStaleInstances(abs)                          :1688          │
│      ├─ getClosure(abs, con)                             :403           │
│      │     └─ [returns closure that calls build() or resolve()]         │
│      ├─ $bindings[abs] = {concrete: closure, shared: bool}             │
│      └─ resolved? → rebound(abs)                         :741           │
│            └─ make(abs) + fire $reboundCallbacks                        │
│                                                                         │
│  when(concrete)                                          :210           │
│    → ContextualBindingBuilder(container, concretes)                     │
│      .needs(abstract)                            CBB:49                 │
│      .give(impl) → addContextualBinding(con,abs,impl)    :474           │
│            └─ $contextual[con][alias(abs)] = impl                       │
│                                                                         │
│  whenHasAttribute(attr, handler)                         :226           │
│    → $contextualAttributes[attr] = handler                              │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────── RESOLUTION ─────────────────────────────────┐
│                                                                         │
│  $container['abs'] / $container->abs / get(abs)                        │
│    ──→ make(abs, params=[])                              :862           │
│           └─ resolve(abs, params, raiseEvents=true)      :904           │
│                 │                                                       │
│                 ├─ getAlias(abs)                          :1653          │
│                 │     └─ follow $aliases[] chain                        │
│                 │                                                       │
│                 ├─ fireBeforeResolvingCallbacks(abs, params) :1507      │
│                 │     └─ fireBeforeCallbackArray()        :1525          │
│                 │                                                       │
│                 ├─ getContextualConcrete(abs)             :1055          │
│                 │     ├─ findInContextualBindings(abs)    :1081          │
│                 │     │     └─ $contextual[end(buildStack)][abs]        │
│                 │     └─ [check abstractAliases + findInContextual]     │
│                 │                                                       │
│                 ├─ [return $instances[abs] if singleton & no context]   │
│                 │                                                       │
│                 ├─ getConcrete(abs)                       :975           │
│                 │     ├─ $bindings[abs]['concrete']  (registered)       │
│                 │     └─ getConcreteBindingFromAttributes(abs)  :998    │
│                 │           ├─ ReflectionClass(abs)                     │
│                 │           ├─ read #[Bind] attributes                  │
│                 │           ├─ getScopedTyped() → #[Singleton]/#[Scoped]:307│
│                 │           └─ call bind()/singleton()/scoped()         │
│                 │                                                       │
│                 ├─ isBuildable(concrete, abs)             :1093          │
│                 │     ├─ YES (closure or abs==con) → build(con)  :1109  │
│                 │     └─ NO  (con is another abstract)  → make(con) ◀─┐ │
│                 │                                                      │ │
│                 ├─ [apply $extenders[abs] in order]                    │ │
│                 │                                                       │ │
│                 ├─ isShared(abs)?                         :274          │ │
│                 │     └─ $instances[abs] = object  (cache singleton)   │ │
│                 │                                                       │ │
│                 ├─ fireResolvingCallbacks(abs, obj)       :1539          │ │
│                 │     ├─ fireCallbackArray(globalResolving)  :1620      │ │
│                 │     ├─ fireCallbackArray(type-specific resolving)     │ │
│                 │     └─ fireAfterResolvingCallbacks()    :1557          │ │
│                 │           ├─ fireCallbackArray(globalAfterResolving)  │ │
│                 │           └─ fireCallbackArray(type-specific after)   │ │
│                 │                                                       │ │
│                 └─ $resolved[abs] = true; pop $with                    │ │
│                                                                         │ │
│  build(concrete)                                         :1109          │ │
│    ├─ Closure?  → $concrete($container, lastParamOverride)             │ │
│    │                                                                    │ │
│    └─ string class name:                                                │ │
│         ├─ new ReflectionClass(concrete)                                │ │
│         ├─ isInstantiable? no → notInstantiable() throws               │ │
│         ├─ SelfBuilding? → buildSelfBuildingInstance()    :1188         │ │
│         │     └─ concrete::build($container)                            │ │
│         ├─ push concrete onto $buildStack  ◀── contextual key          │ │
│         ├─ $constructor = getConstructor()                              │ │
│         ├─ no constructor? → new $concrete; fireAttrCallbacks; return  │ │
│         ├─ resolveDependencies($constructor->getParameters()) :1215     │ │
│         │     └─ [see below]                                            │ │
│         ├─ pop $buildStack                                              │ │
│         ├─ fireAfterResolvingAttributeCallbacks(classAttrs, instance)  │ │
│         └─ return new $concrete(...$instances)                          │ │
│                                                                         │ │
│  resolveDependencies([ReflectionParameter, ...])          :1215         │ │
│    for each $param:                                                     │ │
│      ├─ hasParameterOverride?                             :1260          │ │
│      │     └─ getParameterOverride()                     :1273          │ │
│      │           └─ getLastParameterOverride()           :1283          │ │
│      │                                                                  │ │
│      ├─ Util::getContextualAttributeFromDependency()    Util.php:83    │ │
│      │     → resolveFromAttribute(attr, param)           :1381          │ │
│      │           ├─ $contextualAttributes[attr] ?? null                 │ │
│      │           ├─ attr->newInstance()                                 │ │
│      │           ├─ no handler? → instance->resolve(...)               │ │
│      │           └─ handler($instance, $container, $param)             │ │
│      │                                                                  │ │
│      ├─ Util::getParameterClassName(param) == null?     Util.php:54   │ │
│      │     → resolvePrimitive(param)                     :1295          │ │
│      │           ├─ getContextualConcrete('$'+name)   ← named binding  │ │
│      │           ├─ default value                                       │ │
│      │           ├─ variadic → []                                       │ │
│      │           ├─ nullable → null                                     │ │
│      │           └─ unresolvablePrimitive() throws       :1426          │ │
│      │                                                                  │ │
│      └─ class-typed → resolveClass(param, className)    :1323          │ │
│              ├─ has default & not bound & no contextual → default      │ │
│              ├─ variadic → resolveVariadicClass(param)   :1361          │ │
│              │     ├─ getContextualConcrete → array? resolve each      │ │
│              │     └─ make(className) ──────────────────────────────────┘ │
│              └─ make(className) ────────────────────────────────────────┘ │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────── METHOD INJECTION ───────────────────────────────┐
│                                                                         │
│  Container::call(callback, params, defaultMethod)        :785           │
│    └─ BoundMethod::call(container, callback, params, defaultMethod)    │
│                                                   BoundMethod.php:25   │
│         ├─ isCallableWithAtSign?                          :216          │
│         │     → callClass(container, target, params, defaultMethod)    │
│         │           └─ make(class) + call(method)         :51           │
│         ├─ callBoundMethod(container, callback, default)  :81           │
│         │     ├─ normalizeMethod(callback)                :105          │
│         │     └─ hasMethodBinding? → callMethodBinding()  :461          │
│         └─ getMethodDependencies(container, callback, params)  :122    │
│               ├─ getCallReflector(callback)               :141          │
│               └─ addDependencyForCallParameter() per param :165         │
│                     (same attr → class → primitive logic as build())   │
│         → $callback(...$dependencies)                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 9. Key Invariants

**buildStack is the contextual binding key.** `findInContextualBindings()` (L1081) reads `end($this->buildStack)` — the class currently having its constructor resolved. This is why contextual binding is automatic: the stack is pushed in `build()` before `resolveDependencies()` runs, so the right "outer" class is always visible at lookup time.

**Singleton cache is keyed on the canonical abstract (post-alias).** `getAlias()` is called at the very top of `resolve()` before any cache read, so `resolve('db')` and `resolve('Illuminate\Database\DatabaseManager')` hit the same `$instances` slot.

**Contextual builds bypass the singleton cache in both directions.** When `getContextualConcrete()` returns non-null, `$needsContextualBuild = true`, which skips both the `$instances` read (line 920) and the `$instances` write (line 951). This ensures that `->when(A)->needs(B)->give(C)` always produces a fresh `C` for `A` even if `C` is otherwise registered as a singleton.

**`getClosure()` self-binding vs. alias-binding.** When `$abstract === $concrete`, the generated closure calls `build()` directly to avoid re-entering `resolve()` and triggering the alias-lookup / singleton-cache machinery a second time. When they differ (binding an interface to a class), it calls `resolve()` with `raiseEvents: false` so events fire only at the outermost resolution, not once per layer.

**Attribute-based auto-registration is one-shot.** `getConcreteBindingFromAttributes()` (L998) sets `$checkedForAttributeBindings[$abstract] = true` on the first call, so the `ReflectionClass` construction and attribute scan happen once; subsequent resolutions find the binding already in `$bindings`.
