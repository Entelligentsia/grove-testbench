# transcript: Trace how webpack builds a single module after it has been resolved: name every function it passes through, in order, from where the Compilation begins build...


💬 I'll use grove to trace this path. Let me load the grove tools first.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me start tracing. I'll look at `Compilation.js` for the module-building entry points, and simultaneously look at `NormalModuleFactory` and `NormalMod...
  ▸ mcp__grove__outline({"file":"lib/Compilation.js","detail":0,"kind":"method"})
  ▸ mcp__grove__outline({"file":"lib/NormalModule.js","detail":0,"kind":"method"})

💬 Good. Now let me read the key methods in the build pipeline in parallel.
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#handleModuleCreation@2298"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_handleModuleBuildAndDependencies@2449"})

💬 Now let me read `buildModule`, `_buildModule`, and `NormalModule.build` + `_doBuild` in parallel.
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#buildModule@1660"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_buildModule@1670"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#build@1779"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#_doBuild@1468"})

💬 Let me also check `addModule`/`_addModule` and `_createLoaderContext` signature for completeness.
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#addModule@1585"})
  ▸ mcp__grove__source({"id":"javascript:lib/Compilation.js#_addModule@1596"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#_createLoaderContext@1149"})
  ▸ mcp__grove__source({"id":"javascript:lib/NormalModule.js#createSource@1428"})

💬 I have everything needed. Here is the complete ordered function trace:  ---  ## Module build pipeline — function-by-function  Starting point: `handleModuleCr...

──────── RESULT (success, 138909ms, 14 turns) ────────
I have everything needed. Here is the complete ordered function trace:

---

## Module build pipeline — function-by-function

Starting point: `handleModuleCreation` is called after a factory has finished resolving the module (i.e., `_factorizeModule` has returned a `ModuleFactoryResult`). From here to "dependencies populated":

---

### Phase 1 — de-duplication (`Compilation.js`)

**1. `Compilation.handleModuleCreation`** (`lib/Compilation.js:2298`)
The outer orchestrator. Receives the factory result, then calls `addModule` to register the module, wires up `moduleGraph.setResolvedModule` for each dependency, and finally calls `_handleModuleBuildAndDependencies`.

**2. `Compilation.addModule`** (`lib/Compilation.js:1585`)
One-liner: enqueues the module into `this.addModuleQueue` (an `AsyncQueue`), which serialises concurrent add requests by identifier.

**3. `Compilation._addModule`** (`lib/Compilation.js:1596`) — queue processor
Checks `this._modules` by identifier. If the identifier is absent, tries `this._modulesCache.get` to restore a serialised build from disk. The returned module (factory-fresh or cache-restored) is inserted into `this._modules` and `this.modules`.

---

### Phase 2 — build queue (`Compilation.js`)

**4. `Compilation._handleModuleBuildAndDependencies`** (`lib/Compilation.js:2449`)
Back from `addModule`. Checks for in-progress build cycles via `creatingModuleDuringBuild`. Then calls `this.buildModule(module, callback)`. After the build completes it calls `processModuleDependencies` to recurse into the newly discovered deps.

**5. `Compilation.buildModule`** (`lib/Compilation.js:1660`)
Another one-liner: enqueues the module into `this.buildQueue` (a second `AsyncQueue` that bounds concurrency of active builds).

**6. `Compilation._buildModule`** (`lib/Compilation.js:1670`) — queue processor
- Calls `module.needBuild({ compilation, fileSystemInfo, valueCacheVersions })` to decide whether a cached build is still valid.
- If stale/missing: fires `hooks.buildModule`, marks the module in `this.builtModules`, then calls `module.build(options, compilation, resolver, fs, callback)`.
- After `build` returns: calls `this._modulesCache.store(module.identifier(), null, module, ...)` to persist the result, then fires `hooks.succeedModule`.

---

### Phase 3 — `NormalModule.build` (`NormalModule.js`)

**7. `NormalModule.build`** (`lib/NormalModule.js:1779`)
Resets all per-build state (`_source`, `_ast`, `buildMeta`, `buildInfo`, errors, warnings, dependencies, blocks). Obtains `NormalModule.getCompilationHooks(compilation)`. Then calls `this._doBuild(options, compilation, resolver, fs, hooks, callback)`.

**8. `NormalModule._doBuild`** (`lib/NormalModule.js:1468`)
The loader-runner bridge:
1. Calls `this._createLoaderContext(...)` to build the `loaderContext` object.
2. Fires `hooks.beforeLoaders`.
3. Calls `runLoaders({ resource, loaders, context: loaderContext, processResource }, callback)`.
4. In the `runLoaders` callback: merges `fileDependencies`, `contextDependencies`, `missingDependencies` from the runner result, adds each loader path to `buildInfo.buildDependencies`, then calls `processResult(err, result.result)`.

**9. `NormalModule._createLoaderContext`** (`lib/NormalModule.js:1149`)
Constructs the `loaderContext` plain object — the `this` value inside every loader. Populates it with `getOptions`, `emitWarning`, `emitError`, `emitFile`, `resolve`, `getResolve`, `addDependency`, `addBuildDependency`, `fs`, `_module`, `_compilation`, `_compiler`, etc. Fires `hooks.loader` on it so plugins can extend it. Returns `loaderContext`.

**10. `runLoaders` (from `loader-runner` package)**
Webpack delegates entirely to the external `loader-runner` library. It iterates the loader list:
- **Pitch phase** (left → right): calls each loader's `.pitch()` if present; if one returns a value the remaining pitches and the resource-read are short-circuited.
- **Resource read**: calls the `processResource` callback supplied by `_doBuild`.
- **Normal phase** (right → left): passes the resource content through each loader's default export function, carrying intermediate `source`, `sourceMap`, and optional `extraInfo` (`webpackAST`).

**11. `processResource` (closure inside `_doBuild`)** (`lib/NormalModule.js:~1530`)
Fires `hooks.readResource.for(scheme).callAsync(loaderContext, callback)` — for ordinary `file:` paths the default `NodeEnvironmentPlugin` hook reads the file from `inputFileSystem`. If `extractSourceMap` is on it then runs source-map extraction on the raw bytes before handing them back to loader-runner.

**12. `processResult` (closure inside `_doBuild`)** (`lib/NormalModule.js:~1476`)
Called with the final `[source, sourceMap?, extraInfo?]` tuple from loader-runner:
- Fires `hooks.processResult` (lets plugins transform raw output).
- Validates the final loader returned a `string` or `Buffer`.
- Calls `this.createSource(options.context, source, sourceMap, root)` and stores the result in `this._source`.
- Stores `extraInfo.webpackAST` in `this._ast` if a loader provided a pre-parsed AST.

**13. `NormalModule.createSource`** (`lib/NormalModule.js:1428`)
Wraps the raw content into a `webpack-sources` object:
- `Buffer` → `RawSource`
- string + `useSourceMap` + sourceMap → `SourceMapSource`
- string + `useSourceMap`/`useSimpleSourceMap` → `OriginalSource`
- otherwise → `RawSource`

---

### Phase 4 — parsing (back in `NormalModule.build`)

**14. `hooks.beforeParse.call(this)`** — plugin hook; `JavascriptModulesPlugin` uses it for injection.

**15. `NormalModule.shouldPreventParsing`** (`lib/NormalModule.js:1729`)
Evaluates `options.module.noParse` (string, RegExp, or function). Returns `true` if this module should skip parsing; in that case `buildInfo.parsed` is set to `false` and execution jumps directly to `handleBuildDone`.

**16. `this.parser.parse(this._ast || source, state)`**
For JS modules `this.parser` is a `JavascriptParser` (`lib/javascript/JavascriptParser.js`). It either re-uses a pre-parsed AST from a loader or calls acorn to produce one. The visitor walk fires dozens of hooks; each one can call `module.addDependency`, `module.addBlock`, etc. to register `HarmonyImportDependency`, `CommonJsRequireDependency`, `ExportInfoDependency`, and so on. By the time `parse` returns, `module.dependencies` and `module.blocks` are fully populated.

**17. `handleParseResult` (closure in `NormalModule.build`)** (`lib/NormalModule.js:~1852`)
- Sorts `this.dependencies` by location, then by original insertion order (`keepOriginalOrder`), then calls `sortWithSourceOrder`.
- Calls `this._initBuildHash(compilation)` to compute the initial build hash.
- Saves `this._lastSuccessfulBuildMeta`.
- Calls `handleBuildDone`.

**18. `handleBuildDone` (closure in `NormalModule.build`)** (`lib/NormalModule.js:~1869`)
- Fires `hooks.beforeSnapshot`.
- If `buildInfo.cacheable`, validates all dep paths are absolute, then calls `compilation.fileSystemInfo.createSnapshot(startTime, fileDeps, contextDeps, missingDeps, snapshotOptions, callback)` to record filesystem state for watch-mode cache invalidation. On success it nulls out the raw dep sets and stores the snapshot in `buildInfo.snapshot`.
- Calls `callback()` — returning to `_buildModule`'s `module.build(...)` callback, which then stores to cache and fires `hooks.succeedModule`.

---

### Summary sequence

```
Compilation.handleModuleCreation
  └─ Compilation.addModule                     [AsyncQueue enqueue]
       └─ Compilation._addModule               [dedup + cache restore]
  └─ Compilation._handleModuleBuildAndDependencies  [cycle check]
       └─ Compilation.buildModule              [AsyncQueue enqueue]
            └─ Compilation._buildModule        [needBuild → hooks.buildModule]
                 └─ NormalModule.build         [state reset]
                      └─ NormalModule._doBuild
                           └─ NormalModule._createLoaderContext
                           └─ runLoaders (loader-runner)
                                └─ processResource → hooks.readResource (file read)
                                └─ [each loader's pitch + normal fn, right-to-left]
                           └─ processResult → NormalModule.createSource  [→ this._source]
                      └─ hooks.beforeParse
                      └─ NormalModule.shouldPreventParsing
                      └─ JavascriptParser.parse  [→ this.dependencies/blocks populated]
                      └─ handleParseResult      [sort deps, _initBuildHash]
                      └─ handleBuildDone        [fileSystemInfo.createSnapshot]
```
