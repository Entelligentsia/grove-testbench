# transcript: I need a precise, complete, ordered call-graph trace of webpack's module build subsystem, covering every function call in the path from entry to a fully-buil...


💬 I'll spawn an Explore agent to trace through the key files systematically — this touches Compilation, NormalModuleFactory, NormalModule, and ModuleGraph acro...
  ▸ Agent(Deep trace of webpack module build subsystem)
  ▸ Bash(find /home/bench/repos/webpack -type f -name "Compilation.js" -o -name "NormalModuleFactory.js" -o -name "NormalModule.js" -o -name "ModuleGraph.js" -o -name...)
  ▸ Bash(ls -la /home/bench/repos/webpack/lib/ | grep -E "(Compilation|NormalModuleFactory|NormalModule|ModuleGraph|DependenciesBlock)")
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Bash(grep -n "^\s*addEntry\|^\s*_addEntryItem\|^\s*handleModuleCreation\|^\s*_handleModuleCreation\|^\s*factorizeModule\|^\s*_factorizeModule\|^\s*addModule\|^\s*...)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/DependenciesBlock.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)

💬 Good output from the agent. Let me spot-check the most critical line numbers before presenting this as authoritative.
  ▸ Bash(grep -n "addEntry\|_addEntryItem\|addModuleTree\|handleModuleCreation\|_handleModuleCreation\|factorizeModule\|_factorizeModule\|addModule\b\|_addModule\b\|b...)
  ▸ Bash(grep -n "^\t\(addEntry\|_addEntryItem\|addModuleTree\|handleModuleCreation\|_handleModuleCreation\|factorizeModule\b\|_factorizeModule\b\|addModule\b\|_addMo...)
  ▸ Bash(grep -n "addEntry\|_addEntryItem\|addModuleTree\|handleModuleCreation\|factorizeModule\|_factorizeModule\|_addModule\|_buildModule\|_processModuleDependencie...)
  ▸ Bash(grep -n "factorizeQueue\|addModuleQueue\|buildQueue\|processDependenciesQueue" /home/bench/repos/webpack/lib/Compilation.js | grep "new AsyncQueue\|AsyncQueu...)

💬 Let me read specific sections directly.
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/DependenciesBlock.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)

💬 Now I have all the precise data I need. Here is the complete, verified call graph:  ---  ## webpack Module Build Subsystem: Complete Call Graph  ### Four `As...

──────── RESULT (success, 376589ms, 25 turns) ────────
Now I have all the precise data I need. Here is the complete, verified call graph:

---

## webpack Module Build Subsystem: Complete Call Graph

### Four `AsyncQueue` instances — the concurrency backbone

Defined in `Compilation.js` constructor (~line 1215):

```
processDependenciesQueue  (line 1215)  parallelism=100  processor=_processModuleDependencies
addModuleQueue            (line 1221)  parent=processDependenciesQueue  processor=_addModule
                                       getKey=(module)=>module.identifier()
factorizeQueue            (line 1228)  parent=addModuleQueue            processor=_factorizeModule
buildQueue                (line 1234)  parent=factorizeQueue            processor=_buildModule
```

"parent" means the child queue borrows a slot from the parent's pool — this creates back-pressure and prevents deadlocks.

---

### The linear call path, function by function

```
Compilation.addEntry                                   Compilation.js:2645
  └─ Compilation._addEntryItem                                      :2682
       fires hooks.addEntry (SyncHook)                              :2728
       └─ Compilation.addModuleTree                                 :2591
            looks up factory via this.dependencyFactories.get()     :2604
            └─ Compilation.handleModuleCreation                     :2298
                 └─ Compilation.factorizeModule                     :2271
                      └─ factorizeQueue.add()  ──► queue processor:
                           Compilation._factorizeModule             :2171
                                currentProfile.markFactoryStart()   :2184
                                └─ factory.create()  ──────────────────────────────────────────┐
                                                                                               │
  ┌────────────────────────────────── NormalModuleFactory.create    NormalModuleFactory.js:1011 ◄┘
  │   builds resolveData object                                                         :1039
  │   fires hooks.beforeResolve (AsyncSeriesBailHook)                                   :1054
  │   fires hooks.factorize     (AsyncSeriesBailHook, stage 100)                        :1090
  │     └─ [factorize hook body, registered at line 469]:
  │          fires hooks.resolve (AsyncSeriesBailHook, stage 100)                        :475
  │            └─ [resolve hook body, registered at line 546]:
  │                 this.getResolver("loader")                                           :565
  │                 parses inline loaders from request string                            :577-642
  │                 resolves resource path via enhanced-resolve                          :644-840
  │                 resolves each loader path via loaderResolver                         :852-898
  │                 populates resolveData.createData
  │          fires hooks.afterResolve (AsyncSeriesBailHook)                              :493
  │          fires hooks.createModule  (AsyncSeriesWaterfallHook)                        :512
  │            └─ if no plugin creates one → fires hooks.createModuleClass.for(type)    :523
  │                 → new NormalModule(createData)                                      :528
  │          fires hooks.module (SyncWaterfallHook)                                     :533
  │   returns ModuleFactoryResult ──────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────┘
                                                                                        │
     Back in Compilation._factorizeModule callback                                      │
          currentProfile.markFactoryEnd()                          Compilation.js:~2244 ◄┘

     Back in Compilation.handleModuleCreation factorizeModule callback:           :2325
          moduleGraph.setProfile(newModule, currentProfile)                        :2359
          └─ Compilation.addModule(newModule)                                      :2362
               └─ addModuleQueue.add()  ──► queue processor:
                    Compilation._addModule                                         :1596
                         this._modules.get(identifier)  [dedup check]             :1598
                         this._modulesCache.get()        [restore from cache]      :1610
                         cacheModule.updateCacheModule()  [if hit]                 :1619
                         this._modules.set(identifier, module)                     :1623
                         this.modules.add(module)                                  :1624
                         ModuleGraph.setModuleGraphForModule()  [back-compat]      :1626

     Back in handleModuleCreation addModule callback:
          moduleGraph.setResolvedModule(originModule, dep, module)  ×N deps        :2404
               ModuleGraph.js:259
               → new ModuleGraphConnection(origin, dep, module)                    :260
               → module's incomingConnections.add(connection)                      :269-270
               → origin's outgoingConnections.add(connection)                      :280

          moduleGraph.setIssuerIfUnset(module, originModule)                       :2412
          └─ Compilation._handleModuleBuildAndDependencies(...)                    :2449
               [cycle detection via creatingModuleDuringBuild WeakMap]             :2465-2497
               └─ Compilation.buildModule(module)                                  :2500
                    └─ buildQueue.add()  ──► queue processor:
                         Compilation._buildModule                                  :1670
                              module.needBuild({compilation, fileSystemInfo, ...})  :1678
                              fires hooks.stillValidModule (SyncHook) if cached    :1691
                              fires hooks.buildModule      (SyncHook)              :1695
                              this.builtModules.add(module)                        :1696
                              └─ module.build(options, compilation, resolver, fs)  :1697
                                   ──────────────────────────────────────────────────────┐
                                                                                        │
  ┌─────────────────────── NormalModule.build          NormalModule.js:1779            ◄┘
  │   this.clearWarningsAndErrors()                                             :1786
  │   this.clearDependenciesAndBlocks()   [resets this.dependencies = []]       :1787
  │   initializes this.buildMeta / this.buildInfo                               :1788-1814
  │   hooks = NormalModule.getCompilationHooks(compilation)                     :1818
  │   └─ NormalModule._doBuild(options, compilation, resolver, fs, hooks)       :1820
  │        this._createLoaderContext(resolver, options, compilation, fs, hooks) :1469
  │        fires hooks.beforeLoaders (SyncHook)                                 :1551
  │        runLoaders({resource, loaders, context, processResource})            :1567
  │          [loader-runner npm package — executes each loader in sequence]
  │          processResource calls hooks.readResource.for(scheme) (HookMap/AsyncSeriesBailHook) :1583
  │          accumulates buildInfo.{file,context,missing}Dependencies
  │          in processResult callback:
  │            hooks.processResult (SyncWaterfallHook)                          :1497
  │            this._source = this.createSource(content, sourceMap)             :1526
  │              → RawSource | OriginalSource | SourceMapSource                 :1428-1456
  │            this._ast = extraInfo?.webpackAST ?? null                        :1534
  │   ◄── back in build(), _doBuild callback:
  │   fires hooks.beforeParse (SyncHook)                                        :1954
  │   this.shouldPreventParsing(noParse, request)  [optional early exit]        :1964
  │   this.parser.parse(this._ast || source, state)                             :1975
  │     [Parser is JavascriptParser or CssParser depending on module type]
  │     During parse, parser's internal hooks fire, e.g.:
  │       "import"        → HarmonyImportDependency pushed via addDependency
  │       "call require"  → CommonJsRequireDependency pushed via addDependency
  │       "export"        → HarmonyExportDependency pushed via addDependency
  │     Each dep is added via:
  │       DependenciesBlock.addDependency(dep)       DependenciesBlock.js:61
  │         this.dependencies.push(dep)
  │   handleParseResult():
  │     this.dependencies.sort(compareLocations)                                :1844
  │     this._initBuildHash(compilation)                                        :1851
  │   handleBuildDone():
  │     hooks.beforeSnapshot (SyncHook)                                         :1860
  │     compilation.fileSystemInfo.createSnapshot(...)                          :1933
  └──────────────────────────────────────────────────────────────────────────────┘

     Back in Compilation._buildModule build callback:
          this._modulesCache.store(identifier, null, module)                     :1714
          fires hooks.failedModule / hooks.succeedModule (SyncHook)              :1708/1729

     Back in _handleModuleBuildAndDependencies buildModule callback:
          if (!recursive) → processModuleDependenciesNonRecursive(module)        :2514
               [walks deps, calls moduleGraph.setParents() — no recursion]
          else:
          this._lazyBarrelController.request(module, dependencies)               :2525
          └─ Compilation.processModuleDependencies(module)                       :2561
               └─ processDependenciesQueue.add()  ──► queue processor:
                    Compilation._processModuleDependencies                       :1780
                         this._lazyBarrelController.classify(module)             :1789
                         [walk all deps & blocks, grouping by factory:]
                         processDependency(dep, index) for each dep              :1868
                           moduleGraph.setParents(dep, block, module, index)     :1869
                             ModuleGraph.js:209
                             dep._parentDependenciesBlock = block
                             dep._parentModule = module
                           [unsafe cache fast path or push to sortedDependencies]
                         onDependenciesSorted():                                  :1818
                           processDependenciesQueue.increaseParallelism()         :1827
                           for each factory-grouped batch:
                             Compilation.handleModuleCreation(item)               :1832
                               [╔═ RECURSION — repeats from handleModuleCreation above ═╗]
                           processDependenciesQueue.decreaseParallelism()         :1857
```

---

### Key classes and their roles

| Class | File | Role |
|---|---|---|
| `Compilation` | `lib/Compilation.js` | Orchestrates the entire build; owns all 4 `AsyncQueue`s |
| `NormalModuleFactory` | `lib/NormalModuleFactory.js` | Resolves a request string → `NormalModule` instance |
| `NormalModule` | `lib/NormalModule.js` | Represents one source file; runs loaders + parser |
| `JavascriptParser` | `lib/javascript/JavascriptParser.js` | Walks AST; fires hooks that push `Dependency` objects |
| `ModuleGraph` | `lib/ModuleGraph.js` | Directed graph of `ModuleGraphConnection` edges (dep→module) |
| `DependenciesBlock` | `lib/DependenciesBlock.js` | Base class of `Module`; stores `this.dependencies[]` |
| `ModuleGraphConnection` | `lib/ModuleGraph.js` | One edge: `(originModule, dependency, resolvedModule)` |
| `AsyncQueue` | `lib/util/AsyncQueue.js` | Bounded-parallelism work queue; back-pressure via `parent` |

---

### All hooks fired in order

| # | Hook name | Type | Fired in | File:line |
|---|---|---|---|---|
| 1 | `hooks.addEntry` | `SyncHook` | `_addEntryItem` | Compilation.js:2728 |
| 2 | `hooks.beforeResolve` | `AsyncSeriesBailHook` | `NMF.create` | NormalModuleFactory.js:1054 |
| 3 | `hooks.factorize` | `AsyncSeriesBailHook` | `NMF.create` callback | :1090 |
| 4 | `hooks.resolve` | `AsyncSeriesBailHook` | factorize body | :475 |
| 5 | `hooks.afterResolve` | `AsyncSeriesBailHook` | resolve callback | :493 |
| 6 | `hooks.createModule` | `AsyncSeriesWaterfallHook` | afterResolve callback | :512 |
| 7 | `hooks.createModuleClass.for(type)` | `SyncBailHook` (HookMap) | createModule fallback | :523 |
| 8 | `hooks.module` | `SyncWaterfallHook` | createModule callback | :533 |
| 9 | `hooks.stillValidModule` | `SyncHook` | `_buildModule` (cache hit) | Compilation.js:1691 |
| 10 | `hooks.buildModule` | `SyncHook` | `_buildModule` | :1695 |
| 11 | `hooks.beforeLoaders` | `SyncHook` | `NormalModule._doBuild` | NormalModule.js:1551 |
| 12 | `hooks.readResource.for(scheme)` | `AsyncSeriesBailHook` (HookMap) | `runLoaders` processResource | :1583 |
| 13 | `hooks.processResult` | `SyncWaterfallHook` | `_doBuild` processResult | :1497 |
| 14 | `hooks.beforeParse` | `SyncHook` | `build` after `_doBuild` | :1954 |
| 15 | `hooks.beforeSnapshot` | `SyncHook` | `handleBuildDone` | :1860 |
| 16 | `hooks.failedModule` | `SyncHook` | `_buildModule` (error path) | Compilation.js:1708 |
| 17 | `hooks.succeedModule` | `SyncHook` | `_buildModule` (success) | :1729 |
| 18 | `hooks.failedEntry` / `hooks.succeedEntry` | `SyncHook` | `_addEntryItem` callback | :2740/2743 |

---

### Unified call graph (ASCII)

```
addEntry :2645
└── _addEntryItem :2682
    ├── hooks.addEntry (:2728)
    └── addModuleTree :2591
        └── handleModuleCreation :2298
            └── factorizeModule :2271
                └── [factorizeQueue] _factorizeModule :2171
                    └── NMF.create :1011
                        ├── hooks.beforeResolve
                        └── hooks.factorize
                            └── hooks.resolve
                            │   ├── getResolver("loader")
                            │   ├── resolve resource (enhanced-resolve)
                            │   └── resolve loaders (enhanced-resolve)
                            ├── hooks.afterResolve
                            ├── hooks.createModule
                            │   └── new NormalModule(createData) :528
                            └── hooks.module
            └── [addModuleQueue] _addModule :1596
                ├── _modulesCache.get()   [cache restore]
                ├── _modules.set()
                └── modules.add()
            └── moduleGraph.setResolvedModule() :2404  [ModuleGraph.js:259]
                └── new ModuleGraphConnection(origin, dep, module)
                    ├── module.incomingConnections.add()
                    └── origin.outgoingConnections.add()
            └── moduleGraph.setIssuerIfUnset() :2412
            └── _handleModuleBuildAndDependencies :2449
                └── buildModule :2500
                    └── [buildQueue] _buildModule :1670
                        ├── module.needBuild()
                        ├── hooks.buildModule
                        └── NormalModule.build :1779
                            ├── clearDependenciesAndBlocks()
                            ├── NormalModule.getCompilationHooks()
                            └── _doBuild :1468
                                ├── _createLoaderContext()
                                ├── hooks.beforeLoaders
                                └── runLoaders() [loader-runner]
                                    ├── hooks.readResource.for(scheme)
                                    ├── [executes loaders in sequence]
                                    ├── hooks.processResult
                                    └── createSource() :1428
                                        └── RawSource|OriginalSource|SourceMapSource
                            ├── hooks.beforeParse
                            ├── shouldPreventParsing()
                            └── parser.parse(ast|source, state) :1975
                                └── [JavascriptParser walks AST]
                                    └── parser hooks fire per node:
                                        "import"/"require"/"export"/…
                                        └── DependenciesBlock.addDependency() :61
                                            └── this.dependencies.push(dep)
                            └── handleParseResult → handleBuildDone
                                └── hooks.beforeSnapshot
                                └── fileSystemInfo.createSnapshot()
                        ├── _modulesCache.store()
                        └── hooks.succeedModule
                └── processModuleDependencies :2561
                    └── [processDependenciesQueue] _processModuleDependencies :1780
                        ├── _lazyBarrelController.classify(module)
                        ├── processDependency(dep, i) :1868
                        │   └── moduleGraph.setParents(dep, block, module, i) [ModuleGraph.js:209]
                        │       dep._parentModule = module
                        │       dep._parentDependenciesBlock = block
                        └── onDependenciesSorted() :1818
                            ├── processDependenciesQueue.increaseParallelism()
                            ├── handleModuleCreation(item) ×N  ← RECURSION
                            └── processDependenciesQueue.decreaseParallelism()
```

The recursion through `handleModuleCreation` → `_processModuleDependencies` → `handleModuleCreation` is what walks the entire module graph depth-first (but concurrently, bounded by queue parallelism). The tree terminates when a module's `dependencies[]` is empty after parsing, or all discovered modules are already in `_modules` (dedup in `_addModule`).
