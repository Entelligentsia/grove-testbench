# transcript: Perform a very thorough structural survey of the webpack codebase at /home/bench/repos/webpack to support writing a complete architectural walkthrough. For e...


💬 I'll spawn an Explore agent to do a thorough structural survey of the webpack codebase, then synthesize the walkthrough.
  ▸ Agent(Deep webpack compilation lifecycle survey)
  ▸ Read(/home/bench/repos/webpack/lib/webpack.js)
  ▸ Read(/home/bench/repos/webpack/lib/WebpackOptionsApply.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compiler.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/ContextModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Bash(grep -n "this.hooks = " /home/bench/repos/webpack/lib/Compilation.js | head -1)
  ▸ Bash(grep -n "^\s*addEntry\|^\s*addModule\|^\s*buildModule\|^\s*processModuleDependencies\|^\s*seal\|^\s*codeGeneration\|^\s*createChunkAssets" /home/bench/repos/...)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Bash(find /home/bench/repos/webpack/lib -name "*.js" -type f | head -20)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/ChunkGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/buildChunkGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/optimize/SplitChunksPlugin.js)
  ▸ Read(/home/bench/repos/webpack/lib/javascript/JavascriptModulesPlugin.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)

💬 Good survey. Let me verify precise line numbers for the most critical methods before writing the final document.
  ▸ Bash(grep -n "compile\|run\|emitAssets\|newCompilationParams\|newCompilation\b\|readRecords\|emitRecords" /home/bench/repos/webpack/lib/Compiler.js | head -80)
  ▸ Bash(grep -n "addEntry\|_addEntryItem\|addModuleTree\|handleModuleCreation\|factorizeModule\|addModule\b\|buildModule\|processModuleDependencies\|seal(\|codeGener...)
  ▸ Bash(grep -n "class NormalModule\|doBuild\|runLoaders\|codeGeneration\|^	build(" /home/bench/repos/webpack/lib/NormalModule.js | head -40)

💬 Let me read the key files directly.
  ▸ Read(/home/bench/repos/webpack/lib/Compiler.js)
  ▸ Read(/home/bench/repos/webpack/lib/webpack.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compiler.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compiler.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compiler.js)
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
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/buildChunkGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/buildChunkGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModuleFactory.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/ModuleGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/buildChunkGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/javascript/JavascriptModulesPlugin.js)
  ▸ Read(/home/bench/repos/webpack/lib/javascript/JavascriptModulesPlugin.js)
  ▸ Read(/home/bench/repos/webpack/lib/buildChunkGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/buildChunkGraph.js)
  ▸ Read(/home/bench/repos/webpack/lib/javascript/JavascriptModulesPlugin.js)
  ▸ Read(/home/bench/repos/webpack/lib/javascript/JavascriptModulesPlugin.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compiler.js)

💬 I now have everything I need from the source. Here is the complete walkthrough.  ---  # webpack Compilation Lifecycle: Complete Architectural Walkthrough  ##...

──────── RESULT (success, 418729ms, 49 turns) ────────
I now have everything I need from the source. Here is the complete walkthrough.

---

# webpack Compilation Lifecycle: Complete Architectural Walkthrough

## 1. Entry point — `webpack()` and compiler creation

**`lib/webpack.js:81` — `createCompiler(rawOptions)`**

Everything begins here. The function:

1. Calls `getNormalizedWebpackOptions(rawOptions)` and `applyWebpackOptionsBaseDefaults(options)` to produce a fully-normalized options object with every field populated.
2. Instantiates `new Compiler(options.context, options)` (`lib/Compiler.js:175`).
3. Applies `new NodeEnvironmentPlugin(...)` — wires `inputFileSystem`, `outputFileSystem`, `watchFileSystem`, `intermediateFileSystem` onto the compiler.
4. Calls every plugin in `options.plugins` (`.apply(compiler)` or as a function).
5. Calls `applyWebpackOptionsDefaults(options)`.
6. Fires `compiler.hooks.validate`, `environment`, `afterEnvironment` (all `SyncHook`, declared at lines 247–251).
7. Calls `new WebpackOptionsApply().process(options, compiler, interception)`.
8. Fires `compiler.hooks.initialize` (line 184).

**`lib/webpack.js:59` — `createMultiCompiler(childOptions, options)`** wraps multiple `createCompiler` calls into a `MultiCompiler` for array configs.

---

## 2. Plugin registration — `WebpackOptionsApply`

**`lib/WebpackOptionsApply.js:87` — `class WebpackOptionsApply extends OptionsApply`**  
**`lib/WebpackOptionsApply.js:99` — `process(options, compiler, interception)`**

This is webpack's wiring harness. It reads every field in the normalized options object and calls `.apply(compiler)` on the appropriate built-in plugins, in a fixed order that determines hook priority. Key groups (with approximate lines):

| Line | Plugin group |
|------|-------------|
| ~105–225 | Externals: `NodeTargetPlugin`, `ElectronTargetPlugin`, `ExternalsPlugin` |
| ~233 | `ChunkPrefetchPreloadPlugin` |
| ~236–260 | Chunk format: `ArrayPushCallbackChunkFormatPlugin`, `CommonJsChunkFormatPlugin`, `ModuleChunkFormatPlugin` |
| ~393 | **`JavascriptModulesPlugin`** — the JS rendering engine |
| ~395–398 | `JsonModulesPlugin`, `AssetModulesPlugin` |
| ~536–588 | `EntryOptionPlugin`, `RuntimePlugin`, `HarmonyModulesPlugin`, `CommonJsPlugin`, `RequireContextDependency` plugins, etc. |
| ~596–625 | `SideEffectsFlagPlugin`, `FlagDependencyExportsPlugin`, `FlagDependencyUsagePlugin`, `InnerGraphPlugin` |
| ~642–665 | Production: `ModuleConcatenationPlugin`, `MangleExportsPlugin`, `NoEmitOnErrorsPlugin` |
| ~666–675 | `SplitChunksPlugin`, `RuntimeChunkPlugin` |
| ~681–692 | `RealContentHashPlugin` |
| ~698–791 | ID plugins: `NamedModuleIdsPlugin`/`DeterministicModuleIdsPlugin`, `NamedChunkIdsPlugin`/`DeterministicChunkIdsPlugin` |
| ~802–811 | Minimizer plugins (e.g., `TerserPlugin`) |
| ~838–942 | Cache plugins: `MemoryCachePlugin`, `IdleFileCachePlugin` with pack strategy |
| ~950–982 | `afterPlugins` hook, then resolver factory configuration |

Every plugin's `apply` method taps into `compiler.hooks.*` or saves itself to be applied later when `compiler.hooks.compilation` fires.

---

## 3. Compiler hooks — full declaration

**`lib/Compiler.js:182` — `this.hooks = Object.freeze({...})`**

| Hook name | Type | Line | When it fires |
|-----------|------|------|---------------|
| `initialize` | SyncHook | 184 | After all plugins are applied |
| `shouldEmit` | SyncBailHook | 187 | Before emitting; false → skip write |
| `done` | AsyncSeriesHook | 189 | After emission completes |
| `afterDone` | SyncHook | 191 | Sync, after `done` resolves |
| `additionalPass` | AsyncSeriesHook | 193 | Multi-pass compilation |
| `beforeRun` | AsyncSeriesHook | 195 | Before `run()` body |
| `run` | AsyncSeriesHook | 197 | During `run()` |
| `emit` | AsyncSeriesHook | 199 | Before files are written |
| `assetEmitted` | AsyncSeriesHook | 201 | Per-file, after each write |
| `afterEmit` | AsyncSeriesHook | 203 | After all files written |
| `thisCompilation` | SyncHook | 206 | Before `compilation` hook; used to own a Compilation |
| `compilation` | SyncHook | 208 | After Compilation created |
| `normalModuleFactory` | SyncHook | 210 | NMF created |
| `contextModuleFactory` | SyncHook | 212 | CMF created |
| `beforeCompile` | AsyncSeriesHook | 215 | Before compile body |
| `compile` | SyncHook | 217 | Compilation params ready |
| `make` | **AsyncParallelHook** | 219 | **The make phase; entries plug in here** |
| `finishMake` | AsyncSeriesHook | 221 | After make before finish |
| `afterCompile` | AsyncSeriesHook | 223 | After seal |
| `readRecords` | AsyncSeriesHook | 226 | Load prior build records |
| `emitRecords` | AsyncSeriesHook | 228 | Save records |
| `watchRun` | AsyncSeriesHook | 231 | Watch rebuild |
| `failed` | SyncHook | 233 | On error |
| `invalid` | SyncHook | 235 | File changed |
| `watchClose` | SyncHook | 237 | Watcher stopped |
| `shutdown` | AsyncSeriesHook | 239 | Compiler closing |
| `validate` | SyncHook | 247 | Config validation |
| `environment` | SyncHook | 249 | Env setup |
| `afterEnvironment` | SyncHook | 251 | After env |
| `afterPlugins` | SyncHook | 253 | After WebpackOptionsApply |
| `afterResolvers` | SyncHook | 255 | After resolvers created |
| `entryOption` | SyncBailHook | 257 | Entry processing |

---

## 4. `Compiler.run()` — the outer lifecycle

**`lib/Compiler.js:539` — `run(callback)`**

```
run()
  → this.running = true
  → hooks.beforeRun.callAsync(compiler)
  → hooks.run.callAsync(compiler)
  → this.readRecords()
  → this.compile(onCompiled)   ← main work
    onCompiled:
      → hooks.shouldEmit.call(compilation)
      → this.emitAssets(compilation)
      → this.emitRecords()
      → hooks.done.callAsync(stats)
      → hooks.afterDone.call(stats)
```

---

## 5. `Compiler.compile()` — the inner lifecycle

**`lib/Compiler.js:1403` — `compile(callback)`**

This is the core sequencer:

```
compile()
  → newCompilationParams()           // line 1390: creates NMF + CMF
      → createNormalModuleFactory()  // line 1370 (calls hooks.normalModuleFactory)
      → createContextModuleFactory() // line 1384 (calls hooks.contextModuleFactory)
  → hooks.beforeCompile.callAsync(params)
  → hooks.compile.call(params)       // sync
  → newCompilation(params)           // creates Compilation instance
      → hooks.thisCompilation.call(compilation, params)
      → hooks.compilation.call(compilation, params)
  → hooks.make.callAsync(compilation)  // ← MAKE PHASE begins here (line 1415)
  → hooks.finishMake.callAsync(compilation)
  → compilation.finish()
  → compilation.seal()               // ← SEAL PHASE
  → hooks.afterCompile.callAsync(compilation)
```

---

## 6. Factories — `NormalModuleFactory` and `ContextModuleFactory`

### NormalModuleFactory

**`lib/NormalModuleFactory.js:381` — `class NormalModuleFactory extends ModuleFactory`**

Hooks declared at line 399 (all on `this.hooks`):

| Hook | Type | Purpose |
|------|------|---------|
| `resolve` | AsyncSeriesBailHook | Main resolution path |
| `resolveForScheme` | HookMap | Per-scheme handlers (e.g., `data:`, `file:`) |
| `factorize` | AsyncSeriesBailHook | Outer creation entry point |
| `beforeResolve` | AsyncSeriesBailHook | Pre-resolution (can return false to ignore) |
| `afterResolve` | AsyncSeriesBailHook | Post-resolution, fills `createData` |
| `createModule` | AsyncSeriesBailHook | Create the Module instance |
| `module` | SyncWaterfallHook | Transform/wrap the Module |
| `createParser` | HookMap | Per-type parser factory |
| `parser` | HookMap | After parser created |
| `createGenerator` | HookMap | Per-type generator factory |
| `generator` | HookMap | After generator created |
| `createModuleClass` | HookMap | Per-type Module class selection |

**Resolution flow (line 469 — inner tap on `hooks.factorize`)**:

```
factorize(resolveData)
  → hooks.resolve.callAsync(resolveData)
      → hooks.beforeResolve
      → enhanced-resolve: resolves the resource path to an absolute FS path
      → RuleSet.exec(): matches loader rules → builds allLoaders[]
      → this.resolveRequestArray(): resolves each loader path
      → fills resolveData.createData with { request, loaders, resource, type, parser, generator, ... }
  → hooks.afterResolve
  → hooks.createModule → hooks.createModuleClass.for(type)
      → JavascriptModulesPlugin taps createModuleClass to return new JavascriptModule(createData)
      → fallback: new NormalModule(createData)  (line 528)
  → hooks.module (waterfall — plugins can wrap/replace)
  → callback(null, module)
```

### ContextModuleFactory

**`lib/ContextModuleFactory.js:54` — `class ContextModuleFactory extends ModuleFactory`**

Hooks: `beforeResolve`, `afterResolve`, `contextModuleFiles`, `alternativeRequests` (AsyncSeriesWaterfallHooks). Used for `require.context()` — resolves a directory, finds matching files, produces a `ContextModule` whose dependencies are the individual files.

---

## 7. The Make Phase — building the module graph

Entry plugins (e.g., `EntryPlugin`) tap `compiler.hooks.make` (AsyncParallelHook, so all entries fire in parallel). Each calls:

**`lib/Compilation.js:2645` — `addEntry(context, entry, optionsOrName, callback)`**

Normalizes options and delegates to:

**`lib/Compilation.js:2682` — `_addEntryItem(context, entry, target, options, callback)`**

Registers the entry dependency in `this.entries`, fires `hooks.addEntry`, then calls:

**`lib/Compilation.js:2591` — `addModuleTree({ context, dependency, contextInfo }, callback)`**

Looks up the factory registered for this dependency type in `this.dependencyFactories`, then calls:

**`lib/Compilation.js:2298` — `handleModuleCreation({ factory, dependencies, originModule, ... }, callback)`**

The central orchestrator of the make phase. Its flow:

```
handleModuleCreation()
  → factorizeModule(options)     // queued via this.factorizeQueue
      → factory.create(data)     // calls NormalModuleFactory.create()
      → returns new Module instance
  → addModule(newModule)         // queued via this.addModuleQueue
      → moduleGraph.setResolvedModule(originModule, dependency, module)
      → deduplicates: if module was already built, reuses it
  → _handleModuleBuildAndDependencies()
      → buildModule(module)      // queued via this.buildQueue (line 2500)
      → processModuleDependencies(module)
```

**`lib/Compilation.js:2271` — `factorizeModule(options, callback)`**

Enqueues into `this.factorizeQueue` (an `AsyncQueue` with configurable concurrency), which calls the factory.

**`lib/Compilation.js:2362` — `addModule(newModule, callback)` (inside handleModuleCreation)**

Registers the module in `this.moduleGraph` and `this.modules`, handling cache restoration and deduplication.

**`lib/Compilation.js:2500` — `buildModule(module, callback)`**

Fires `hooks.buildModule`, calls `module.build(options, compilation, resolver, fs, callback)`. On success fires `hooks.succeedModule` or `hooks.failedModule`.

After build, `processModuleDependencies(module)` is called to recurse into the newly-discovered dependencies, creating a work queue that drains until the entire reachable module graph is built. `hooks.finishModules` fires when the queue empties.

---

## 8. `NormalModule.build()` — loader chain and parsing

**`lib/NormalModule.js:1779` — `build(options, compilation, resolver, fs, callback)`**

Clears prior build state, resets `buildMeta`, `buildInfo`, `dependencies`, then calls:

**`lib/NormalModule.js:1468` — `_doBuild(options, compilation, resolver, fs, hooks, callback)`**

1. **`_createLoaderContext(resolver, options, compilation, fs, hooks)`** (line ~1100) — builds the full `loaderContext` object exposed to loaders: `this`, `emitFile`, `getOptions`, `resolve`, `getResolve`, `addDependency`, etc.
2. **`runLoaders({ resource, loaders, context: loaderContext, processResource }, callback)`** (line 1567) — imported from `loader-runner` (`lib/NormalModule.js:9`). Executes the loader pipeline right-to-left (pre, normal, post) producing a string/Buffer source and optional source map.
3. `processResult()` takes the raw output and calls `this.createSource()` (line 1428) to produce a `webpack-sources` `Source` object (`OriginalSource`, `SourceMapSource`, or `RawSource` depending on config).

Back in `build()` after `_doBuild` (line 1820):

4. Checks `module.noParse` rules.
5. **`this.parser.parse(this._ast || source, { current: this, compilation, ... })`** (line 1975) — the `JavascriptParser` (an acorn-based walker) traverses the AST and emits `Dependency` objects (e.g., `HarmonyImportDependency`, `CommonJsRequireDependency`) into `this.dependencies` and `this.blocks`.
6. `handleParseResult()` sorts dependencies and calls `_initBuildHash()` to hash the source, then snapshots file-system timestamps via `compilation.fileSystemInfo.createSnapshot()`.

---

## 9. `ModuleGraph` — the dependency graph

**`lib/ModuleGraph.js:140` — `class ModuleGraph`**

Internal storage (line 141–185):

```
this._dependencyMap  WeakMap<Dependency, ModuleGraphConnection | null>
this._moduleMap      Map<Module, ModuleGraphModule>
this._metaMap        WeakMap<MetaKey, Meta>
```

**`lib/ModuleGraph.js:96` — `class ModuleGraphModule`** (inner class, line 96)

Each `Module` gets a `ModuleGraphModule` wrapper holding:

```js
incomingConnections  SortableSet<ModuleGraphConnection>  // who imports this
outgoingConnections  SortableSet<ModuleGraphConnection>  // what this imports
issuer              Module | null                         // first importer
exports             ExportsInfo                           // known exports
preOrderIndex, postOrderIndex, depth                     // traversal state
```

**`lib/ModuleGraph.js:192` — `_getModuleGraphModule(module)`** — lazy-creates and returns the `ModuleGraphModule` for any module.

Key mutation methods: `setResolvedModule(originModule, dependency, module)`, `setParents(dependency, block, module, index)`, `setIssuerIfUnset(module, issuerModule)`.

Key query methods: `getOutgoingDependencies(module)`, `getIncomingConnections(module)`, `getOutgoingConnectionsByModule(module)` (returns `Map<Module, ModuleGraphConnection[]>`).

---

## 10. `Compilation.seal()` — the seal phase in full

**`lib/Compilation.js:3473` — `seal(callback)`**

This is the longest and most complex method in the codebase. In order:

```
seal()
  hooks.seal.call()                              // line 3496

  OPTIMIZATION 0: DEPENDENCIES
  hooks.optimizeDependencies (loop until false)  // line 3499
  hooks.afterOptimizeDependencies

  CHUNK GRAPH CONSTRUCTION
  hooks.beforeChunks.call()                      // line 3506
  moduleGraph.freeze("seal")                     // immutable from here
  for each entry in this.entries:
    this.addChunk(name)                          // line 3512
    new Entrypoint(options)                      // line 3516
    chunkGraph.connectChunkAndEntryModule(chunk, module, entrypoint)
    this.assignDepths(entryModules)
  buildChunkGraph(this, chunkGraphInit)          // line 3656 — external function
  hooks.afterChunks.call(this.chunks)            // line 3657

  OPTIMIZATION PIPELINE
  hooks.optimize.call()                          // line 3661
  loop: hooks.optimizeModules (SyncBailHook)     // line 3663
  hooks.afterOptimizeModules
  loop: hooks.optimizeChunks (SyncBailHook)      // line 3668
  hooks.afterOptimizeChunks
  hooks.optimizeTree.callAsync (async)           // line 3673
  hooks.afterOptimizeTree
  hooks.optimizeChunkModules.callAsync (async)   // line 3682
  hooks.afterOptimizeChunkModules

  ID ASSIGNMENT
  hooks.reviveModules / reviveChunks             // line 3696, 3706
  hooks.moduleIds.call (DeterministicModuleIdsPlugin taps here)
  hooks.chunkIds.call  (DeterministicChunkIdsPlugin taps here)
  this.assignRuntimeIds()                        // line 3716

  CODEGEN PREP
  this._computeAffectedModulesWithChunkGraph()   // line 3719
  hooks.optimizeCodeGeneration                   // line 3737

  MODULE HASHING
  hooks.beforeModuleHash
  this.createModuleHashes()                      // line 3742
  hooks.afterModuleHash

  CODE GENERATION
  hooks.beforeCodeGeneration
  this.codeGeneration(callback)                  // line 3748 — see §11
  hooks.afterCodeGeneration

  RUNTIME REQUIREMENTS
  hooks.beforeRuntimeRequirements
  this.processRuntimeRequirements()              // line 3757
  hooks.afterRuntimeRequirements

  HASHING
  hooks.beforeHash
  this.createHash()                              // returns deferred codegen jobs
  hooks.afterHash
  this._runCodeGenerationJobs(jobs)              // line 3767

  ASSETS
  this.clearAssets()
  hooks.beforeModuleAssets
  this.createModuleAssets()                      // line 3785 — modules with emitFile() assets
  if shouldGenerateChunkAssets:
    hooks.beforeChunkAssets
    this.createChunkAssets(callback)             // line 3841 — main JS outputs
  hooks.processAssets.callAsync(this.assets)     // line 3790 — plugin post-processing
  hooks.afterProcessAssets

  FINALIZE
  if hooks.needAdditionalSeal → this.unseal() → this.seal()   // re-seal loop
  hooks.afterSeal.callAsync()
```

---

## 11. `buildChunkGraph()` — grouping modules into chunks

**`lib/buildChunkGraph.js` — `buildChunkGraph(compilation, chunkGraphInit)`** (exported at bottom of file)

Called from `seal()` at line 3656. Uses a **bigint bitmask** scheme to track available modules efficiently. Three internal phases run in a tight loop:

### Phase 1: `visitModules` (the main queue loop, line ~1233)

Processes a queue of `QueueItem` objects:

```js
{ action, block, module, chunk, chunkGroup, chunkGroupInfo }
```

Actions:
- `ADD_AND_ENTER_MODULE` — calls `chunkGraph.connectChunkAndModule(chunk, module)`, then processes the module's dependencies as a block
- `PROCESS_BLOCK` — iterates `blockModules` for this block, checking the bitset `minAvailableModules` to skip already-available modules; pushes found modules back to queue
- `ADD_AND_ENTER_ENTRYPOINT`, `LEAVE_CONTEXT`

For each `AsyncDependenciesBlock` (dynamic `import()`), a new `ChunkGroup` is created and its seed `QueueItem` is deferred to `queueDelayed` so sync modules resolve first.

Supporting sub-routines called inside the loop:

- `processQueue()` — drains the BFS queue
- `processChunkGroupsForCombining()` — merges `minAvailableModules` from parent groups
- `processConnectQueue()` — propagates `resultingAvailableModules` to child groups
- `processChunkGroupsForMerging()` — intersection of available module sets
- `processOutdatedChunkGroupInfo()` — re-queues groups whose availability shrunk

### Phase 2: `connectChunkGroups` (line 1340)

**`connectChunkGroups(compilation, blocksWithNestedBlocks, blockConnections, maskByChunk)`**

Walks every async block, checks whether its target `ChunkGroup` is already fully contained in the parent (using the bitmask), and calls `chunkGroup.addParent(parentGroup)` / `chunkGroup.addChild(childGroup)` to wire the tree. Eliminates duplicate chunks.

### Phase 3: `cleanupUnconnectedGroups` (called at end)

Removes `ChunkGroup` nodes that are unreachable, releasing them from `compilation.chunkGroups`.

---

## 12. `ChunkGraph` — the chunk/module bipartite index

**`lib/ChunkGraph.js` — `class ChunkGraph`**

Two complementary maps:

```
_chunks  WeakMap<Chunk, ChunkGraphChunk>
             .modules    SortableSet<Module>
             .entryModules
             .runtimes
_modules WeakMap<Module, ChunkGraphModule>
             .chunks     SortableSet<Chunk>
             .runtimes   Set<RuntimeSpec>
```

Key methods:
- `connectChunkAndModule(chunk, module)` — adds to both maps; called during `visitModules`
- `connectChunkAndEntryModule(chunk, module, entrypoint)` — also tracks entry point
- `getChunkModules(chunk)` → `SortableSet<Module>`
- `getModuleChunks(module)` → `SortableSet<Chunk>`
- `getModuleHash(module, runtime)` / `getModuleId(module)` — used in codegen
- `isModuleInChunk(module, chunk)` — O(1) via the bitmask approach in `buildChunkGraph`

---

## 13. Optimization plugins (seal phase hooks)

**SplitChunksPlugin** — `lib/optimize/SplitChunksPlugin.js`

Taps `compilation.hooks.optimizeChunks` (stage ADVANCED, line ~150 of the plugin). Algorithm:

1. Iterates all modules in all chunks, scores them against cache groups (`vendors`, `default`, custom).
2. For groups meeting `minChunks`, `minSize`, `maxSize` thresholds, calls `compilation.addChunk(key)` and `chunkGraph.connectChunkAndModule()` to move shared modules into new split chunks.
3. Removes moved modules from their original chunks.
4. Handles max-size splitting by further subdividing generated chunks.

**ModuleConcatenationPlugin** — taps `optimizeChunkModules`; merges harmony-module groups into a single `ConcatenatedModule`.

**MangleExportsPlugin** / **FlagDependencyUsagePlugin** — tap `optimizeDependencies`; prune unused exports from `ExportsInfo`.

---

## 14. Code generation

**`lib/Compilation.js:3911` — `codeGeneration(callback)`**

Creates `this.codeGenerationResults = new CodeGenerationResults(...)`, then builds a `jobs[]` array: for each module, for each `(runtime)` tuple it belongs to, one job `{ module, hash, runtime, runtimes }`. Calls:

**`lib/Compilation.js` — `_runCodeGenerationJobs(jobs, callback)`**

Runs jobs in parallel via `asyncLib.each`. For each job calls `module.codeGeneration({ dependencyTemplates, runtimeTemplate, moduleGraph, chunkGraph, runtime })`.

**`lib/NormalModule.js` — `codeGeneration(context)`** (approximately line 2000+)

Retrieves the `Generator` (set during factory resolution — `JavascriptGenerator` for JS modules). Calls `generator.generate(module, { dependencyTemplates, runtimeTemplate, moduleGraph, chunkGraph, runtime, ... })`.

**`lib/javascript/JavascriptGenerator.js` — `generate(module, generateContext)`**

Builds the module's source by:
1. Starting from the raw `_source` stored during `build()`.
2. Applying each `Dependency`'s template: each `HarmonyImportDependency` calls its `HarmonyImportDependencyTemplate.apply()`, which rewrites `import` statements into `__webpack_require__()` calls using `ReplaceSource`.
3. Wrapping with the module factory iife pattern.
4. Returns `CodeGenerationResult { sources: Map<SourceType, Source> }`.

---

## 15. `createChunkAssets()` — rendering chunks to sources

**`lib/Compilation.js:3841` (call site) — `createChunkAssets(callback)`**

For each chunk:

1. Fires `compilation.hooks.renderManifest` (SyncWaterfallHook, declared at line 1087) — plugins push `RenderManifestEntry` objects: `{ render(), filename, info, ... }`.
2. **`JavascriptModulesPlugin`** adds the primary entry via its tap on `renderManifest` — its `render()` function calls **`renderChunk()`** or **`renderMain()`** (hooks at lines 461–462 of the plugin).

Inside `JavascriptModulesPlugin.renderChunk() / renderMain()`:

- `renderModuleContent` (SyncWaterfallHook) — transforms `CodeGenerationResult.sources.get("javascript")` per module
- `renderModuleContainer` — wraps with the module-factory wrapper (`/***/ (function(module, exports, __webpack_require__)`)
- `renderModulePackage` — adds module identifier comment
- Assembles all modules into a `ConcatSource` using `Template.renderChunkModules()`
- `renderMain` adds the webpack bootstrap runtime (module registry `__webpack_modules__`, `__webpack_require__`, runtime chunk startup)
- `render` / `renderContent` hooks let plugins further process the full chunk source

3. `this.emitAsset(filename, source, assetInfo)` registers each rendered source under `compilation.assets[filename]`.

---

## 16. `processRuntimeRequirements()` and runtime modules

Between code generation and hashing, `processRuntimeRequirements()` collects what `RuntimeGlobals` symbols each module declared (e.g., `__webpack_require__`, `__webpack_exports__`). For each chunk it fires:

- `hooks.additionalModuleRuntimeRequirements` → `hooks.runtimeRequirementInModule` (HookMap)
- `hooks.additionalChunkRuntimeRequirements` → `hooks.runtimeRequirementInChunk` (HookMap)
- `hooks.additionalTreeRuntimeRequirements` → `hooks.runtimeRequirementInTree` (HookMap)

Each requirement maps to a `RuntimeModule` subclass (e.g., `PublicPathRuntimeModule`, `RuntimeIdRuntimeModule`, `ChunkLoadingRuntimeModule`). These are added to the runtime chunk and participate in `createHash()`.

---

## 17. Hashing — `createHash()`

**`lib/Compilation.js:3763` — `const codeGenerationJobs = this.createHash()`**

Fires `hooks.beforeHash`, then for each chunk:

1. `hooks.chunkHash` — plugins add chunk-specific content to the hash.
2. `hooks.contentHash` — computes the per-chunk content hash for filename interpolation (`[contenthash]`).
3. `hooks.fullHash` — the full compilation hash.

Returns any deferred code-generation jobs (modules whose generated code depends on the final hash, e.g., `RealContentHashPlugin`). These are run in `_runCodeGenerationJobs()` after hashing.

---

## 18. `processAssets` — late asset transformation

**`hooks.processAssets` (AsyncSeriesHook, declared at line 1077)** runs after `createChunkAssets`. Stages (constants on `Compilation`):

| Stage | Value | Purpose |
|-------|-------|---------|
| `ADDITIONAL` | -2000 | Extra generated files |
| `PRE_PROCESS` | -1000 | Size reporting |
| `DERIVED` | -200 | Source map generation |
| `ADDITIONS` | -100 | Banners, license comments |
| `OPTIMIZE` | 100 | Minimizers (TerserPlugin) |
| `OPTIMIZE_COUNT` | 200 | Gzip stats |
| `OPTIMIZE_COMPATIBILITY` | 300 | Old browser compat |
| `OPTIMIZE_SIZE` | 400 | Size budget check |
| `DEV_TOOLING` | 500 | Source map finalization |
| `OPTIMIZE_INLINE` | 700 | Inline resources |
| `SUMMARIZE` | 1000 | Stats summaries |
| `ANALYSE` | 2000 | Analysis plugins |
| `REPORT` | 5000 | Final reports |

---

## 19. `Compiler.emitAssets()` — writing to disk

**`lib/Compiler.js:746` — `emitAssets(compilation, callback)`**

1. Fires `hooks.emit.callAsync(compilation)` (line 199) — last chance to modify `compilation.assets`.
2. `const emitFiles = (err) => {...}` (line 755) — the actual write loop:
   - Iterates `compilation.getAssets()` via `asyncLib.forEachLimit(..., 15, ...)` — 15 concurrent writes.
   - Strips `?` / `#` query strings from filenames for the actual path.
   - Checks `_assetEmittingSourceCache` — if the same `Source` was already written, compares timestamps to skip redundant writes.
   - Checks `_assetEmittingWrittenFiles` for de-duplication across assets.
   - For non-immutable files: reads existing file, compares with new content; skips write if identical.
   - For immutable files (`[contenthash]` in name): can skip entirely if already present.
   - Calls `outputFileSystem.writeFile(targetPath, content, callback)` (line ~893) — the actual FS write.
   - After each file: fires `hooks.assetEmitted.callAsync(file, { source, outputPath, ... })`.
3. After all files: fires `hooks.afterEmit.callAsync(compilation)`.

`compilation.finish()` (called by `compile()` before `seal()`) calls `hooks.finishModules` and reports dependency errors/warnings collected during build.

---

## 20. Architecture Diagram

```
webpack(config)
│
├─ createCompiler()                        [webpack.js:81]
│  ├─ new Compiler(context, options)       [Compiler.js:175]
│  ├─ NodeEnvironmentPlugin.apply()        (wires FS)
│  ├─ user plugins.apply()
│  └─ WebpackOptionsApply.process()        [WebpackOptionsApply.js:99]
│     └─ registers 50+ built-in plugins via .apply(compiler)
│
compiler.run()                             [Compiler.js:539]
│
├─ hooks.beforeRun / run
├─ readRecords()
└─ compile()                               [Compiler.js:1403]
   │
   ├─ newCompilationParams()               [Compiler.js:1390]
   │  ├─ new NormalModuleFactory(...)      [NormalModuleFactory.js:381]
   │  └─ new ContextModuleFactory(...)     [ContextModuleFactory.js:54]
   │
   ├─ hooks.beforeCompile / compile
   ├─ newCompilation()                     → hooks.thisCompilation, hooks.compilation
   │
   ╔══════════════════════════════════════════════════════════╗
   ║  MAKE PHASE  hooks.make (AsyncParallelHook)              ║
   ║  [Compiler.js:1415]                                      ║
   ║                                                          ║
   ║  EntryPlugin.tap("make") →                               ║
   ║    compilation.addEntry()            [Compilation.js:2645]║
   ║      _addEntryItem()                 [Compilation.js:2682]║
   ║        addModuleTree()               [Compilation.js:2591]║
   ║          handleModuleCreation()      [Compilation.js:2298]║
   ║            │                                             ║
   ║            ├─ factorizeModule()      [Compilation.js:2271]║
   ║            │    └─ NormalModuleFactory.create()          ║
   ║            │         hooks.factorize → hooks.resolve     ║
   ║            │         → enhanced-resolve (path + loaders) ║
   ║            │         → hooks.afterResolve                ║
   ║            │         → hooks.createModule / createModuleClass║
   ║            │         → new JavascriptModule / NormalModule║
   ║            │                                             ║
   ║            ├─ addModule()            (dedup + graph reg) ║
   ║            │    moduleGraph.setResolvedModule()          ║
   ║            │                                             ║
   ║            └─ buildModule()          [Compilation.js:2500]║
   ║                 hooks.buildModule                        ║
   ║                 NormalModule.build() [NormalModule.js:1779]║
   ║                 │                                       ║
   ║                 ├─ _doBuild()        [NormalModule.js:1468]║
   ║                 │   _createLoaderContext()               ║
   ║                 │   runLoaders()     (loader-runner)     ║
   ║                 │   createSource()   (webpack-sources)   ║
   ║                 │                                       ║
   ║                 └─ parser.parse()    [NormalModule.js:1975]║
   ║                     JavascriptParser (acorn AST walk)    ║
   ║                     → emits Dependency objects           ║
   ║                     → module.dependencies[]              ║
   ║                     → module.blocks[] (async imports)    ║
   ║                                                          ║
   ║            processModuleDependencies()  (recurse)        ║
   ║            → back to handleModuleCreation for each dep   ║
   ║                                                          ║
   ║  hooks.finishMake → compilation.finish()                 ║
   ║    hooks.finishModules                                   ║
   ╚══════════════════════════════════════════════════════════╝
   │
   ╔══════════════════════════════════════════════════════════╗
   ║  SEAL PHASE  compilation.seal()      [Compilation.js:3473]║
   ║                                                          ║
   ║  hooks.seal                                              ║
   ║  hooks.optimizeDependencies (loop)   [line 3499]         ║
   ║                                                          ║
   ║  ┌─ Chunk Graph Construction ───────────────────────┐   ║
   ║  │  hooks.beforeChunks                  [line 3506]  │   ║
   ║  │  moduleGraph.freeze("seal")                       │   ║
   ║  │  for each entry:                                  │   ║
   ║  │    addChunk(name)                                 │   ║
   ║  │    new Entrypoint()                               │   ║
   ║  │    chunkGraph.connectChunkAndEntryModule()        │   ║
   ║  │  buildChunkGraph(this, chunkGraphInit) [line 3656]│   ║
   ║  │  ┌─ visitModules ──────────────────────────────┐ │   ║
   ║  │  │  BFS queue over ModuleGraph                 │ │   ║
   ║  │  │  chunkGraph.connectChunkAndModule()         │ │   ║
   ║  │  │  async blocks → new ChunkGroup (deferred)   │ │   ║
   ║  │  │  bigint bitmasks for available-module skip  │ │   ║
   ║  │  └─────────────────────────────────────────────┘ │   ║
   ║  │  connectChunkGroups()             [bcg.js:1340]   │   ║
   ║  │  cleanupUnconnectedGroups()                       │   ║
   ║  │  hooks.afterChunks                [line 3657]     │   ║
   ║  └───────────────────────────────────────────────────┘   ║
   ║                                                          ║
   ║  ┌─ Optimization Pipeline ─────────────────────────┐    ║
   ║  │  hooks.optimizeModules (loop)     [line 3663]   │    ║
   ║  │  hooks.optimizeChunks  (loop)     [line 3668]   │    ║
   ║  │    SplitChunksPlugin taps here                  │    ║
   ║  │  hooks.optimizeTree   (async)     [line 3673]   │    ║
   ║  │  hooks.optimizeChunkModules (async)[line 3682]  │    ║
   ║  │    ModuleConcatenationPlugin taps here          │    ║
   ║  └─────────────────────────────────────────────────┘    ║
   ║                                                          ║
   ║  ┌─ ID Assignment ─────────────────────────────────┐    ║
   ║  │  hooks.moduleIds  → DeterministicModuleIdsPlugin│    ║
   ║  │  hooks.chunkIds   → DeterministicChunkIdsPlugin │    ║
   ║  │  assignRuntimeIds()                             │    ║
   ║  └─────────────────────────────────────────────────┘    ║
   ║                                                          ║
   ║  ┌─ Module Hashing ────────────────────────────────┐    ║
   ║  │  createModuleHashes()             [line 3742]   │    ║
   ║  └─────────────────────────────────────────────────┘    ║
   ║                                                          ║
   ║  ┌─ Code Generation ───────────────────────────────┐    ║
   ║  │  codeGeneration()                 [line 3748]   │    ║
   ║  │    _runCodeGenerationJobs()                     │    ║
   ║  │    per module × runtime:                        │    ║
   ║  │      NormalModule.codeGeneration()              │    ║
   ║  │      JavascriptGenerator.generate()             │    ║
   ║  │        Dependency templates rewrite source      │    ║
   ║  │        ReplaceSource patches import/export      │    ║
   ║  └─────────────────────────────────────────────────┘    ║
   ║                                                          ║
   ║  ┌─ Runtime Requirements ──────────────────────────┐    ║
   ║  │  processRuntimeRequirements()     [line 3757]   │    ║
   ║  │    RuntimeGlobals → RuntimeModule instances     │    ║
   ║  └─────────────────────────────────────────────────┘    ║
   ║                                                          ║
   ║  ┌─ Hashing ───────────────────────────────────────┐    ║
   ║  │  createHash()                     [line 3763]   │    ║
   ║  │    hooks.chunkHash / contentHash / fullHash     │    ║
   ║  └─────────────────────────────────────────────────┘    ║
   ║                                                          ║
   ║  ┌─ Asset Creation ────────────────────────────────┐    ║
   ║  │  createModuleAssets()             [line 3785]   │    ║
   ║  │  createChunkAssets()              [line 3841]   │    ║
   ║  │    hooks.renderManifest (per chunk)             │    ║
   ║  │    JavascriptModulesPlugin renders:             │    ║
   ║  │      renderModuleContent / Container / Package  │    ║
   ║  │      renderChunk / renderMain                   │    ║
   ║  │      Template.renderChunkModules()              │    ║
   ║  │      webpack bootstrap runtime iife             │    ║
   ║  │    compilation.emitAsset(filename, source)      │    ║
   ║  │  hooks.processAssets (staged, async)            │    ║
   ║  │    TerserPlugin minimizes at OPTIMIZE stage     │    ║
   ║  │    SourceMapDevToolPlugin at DEV_TOOLING stage  │    ║
   ║  └─────────────────────────────────────────────────┘    ║
   ║                                                          ║
   ║  hooks.afterSeal                                         ║
   ╚══════════════════════════════════════════════════════════╝
   │
   hooks.afterCompile
   │
   ╔══════════════════════════════════════════════════════════╗
   ║  EMIT PHASE  compiler.emitAssets()   [Compiler.js:746]  ║
   ║                                                          ║
   ║  hooks.emit (last chance to modify assets)               ║
   ║  asyncLib.forEachLimit(assets, 15, ...)                  ║
   ║  │  per asset:                                          ║
   ║  │    resolve targetPath via outputFileSystem            ║
   ║  │    check _assetEmittingSourceCache (skip if same)     ║
   ║  │    compare file content (skip if unchanged)           ║
   ║  │    outputFileSystem.writeFile(targetPath, buf)        ║
   ║  │    hooks.assetEmitted(file, info)                     ║
   ║  hooks.afterEmit                                         ║
   ╚══════════════════════════════════════════════════════════╝
   │
   emitRecords()
   hooks.done.callAsync(stats)      ← Stats object built from Compilation
   hooks.afterDone.call(stats)
```

---

## Key data-structure summary

| Structure | File | Role |
|-----------|------|------|
| `Compiler` | `Compiler.js:175` | Owns the run lifecycle, hooks, factories |
| `Compilation` | `Compilation.js` | One build pass: modules, chunks, assets, all hooks |
| `ModuleGraph` | `ModuleGraph.js:140` | Dep→module map, connections, exports info |
| `ModuleGraphModule` | `ModuleGraph.js:96` | Per-module metadata: in/out connections, issuer, exports |
| `ModuleGraphConnection` | `ModuleGraphConnection.js` | One edge: originModule → module via dependency |
| `ChunkGraph` | `ChunkGraph.js` | Chunk↔module bipartite index + runtime requirements |
| `NormalModule` | `NormalModule.js:~830` | A single source file: loaders, parser, generator, deps |
| `Chunk` | `Chunk.js` | A bundle output unit: id, modules, groups |
| `ChunkGroup` | `ChunkGroup.js` | Ordered list of chunks (entrypoint or async split) |
| `Entrypoint` | `Entrypoint.js` | ChunkGroup for entry points; holds runtime chunk ref |
| `Dependency` | `Dependency.js` | Base for import/require/export edges |
| `ExportsInfo` | `ExportsInfo.js` | Per-module export visibility for tree-shaking |
| `CodeGenerationResults` | `Compilation.js` | Map of module×runtime → generated Source + runtime reqs |
