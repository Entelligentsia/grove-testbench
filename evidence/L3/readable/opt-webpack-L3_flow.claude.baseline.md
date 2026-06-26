# transcript: I need to trace the exact function call sequence webpack uses to build a single module, from when Compilation begins building it, through loader execution, a...


💬 I'll explore the webpack source to trace the build pipeline systematically.
  ▸ Bash(ls /home/bench/repos/webpack/lib/)
  ▸ Bash(ls /home/bench/repos/webpack/lib/ 2>&1 || echo "fallback" && find /home/bench/repos/webpack -maxdepth 2 -name "*.js" | head -20)
  ▸ Read(/home/bench/repos/webpack)
  ▸ Agent(Trace webpack module build pipeline)
  ▸ Bash(find /home/bench/repos/webpack -type f -name "*.js" | grep -E "(Compilation|NormalModule)" | head -20)
  ▸ Bash(find /home/bench/repos/webpack/lib -type f -name "*.js" | head -30)
  ▸ Read(/home/bench/repos/webpack)
  ▸ Bash(ls -la /home/bench/repos/webpack 2>&1 | head -50)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Bash(grep -n "buildModule\|_buildModule" /home/bench/repos/webpack/lib/Compilation.js | head -20)
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
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)

💬 Good trace. Let me verify the key line numbers against the actual source.
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)
  ▸ Read(/home/bench/repos/webpack/lib/NormalModule.js)

💬 Now let me check where `processModuleDependencies` is called after `_buildModule` completes, and look at `_processModuleDependencies`.
  ▸ Bash(grep -n "processModuleDependencies\|_handleModuleBuildAndDependencies\|handleModuleCreation" /home/bench/repos/webpack/lib/Compilation.js | head -40)
  ▸ Agent(Find processModuleDependencies call site and _processModuleDependencies)
  ▸ Read(/home/bench/repos/webpack/lib/Compilation.js)
  ▸ Bash(grep -n "processModuleDependencies" /home/bench/repos/webpack/lib/Compilation.js | head -20)
  ▸ Bash(grep -n "processModuleDependencies" /home/bench/repos/webpack/lib/Compilation.js)
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

💬 I now have everything needed from the source. Here is the precise, in-order call chain:  ---  ## Webpack module build pipeline — function-by-function trace  ...

──────── RESULT (success, 242054ms, 13 turns) ────────
I now have everything needed from the source. Here is the precise, in-order call chain:

---

## Webpack module build pipeline — function-by-function trace

### 1. `Compilation.buildModule` — `Compilation.js:1660`

```js
buildModule(module, callback) {
    this.buildQueue.add(module, callback);
}
```

Enqueues the module in `this.buildQueue` (`AsyncQueue`). The queue's processor is `_buildModule`.

---

### 2. `Compilation._buildModule` — `Compilation.js:1670`

Actual build executor, called by the `AsyncQueue` when a slot is free.

- **:1678** — `module.needBuild({compilation, fileSystemInfo, valueCacheVersions}, cb)` — checks whether a rebuild is actually needed (skips if the cached snapshot is still valid; calls `hooks.stillValidModule` and returns early)
- **:1695** — `hooks.buildModule.call(module)` — plugin hook, fires before the build starts
- **:1697** — `module.build(options, compilation, resolver, inputFileSystem, callback)`

---

### 3. `NormalModule.build` — `NormalModule.js:1779`

Resets all per-build state (`_source`, `_ast`, `error`, `dependencies`, `blocks`, `buildMeta`, `buildInfo`) then:

- **:1818** — `NormalModule.getCompilationHooks(compilation)` — fetches the per-compilation hook set
- **:1820** — `this._doBuild(options, compilation, resolver, fs, hooks, callback)`

---

### 4. `NormalModule._doBuild` — `NormalModule.js:1468`

Runs the loader pipeline.

- **:1469** — `this._createLoaderContext(resolver, options, compilation, fs, hooks)` — constructs the full loader context object (`loaderContext`) that every loader receives as `this`
- **:1543–1548** — initialises `buildInfo.fileDependencies`, `contextDependencies`, `missingDependencies`, marks `cacheable = true`
- **:1551** — `hooks.beforeLoaders.call(loaders, this, loaderContext)` — plugin hook
- **:1567** — `runLoaders({resource, loaders, context: loaderContext, processResource}, resultCallback)` — this is `loader-runner`'s entry point; it chains every loader right-to-left (pitching left-to-right first) over the source

  Inside `runLoaders`:
  - **`processResource`** (`:1578`) — reads the raw file: calls `hooks.readResource.for(scheme).callAsync(loaderContext, cb)`, which reads from `inputFileSystem`; if `extractSourceMap` is on, also strips the inline map here
  - Each loader's exported function is called in turn with the previous result

- **`resultCallback`** (`:1649`) — after all loaders finish:
  - **:1679–1681** — merges `result.fileDependencies`, `contextDependencies`, `missingDependencies` from `loader-runner` into `buildInfo`
  - **:1690** — `processResult(err, result.result)`

- **`processResult`** (`:1482`):
  - **:1497** — `hooks.processResult.call(result_, this)` — allows plugins to post-process loader output
  - **:1526** — `this.createSource(options.context, source, sourceMap, root)` — wraps the string/Buffer in a webpack `Source` object, stored as `this._source`
  - **:1534–1539** — if a loader passed back `extraInfo.webpackAST`, stores it in `this._ast` (skips re-parsing later)
  - **:1540** — `callback()` — returns to `build()`'s `_doBuild` callback

---

### 5. Back in `NormalModule.build`'s `_doBuild` callback — `NormalModule.js:1820`

- **:1954** — `hooks.beforeParse.call(this)` — plugin hook (e.g., used by `DefinePlugin` to inject globals before the AST walk)
- **:1964** — `this.shouldPreventParsing(noParseRule, this.request)` — checks `module.noParse`; if true, skips to `handleBuildDone()` immediately
- **:1972–1985** — `this.parser.parse(this._ast || source, {source, current: this, module: this, compilation, options, …})`

---

### 6. `JavascriptParser.parse` (or the type-appropriate parser)

For JS modules this is `JavascriptParser` in `lib/javascript/JavascriptParser.js`. It walks the AST (using `acorn` if no pre-parsed AST was supplied) and fires visitor hooks at each node. Those hooks create `Dependency` objects (e.g., `HarmonyImportDependency`, `CommonJsRequireDependency`) and push them into `module.dependencies` and `module.blocks`. The call is **synchronous** — when `parse()` returns, all dependencies have been added.

---

### 7. `handleParseResult` — `NormalModule.js:1843`

Defined inline inside `build()`. Called immediately after `parser.parse()` returns:

- **:1844–1850** — sorts `this.dependencies` by source location (`Dependency.compareLocations`) and then by original insertion order (`keepOriginalOrder`)
- **:1851** — `this._initBuildHash(compilation)` — computes the module's content hash
- **:1852** — saves `this._lastSuccessfulBuildMeta`
- **:1855** — `handleBuildDone()`

---

### 8. `handleBuildDone` — `NormalModule.js:1858`

Also inline in `build()`:

- **:1860** — `hooks.beforeSnapshot.call(this)` — plugin hook
- **:1933** — `compilation.fileSystemInfo.createSnapshot(startTime, fileDeps, contextDeps, missingDeps, snapshotOptions, cb)` — converts raw filesystem dependency lists into a `Snapshot` for incremental rebuild tracking
- **:1948** — `callback()` — fires the `build()` completion callback back up to `_buildModule`

---

### 9. Back in `_buildModule`'s `module.build()` callback — `Compilation.js:1703`

- **:1714** — `this._modulesCache.store(module.identifier(), null, module, cb)` — persists the built module to the cache
- **:1729** — `hooks.succeedModule.call(module)`
- **:1730** — `callback()` — fires the `buildQueue`'s completion callback, which is the one registered by `_handleModuleBuildAndDependencies`

---

### 10. `Compilation._handleModuleBuildAndDependencies` — `Compilation.js:2449`

This is the method that called `buildModule` at line 2500. In its `buildModule` callback:

- **:2513–2516** — if `recursive = false`, calls `processModuleDependenciesNonRecursive` and exits
- **:2525** — `this._lazyBarrelController.request(module, dependencies)` — handles lazy barrel (side-effect-free re-export) deferral
- **:2561** — `this.processModuleDependencies(module, callback)` — normal recursive path

---

### 11. `Compilation.processModuleDependencies` — `Compilation.js:1745`

```js
processModuleDependencies(module, callback) {
    this.processDependenciesQueue.add(module, callback);
}
```

Enqueues in `processDependenciesQueue` (`AsyncQueue`); processor is `_processModuleDependencies`.

---

### 12. `Compilation._processModuleDependencies` — `Compilation.js:1780`

Walks all discovered dependencies and re-enters the pipeline for each one.

- **:1789** — `this._lazyBarrelController.classify(module)` — decides if this module is a lazy barrel
- **:2097–2115** — iterates `module.dependencies` and every `block` in `module.blocks` (async chunks), calling `processDependency(dep, index)` for each
  - `processDependency` → `processDependencyForResolving(dep)` — looks up the `ModuleFactory` for the dependency's constructor type, groups dependencies by `(factory, category, resourceIdent)` into `sortedDependencies`
- **:1818** — `onDependenciesSorted()` — called after the grouping pass completes:
  - **:1832** — for each group: `this.handleModuleCreation(item, callback)`

---

### 13. `Compilation.handleModuleCreation` — `Compilation.js:~2298`

Starts the whole pipeline over for each discovered import:

- `factorizeModule(...)` — resolves the import path to a filesystem path
- `addModule(...)` — deduplicates against already-known modules
- `_handleModuleBuildAndDependencies(...)` — which calls `buildModule(...)` → **back to step 2**

---

## Condensed call chain

```
Compilation.buildModule                           :1660  enqueue in buildQueue (AsyncQueue)
  Compilation._buildModule                        :1670  queue processor
    module.needBuild()                            :1678
    hooks.buildModule                             :1695
    NormalModule.build()                          :1697 / NormalModule.js:1779
      NormalModule._createLoaderContext()         :1469
      hooks.beforeLoaders                         :1551
      runLoaders()  [loader-runner]               :1567
        processResource → hooks.readResource      :1578  read file from disk
        <each loader function, right-to-left>
        processResult()                           :1482  wrap output in Source
          hooks.processResult                     :1497
          NormalModule.createSource()             :1526  → this._source
      hooks.beforeParse                           :1954
      shouldPreventParsing()                      :1964
      JavascriptParser.parse()                    :1975  walk AST → push Dependencies
      handleParseResult()                         :1843  sort deps, initBuildHash
        handleBuildDone()                         :1858
          hooks.beforeSnapshot                    :1860
          fileSystemInfo.createSnapshot()         :1933
    _modulesCache.store()                         :1714
    hooks.succeedModule                           :1729
  Compilation._handleModuleBuildAndDependencies   :2449  build callback site
    Compilation.processModuleDependencies()       :1745  enqueue in processDependenciesQueue
      Compilation._processModuleDependencies()    :1780  queue processor
        processDependencyForResolving()           :2004  group by factory
        onDependenciesSorted()                    :1818
          Compilation.handleModuleCreation()      :1832  → factorize → addModule → _handleModuleBuildAndDependencies
```

The cycle from `handleModuleCreation` → `_handleModuleBuildAndDependencies` → `buildModule` → `_buildModule` → `module.build` → `_doBuild` → `runLoaders` → `parser.parse` → `processModuleDependencies` → `handleModuleCreation` repeats until no new unvisited modules are enqueued.
