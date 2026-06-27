# transcript: Give a complete architectural walkthrough of webpack's full compilation lifecycle from configuration to emitted assets — the cross-cutting build architecture...


💬 I'll use grove to map the full architecture systematically, starting with the top-level dependency graph and then drilling into each phase.
  ▸ ToolSearch(select:mcp__grove__map,mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition)

💬 Now let me run parallel grove explorations across all major subsystems simultaneously.
  ▸ mcp__grove__outline({"file":"lib/Compiler.js","detail":1})
  ▸ mcp__grove__outline({"file":"lib/Compilation.js","detail":0})
  ▸ mcp__grove__outline({"file":"lib/webpack.js","detail":1})
  ▸ mcp__grove__outline({"file":"lib/WebpackOptionsApply.js","detail":0})

💬 Good. Now I'll read the key methods in parallel across all phases.
  ▸ mcp__grove__source({"id":"javascript:lib/webpack.js#createCompiler@81"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compiler.js#run@539"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compiler.js#compile@1403"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compiler.js#newCompilation@1361"})

💬 Now the seal, finish, and make-phase entry points in parallel.
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#seal@3473"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#finish@3171"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compiler.js#emitAssets@746"})
  ▸ mcp__grove__outline({"file":"lib/EntryPlugin.js","detail":1})
  ▸ mcp__grove__outline({"file":"lib/NormalModuleFactory.js","detail":0})

💬 Now let me pull the make-phase core and the graph/codegen systems in parallel.
  ▸ mcp__grove__source({"id":"javascript:lib/EntryPlugin.js#apply@33"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#handleModuleCreation@2298"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_processModuleDependencies@1780"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#processRuntimeRequirements@4159"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#createChunkAssets@5522"})
  ▸ mcp__grove__outline({"file":"lib/NormalModule.js","detail":0})

💬 Now I have enough for the full picture. Let me grab the final three load-bearing implementations.
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#build@1779"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#_doBuild@1468"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModuleFactory.js#create@1011"})
  ▸ mcp__grove__outline({"file":"lib/optimize/buildChunkGraph.js","detail":0})
  ▸ mcp__grove__outline({"file":"lib/WebpackOptionsApply.js","detail":1})

💬 Let me grab the buildChunkGraph entry and ChunkGraph/ModuleGraph outlines.
  ▸ mcp__grove__symbols({"dir":"lib/optimize","name":"buildChunkGraph"})
  ▸ mcp__grove__outline({"file":"lib/ModuleGraph.js","detail":0})
  ▸ mcp__grove__outline({"file":"lib/ChunkGraph.js","detail":0})

💬 I now have everything. Here is the complete architectural walkthrough.  ---  # webpack Compilation Lifecycle: Complete Architectural Walkthrough  ---  ## Pha...

──────── RESULT (success, 293933ms, 29 turns) ────────
I now have everything. Here is the complete architectural walkthrough.

---

# webpack Compilation Lifecycle: Complete Architectural Walkthrough

---

## Phase 0 — Initialization (`lib/webpack.js`, `lib/WebpackOptionsApply.js`)

### `webpack()` → `createCompiler()` · `lib/webpack.js:81`

The public `webpack(options, callback)` function calls `createCompiler(rawOptions)`, which is the true entry point.

| Step | Call | Location |
|------|------|----------|
| 1 | `getNormalizedWebpackOptions(rawOptions)` | normalizes config shape |
| 2 | `applyWebpackOptionsBaseDefaults(options)` | sets `context`, `infrastructureLogging` |
| 3 | `new Compiler(context, options)` | `lib/Compiler.js:175` |
| 4 | `new NodeEnvironmentPlugin().apply(compiler)` | wires `inputFileSystem`, `outputFileSystem`, `watchFileSystem` |
| 5 | user `options.plugins[].apply(compiler)` | each plugin taps `compiler.hooks.*` |
| 6 | `applyWebpackOptionsDefaults(options)` | fills remaining defaults (mode, devtool, output, etc.) |
| 7 | `compiler.hooks.environment.call()` | |
| 8 | `compiler.hooks.afterEnvironment.call()` | |
| 9 | `new WebpackOptionsApply().process(options, compiler)` | `lib/WebpackOptionsApply.js:99` |
| 10 | `compiler.hooks.initialize.call()` | |

### `WebpackOptionsApply.process()` · `lib/WebpackOptionsApply.js:99`

This single ~900-line method installs every built-in plugin that implements webpack's defaults. Key installations (in order):

- **Module type plugins**: `JavascriptModulesPlugin`, `JsonModulesPlugin`, `AssetModulesPlugin`, `CssModulesPlugin` — each taps `compiler.hooks.compilation` to register parsers, generators, and render hooks
- **Entry plugins**: one `EntryPlugin` per `options.entry.*` — each taps `compiler.hooks.make`
- **Optimization plugins** (conditional on `options.optimization.*`):
  - `SplitChunksPlugin` → `compilation.hooks.optimizeChunks`
  - `ModuleConcatenationPlugin` → `compilation.hooks.optimizeChunkModules`
  - `FlagDependencyExportsPlugin` + `FlagDependencyUsagePlugin` → `compilation.hooks.finishModules`
  - `TerserPlugin` (if minimizer) → `compilation.hooks.processAssets`
- **ID plugins**: `DeterministicModuleIdsPlugin`, `DeterministicChunkIdsPlugin`, `NamedModuleIdsPlugin` — tap `compilation.hooks.moduleIds`, `chunkIds`
- **Runtime**: `RuntimeChunkPlugin`, `RuntimePlugin`
- **Hashing**: `RealContentHashPlugin`, `FullHashModulePlugin`
- **Record tracking**: `RecordIdsPlugin` → `compilation.hooks.reviveModules`, `recordModules`
- **Output**: `TemplatedPathPlugin`, `SourceMapDevToolPlugin` (conditional)

---

## Phase 1 — Run · `Compiler.run()` · `lib/Compiler.js:539`

```
Compiler.run(callback)
  ├─ cache.endIdle()                           // warm up persistent cache
  ├─ hooks.beforeRun.callAsync(compiler)       // CachePlugin restores cache here
  ├─ hooks.run.callAsync(compiler)
  ├─ readRecords()   lib/Compiler.js:1180      // load records.json for stable IDs
  └─ compile(onCompiled)
```

On completion, `onCompiled` checks `hooks.shouldEmit`, then calls `emitAssets()`, then `emitRecords()`, then fires `hooks.done` (Stats), `cache.storeBuildDependencies()`, `hooks.afterDone`, and the user callback.

---

## Phase 2 — Compile · `Compiler.compile()` · `lib/Compiler.js:1403`

```
Compiler.compile(callback)
  ├─ newCompilationParams()   lib/Compiler.js:1390
  │    ├─ createNormalModuleFactory()   → new NormalModuleFactory(...)
  │    └─ createContextModuleFactory()  → new ContextModuleFactory(...)
  ├─ hooks.beforeCompile.callAsync(params)    // DllReferencePlugin, etc.
  ├─ hooks.compile.call(params)              // synchronous
  ├─ newCompilation(params)   lib/Compiler.js:1361
  │    ├─ createCompilation(params)   → new Compilation(compiler)
  │    ├─ hooks.thisCompilation.call(compilation, params)
  │    └─ hooks.compilation.call(compilation, params)
  │         └─ EntryPlugin installs:
  │              compilation.dependencyFactories.set(EntryDependency, normalModuleFactory)
  ├─ hooks.make.callAsync(compilation)        // ← MAKE PHASE begins here
  ├─ hooks.finishMake.callAsync(compilation)
  ├─ compilation.finish(cb)
  ├─ compilation.seal(cb)
  └─ hooks.afterCompile.callAsync(compilation)
```

---

## Phase 3 — Make (Module Graph) · `lib/Compilation.js`

### Entry point: `EntryPlugin.apply()` · `lib/EntryPlugin.js:33`

```js
compiler.hooks.make.tapAsync(PLUGIN_NAME, (compilation, callback) => {
    compilation.addEntry(context, dep, options, callback);
});
```

### Full module discovery chain

```
compilation.addEntry()   lib/Compilation.js:2645
  └─ _addEntryItem()    lib/Compilation.js:2682
       └─ addModuleTree()  lib/Compilation.js:2591
            └─ addModuleChain()  lib/Compilation.js:2578
                 └─ handleModuleCreation()  lib/Compilation.js:2298
```

### `handleModuleCreation()` · `lib/Compilation.js:2298`

The workhorse of the make phase. For every dependency group:

```
handleModuleCreation({ factory, dependencies, originModule, ... })
  ├─ factorizeModule()   lib/Compilation.js:2271
  │    └─ [factorizeQueue] → _factorizeModule()  lib/Compilation.js:2171
  │         └─ factory.create(data, callback)    // NormalModuleFactory.create()
  │
  ├─ addModule()   lib/Compilation.js:1585
  │    └─ [addModuleQueue] → _addModule()  lib/Compilation.js:1596
  │         └─ dedup via this._modules Map<identifier, Module>
  │              moduleGraph.setResolvedModule(originModule, dep, module)
  │
  └─ _handleModuleBuildAndDependencies()  lib/Compilation.js:2449
       ├─ buildModule()  lib/Compilation.js:1660
       │    └─ [buildQueue] → _buildModule()  lib/Compilation.js:1670
       │         └─ module.build(options, compilation, resolver, fs, cb)
       │
       └─ processModuleDependencies()  lib/Compilation.js:1745
            └─ [processDependenciesQueue] → _processModuleDependencies()  lib/Compilation.js:1780
                 └─ for each dep in module.dependencies + module.blocks:
                      processDependencyForResolving(dep)
                        → groups by (factory, resourceIdent)
                        → sortedDependencies[]
                 └─ for each group: handleModuleCreation(...)  ← RECURSIVE
```

The four `AsyncQueue` instances (`factorizeQueue`, `addModuleQueue`, `buildQueue`, `processDependenciesQueue`) bound-concurrency on each stage independently. The dependency traversal is breadth-first through async import blocks and depth-first within synchronous imports.

### `NormalModuleFactory.create()` · `lib/NormalModuleFactory.js:1011`

```
NormalModuleFactory.create(data, callback)
  ├─ hooks.beforeResolve.callAsync(resolveData)   // IgnorePlugin short-circuits here
  ├─ hooks.factorize.callAsync(resolveData)
  │    └─ defaultResolve()  lib/NormalModuleFactory.js:904
  │         ├─ resolveResource()   lib/NormalModuleFactory.js:1123
  │         │    └─ resolver.resolve(context, request)   // enhanced-resolve
  │         │         → handles aliasing, mainFields, extensions, symlinks
  │         ├─ resolveRequestArray()  lib/NormalModuleFactory.js:1323
  │         │    └─ resolves each loader path via loaderResolver
  │         └─ hooks.resolve → builds createData:
  │              { resource, loaders[], parser, generator, resolveOptions }
  ├─ hooks.afterResolve.callAsync(resolveData)
  ├─ hooks.createModule.callAsync(createData)      // → new NormalModule(createData)
  └─ returns ModuleFactoryResult { module, fileDependencies, ... }
```

### `NormalModule.build()` · `lib/NormalModule.js:1779`

```
NormalModule.build(options, compilation, resolver, fs, callback)
  ├─ reset: _source=null, _ast=null, buildMeta={}, buildInfo={}, deps=[], blocks=[]
  ├─ _doBuild()   lib/NormalModule.js:1468
  │    ├─ _createLoaderContext()  lib/NormalModule.js:1149
  │    │    → loaderContext: { emitFile, addDependency, resolve, fs, ... }
  │    └─ runLoaders({ resource, loaders, context: loaderContext })
  │         (loader-runner package)
  │         ├─ pitch phase: each loader left→right (if loader.pitch defined)
  │         ├─ readResource: hooks.readResource.for(scheme).callAsync(loaderContext)
  │         │    → reads file bytes from inputFileSystem
  │         ├─ normal phase: each loader right→left (transform)
  │         │    → each loader fn receives (source, sourceMap?, data?)
  │         │    → returns [source, sourceMap?, extraInfo?]
  │         └─ processResult(): createSource() → OriginalSource | SourceMapSource
  │
  ├─ hooks.beforeParse.call(this)
  ├─ shouldPreventParsing(noParse, request) → if true, skip parser
  ├─ parser.parse(source | ast, state)
  │    JavascriptParser (lib/javascript/JavascriptParser.js)
  │    ├─ acorn.parse() → ESTree AST
  │    └─ walk: hooks per node type (importDeclaration, callExpression, etc.)
  │         → creates HarmonyImportDependency, CommonJsDependency, etc.
  │         → attaches to module.dependencies[] (sync) / module.blocks[] (async)
  │
  └─ handleBuildDone():
       fileSystemInfo.createSnapshot(startTime, fileDeps, contextDeps, missingDeps)
       → buildInfo.snapshot (used for cache invalidation in watch mode)
```

**`ModuleGraph`** (`lib/ModuleGraph.js:140`) accumulates the result: it stores per-`Dependency` the resolved `Module`, and per-`Module` its incoming/outgoing `ModuleGraphConnection` edges, issuer, exports info, pre/post-order indices, depth, and profiling data.

---

## Phase 4 — Finish · `Compilation.finish()` · `lib/Compilation.js:3171`

After all modules are built and their transitive graph is complete:

```
compilation.finish(callback)
  ├─ factorizeQueue.clear()
  ├─ [profile mode] ParallelismFactorCalculator — build timing report
  ├─ _computeAffectedModules(modules)   lib/Compilation.js:2815
  │    → compares buildInfo.hash per module to detect changed set (incremental)
  ├─ hooks.finishModules.callAsync(modules)
  │    ├─ FlagDependencyExportsPlugin → fills moduleGraph.getExportsInfo(m).providedExports
  │    ├─ InferAsyncModulesPlugin → marks modules with top-level-await
  │    └─ other analysis plugins
  ├─ moduleGraph.freeze("dependency errors")
  └─ per module: reportDependencyErrorsAndWarnings()
       → collects module.getErrors() / getWarnings() into compilation.errors/warnings
```

---

## Phase 5 — Seal · `Compilation.seal()` · `lib/Compilation.js:3473`

The longest phase. Organized into six sub-phases:

### 5a · Chunk graph creation

```
hooks.seal.call()
while hooks.optimizeDependencies.call(modules)   // FlagDependencyUsagePlugin: tree-shake
hooks.afterOptimizeDependencies

moduleGraph.freeze("seal")

for each entry in this.entries:
  addChunk(name)                     lib/Compilation.js:4448
  new Entrypoint(options)
  chunkGraph.connectChunkAndEntryModule(chunk, module, entrypoint)
  assignDepths(entryModules)         lib/Compilation.js:4509

buildChunkGraph(this, chunkGraphInit)  lib/optimize/buildChunkGraph.js
  // BFS over import() blocks; creates async ChunkGroups; populates ChunkGraph
  // ChunkGraph: lib/ChunkGraph.js:281
  //   connectChunkAndModule(), connectBlockAndChunkGroup(), etc.

hooks.afterChunks.call(chunks)
```

### 5b · Optimization

```
hooks.optimize.call()

while hooks.optimizeModules.call(modules)        // ModuleConcatenationPlugin (scope hoisting)
hooks.afterOptimizeModules

while hooks.optimizeChunks.call(chunks, chunkGroups)   // SplitChunksPlugin
hooks.afterOptimizeChunks

hooks.optimizeTree.callAsync(chunks, modules)    // async tree optimization
hooks.afterOptimizeTree

hooks.optimizeChunkModules.callAsync(chunks, modules)
hooks.afterOptimizeChunkModules
```

### 5c · ID assignment

```
hooks.reviveModules.call(modules, records)       // restore from records.json
hooks.beforeModuleIds → hooks.moduleIds          // DeterministicModuleIdsPlugin
hooks.optimizeModuleIds → hooks.afterOptimizeModuleIds

hooks.reviveChunks.call(chunks, records)
hooks.beforeChunkIds → hooks.chunkIds            // DeterministicChunkIdsPlugin
hooks.optimizeChunkIds → hooks.afterOptimizeChunkIds

assignRuntimeIds()   lib/Compilation.js:4646
_computeAffectedModulesWithChunkGraph()  lib/Compilation.js:2986
sortItemsWithChunkIds()                  lib/Compilation.js:4665
```

### 5d · Module hashing + code generation

```
hooks.beforeModuleHash → createModuleHashes()   lib/Compilation.js:4693
  → per module × runtime: _createModuleHash()   lib/Compilation.js:4764
    → module.updateHash(hash, { chunkGraph, runtime })

hooks.beforeCodeGeneration → codeGeneration()   lib/Compilation.js:3911
  └─ _runCodeGenerationJobs()   lib/Compilation.js:3952
       → per module × runtime: _codeGenerationModule()  lib/Compilation.js:4069
            └─ module.codeGeneration({ dependencyTemplates, runtimeTemplate,
                                       moduleGraph, chunkGraph, runtime })
               NormalModule.codeGeneration()   lib/NormalModule.js:2053
                 └─ per dep: DependencyTemplate.apply(dep, source, ...)
                    e.g. HarmonyImportSpecifierDependency::Template
                         CommonJsRequireDependencyTemplate
                    → returns { sources: Map<type,Source>, runtimeRequirements: Set }
hooks.afterCodeGeneration

processRuntimeRequirements()   lib/Compilation.js:4159
  ├─ per module × runtime:
  │    codeGenerationResults.getRuntimeRequirements(module, runtime)
  │    hooks.additionalModuleRuntimeRequirements + hooks.runtimeRequirementInModule
  │    → chunkGraph.addModuleRuntimeRequirements(module, runtime, set)
  ├─ per chunk:
  │    union all module requirements
  │    hooks.additionalChunkRuntimeRequirements + hooks.runtimeRequirementInChunk
  │    → chunkGraph.addChunkRuntimeRequirements(chunk, set)
  └─ per entry (tree root):
       union all chunk requirements
       hooks.additionalTreeRuntimeRequirements
       hooks.runtimeRequirementInTree.for(r).call(entry, set)
         → RuntimePlugin taps: for each required symbol (e.g. __webpack_require__,
           __webpack_require__.r, publicPath, etc.) → addRuntimeModule(chunk, runtimeModule)
       → chunkGraph.addTreeRuntimeRequirements(entry, set)

hooks.beforeHash → createHash()   lib/Compilation.js:4797
  → per chunk: hash of chunk content + module hashes → chunk.hash, compilation.hash
hooks.afterHash

_runCodeGenerationJobs(codeGenerationJobs)   // second pass for full-hash modules
```

### 5e · Asset creation

```
createModuleAssets()   lib/Compilation.js:5483
  → for modules with buildInfo.assets: emitAsset(name, source)

hooks.beforeChunkAssets → createChunkAssets()   lib/Compilation.js:5522
  asyncLib.forEachLimit(chunks, 15):
    getRenderManifest({ chunk, hash, ... })   lib/Compilation.js:5513
      → hooks.renderManifest.call([], options)
        JavascriptModulesPlugin taps: returns [{ render(), filenameTemplate, ... }]
    for each fileManifest:
      _assetsCache.getItemCache(ident, hash).get()   // check render cache
      fileManifest.render()
        → JavascriptModulesPlugin.renderChunk()
             → renderChunkModules() → per module: renderModule()
                  → source from codeGenerationResults.getSource(module, 'javascript')
                  → wraps in DependencyTemplate-applied ReplaceSource
             → wraps in ConcatSource with webpack bootstrap + runtime modules
      emitAsset(file, source, info)   lib/Compilation.js:5106
      _assetsCache.getItemCache(...).store(source)

hooks.processAssets.callAsync(assets)   // PROCESS_ASSETS_STAGE_* ordering
  ├─ SUMMARIZE: SourceMapDevToolPlugin writes .map files
  ├─ OPTIMIZE: TerserPlugin minifies, CssMinimizerPlugin
  └─ REPORT: real-content-hash plugin substitutes hashes in filenames

hooks.afterProcessAssets
this.assets = Object.freeze(this.assets)   // sealed from here on
summarizeDependencies()   lib/Compilation.js:4675
hooks.afterSeal.callAsync()
```

---

## Phase 6 — Emit · `Compiler.emitAssets()` · `lib/Compiler.js:746`

```
Compiler.emitAssets(compilation, callback)
  ├─ hooks.emit.callAsync(compilation)   // last plugin chance; CopyPlugin runs here
  ├─ outputPath = compilation.getPath(this.outputPath, {})
  ├─ mkdirp(outputFileSystem, outputPath)
  └─ asyncLib.forEachLimit(compilation.getAssets(), 15):
       for each { name, source, info }:
         targetPath = join(outputPath, name)
         mkdirp(fs, dirname(targetPath))        // create subdirs as needed
         if immutable && already written same generation → skip
         if options.output.compareBeforeEmit:
           stat(targetPath) → if exists + content equal → skip (preserve mtime)
         else:
           content = source.buffer()            // materialize webpack-sources object
           outputFileSystem.writeFile(targetPath, content)
           compilation.emittedAssets.add(name)
           replace in-memory Source with SizeOnlySource(size) → GC freed
           hooks.assetEmitted.callAsync(name, { content, source, outputPath, ... })
       hooks.afterEmit.callAsync(compilation)

emitRecords()   lib/Compiler.js:1105     // write records.json
  └─ _emitRecords()   lib/Compiler.js:1130

hooks.done.callAsync(new Stats(compilation))
  └─ stats plugins compute output; user callback receives Stats

cache.storeBuildDependencies(compilation.buildDependencies)
hooks.afterDone.call(stats)
finalCallback(null, stats)
```

---

## Unified Architecture Diagram

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║  webpack(options)  lib/webpack.js:188                                           ║
║  createCompiler()  lib/webpack.js:81                                            ║
║  ┌──────────────────────────────────────────────────────────────────────────┐   ║
║  │ getNormalizedWebpackOptions → applyWebpackOptionsBaseDefaults             │   ║
║  │ new Compiler(context, options)              lib/Compiler.js:175          │   ║
║  │ NodeEnvironmentPlugin.apply(compiler)       (fs, watchFs wired)          │   ║
║  │ user plugins[].apply(compiler)                                           │   ║
║  │ applyWebpackOptionsDefaults(options)                                     │   ║
║  │ WebpackOptionsApply.process()               lib/WebpackOptionsApply.js:99│   ║
║  │   └─ installs: EntryPlugin, JavascriptModulesPlugin, SplitChunksPlugin, │   ║
║  │      ModuleConcatenationPlugin, FlagDependencyExportsPlugin,             │   ║
║  │      TerserPlugin, DeterministicModuleIdsPlugin, RuntimePlugin, ...      │   ║
║  │ compiler.hooks.initialize.call()                                         │   ║
║  └──────────────────────────────────────────────────────────────────────────┘   ║
╚══════════════════════════════════════════════════════════════════════════════════╝
                                    │
                                    ▼
╔══════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 1 · RUN      Compiler.run()  lib/Compiler.js:539                        ║
║  ┌──────────────────────────────────────────────────────────────────────────┐   ║
║  │  cache.endIdle()                                                         │   ║
║  │  hooks.beforeRun ──▶ hooks.run ──▶ readRecords() ──▶ compile()          │   ║
║  └──────────────────────────────────────────────────────────────────────────┘   ║
╚══════════════════════════════════════════════════════════════════════════════════╝
                                    │
                                    ▼
╔══════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 2 · COMPILE  Compiler.compile()  lib/Compiler.js:1403                   ║
║  ┌──────────────────────────────────────────────────────────────────────────┐   ║
║  │  newCompilationParams()   → NormalModuleFactory + ContextModuleFactory   │   ║
║  │  hooks.beforeCompile ──▶ hooks.compile                                   │   ║
║  │  newCompilation()         → new Compilation(compiler)                    │   ║
║  │    hooks.thisCompilation ──▶ hooks.compilation                           │   ║
║  │      (plugins install compilation-scoped hooks here)                     │   ║
║  └──────────────────────────────────────────────────────────────────────────┘   ║
╚══════════════════════════════════════════════════════════════════════════════════╝
                                    │ hooks.make.callAsync
                                    ▼
╔══════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 3 · MAKE (Module Graph)    lib/Compilation.js                           ║
║                                                                                  ║
║  EntryPlugin (lib/EntryPlugin.js:33)                                            ║
║    └─▶ compilation.addEntry()   :2645                                           ║
║          └─▶ _addEntryItem()    :2682                                           ║
║                └─▶ addModuleTree() → addModuleChain()                           ║
║                      └─▶ handleModuleCreation()   :2298 ◀──────────────┐        ║
║                                                                          │        ║
║  ┌──────────────────────────────────────────────────────────────────┐   │        ║
║  │ factorizeModule() :2271 ──▶ [factorizeQueue]                     │   │        ║
║  │   └─▶ NormalModuleFactory.create()  lib/NormalModuleFactory.js:1011  │        ║
║  │         ├─ hooks.beforeResolve                                   │   │        ║
║  │         ├─ hooks.factorize → defaultResolve() :904              │   │        ║
║  │         │    ├─ resolveResource()  :1123  (enhanced-resolve)    │   │        ║
║  │         │    └─ resolveRequestArray() :1323 (loader resolution) │   │        ║
║  │         ├─ hooks.afterResolve                                    │   │        ║
║  │         └─ hooks.createModule → new NormalModule(createData)    │   │        ║
║  │                                                                   │   │        ║
║  │ addModule() :1585 ──▶ [addModuleQueue]                           │   │        ║
║  │   └─▶ _addModule() :1596  (dedup Map<identifier,Module>)        │   │        ║
║  │        moduleGraph.setResolvedModule(origin, dep, module)        │   │        ║
║  │         ╔═════ ModuleGraph  lib/ModuleGraph.js:140 ═════╗       │   │        ║
║  │         ║ Dependency → Module mapping                    ║       │   │        ║
║  │         ║ Module → [incomingConnections, outgoing]       ║       │   │        ║
║  │         ║ ExportsInfo per module (providedExports, used) ║       │   │        ║
║  │         ╚═══════════════════════════════════════════════╝       │   │        ║
║  │                                                                   │   │        ║
║  │ buildModule() :1660 ──▶ [buildQueue]                             │   │        ║
║  │   └─▶ NormalModule.build()  lib/NormalModule.js:1779            │   │        ║
║  │         ├─ _doBuild() :1468                                      │   │        ║
║  │         │    ├─ _createLoaderContext() :1149                     │   │        ║
║  │         │    └─ runLoaders() [loader-runner]                     │   │        ║
║  │         │         ├─ pitch phase (left→right)                    │   │        ║
║  │         │         ├─ hooks.readResource → inputFileSystem.read() │   │        ║
║  │         │         ├─ normal phase (right→left transforms)        │   │        ║
║  │         │         └─ processResult() → createSource()            │   │        ║
║  │         └─ parser.parse(source, state)  [JavascriptParser/acorn] │   │        ║
║  │              └─ AST walk → Dependency objects added to           │   │        ║
║  │                   module.dependencies[]  (sync imports)          │   │        ║
║  │                   module.blocks[]        (async import() blocks) │   │        ║
║  │                                                                   │   │        ║
║  │ processModuleDependencies() :1745 ──▶ [processDependenciesQueue] │   │        ║
║  │   └─▶ _processModuleDependencies() :1780                        │   │        ║
║  │         ├─ groups deps by (factory, resourceIdent)               │   │        ║
║  │         └─ per group: handleModuleCreation() ──────────────────────┘        ║
║  └──────────────────────────────────────────────────────────────────┘            ║
╚══════════════════════════════════════════════════════════════════════════════════╝
                                    │ hooks.finishMake
                                    ▼
╔══════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 4 · FINISH   Compilation.finish()  lib/Compilation.js:3171              ║
║  ┌──────────────────────────────────────────────────────────────────────────┐   ║
║  │  _computeAffectedModules()   (incremental: which modules changed)        │   ║
║  │  hooks.finishModules                                                     │   ║
║  │    ├─ FlagDependencyExportsPlugin → moduleGraph providedExports          │   ║
║  │    └─ InferAsyncModulesPlugin → top-level-await marking                  │   ║
║  │  reportDependencyErrorsAndWarnings() per module                          │   ║
║  └──────────────────────────────────────────────────────────────────────────┘   ║
╚══════════════════════════════════════════════════════════════════════════════════╝
                                    │
                                    ▼
╔══════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 5 · SEAL     Compilation.seal()  lib/Compilation.js:3473                ║
║                                                                                  ║
║  ┌─ 5a CHUNK GRAPH ──────────────────────────────────────────────────────────┐  ║
║  │  hooks.optimizeDependencies  (FlagDependencyUsagePlugin: tree-shake)      │  ║
║  │  for each entry → addChunk() + new Entrypoint()                           │  ║
║  │  buildChunkGraph(this, chunkGraphInit)  lib/optimize/buildChunkGraph.js   │  ║
║  │    BFS over import() blocks → async ChunkGroups                           │  ║
║  │    ╔═══════ ChunkGraph  lib/ChunkGraph.js:281 ═══════╗                   │  ║
║  │    ║ Module → Set<Chunk>                              ║                   │  ║
║  │    ║ Chunk → Set<Module>  +  Set<RuntimeModule>       ║                   │  ║
║  │    ║ ChunkGroup → Chunk[]  (entry/async entrypoints)  ║                   │  ║
║  │    ║ RuntimeRequirements per module/chunk/tree        ║                   │  ║
║  │    ╚══════════════════════════════════════════════════╝                   │  ║
║  └───────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                  ║
║  ┌─ 5b OPTIMIZATION ─────────────────────────────────────────────────────────┐  ║
║  │  hooks.optimizeModules  (ModuleConcatenationPlugin: scope hoisting)       │  ║
║  │  hooks.optimizeChunks   (SplitChunksPlugin: split/merge chunks)           │  ║
║  │  hooks.optimizeTree + hooks.optimizeChunkModules                          │  ║
║  └───────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                  ║
║  ┌─ 5c IDs ──────────────────────────────────────────────────────────────────┐  ║
║  │  hooks.moduleIds  (DeterministicModuleIdsPlugin → numeric/named IDs)      │  ║
║  │  hooks.chunkIds   (DeterministicChunkIdsPlugin)                           │  ║
║  │  assignRuntimeIds()                                                       │  ║
║  └───────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                  ║
║  ┌─ 5d CODE GENERATION ──────────────────────────────────────────────────────┐  ║
║  │  createModuleHashes()       per module × runtime → ChunkGraph hashes      │  ║
║  │                                                                            │  ║
║  │  codeGeneration()   :3911                                                 │  ║
║  │    per module × runtime: NormalModule.codeGeneration()  :2053             │  ║
║  │      per Dependency: DependencyTemplate.apply()                           │  ║
║  │        e.g. HarmonyImportSpecifierDependency::Template                    │  ║
║  │             CommonJsRequireDependency::Template                           │  ║
║  │      → ReplaceSource (webpack-sources) with substituted bindings          │  ║
║  │                                                                            │  ║
║  │  processRuntimeRequirements()  :4159                                      │  ║
║  │    module → chunk → entry tree propagation of RuntimeRequirements         │  ║
║  │    hooks.runtimeRequirementInTree.for(r)                                  │  ║
║  │      → RuntimePlugin injects RuntimeModules:                              │  ║
║  │         __webpack_require__, publicPath, chunkLoading, hasOwnProperty ... │  ║
║  │         addRuntimeModule(chunk, new XxxRuntimeModule())  :4300            │  ║
║  │                                                                            │  ║
║  │  createHash()  :4797     chunk hashes + compilation.hash (content-addr.)  │  ║
║  │  _runCodeGenerationJobs()  second pass for full-hash modules               │  ║
║  └───────────────────────────────────────────────────────────────────────────┘  ║
║                                                                                  ║
║  ┌─ 5e ASSETS ───────────────────────────────────────────────────────────────┐  ║
║  │  createModuleAssets()   :5483   (modules with buildInfo.assets)           │  ║
║  │                                                                            │  ║
║  │  createChunkAssets()    :5522                                             │  ║
║  │    asyncLib.forEachLimit(chunks, 15):                                     │  ║
║  │      getRenderManifest() → hooks.renderManifest                           │  ║
║  │        JavascriptModulesPlugin: renderChunk() → renderChunkModules()      │  ║
║  │          per module: source from codeGenerationResults                    │  ║
║  │          + webpack bootstrap ConcatSource + RuntimeModules                │  ║
║  │      emitAsset(filename, CachedSource, info)   :5106                     │  ║
║  │                                                                            │  ║
║  │  hooks.processAssets  (SUMMARIZE→OPTIMIZE→REPORT stages)                 │  ║
║  │    ├─ SourceMapDevToolPlugin → emits .map files                           │  ║
║  │    ├─ TerserPlugin → minifies JS sources                                  │  ║
║  │    └─ RealContentHashPlugin → replaces [contenthash] in filenames         │  ║
║  │                                                                            │  ║
║  │  assets = Object.freeze(assets)                                           │  ║
║  │  hooks.afterSeal                                                          │  ║
║  └───────────────────────────────────────────────────────────────────────────┘  ║
╚══════════════════════════════════════════════════════════════════════════════════╝
                                    │
                                    ▼
╔══════════════════════════════════════════════════════════════════════════════════╗
║  PHASE 6 · EMIT     Compiler.emitAssets()  lib/Compiler.js:746                 ║
║  ┌──────────────────────────────────────────────────────────────────────────┐   ║
║  │  hooks.emit.callAsync(compilation)   (CopyPlugin etc.)                   │   ║
║  │  mkdirp(outputFileSystem, outputPath)                                    │   ║
║  │  asyncLib.forEachLimit(assets, 15):                                      │   ║
║  │    ├─ immutable + same generation  →  skip (watch mode optimisation)     │   ║
║  │    ├─ compareBeforeEmit + stat()   →  read+compare, skip if equal        │   ║
║  │    └─ outputFileSystem.writeFile(targetPath, source.buffer())            │   ║
║  │         compilation.emittedAssets.add(name)                              │   ║
║  │         replace Source → SizeOnlySource   (free heap)                   │   ║
║  │         hooks.assetEmitted.callAsync(name, { content, ... })             │   ║
║  │  hooks.afterEmit.callAsync(compilation)                                  │   ║
║  │                                                                           │   ║
║  │  emitRecords()   lib/Compiler.js:1105  → writes records.json            │   ║
║  │  hooks.done.callAsync(new Stats(compilation))                            │   ║
║  │  cache.storeBuildDependencies(compilation.buildDependencies)             │   ║
║  │  hooks.afterDone.call(stats)                                             │   ║
║  │  finalCallback(null, stats)          ← user receives Stats object        │   ║
║  └──────────────────────────────────────────────────────────────────────────┘   ║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## Key Class and Data Structure Index

| Class / File | Role |
|---|---|
| `Compiler` · `lib/Compiler.js:175` | Lifecycle orchestrator; owns all top-level hooks; singleton per config |
| `Compilation` · `lib/Compilation.js:585` | One build pass; owns `ModuleGraph`, `ChunkGraph`, `modules`, `chunks`, `assets` |
| `NormalModuleFactory` · `lib/NormalModuleFactory.js:381` | Resolves requests to `NormalModule` instances via enhanced-resolve |
| `NormalModule` · `lib/NormalModule.js:768` | One source file; runs loaders, parses, holds deps and generated source |
| `ModuleGraph` · `lib/ModuleGraph.js:140` | Bipartite graph: `Dependency → Module` edges; exports info; issuer chain |
| `ChunkGraph` · `lib/ChunkGraph.js:281` | `Module ↔ Chunk` membership; runtime requirements; module/chunk hashes |
| `EntryPlugin` · `lib/EntryPlugin.js:15` | Fires `compilation.addEntry()` on `hooks.make` |
| `WebpackOptionsApply` · `lib/WebpackOptionsApply.js:87` | Installs all default plugins from normalized config |
| `JavascriptParser` · `lib/javascript/JavascriptParser.js` | Acorn-based AST walker; emits Dependency objects |
| `JavascriptModulesPlugin` · `lib/javascript/JavascriptModulesPlugin.js` | Owns `renderManifest`, `renderChunk`, `renderModule` for JS output |
| `buildChunkGraph` · `lib/optimize/buildChunkGraph.js` | BFS over async blocks; populates `ChunkGraph` from `ModuleGraph` |
| `SplitChunksPlugin` · `lib/optimize/SplitChunksPlugin.js` | Taps `optimizeChunks`; splits chunks by size/sharing heuristics |
| `DependencyTemplate` · each `lib/dependencies/*Template.js` | Per-dependency code emission; called inside `NormalModule.codeGeneration()` |
| `RuntimePlugin` · `lib/RuntimePlugin.js` | Taps `runtimeRequirementInTree`; injects `__webpack_require__` and friends |
| `AsyncQueue` · `lib/util/AsyncQueue.js` | Bounds concurrency for `factorize`, `addModule`, `build`, `processDependencies` |
