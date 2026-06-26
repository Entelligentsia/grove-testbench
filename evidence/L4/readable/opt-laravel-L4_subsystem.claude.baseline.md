# transcript: Read the Laravel service container source files thoroughly. I need to document the complete call graph for: 1. bind() / singleton() registration path 2. make...


💬 I'll explore the Container source in depth to trace every path accurately.
  ▸ Agent(Deep exploration of Laravel service container source)
  ▸ Bash(find /home/bench/repos/laravel/src/Illuminate/Container -type f -name "*.php" | sort)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/ContextualBindingBuilder.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/BoundMethod.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/EntryNotFoundException.php)
  ▸ Bash(ls -la /home/bench/repos/laravel/src/Illuminate/Container/ 2>&1 | grep -v "permission denied" || true)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Util.php)

💬 Let me verify the key line numbers directly before writing up the final answer.
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/ContextualBindingBuilder.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Container.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/BoundMethod.php)
  ▸ Read(/home/bench/repos/laravel/src/Illuminate/Container/Util.php)

💬 Here is the complete end-to-end picture.  ---  ## Laravel Service Container — Complete Subsystem Reference  All code lives under `src/Illuminate/Container/`....

──────── RESULT (success, 274128ms, 12 turns) ────────
Here is the complete end-to-end picture.

---

## Laravel Service Container — Complete Subsystem Reference

All code lives under `src/Illuminate/Container/`.

### Key files

| File | Role |
|---|---|
| `Container.php` | The entire container: bindings, resolution, DI, callbacks |
| `ContextualBindingBuilder.php` | Fluent `when()->needs()->give()` DSL |
| `BoundMethod.php` | `call()` — DI for arbitrary callables |
| `Util.php` | Three static reflection helpers |

---

## 1. Binding Registration

### `bind()` — `Container.php:358`

```
bind(abstract, concrete = null, shared = false)
```

1. **L360** — if `$abstract` is a Closure, branches immediately to `bindBasedOnClosureReturnTypes()` (L556), which uses `ReflectsClosures::closureReturnTypes()` to discover the abstract name(s) and calls `bind()` recursively for each.

2. **L366** — `dropStaleInstances($abstract)` (L1688): clears any old entry from `$this->instances` and `$this->aliases` so stale singletons don't linger.

3. **L371** — if `$concrete` is null, the abstract is self-binding (`$concrete = $abstract`).

4. **L378** — if `$concrete` is a plain string (a class name), it is wrapped:

   ```
   getClosure($abstract, $concrete)  →  Container.php:403
   ```

   The resulting Closure:
   - calls `build($concrete)` when `$abstract === $concrete` (auto-wire the concrete directly)
   - calls `resolve($concrete, $parameters, raiseEvents: false)` otherwise (follow the full chain but suppress double-fire of events)

5. **L386** — stores `['concrete' => $closure, 'shared' => $shared]` in `$this->bindings[$abstract]`.

6. **L391** — if the abstract was already resolved, calls `rebound($abstract)`, which fires `reboundCallbacks` and calls `make()` again to push the update to anything holding a reference.

### `singleton()` — `Container.php:501`

```
singleton(abstract, concrete = null)
  └─ bind(abstract, concrete, shared: true)   ← L503
```

That is the entire method. The only difference from `bind()` is the `shared = true` flag, which is stored in `$this->bindings[$abstract]['shared']` and checked at cache-write time during resolution.

### Other registration helpers (all delegate to `bind`)

| Method | Line | Notes |
|---|---|---|
| `singletonIf` | ~513 | calls `singleton` only if not already `bound()` |
| `scoped` | ~521 | calls `bind` with `shared=true`; also records in `$scopedInstances` |
| `instance` | ~576 | stores directly in `$this->instances[$abstract]` — bypasses `build()` entirely |
| `alias` | ~610 | stores in `$this->aliases[$alias] = $abstract` and `$this->abstractAliases[$abstract][]` |

---

## 2. Resolution — `make()` → `resolve()` → `build()`

### `make()` — `Container.php:862`

```
make(abstract, parameters = [])
  └─ resolve(abstract, parameters)   ← L864
```

`get()` (L878, PSR-11) also delegates to `resolve()` but wraps the call in a try/catch that converts `BindingResolutionException` → `EntryNotFoundException` when the binding doesn't exist.

---

### `resolve()` — `Container.php:904` — the core engine

```
resolve(abstract, parameters = [], raiseEvents = true)
```

Every call through `make()` or `get()` enters here. Steps in order:

| Step | Line | What happens |
|---|---|---|
| **Alias normalisation** | 906 | `getAlias($abstract)` — recursive chain walk through `$this->aliases` |
| **Before-resolving hooks** | 911–913 | `fireBeforeResolvingCallbacks($abstract, $parameters)` if `$raiseEvents` |
| **Contextual check** | 915 | `getContextualConcrete($abstract)` — may return a concrete for the current build-stack context |
| **Singleton cache hit** | 922 | If `$this->instances[$abstract]` exists and no contextual override, return it immediately |
| **Push parameter override** | 926 | `$this->with[] = $parameters` — makes caller-supplied `$parameters` visible to `resolveDependencies` |
| **Concrete lookup** | 928–930 | if no contextual concrete, call `getConcrete($abstract)` |
| **Dispatch to builder** | 935–937 | `isBuildable($concrete, $abstract)` — true when concrete === abstract OR concrete is a Closure; if true call `build($concrete)`, else call `make($concrete)` (re-enter `resolve` with the concrete as the new abstract) |
| **Extenders** | 942–944 | loop `getExtenders($abstract)` — each extender is a Closure that receives `($object, $container)` and returns a decorated/modified object |
| **Singleton store** | 949–951 | if `isShared($abstract)` and no contextual override, cache in `$this->instances[$abstract]` |
| **Resolving hooks** | 953–955 | `fireResolvingCallbacks($abstract, $object)` → `fireAfterResolvingCallbacks` |
| **Mark resolved** | 960–962 | `$this->resolved[$abstract] = true` |
| **Pop parameter override** | 964 | `array_pop($this->with)` |

---

### `getConcrete()` — `Container.php:975`

```
getConcrete(abstract)
```

- **L980** — if `$this->bindings[$abstract]` exists, return the stored Closure.
- **L984–989** — if no binding and `$environmentResolver` is set, call `getConcreteBindingFromAttributes($abstract)` (L998) which inspects PHP 8 `#[Bind]` attributes on the class. If a `#[Bind]` attribute matches the current environment it calls `singleton()`, `scoped()`, or `bind()` (depending on whether the class also carries `#[Singleton]` or `#[Scoped]`), then returns the newly stored concrete closure.
- **Fallback** — returns `$abstract` as-is, meaning the abstract is its own concrete (unbound concrete class).

### `isBuildable()` — `Container.php:1093`

```
isBuildable(concrete, abstract) → bool
  ← true when concrete === abstract OR concrete instanceof Closure
```

A string concrete that differs from the abstract means "resolve this other binding first" — so `make($concrete)` is called instead.

---

### `build()` — `Container.php:1109` — reflection and instantiation

```
build(concrete)
```

**Closure path (L1114–1122)**:  
If `$concrete` is a Closure, push `spl_object_hash($concrete)` onto `$this->buildStack`, execute the closure as `$concrete($this, $this->getLastParameterOverride())`, pop the stack, return the result. The `getLastParameterOverride()` (L1283) gives the top of `$this->with[]` to the factory so callers can pass runtime parameters through.

**Class path (L1124–1174)**:

| Step | Line | What happens |
|---|---|---|
| `new ReflectionClass($concrete)` | 1125 | fails → `BindingResolutionException` |
| `$reflector->isInstantiable()` | 1133 | false (abstract class, interface) → `notInstantiable()` (L1406) throws |
| `SelfBuilding` check | 1137–1140 | if the class implements `SelfBuilding` and isn't already being built, delegates to `buildSelfBuildingInstance()` (L1188) which calls `$this->call([$concrete, 'newInstance'])` |
| Push build stack | 1142 | `$this->buildStack[] = $concrete` — used by `findInContextualBindings` |
| `$reflector->getConstructor()` | 1144 | null → no-arg class; instantiate directly, fire `fireAfterResolvingAttributeCallbacks`, return |
| `$constructor->getParameters()` | 1159 | array of `ReflectionParameter` objects |
| `resolveDependencies($deps)` | 1165 | fills `$instances` array; build stack is popped in a `finally` block |
| Instantiate | 1171 | `new $concrete(...$instances)` + `fireAfterResolvingAttributeCallbacks` |

---

### `resolveDependencies()` — `Container.php:1215`

Loops over `ReflectionParameter[]`. For each:

```
resolveDependencies(dependencies[])
  foreach dependency:
    ├─ hasParameterOverride(dep)          L1223   → getParameterOverride(dep)   L1273
    │     (checks top of $this->with[] by parameter name)
    ├─ getContextualAttributeFromDependency(dep)   Util.php:83
    │     (returns first ReflectionAttribute implementing ContextualAttribute)
    │   └─ resolveFromAttribute(attr, dep)  L1381
    │         reads $contextualAttributes[attr] handler or calls attr->resolve()
    ├─ Util::getParameterClassName(dep)    Util.php:54
    │     (extracts class name from type; null for builtins/no-type)
    ├─ null className → resolvePrimitive(dep)  L1295
    └─ class className → resolveClass(dep, className)  L1323
    then:
    └─ fireAfterResolvingAttributeCallbacks(dep->getAttributes(), result)  L1242
```

#### `resolvePrimitive()` — `Container.php:1295`

For parameters with no class type (scalars, untyped):

1. **L1297** — `getContextualConcrete('$' . $parameter->getName())` — primitive contextual binding lookup (prefix `$` + param name as the key)
2. **L1301** — `$parameter->getDefaultValue()` if available
3. **L1305** — empty array if variadic
4. **L1309** — `null` if nullable
5. **L1313** — `unresolvablePrimitive()` (L1426) throws `BindingResolutionException`

#### `resolveClass()` — `Container.php:1323`

For parameters that have a class/interface type hint:

1. **L1330–1332** — if the parameter has a default value AND the class is not bound AND no contextual binding exists, return the default (avoids overriding optional injections).
2. **L1337** — variadic → `resolveVariadicClass($parameter)` (L1361)
3. **L1339** — otherwise `make($className)` — **full recursive re-entry into** `resolve()`.
4. On `BindingResolutionException` for a variadic, returns `[]`.

#### `resolveVariadicClass()` — `Container.php:1361`

1. `Util::getParameterClassName($parameter)` → class name
2. `getAlias($className)` → canonical name
3. `getContextualConcrete($abstract)` — if the result is an array (a list of concretes registered via `give([A::class, B::class])`), maps each through `resolve($abstract)` and returns the array.
4. Otherwise falls back to `make($className)`.

---

## 3. Contextual Binding

### Registration: `when()` → `needs()` → `give()`

```
Container::when(concrete)                      Container.php:210
  └─ new ContextualBindingBuilder($this, $aliases)
        ContextualBindingBuilder.php:37

ContextualBindingBuilder::needs(abstract)      :49
  └─ $this->needs = $abstract; return $this

ContextualBindingBuilder::give(implementation) :62
  └─ foreach Util::arrayWrap($this->concrete) as $c:
       Container::addContextualBinding($c, $needs, $impl)   Container.php:474
         └─ $this->contextual[$concrete][$this->getAlias($abstract)] = $implementation
```

The map is keyed `contextual[concrete][abstract]`. The concrete key is the class that *has* the dependency; the abstract key is the interface/type it *needs*.

### Lookup during resolution: `getContextualConcrete()` — `Container.php:1055`

Called at `resolve():915` and again inside `resolvePrimitive():1297` and `resolveVariadicClass():1367`.

```
getContextualConcrete(abstract)
  └─ findInContextualBindings(abstract)     L1081
       └─ $this->contextual[end($this->buildStack)][$abstract] ?? null
  if null, check $this->abstractAliases[$abstract] for alias forms
  └─ findInContextualBindings(alias)        (same lookup, alias key)
```

`end($this->buildStack)` is the class currently being built — the "concrete" side of the contextual map. If a match is found the result can be:

- a **string** → treated as a concrete class name, re-enters `resolve()`
- a **Closure** → unwrapped via `Util::unwrapIfClosure()`
- an **array** → used by `resolveVariadicClass()` to produce multiple instances

### Primitive contextual binding

`when(Foo::class)->needs('$apiKey')->give('abc')` stores the value at:
```
$this->contextual['Foo']['$apiKey'] = 'abc'
```
`resolvePrimitive()` looks up `'$' . $parameter->getName()` in the same table.

---

## 4. `isShared()` and singleton caching — `Container.php:274`

Three checks, in order:

1. `$this->instances[$abstract]` already set → true (previously cached)
2. `$this->bindings[$abstract]['shared'] === true` → true (registered with `singleton()`)
3. `getScopedTyped($abstract)` (L307) — inspects PHP 8 class attributes `#[Singleton]` or `#[Scoped]` via `ReflectionClass::getAttributes()`, caches in `$this->checkedForSingletonOrScopedAttributes[$className]`

---

## 5. Alias resolution — `getAlias()` — `Container.php:1653`

```php
// L1653
public function getAlias($abstract)
{
    return isset($this->aliases[$abstract])
        ? $this->getAlias($this->aliases[$abstract])  // recursive
        : $abstract;
}
```

Pure recursion following the alias chain. `alias('db', 'Illuminate\Database\DatabaseManager')` followed by `alias('DB', 'db')` resolves `'DB'` → `'db'` → `'Illuminate\Database\DatabaseManager'` in two recursive steps.

---

## 6. Callback hooks

Three hook points fire during `resolve()`:

| Hook | Fires at | Fire method | Line |
|---|---|---|---|
| `beforeResolving` | Start of resolution | `fireBeforeResolvingCallbacks` | 1507 |
| `resolving` | After object built, before return | `fireResolvingCallbacks` | 1539 |
| `afterResolving` | Called by `fireResolvingCallbacks` | `fireAfterResolvingCallbacks` | 1557 |

Each has a global array (`globalBeforeResolvingCallbacks`, etc.) and a per-type array. `fireCallbackArray()` (L1620) calls every callback as `$callback($object, $container)`.

`fireAfterResolvingAttributeCallbacks()` (L1573) is a separate mechanism: after constructing an instance it iterates PHP 8 class/parameter attributes that implement `ContextualAttribute`, calling their `after()` method if it exists, then dispatching any `afterResolvingAttribute` callbacks registered via `afterResolvingAttribute(string $attribute, Closure $callback)`.

---

## Unified Call Graph

```
═══════════════════════════════════════════════════════════════
REGISTRATION PATH
═══════════════════════════════════════════════════════════════

singleton($abstract, $concrete)                    Container.php:501
  └─ bind($abstract, $concrete, shared=true)       Container.php:358
       ├─ [if abstract is Closure]
       │    bindBasedOnClosureReturnTypes()         Container.php:556
       │      └─ bind()  (recursive, per return type)
       ├─ dropStaleInstances($abstract)             Container.php:1688
       │    └─ unset instances[$abstract], aliases[$abstract]
       ├─ [if concrete is string]
       │    getClosure($abstract, $concrete)        Container.php:403
       │      returns Closure { build() | resolve() }
       ├─ $this->bindings[$abstract] = [concrete, shared]
       └─ [if already resolved]
            rebound($abstract)
              └─ make($abstract)  ──────────────────────────────┐
                                                                 │
═══════════════════════════════════════════════════════════════  │
RESOLUTION PATH                                                  │
═══════════════════════════════════════════════════════════════  │
                                                                 │
make($abstract, $parameters)                       :862 ◄────────┘
  └─ resolve($abstract, $parameters, raiseEvents=true)  :904
       │
       ├─ getAlias($abstract)              :1653  [recursive alias walk]
       │
       ├─ fireBeforeResolvingCallbacks()   :1507
       │    ├─ fireBeforeCallbackArray(globalBeforeResolvingCallbacks)   :1525
       │    └─ fireBeforeCallbackArray(beforeResolvingCallbacks[type])
       │
       ├─ getContextualConcrete($abstract) :1055
       │    ├─ findInContextualBindings($abstract)      :1081
       │    │    └─ contextual[end(buildStack)][$abstract] ?? null
       │    └─ [foreach abstractAliases[$abstract]]
       │         findInContextualBindings($alias)
       │
       ├─ [cache hit] return $this->instances[$abstract]
       │
       ├─ $this->with[] = $parameters     [push parameter override stack]
       │
       ├─ getConcrete($abstract)           :975
       │    ├─ bindings[$abstract]['concrete']          [explicit binding]
       │    └─ getConcreteBindingFromAttributes()       :998
       │         ├─ new ReflectionClass($abstract)
       │         ├─ $reflected->getAttributes(Bind::class)
       │         ├─ currentEnvironmentIs()
       │         ├─ getScopedTyped()       :307
       │         │    └─ ReflectionClass->getAttributes(Singleton|Scoped)
       │         └─ scoped()|singleton()|bind()  →→ re-enters bind() above
       │
       ├─ isBuildable($concrete, $abstract) :1093
       │    └─ true if concrete===abstract OR concrete instanceof Closure
       │
       ├─ [buildable]  build($concrete)    :1109 ─────────────────────────┐
       │  [not buildable] make($concrete)  :862  [re-enters resolve()]    │
       │                                                                   │
       ├─ foreach getExtenders($abstract) as $extender:                    │
       │    $object = $extender($object, $this)                            │
       │                                                                   │
       ├─ [isShared && !contextual] $this->instances[$abstract] = $object  │
       │    isShared()  :274                                               │
       │      ├─ isset(instances[$abstract])                               │
       │      ├─ bindings[$abstract]['shared'] === true                    │
       │      └─ getScopedTyped($abstract)  :307                           │
       │                                                                   │
       ├─ fireResolvingCallbacks($abstract, $object)   :1539               │
       │    ├─ fireCallbackArray(globalResolvingCallbacks)    :1620         │
       │    ├─ fireCallbackArray(getCallbacksForType(...))    :1601         │
       │    └─ fireAfterResolvingCallbacks()           :1557               │
       │         ├─ fireCallbackArray(globalAfterResolvingCallbacks)       │
       │         └─ fireCallbackArray(getCallbacksForType(...))            │
       │                                                                   │
       ├─ $this->resolved[$abstract] = true                                │
       ├─ array_pop($this->with)                                           │
       └─ return $object                                                   │
                                                                           │
═══════════════════════════════════════════════════════════════            │
BUILD PATH                                                                 │
═══════════════════════════════════════════════════════════════            │
                                                                           ▼
build($concrete)                                   :1109
  │
  ├─ [Closure] buildStack[] = hash; $concrete($this, getLastParameterOverride()); pop
  │
  └─ [class string]
       ├─ new ReflectionClass($concrete)           PHP
       ├─ $reflector->isInstantiable() → false → notInstantiable()  :1406  throws
       ├─ [implements SelfBuilding]
       │    buildSelfBuildingInstance()  :1188
       │      └─ call([$concrete,'newInstance'])  → BoundMethod::call()
       ├─ buildStack[] = $concrete
       ├─ $constructor = $reflector->getConstructor()
       │    [null] → new $concrete(); fireAfterResolvingAttributeCallbacks(); return
       ├─ $dependencies = $constructor->getParameters()
       ├─ resolveDependencies($dependencies)        :1215 ───────────────────┐
       │    (buildStack popped in finally)                                    │
       ├─ $instance = new $concrete(...$instances)                            │
       ├─ fireAfterResolvingAttributeCallbacks()    :1573                     │
       │    └─ foreach class attributes:                                      │
       │         [ContextualAttribute] attr->after(attr, obj, container)      │
       │         afterResolvingAttributeCallbacks[attr] callbacks              │
       └─ return $instance                                                     │
                                                                              │
═══════════════════════════════════════════════════════════════              │
DEPENDENCY RESOLUTION PATH                                                   │
═══════════════════════════════════════════════════════════════              │
                                                                             ▼
resolveDependencies(ReflectionParameter[])         :1215
  foreach $dependency:
    │
    ├─ hasParameterOverride($dependency)           :1260
    │    └─ array_key_exists(name, getLastParameterOverride())  :1283
    │         → getParameterOverride($dependency)  :1273
    │
    ├─ Util::getContextualAttributeFromDependency($dep)  Util.php:83
    │    └─ $dep->getAttributes(ContextualAttribute, IS_INSTANCEOF)[0]
    │   └─ resolveFromAttribute($attr, $dep)       :1381
    │         ├─ $handler = contextualAttributes[$attr->getName()]
    │         ├─ $instance = $attr->newInstance()
    │         ├─ [no handler] $handler = $instance->resolve(...)
    │         └─ $handler($instance, $this, $parameter)
    │
    ├─ Util::getParameterClassName($dep)           Util.php:54
    │    └─ $dep->getType() → ReflectionNamedType; resolve 'self'/'parent'
    │
    ├─ [className is null]  resolvePrimitive($dep) :1295
    │    ├─ getContextualConcrete('$'.$name)  :1055  [primitive contextual]
    │    │    └─ Util::unwrapIfClosure($concrete, $this)    Util.php:41
    │    ├─ $dep->getDefaultValue()
    │    ├─ []  (variadic)
    │    ├─ null (nullable)
    │    └─ unresolvablePrimitive()             :1426  throws
    │
    └─ [className set]  resolveClass($dep, $className)  :1323
         ├─ [has default AND not bound AND no contextual] return default
         ├─ [variadic] resolveVariadicClass($dep)        :1361
         │    ├─ Util::getParameterClassName($dep)
         │    ├─ getAlias($className)
         │    ├─ getContextualConcrete($abstract)
         │    │    [array result] → array_map(resolve(), $concrete)  ◄──┐
         │    └─ make($className)  ───────────────────────────────────── │──►  re-enters resolve()
         └─ make($className)  ─────────────────────────────────────────────►  re-enters resolve()

  then per dependency:
  └─ fireAfterResolvingAttributeCallbacks($dep->getAttributes(), $result)  :1242

═══════════════════════════════════════════════════════════════
CONTEXTUAL BINDING REGISTRATION
═══════════════════════════════════════════════════════════════

Container::when($concrete)                         :210
  ├─ foreach Util::arrayWrap($concrete) as $c:
  │    getAlias($c)
  └─ return new ContextualBindingBuilder($this, $aliases)   CBB.php:37

ContextualBindingBuilder::needs($abstract)         CBB.php:49
  └─ $this->needs = $abstract; return $this

ContextualBindingBuilder::give($implementation)    CBB.php:62
  └─ foreach Util::arrayWrap($this->concrete) as $c:
       Container::addContextualBinding($c, $needs, $impl)   :474
         └─ contextual[$concrete][getAlias($abstract)] = $implementation

══════════════ runtime lookup: getContextualConcrete() :1055 ══════════════
   → findInContextualBindings(abstract)   :1081
        contextual[ end(buildStack) ][ abstract ] ?? null
   ← returns Closure|string|string[]|null
```

---

### Key invariants

- **`$this->buildStack[]`** is the "who is being built right now" stack. `end($buildStack)` is what `findInContextualBindings` uses as the concrete side of the contextual map. It is pushed in `build()` at L1115 (Closure hash) and L1142 (class name), always popped in a `finally`.
- **`$this->with[]`** is the parameter-override stack. Each call to `resolve()` pushes the caller's `$parameters` at L926 and pops at L964, creating a per-level scope so nested `make()` calls don't see outer overrides.
- **`$this->instances[]`** is the singleton cache. Written by `resolve()` at L950 only when `isShared()` is true and there is no contextual override active; read as an early exit at L922.
- **Recursive termination**: `resolve()` calling `make()` calling `resolve()` terminates because either (a) the concrete resolves through `build()` to a leaf class with no further dependencies, or (b) a binding has already been cached in `$this->instances`. Circular dependencies (A → B → A) are caught because `buildStack` contains `A` when `A` is encountered again; the container throws `CircularDependencyException` (enforced in the `Foundation` Application subclass which overrides `build()`).
