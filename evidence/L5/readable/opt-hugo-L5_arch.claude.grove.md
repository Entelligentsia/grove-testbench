# transcript: Give a complete architectural walkthrough of a full Hugo site build from the command invocation to files written on disk — the cross-cutting build architectu...


💬 I'll use grove's map tool to trace the full build architecture across every subsystem. Let me load grove first, then fan out across all layers simultaneously.
  ▸ ToolSearch(select:mcp__grove__map,mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition)

💬 Now I'll fan out across all subsystems in parallel — commands, hugolib, config, resources, output, and publish layers simultaneously.
  ▸ mcp__grove__map({"dir":"commands"})
  ▸ mcp__grove__map({"dir":"config"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"struct"})
  ▸ mcp__grove__symbols({"dir":"resources/page","kind":"struct"})
  ▸ mcp__grove__map({"dir":"output"})
  ▸ mcp__grove__map({"dir":"publish"})

💬 Now let me drill into the core engine — hugolib's build pipeline, content tree, template execution, markup conversion, and the publisher — all in parallel.
  ▸ mcp__grove__map({"dir":"hugolib","kind":"function","name":"NewHugoSites"})
  ▸ mcp__grove__map({"dir":"hugolib","kind":"function","name":"Build"})
  ▸ mcp__grove__outline({"file":"hugolib/hugo_sites.go","detail":0})
  ▸ mcp__grove__outline({"file":"hugolib/site.go","detail":0})
  ▸ mcp__grove__outline({"file":"hugolib/hugo_sites_build.go","detail":0})

💬 Now let me read the key function bodies in parallel — the build pipeline, content processing, rendering, and publisher.
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#Build@64"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#process@283"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#assemble@302"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#render@399"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#postProcess@650"})
  ▸ mcp__grove__map({"dir":"hugolib","kind":"function","name":"processFiles"})

💬 Now let me get the content processing pipeline, the page rendering loop, and the publisher in parallel.
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#processFull@1274"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#processFiles@1346"})
  ▸ mcp__grove__source({"id":"go:hugolib/site.go#renderAndWritePage@1647"})
  ▸ mcp__grove__source({"id":"go:hugolib/site.go#render@1787"})
  ▸ mcp__grove__outline({"file":"hugolib/page_map.go","detail":0})
  ▸ mcp__grove__outline({"file":"hugolib/pages_assembler.go","detail":0})
  ▸ Bash(ls hugolib/page_map* hugolib/pages_assembler* hugolib/content_map* 2>/dev/null | head -30)
  ▸ mcp__grove__outline({"file":"hugolib/site_render.go","detail":0})
  ▸ mcp__grove__map({"dir":"publisher"})
  ▸ mcp__grove__map({"dir":"tpl/tplimpl","kind":"function","name":"ExecuteWithContext"})

💬 Now let me get the key content collection, template execution, and markup conversion — all the final connecting pieces.
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"newPagesCollector"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"struct","name":"pagesCollector"})
  ▸ mcp__grove__source({"id":"go:hugolib/site_render.go#renderPages@71"})
  ▸ mcp__grove__source({"id":"go:hugolib/site_render.go#pageRenderer@123"})
  ▸ mcp__grove__source({"id":"go:publisher/publisher.go#Publish@94"})
  ▸ mcp__grove__map({"dir":"markup/goldmark","kind":"function","name":"Convert"})

💬 Now let me get the pagesCollector, markup converter, template lookup, and the site's `prepareInits` — the final connecting tissue.
  ▸ mcp__grove__outline({"file":"hugolib/pages_capture.go","detail":0})
  ▸ mcp__grove__symbols({"dir":"markup/goldmark","kind":"struct","name":"Provider"})
  ▸ mcp__grove__map({"dir":"markup/goldmark","kind":"function","name":"New"})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"function","name":"ExecuteWithContext"})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"struct","name":"TemplateStore"})
  ▸ mcp__grove__symbols({"dir":"hugofs","kind":"function","name":"NewDestinationPublisher"})
  ▸ mcp__grove__source({"id":"go:hugolib/pages_capture.go#Collect@84"})
  ▸ mcp__grove__symbols({"dir":"markup/converter","kind":"struct"})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"struct"})
  ▸ mcp__grove__outline({"file":"hugolib/pages_assembler.go","detail":0})
  ▸ Bash(find /home/bench/repos/hugo/hugolib -name "*.go" | grep -E "(assembler|pageMap|page_map|content_map)" | head -20)
  ▸ mcp__grove__symbols({"dir":"markup/converter","kind":"function"})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"function","name":"LookupByPath"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"newPageMap"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"struct","name":"pageMap"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"assemblePagesStep1"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"createAllPages"})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"function","name":"Initialize"})
  ▸ mcp__grove__outline({"file":"hugolib/content_map_page.go","detail":0})
  ▸ mcp__grove__outline({"file":"tpl/tplimpl/template.go","detail":0})
  ▸ mcp__grove__outline({"file":"markup/converter/converter.go","detail":0})

💬 Now let me get the template store, goldmark converter, and the `AddFi` entry point to the page map — the last missing pieces.
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"function","name":"GetTemplateStore"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"AddFi"})
  ▸ mcp__grove__symbols({"dir":"markup/goldmark","kind":"function","name":"Provider"})
  ▸ mcp__grove__source({"id":"go:hugolib/site.go#renderForTemplate@1743"})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"function","name":"NewTemplateStore"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"AddFi","nameContains":true})
  ▸ mcp__grove__symbols({"dir":"markup","kind":"function","name":"NewConverterProvider"})
  ▸ mcp__grove__source({"id":"go:markup/markup.go#NewConverterProvider@36"})
  ▸ mcp__grove__outline({"file":"tpl/tplimpl/template_store.go","detail":0})
  ▸ mcp__grove__symbols({"dir":"hugolib","name":"AddFi","nameContains":true})
  ▸ mcp__grove__source({"id":"go:hugolib/content_map.go#AddFi@240"})
  ▸ mcp__grove__outline({"file":"tpl/tplimpl/templatestore.go","detail":0})

💬 I now have everything needed for the complete walkthrough. Let me write it.  ---  # Hugo Full Build Architecture  A complete trace from `hugo` on the command...

──────── RESULT (success, 273123ms, 68 turns) ────────
I now have everything needed for the complete walkthrough. Let me write it.

---

# Hugo Full Build Architecture

A complete trace from `hugo` on the command line to bytes on disk.

---

## 1. Command Layer

### 1.1 Entry point
**`main.go`** calls `commands.Execute(os.Args[1:])`.

**`commands/commandeer.go:Execute@61`** creates the command tree by calling `newExec()`, then calls `exec.Execute(ctx, args)` (simplecobra).

**`commands/commands.go:newExec@23`** registers all subcommands. The plain `hugo` invocation uses `hugoBuildCommand`; `hugo server` uses `serverCommand`. Both embed `*rootCommand`.

### 1.2 Command lifecycle (simplecobra)
simplecobra calls `Init → PreRun → Run` on the matched command.

**`hugoBuildCommand.Init@62`** → `r.initRootCommand("hugo", cd)` which registers all CLI flags (`--minify`, `--baseURL`, `--destination`, etc.) via `applyLocalFlagsBuild@610`.

**`rootCommand.PreRun@448`**: creates the logger (`createLogger@492`), sets up the initial `commonConfig`.

**`rootCommand.Run@393`**: the main build entry point:
```
loadConfig → newHugoBuilder → build.build() → postBuild
```

### 1.3 Builder bootstrap
**`commands/server.go:newHugoBuilder@94`** constructs a `hugoBuilder` struct (`commands/hugobuilder.go:hugoBuilder@56`) which owns:
- A `*rootCommand` reference
- A `*commonConfig` with `Configs` and filesystem handles
- An `EvictingQueue` for partial re-renders (live server mode)

**`hugoBuilder.loadConfig@1070`** calls `rootCommand.ConfigFromProvider@240` which calls `allconfig.LoadConfig`.

---

## 2. Configuration

### 2.1 Loading
**`config/allconfig/load.go:LoadConfig@45`** is the single entry point:
```go
configLoader.loadConfigMain → fromLoadConfigResult → Configs.Init
```

**`loadConfigMain@323`**:
1. Locates `hugo.toml` / `hugo.yaml` / `hugo.json` in the config dir via `LoadConfigFromDir` (`config/configLoader.go:131`).
2. Applies env-variable overrides: `applyOsEnvOverrides@218` — maps `HUGO_*` env vars to nested config keys.
3. Applies CLI flag overrides: `applyFlagsOverrides@211`.
4. Loads Hugo modules: `loadModules@445` → module `Client.Collect()` resolves imports and mount points.

**`fromLoadConfigResult@1065`** (`config/allconfig/allconfig.go`): for each language defined in config, calls `cloneForLang@231` to produce a per-language `*Config`, then `decodeConfigFromParams@1219` to decode each section (Build, Imaging, MinifyConfig, OutputFormats, Permalinks, etc.) via `mapstructure`.

### 2.2 Compiled config
**`Config.CompileConfig@270`**: resolves `BaseURL` (into a parsed `urls.BaseURL`), parses timeout durations, compiles output format mappings and permalink patterns. Result: **`ConfigCompiled@568`**.

### 2.3 Per-language wrapper
**`Configs.Init@901`**: produces one `ConfigLanguage` (`config/allconfig/configlanguage.go:ConfigLanguage@27`) per language — this is the `config.AllProvider` used everywhere in the build. It implements 50+ accessor methods (`BaseURL`, `StaticDirs`, `IsKindEnabled`, `ContentTypes`, etc.).

---

## 3. Dependencies & Site Assembly

### 3.1 Deps construction
**`rootCommand.HugFromConfig@356`** calls `hugolib.NewHugoSites(cfg deps.DepsCfg)`.

`deps.DepsCfg` carries the `Configs`, filesystem roots, and logger. **`deps.New`** (called inside `newHugoSites`) wires:
- `PathSpec` — URL/path computation
- `BaseFs` — the layered virtual filesystem (hugofs overlay of project + modules + themes)
- `ResourceSpec` — the asset pipeline
- `TemplateStore` — the template engine
- Markup converter registry

### 3.2 `NewHugoSites@199` (`hugolib/site.go`)
Creates one `*Site` per language × version × role dimension (`siteLanguageVersionRole@139`). For each site:
- `newPageMap@696` (`hugolib/content_map_page.go`) allocates the content tree: `pageTrees@114` holding `treePages`, `treeResources`, `treeTaxonomyEntries` (all radix trees, `doctree.NodeShiftTree[contentNode]`).
- `prepareInits@864` wires lazy init functions (page collections, taxonomies, menus) that resolve on first access.
- A `NewDestinationPublisher` (`publisher/publisher.go:80`) is created — wraps the publish-dir afero filesystem.

### 3.3 `newHugoSites@462` (`hugolib/site.go`)
Builds shared infrastructure across all sites:
- **Template store**: `tplimpl.NewStore` → `tplimpl.TemplateStore` (`tpl/tplimpl/templatestore.go:TemplateStore@434`). Scans layout directories, parses and transforms all templates at startup via `insertTemplates@1322` → `parseTemplates@1630` → `transformTemplates@1889`.
- **Markup**: `markup.NewConverterProvider@36` (`markup/markup.go`) registers goldmark (`markup/goldmark`), asciidocext, rst, pandoc, org-mode providers — each is a `converter.Provider` that can create a `Converter` per document.
- **Data loaders**: `loadData@699` (`hugolib/hugo_sites.go`) populates `Site.Data` from `data/` directories.
- **Git info**: `loadGitInfo@546` runs `git log` if `enableGitInfo` is set.

---

## 4. The Build Pipeline

`hugoBuilder.buildSites@440` calls `HugoSites.Build(BuildCfg{})`.

### `HugoSites.Build@64` (`hugolib/hugo_sites_build.go`)

The five sequenced phases:

```
initSites / initRebuild
      ↓
  process          ← content collection
      ↓
  assemble         ← page tree construction
      ↓
  render           ← template execution + markup conversion
      ↓
  postProcess      ← deferred resource resolution
```

---

## 5. Phase 1 — Process (Content Collection)

**`process@283`** dispatches by build type:
- Fresh build → `processFull@1274` → `processFiles@1346`
- Watched file-event rebuild → `processPartialFileEvents@865`
- Identity-change rebuild → `processPartialRebuildChanges@853`

### `processFiles@1346`
```go
sourceSpec := source.NewSourceSpec(s.PathSpec, filter, s.BaseFs.Content.Fs)
pageMap   := s.Sites[0].pageMap
c         := newPagesCollector(ctx, s.h, sourceSpec, ...)
c.Collect()
```

### `pagesCollector.Collect@84` (`hugolib/pages_capture.go`)
- Launches `numWorkers` goroutines via `rungroup.Run`.
- `collectDir@225` walks the hugofs virtual filesystem (all content mounts merged by the module layer), calling `collectDirDir@257` for directory traversal and `handleBundleLeaf@368` for leaf bundles.
- Each `hugofs.FileMetaInfo` is dispatched to the worker pool's `Handle` function which calls `pageMap.AddFi`.

### `pageMap.AddFi@240` (`hugolib/content_map.go`)
Classifies the file by `PathInfo.Type()`:

| `paths.Type`          | Action                                                                 |
|-----------------------|------------------------------------------------------------------------|
| `TypeFile` / `TypeContentResource` | `insertResource` → stored in `treeResources`             |
| `TypeContentData`     | `addPagesFromGoTmplFi` → runs the content adapter (Go template) to emit pages |
| Default (content singles, branch/leaf bundle indexes) | `newPageMetaSourceFromFile` → creates a `pageMetaSource` stub, inserts into `treePages` |

At this point `treePages` holds lightweight `pageMetaSource` stubs — front matter is not yet parsed.

---

## 6. Phase 2 — Assemble (Page Tree Construction)

**`assemble@302`** builds the full page graph.

### `allPagesAssembler.createAllPages()`
Walks every entry in `treePages`. For each `pageMetaSource`:
1. Parses front matter (lazily via `FrontmatterHandler`).
2. Promotes it to a `*pageState` (the full `page.Page` implementation).
3. Inserts into the appropriate site's `pageMap` keyed by language.

### `sitePagesAssembler.assemblePagesStep1()` (parallel)
For each site:
- Builds section hierarchy — every directory becomes a `KindSection` page.
- Resolves cascade configuration (front matter cascaded down the tree).
- Assigns parent-child relationships.
- Computes aggregate `Lastmod` dates up the tree.
- Creates taxonomy entry nodes.

### `assemblePagesStep2()`
- Creates taxonomy term pages (`KindTerm`, `KindTaxonomy`) from collected entries.
- Assembles menu entries: `assembleMenus@1423` in `site.go`.

### `assemblePagesStepFinal()`
- `initRenderFormats@968` (`site.go`): for each page, intersects page-level output formats with site-level output formats. Produces the `page.OutputFormats` list.
- `h.renderFormats` accumulates across all sites.

After assemble: every page has a resolved output format list, target path, and full metadata. The page tree is a fully navigable graph.

---

## 7. Phase 3 — Render (Template Execution)

**`render@399`** iterates: `for each site × for each renderFormat`.

For each combination:
1. `preparePagesForRender@682` (`hugolib/hugo_sites.go`): primes page output caches for all sites at this `sitesOutIdx`.
2. `Site.render@1787` → `Site.renderPages`.

### `renderPages@71` (`hugolib/site_render.go`)
```go
// Fan-out: N workers consuming pages channel
for range numWorkers {
    go pageRenderer(ctx, s, pages, results, wg)
}
// Producer: tree walk
NodeShiftTreeWalker[contentNode]{Tree: s.pageMap.treePages}.Walk(...)
// qualifying pages sent to pages channel
```

### `pageRenderer@123` (`hugolib/site_render.go`)
For each `*pageState` received:

1. **Render resources**: `p.renderResources()` — publishes page-bundle resources (images, files).
2. **Render aliases**: `renderAliasesForPage@317` — writes redirect HTML stubs for `aliases:` front matter.
3. **Resolve template**: `p.resolveTemplate()` → **`TemplateStore.LookupPagesLayout@584`** (`tpl/tplimpl/templatestore.go`).
4. **Render page**: `renderAndWritePage`.
5. **Render paginator**: if page has a paginator, `renderPaginator@277` repeats the render for each page number.

### Template lookup: `TemplateStore.LookupPagesLayout@584`
Walks a prioritized sequence of layout name candidates (kind, type, layout, output format, language) from most specific to most generic. Uses `findBestMatchGet@824` / `findBestMatchWalkPath@858` over the stored `TemplInfo` index. Returns the winning `*TemplInfo`.

### `renderAndWritePage@1647` (`hugolib/site.go`)
```go
ctx := s.TemplateStore.PrepareTopLevelRenderCtx(context.Background(), p)
renderForTemplate(ctx, p.Kind(), of.Name, d, renderBuffer, templ)
// then: s.publisher.Publish(publisher.Descriptor{...})
```

### `renderForTemplate@1743` → `TemplateStore.ExecuteWithContext@503`
Executes the resolved Go `html/template` (or `text/template`) with the page as dot. During execution:

- Template calls like `{{ .Content }}` trigger lazy markup conversion.
- **Markup conversion** (when `.Content` is first accessed):
  - The `pageContentOutput` init calls `pageState`'s registered `converter.Converter.Convert(ctx)`.
  - For Markdown: **goldmark** parses the source into an AST, then renders to HTML. Hugo extensions are registered as goldmark `Extender`s: `codeblocks` (syntax highlighting via Chroma), `render hooks` (link/heading/image/blockquote overrides via Hugo templates), `passthrough` (math/raw spans), `hugocontext` (shortcode injection).
  - Shortcodes encountered in Markdown source are expanded by calling back into `TemplateStore.LookupShortcode@640` and re-executing.
- `{{ partial "..." . }}` calls `TemplateStore.LookupPartial@608` and executes inline.
- `{{ resources.Get }}`, `{{ images.Process }}` etc. invoke the resource pipeline (`resources/` package) which may run asset transformations (SCSS, minify, fingerprint) and write processed assets to the publish dir directly.

---

## 8. Phase 4 — Publishing

### `DestinationPublisher.Publish@94` (`publisher/publisher.go`)

```go
transformers := p.createTransformerChain(d)
transformers.Apply(b, d.Src)         // in-memory transform chain
f, _ := helpers.OpenFileForWriting(p.fs, d.TargetPath)
io.Copy(w, src)                       // write to hugofs PublishFs
```

**`createTransformerChain@156`** assembles a `transform.Chain` based on output format:
- HTML pages: `NewAbsURLTransformer` (rewrites relative `href`/`src` when `canonifyURLs` or `relativeURLs` is set), live-reload script injector (server mode), Hugo generator `<meta>` tag injector.
- XML/RSS: `NewAbsURLInXMLTransformer`.

**`helpers.OpenFileForWriting`** opens the destination path in `DestinationPublisher.fs` — which is `HugoSites.BaseFs.PublishFs`, an afero filesystem rooted at the configured `publishDir` (default: `public/`). Parent directories are created on demand.

If `BuildStats.Enable` is set, output is tee'd through `htmlElementsCollectorWriter@138` which lexes the HTML stream and collects all CSS class names, IDs, and tag names into `htmlElementsCollector` — written to `hugo_stats.json` at the end.

---

## 9. Phase 5 — Post-Process

**`postProcess@650`** (`hugolib/hugo_sites_build.go`):

During render, calls to `resources.PostProcess` (e.g. for fingerprinted CSS whose hash wasn't known at render time) leave **sentinel byte sequences** (`postpub.PostProcessPrefix`…`PostProcessSuffix`) in the published HTML. Post-process scans every file that contains a sentinel, resolves the actual resource field value (fingerprint, integrity hash, etc.), and rewrites the file in place — in parallel across `numWorkers`.

Also writes `jsconfig.json` to the assets directory if `js.Build` was invoked with project-local imports (VS Code IntelliSense support).

---

## 10. Static File Sync

Concurrent with `buildSites`, **`hugoBuilder.copyStatic@454`** runs via a goroutine in `fullBuild@559`:

```go
g.Go(func() error { _, err = copyStatic(); return err })
g.Go(func() error { return buildSites(noBuildLock) })
g.Wait()
```

`copyStaticTo@462` creates a `syncer.Syncer` and syncs each `SourceFilesystem` in `BaseFs.Static` to the publish dir. This copies everything under `static/` (and module-contributed static mounts) without template processing.

---

## Unified Architecture Diagram

```
hugo (CLI args)
│
└─ commands.Execute                    [commands/commandeer.go:61]
     └─ newExec → hugoBuildCommand     [commands/commands.go:23,50]
          └─ rootCommand.Run           [commands/commandeer.go:393]
               ├─ loadConfig           [commands/hugobuilder.go:1070]
               │    └─ allconfig.LoadConfig  [config/allconfig/load.go:45]
               │         ├─ loadConfigMain   [load.go:323]
               │         │    ├─ LoadConfigFromDir  (TOML/YAML/JSON files)
               │         │    ├─ applyOsEnvOverrides [load.go:218]
               │         │    └─ loadModules         [load.go:445]
               │         ├─ fromLoadConfigResult     [allconfig.go:1065]
               │         │    └─ decodeConfigFromParams (per language)
               │         └─ Configs.Init             [allconfig.go:901]
               │              └─ ConfigLanguage (AllProvider per lang)
               │
               ├─ newHugoBuilder                    [server.go:94]
               └─ hugoBuilder.build                 [hugobuilder.go:410]
                    └─ fullBuild                    [hugobuilder.go:559]
                         ├─ copyStatic ─────────────────────────────────┐
                         └─ buildSites                                   │
                              └─ HugoSites.Build  [hugo_sites_build.go:64]
                                   │                                     │
               ┌──────────────────┼────────────────────────────────┐    │
               │                  │                                 │    │
      ┌─── NewHugoSites ──────────┘                                │    │
      │    [site.go:199]                                            │    │
      │     ├─ newPageMap×N langs    [content_map_page.go:696]      │    │
      │     │    └─ pageTrees (radix: treePages/Resources/Taxonomies)│   │
      │     └─ newHugoSites [site.go:462]                           │    │
      │          ├─ tplimpl.NewStore [templatestore.go:116]         │    │
      │          │    └─ insertTemplates→parseTemplates             │    │
      │          └─ markup.NewConverterProvider [markup.go:36]      │    │
      │               └─ goldmark, asciidoc, rst, pandoc, org       │    │
      │                                                              │    │
      └───────────────────────────────────────────────────────────  │    │
                                                                     │    │
   ┌─────────────────── Build phases ───────────────────────────────┘    │
   │                                                                      │
   │  1. PROCESS [hugo_sites_build.go:283]                                │
   │     processFull → processFiles [build.go:1346]                       │
   │       └─ pagesCollector.Collect [pages_capture.go:84]                │
   │            ├─ collectDir: walk hugofs virtual FS                      │
   │            └─ (N workers) pageMap.AddFi [content_map.go:240]         │
   │                  ├─ TypeFile/Resource → treeResources                 │
   │                  ├─ TypeContentData  → content adapter (Go tmpl)      │
   │                  └─ TypeContent*     → pageMetaSource → treePages     │
   │                                                                       │
   │  2. ASSEMBLE [hugo_sites_build.go:302]                                │
   │     allPagesAssembler.createAllPages()                                │
   │       └─ pageMetaSource → *pageState (parse front matter)             │
   │     sitePagesAssembler.assemblePagesStep1() [parallel]                │
   │       └─ section tree, cascade, parent/child, dates                   │
   │     assemblePagesStep2()                                               │
   │       └─ taxonomy terms, menus                                        │
   │     assemblePagesStepFinal()                                           │
   │       └─ initRenderFormats [site.go:968] → per-page OutputFormats     │
   │                                                                       │
   │  3. RENDER [hugo_sites_build.go:399]                                  │
   │     for site × renderFormat:                                           │
   │       preparePagesForRender [hugo_sites.go:682]                        │
   │       Site.render [site.go:1787]                                       │
   │         └─ renderPages [site_render.go:71]                             │
   │              ├─ NodeShiftTreeWalker → pages channel                    │
   │              └─ (N workers) pageRenderer [site_render.go:123]          │
   │                   ├─ renderResources()                                 │
   │                   ├─ renderAliasesForPage [site_render.go:317]         │
   │                   ├─ TemplateStore.LookupPagesLayout [tplstore.go:584] │
   │                   └─ renderAndWritePage [site.go:1647]                 │
   │                        ├─ renderForTemplate [site.go:1743]             │
   │                        │    └─ TemplateStore.ExecuteWithContext [503]  │
   │                        │         ├─ html/template execution            │
   │                        │         ├─ .Content → Converter.Convert()     │
   │                        │         │    └─ goldmark AST → HTML          │
   │                        │         │         ├─ render hooks (templates) │
   │                        │         │         ├─ shortcode expansion      │
   │                        │         │         └─ Chroma highlighting      │
   │                        │         └─ partial/shortcode recursion        │
   │                        └─ DestinationPublisher.Publish [publisher:94]  │
   │                             ├─ createTransformerChain [publisher:156]  │
   │                             │    ├─ AbsURLTransformer                  │
   │                             │    └─ LiveReload injector (server mode)  │
   │                             ├─ transformers.Apply (in-memory)          │
   │                             └─ helpers.OpenFileForWriting              │
   │                                  └─ afero.Write → public/ (disk)      │
   │                                       └─ htmlElementsCollector tee     │
   │                                            └─ hugo_stats.json          │
   │                                                                        │
   │  4. POST-PROCESS [hugo_sites_build.go:650]                             │
   │     scan published HTML for PostProcessPrefix sentinels                │
   │     resolve deferred resource fields (fingerprints, hashes)            │
   │     rewrite files in place (parallel)                                  │
   │                                                                        │
   └────────────────────────────────────────────────────────────────────────┘
                                                                       │
   static sync [hugobuilder.go:462] ─────────────────────────────────┘
     syncer.Sync(BaseFs.Static → PublishFs)
```

---

## Key Type Index

| Type | File | Role |
|---|---|---|
| `rootCommand` | `commands/commandeer.go:105` | CLI root; owns config, logger, HugoSites |
| `hugoBuilder` | `commands/hugobuilder.go:56` | Orchestrates build/watch loop |
| `Configs` | `config/allconfig/allconfig.go:861` | All per-language configs + module info |
| `ConfigLanguage` | `config/allconfig/configlanguage.go:27` | Per-language `AllProvider` implementation |
| `HugoSites` | `hugolib/hugo_sites.go:62` | The build root; owns all `*Site`s |
| `Site` | `hugolib/site.go:103` | Per-language/role site; owns pageMap + publisher |
| `pageMap` | `hugolib/content_map_page.go:84` | Radix tree holding the live content tree |
| `pageTrees` | `hugolib/content_map_page.go:114` | Container for treePages / treeResources / treeTaxonomies |
| `pagesCollector` | `hugolib/pages_capture.go:61` | Walks hugofs, feeds `AddFi` in parallel |
| `pageState` | (assembled from `pageMetaSource`) | Full `page.Page` implementation used in templates |
| `TemplateStore` | `tpl/tplimpl/templatestore.go:434` | Parsed layout/partial/shortcode template index |
| `TemplInfo` | `tpl/tplimpl/templatestore.go:220` | A single parsed template + its variant metadata |
| `DestinationPublisher` | `publisher/publisher.go:73` | Applies transform chain, writes to publish FS |
| `Descriptor` | `publisher/publisher.go:42` | Per-page publish job: buffer, target path, format |
| `converter.Converter` | `markup/converter/converter.go:90` | Per-document markup converter interface |
| `BuildCfg` | `hugolib/hugo_sites.go:607` | Build options: SkipRender, PartialReRender, WhatChanged |
