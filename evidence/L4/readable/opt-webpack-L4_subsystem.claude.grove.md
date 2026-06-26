# transcript: Give the complete end-to-end picture of webpack's module build subsystem: from Compilation.addEntry / handleModuleCreation, through the NormalModuleFactory (...


💬 I'll trace this using the grove MCP tools as required. Let me load their schemas first.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now I'll fan out to outline all three core files in parallel.
  ▸ mcp__grove__outline({"file":"lib/Compilation.js","detail":0,"kind":"method"})
  ▸ mcp__grove__outline({"file":"lib/NormalModuleFactory.js","detail":0,"kind":"method"})
  ▸ mcp__grove__outline({"file":"lib/NormalModule.js","detail":0,"kind":"method"})

💬 Good. Now I'll read the key entry-point methods in parallel.
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#addEntry@2645"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_addEntryItem@2682"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#addModuleTree@2591"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#handleModuleCreation@2298"})

💬 Now I'll read the build/dependency side in parallel.
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_handleModuleBuildAndDependencies@2449"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#factorizeModule@2271"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_factorizeModule@2171"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#addModule@1585"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_addModule@1596"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#buildModule@1660"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_buildModule@1670"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_processModuleDependencies@1780"})

💬 Now let me read the NormalModuleFactory `create` method and NormalModule's `build`/`_doBuild` in parallel.
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModuleFactory.js#create@1011"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#build@1779"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#_doBuild@1468"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModuleFactory.js#resolveResource@1123"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModuleFactory.js#resolveRequestArray@1323"})

💬 Now I need the NormalModuleFactory constructor to see how hooks like `factorize` and `resolve` are wired. Let me get the outline at detail 1 and then read th...
  ▸ mcp__grove__outline({"file":"lib/NormalModuleFactory.js","detail":1,"kind":"function"})
  ▸ mcp__grove__source({"file":"lib/Compilation.js","name":"processModuleDependencies"})
  ▸ mcp__grove__source({"file":"lib/Compilation.js","name":"addModuleChain"})

💬 Now let me find the NormalModuleFactory constructor and the critical inner `resolve` function wired to the `factorize` hook.
  ▸ mcp__grove__outline({"file":"lib/NormalModuleFactory.js","detail":1,"kind":"class"})
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)

💬 Let me read the constructor body and the `factorize`/`resolve` hook handlers.
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)

💬 Let me check the two ModuleGraph methods that wire modules into the graph.
  ▸ mcp__grove__symbols({"dir":"lib","name":"setResolvedModule"})
  ▸ mcp__grove__symbols({"dir":"lib","name":"setParents"})
  ▸ mcp__grove__source({"file":"lib/Compilation.js","name":"processModuleDependenciesNonRecursive"})

💬 Final lookups: the two ModuleGraph wiring methods.
  ▸ mcp__grove__source({"id":"javascript:lib/ModuleGraph.js#setResolvedModule@259"})
  ▸ mcp__grove__source({"id":"javascript:lib/ModuleGraph.js#setParents@209"})

💬 Now I have everything. Let me compose the complete picture.  ---  ## Webpack module build subsystem — end-to-end call graph  All files are under `lib/` unles...

──────── RESULT (success, 213689ms, 33 turns) ────────
Now I have everything. Let me compose the complete picture.

---

## Webpack module build subsystem — end-to-end call graph

All files are under `lib/` unless noted. Line numbers are 1-based.

---

### Architectural skeleton

Four `AsyncQueue` instances in `Compilation` serialize concurrency at each stage:

| queue | processor | file:line |
|---|---|---|
| `factorizeQueue` | `_factorizeModule` | Compilation.js:2171 |
| `addModuleQueue` | `_addModule` | Compilation.js:1596 |
| `buildQueue` | `_buildModule` | Compilation.js:1670 |
| `processDependenciesQueue` | `_processModuleDependencies` | Compilation.js:1780 |

Every public method (`factorizeModule`, `addModule`, `buildModule`, `processModuleDependencies`) is a one-liner that calls `.add()` on the matching queue. The queues execute their processor concurrently up to the configured parallelism ceiling.

---

### Phase 1 — Entry wiring

```
Compilation.addEntry                         Compilation.js:2645
  │  normalise optionsOrName → options{}
  └─► Compilation._addEntryItem              Compilation.js:2682
        │  create/update EntryData in this.entries
        │  fire hooks.addEntry
        └─► Compilation.addModuleTree        Compilation.js:2591
              │  dependencyFactories.get(Dep) → moduleFactory
              └─► Compilation.handleModuleCreation   (→ Phase 2)
```

`addModuleChain` (Compilation.js:2578) is a thin alias of `addModuleTree` kept for back-compat.

---

### Phase 2 — handleModuleCreation

**`Compilation.handleModuleCreation`** — Compilation.js:2298

Orchestrates the full lifecycle for one batch of co-located dependencies (all pointing at the same resource):

```
handleModuleCreation({ factory, dependencies, originModule, context, … })
  │  new ModuleProfile()               (if profiling)
  │
  ├─► factorizeModule                  → Phase 3
  │     on result:
  │       applyFactoryResultDependencies()  (copy fs-dep sets to Compilation)
  │       newModule = factoryResult.module
  │
  ├─► addModule(newModule)             → Phase 4
  │     on result (deduplicated module):
  │       moduleGraph.setResolvedModule(originModule, dep, module)  × each dep
  │       moduleGraph.setIssuerIfUnset(module, originModule)
  │
  └─► _handleModuleBuildAndDependencies  → Phase 5
```

---

### Phase 3 — Factorization

```
Compilation.factorizeModule             Compilation.js:2271
  └─► factorizeQueue.add()
        └─► Compilation._factorizeModule   Compilation.js:2171
              │  currentProfile.markFactoryStart()
              └─► factory.create({ contextInfo, resolveOptions,
                                   context, dependencies })
                    (factory = NormalModuleFactory)  → Phase 6
```

---

### Phase 4 — Module deduplication / cache restore

```
Compilation.addModule                   Compilation.js:1585
  └─► addModuleQueue.add()
        └─► Compilation._addModule      Compilation.js:1596
              │  identifier = module.identifier()
              │  if this._modules.has(identifier) → return existing   ← dedup
              │  this._modulesCache.get(identifier)                    ← persistent cache
              │    if hit: cacheModule.updateCacheModule(module)
              │  this._modules.set(identifier, module)
              └─► this.modules.add(module)
```

---

### Phase 5 — Build + recursive dependency discovery

```
Compilation._handleModuleBuildAndDependencies   Compilation.js:2449
  │  cycle detection via creatingModuleDuringBuild Map
  │
  └─► Compilation.buildModule             Compilation.js:1660
        └─► buildQueue.add()
              └─► Compilation._buildModule   Compilation.js:1670
                    │  module.needBuild({ compilation, fileSystemInfo,
                    │                     valueCacheVersions })
                    │    if false → hooks.stillValidModule → done
                    │  hooks.buildModule.call(module)
                    │  this.builtModules.add(module)
                    │
                    └─► module.build(options, compilation, resolver, fs)
                          (module = NormalModule)  → Phase 7
                          on success:
                            this._modulesCache.store(identifier, null, module)
                            hooks.succeedModule.call(module)

  then (if recursive):
  └─► Compilation.processModuleDependencies   Compilation.js:1745
        └─► processDependenciesQueue.add()
              └─► Compilation._processModuleDependencies   Compilation.js:1780
                    → Phase 9  (recursive re-entry)
```

---

### Phase 6 — NormalModuleFactory.create

**`NormalModuleFactory.create`** — NormalModuleFactory.js:1011

```
NormalModuleFactory.create(data, callback)
  │  build resolveData { contextInfo, context, request,
  │                      fileDependencies, missingDependencies,
  │                      contextDependencies, createData:{} }
  │
  ├─► hooks.beforeResolve.callAsync(resolveData)   ← plugins can short-circuit
  │     (false → return ignoredModule / no module)
  │
  └─► hooks.factorize.callAsync(resolveData)       ← Phase 6a
```

#### Phase 6a — `factorize` hook tap (NormalModuleFactory constructor, NormalModuleFactory.js:469)

```
hooks.factorize tap @stage 100
  └─► hooks.resolve.callAsync(resolveData)          ← Phase 6b

      on success:
      └─► hooks.afterResolve.callAsync(resolveData)
            └─► hooks.createModule.callAsync(createData, resolveData)
                  │  if no plugin creates one:
                  │    hooks.createModuleClass.for(type).call(createData, resolveData)
                  │    or: new NormalModule(createData)
                  └─► hooks.module.call(createdModule, createData, resolveData)
                        return createdModule
```

#### Phase 6b — `resolve` hook tap (NormalModuleFactory constructor, NormalModuleFactory.js:546)

This is the full request-parsing + resolution pipeline:

```
hooks.resolve tap @stage 100
  │
  │  1. Parse request string
  │       strip "!=!" match-resource prefix  → matchResourceData
  │       strip "!!" / "-!" / "!" prefixes   → noPrePostAutoLoaders / noAutoLoaders / noPreAutoLoaders
  │       split remaining on "!" → inline loader strings + unresolvedResource
  │
  │  2. Resolve inline loaders (from request string)
  │       NormalModuleFactory.resolveRequestArray(elements, loaderResolver)   NMF.js:1323
  │         asyncLib.map → loaderResolver.resolve() × each loader
  │
  │  3. Resolve resource path
  │       if scheme:  hooks.resolveForScheme.for(scheme).callAsync()
  │       otherwise:  NormalModuleFactory.resolveResource(             NMF.js:1123
  │                     context, unresolvedResource, resolver)
  │                     └─► resolver.resolve()   ← enhanced-resolve
  │
  │  4. Match module rules
  │       this.ruleSet.exec({ resource, resourceQuery, scheme,
  │                           dependency, issuer, … })
  │         → useLoadersPost[], useLoaders[], useLoadersPre[]
  │         → settings { type, parser, generator, resolve, layer, … }
  │
  │  5. Resolve rule-matched loaders (3 parallel resolveRequestArray calls)
  │       resolveRequestArray(useLoadersPost, loaderResolver)
  │       resolveRequestArray(useLoaders,     loaderResolver)
  │       resolveRequestArray(useLoadersPre,  loaderResolver)
  │         each → NormalModuleFactory.resolveRequestArray    NMF.js:1323
  │
  │  6. Assemble allLoaders = postLoaders ++ [inlineLoaders] ++
  │                           normalLoaders ++ preLoaders
  │
  └─► Object.assign(resolveData.createData, {
        layer, request, userRequest, rawRequest,
        loaders: allLoaders, resource,
        type,
        parser:  this.getParser(type, settings.parser),     NMF.js:1421
        generator: this.getGenerator(type, settings.generator), NMF.js:1467
        resolveOptions, extractSourceMap, …
      })
```

---

### Phase 7 — NormalModule.build

**`NormalModule.build`** — NormalModule.js:1779

```
NormalModule.build(options, compilation, resolver, fs, callback)
  │  reset: _source=null, _ast=null, deps=[], buildMeta={}, buildInfo={}
  │  hooks = NormalModule.getCompilationHooks(compilation)
  │
  └─► NormalModule._doBuild(options, compilation, resolver, fs, hooks)   → Phase 8
        on success:
          hooks.beforeParse.call(this)
          if shouldPreventParsing(noParse, request) → skip parser
          │
          └─► this.parser.parse(this._ast || source, {       ← Phase 9
                source, current: this, module: this,
                compilation, options })

          handleParseResult():
            sort this.dependencies (compareLocations + source order)
            this._initBuildHash(compilation)
            this._lastSuccessfulBuildMeta = this.buildMeta

          handleBuildDone():
            hooks.beforeSnapshot.call(this)
            compilation.fileSystemInfo.createSnapshot(
              startTime, fileDependencies, contextDependencies,
              missingDependencies, snapshotOptions)
              → buildInfo.snapshot = snapshot
```

---

### Phase 8 — NormalModule._doBuild (loader runner)

**`NormalModule._doBuild`** — NormalModule.js:1468

```
NormalModule._doBuild(options, compilation, resolver, fs, hooks, callback)
  │  loaderContext = this._createLoaderContext(resolver, options,   NM.js:1149
  │                     compilation, fs, hooks)
  │    (builds the loader API surface: emitFile, resolve, addDependency, …)
  │
  │  hooks.beforeLoaders.call(loaders, this, loaderContext)
  │
  └─► runLoaders({                        ← loader-runner (npm package)
        resource: this.resource,
        loaders:  this.loaders,           ← allLoaders array from createData
        context:  loaderContext,
        processResource: async (loaderContext, resourcePath, cb) => {
          hooks.readResource.for(scheme).callAsync(loaderContext)
          │  default scheme: loaderContext.fs.readFile(resourcePath)
          └─► cb(null, fileContents)
        }
      }, (err, result) => {
        copy result.fileDependencies / contextDependencies / missingDependencies
             → buildInfo.*
        buildInfo.cacheable &&= result.cacheable
        processResult(err, result.result)
          │  hooks.processResult.call(result, this)
          │  this._source = this.createSource(         NM.js:1428
          │    context, source, sourceMap, root)
          └─► this._ast = extraInfo?.webpackAST ?? null
      })
```

---

### Phase 9 — Parser populates module.dependencies

`this.parser.parse()` is called on the transformed source. For JS, this is `JavascriptParser` (`lib/javascript/JavascriptParser.js`). It:

- Walks the Acorn AST via statement/expression hooks
- Calls `module.addDependency(dep)` (NormalModule.js:1623, inherited from `DependenciesBlock`) for every resolved specifier (e.g. `HarmonyImportDependency`, `CommonJsRequireDependency`, `ImportDependency`, …)
- Calls `module.addBlock(block)` for dynamic `import()` → `AsyncDependenciesBlock`

The populated `module.dependencies[]` and `module.blocks[]` are what `_processModuleDependencies` will walk next.

---

### Phase 10 — _processModuleDependencies wires the graph and recurses

**`Compilation._processModuleDependencies`** — Compilation.js:1780

```
_processModuleDependencies(module, callback)
  │
  │  queue = [module] (walks module + all AsyncDependenciesBlocks)
  │  for each block:
  │    for each dep:
  │      moduleGraph.setParents(dep, block, module, index)    ← ModuleGraph.js:209
  │        dep._parentModule = module
  │        dep._parentDependenciesBlock = block
  │        dep._parentDependenciesBlockIndex = index
  │
  │      processDependency(dep):
  │        if unsafeCache hit:
  │          _handleExistingModuleFromUnsafeCache(module, dep, cachedModule)
  │            moduleGraph.setResolvedModule(module, dep, cachedModule)
  │          else _handleNewModuleFromUnsafeCache(...)
  │        else:
  │          processDependencyForResolving(dep):
  │            group deps by (factory, category+resourceIdentifier)
  │            → sortedDependencies[]
  │
  │  onDependenciesSorted():
  │    for each item in sortedDependencies:
  └─────── handleModuleCreation(item)     ← *** recursive re-entry ***
```

---

### Module graph wiring

**`ModuleGraph.setResolvedModule`** — ModuleGraph.js:259

Called in `handleModuleCreation` after `addModule` succeeds, once per dependency:

```
setResolvedModule(originModule, dependency, module)
  conn = new ModuleGraphConnection(originModule, dependency, module,
                                   dependency.weak, dependency.getCondition())
  module._mgm.incomingConnections.add(conn)
  originModule._mgm.outgoingConnections.add(conn)
  originModule._mgm._unassignedConnections.push(conn)
```

For entry-point dependencies `originModule` is `null` — the connection is stored in `_dependencyMap` instead.

**`ModuleGraph.setParents`** — ModuleGraph.js:209

Called in `_processModuleDependencies` for each dependency before grouping:

```
setParents(dep, block, module, indexInBlock)
  dep._parentDependenciesBlockIndex = indexInBlock
  dep._parentDependenciesBlock      = block
  dep._parentModule                 = module
```

---

### Unified call graph

```
Compilation.addEntry  (Compilation.js:2645)
└── Compilation._addEntryItem  (Compilation.js:2682)
    └── hooks.addEntry
    └── Compilation.addModuleTree  (Compilation.js:2591)
        │   dependencyFactories.get(Dep) → factory
        └── Compilation.handleModuleCreation  (Compilation.js:2298)  ◄──────────────────┐
            │                                                                              │
            ├── Compilation.factorizeModule  (Compilation.js:2271)                        │
            │   └── factorizeQueue → Compilation._factorizeModule  (Compilation.js:2171)  │
            │       └── NormalModuleFactory.create  (NormalModuleFactory.js:1011)          │
            │           ├── hooks.beforeResolve                                            │
            │           └── hooks.factorize  [tap @stage 100, NMF.js:469]                 │
            │               ├── hooks.resolve  [tap @stage 100, NMF.js:546]                │
            │               │   ├── parse request → matchResource + inline loaders         │
            │               │   ├── NMF.resolveRequestArray (inline loaders) NMF.js:1323  │
            │               │   ├── NMF.resolveResource  NMF.js:1123                      │
            │               │   │   └── resolver.resolve()  (enhanced-resolve)             │
            │               │   ├── ruleSet.exec()  → loader lists + settings              │
            │               │   └── NMF.resolveRequestArray ×3 (post/normal/pre)           │
            │               │       → resolveData.createData populated                     │
            │               ├── hooks.afterResolve                                         │
            │               ├── hooks.createModule → new NormalModule(createData)          │
            │               └── hooks.module                                               │
            │                                                                              │
            ├── ModuleGraph.setResolvedModule  (ModuleGraph.js:259)  × each dep            │
            │   └── new ModuleGraphConnection(origin, dep, module)                         │
            │       module.incomingConnections.add / origin.outgoingConnections.add         │
            │                                                                              │
            ├── Compilation.addModule  (Compilation.js:1585)                              │
            │   └── addModuleQueue → Compilation._addModule  (Compilation.js:1596)         │
            │       ├── this._modules dedup check                                          │
            │       ├── this._modulesCache.get()  (persistent cache restore)               │
            │       └── this._modules.set / this.modules.add                               │
            │                                                                              │
            └── Compilation._handleModuleBuildAndDependencies  (Compilation.js:2449)       │
                ├── cycle detection via creatingModuleDuringBuild                          │
                └── Compilation.buildModule  (Compilation.js:1660)                        │
                    └── buildQueue → Compilation._buildModule  (Compilation.js:1670)       │
                        ├── module.needBuild()                                             │
                        ├── hooks.buildModule                                              │
                        ├── NormalModule.build  (NormalModule.js:1779)                    │
                        │   ├── reset state (deps, buildMeta, buildInfo, _source, _ast)    │
                        │   ├── NormalModule._doBuild  (NormalModule.js:1468)              │
                        │   │   ├── NormalModule._createLoaderContext  (NM.js:1149)        │
                        │   │   ├── hooks.beforeLoaders                                    │
                        │   │   └── runLoaders()  (loader-runner)                         │
                        │   │       ├── processResource → hooks.readResource → fs.readFile │
                        │   │       ├── loader pitch phases  (left → right)                │
                        │   │       ├── loader normal phases (right → left)                │
                        │   │       └── processResult → NormalModule.createSource          │
                        │   │           → this._source = RawSource / SourceMapSource       │
                        │   ├── hooks.beforeParse                                          │
                        │   ├── NormalModule.shouldPreventParsing()  (NM.js:1729)          │
                        │   └── this.parser.parse(_ast || source)                          │
                        │       (JavascriptParser.js — acorn walk)                         │
                        │         module.addDependency() × each import/require             │
                        │         module.addBlock()      × each dynamic import()           │
                        │       handleParseResult → sort deps, _initBuildHash              │
                        │       handleBuildDone  → fileSystemInfo.createSnapshot()         │
                        │                                                                  │
                        └── this._modulesCache.store()                                     │
                        └── hooks.succeedModule                                            │
                                                                                           │
                        then:                                                              │
                        Compilation.processModuleDependencies  (Compilation.js:1745)      │
                        └── processDependenciesQueue                                       │
                            → Compilation._processModuleDependencies  (Compilation.js:1780)│
                                ├── moduleGraph.setParents(dep, block, module)  (MG.js:209)│
                                │   per dep: _parentModule / _parentBlock / _index         │
                                ├── processDependencyForResolving(dep)                     │
                                │   group by (factory, resourceIdent) → sortedDependencies │
                                └── for each sortedDependency group:                       │
                                    handleModuleCreation(item) ──────────────────────────-─┘
                                    (recurse for every imported module)
```

---

### Key classes and their roles

| Class | File | Role |
|---|---|---|
| `Compilation` | Compilation.js | Owns all four queues, the `ModuleGraph`, the `_modules` map, and the `entries` map. Drives the entire lifecycle. |
| `NormalModuleFactory` | NormalModuleFactory.js | Stateless factory: resolves a request string to a `NormalModule` instance via the hook chain. |
| `NormalModule` | NormalModule.js | One source file. Holds `loaders[]`, `_source`, `_ast`, `dependencies[]`, `blocks[]`, `buildMeta`, `buildInfo`. |
| `ModuleGraph` | ModuleGraph.js | Stores `ModuleGraphConnection` objects keyed by module and dependency; provides `setResolvedModule` / `setParents` / `getProfile` / `setIssuerIfUnset`. |
| `ModuleGraphConnection` | ModuleGraph.js | Edge: `(originModule, dependency, module, condition)`. Held in `incomingConnections` / `outgoingConnections`. |
| `AsyncQueue` | util/AsyncQueue.js | Bounded-concurrency work queue; each queue has exactly one processor function. |
| `JavascriptParser` | javascript/JavascriptParser.js | Acorn-based; populates `module.dependencies` by tapping AST node hooks. |
| `RuleSet` | rules/RuleSet.js | Compiled from `module.rules` + `module.defaultRules`; `exec()` returns loader lists and settings for a resource path. |
