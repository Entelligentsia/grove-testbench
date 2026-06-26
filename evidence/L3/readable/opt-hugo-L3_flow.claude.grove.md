# transcript: Trace how Hugo turns a single Markdown content file into rendered HTML during a build: name every function it passes through, in order, from where the page's...


💬 I'll trace this using grove's semantic tools. Let me start by loading the grove schemas and then map the build pipeline.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me explore the build pipeline systematically. I'll start with the top-level build entry in `hugolib` and trace down into the markup layer.
  ▸ mcp__grove__map({"dir":"hugolib","kind":"method","nameContains":true,"name":"Build"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"Build"})

💬 Good. Now let me read `HugoSites.Build` and trace the `process` → `assemble` → `render` chain, then drill into markup conversion in parallel.
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#Build@64"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"process"})

💬 Good. Now let me read `process`, `assemble`, and `render` together.
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#process@283"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"assemble"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"render"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#assemble@302"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#render@399"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"processFull"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#processFull@1274"})
  ▸ mcp__grove__source({"id":"go:hugolib/site.go#render@1787"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"readAndProcessContent"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"processFiles"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"renderPages"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#processFiles@1346"})
  ▸ mcp__grove__source({"id":"go:hugolib/site_render.go#renderPages@71"})

💬 Now let me trace `pageRenderer`, `Collect`, and the content-to-Markdown conversion path simultaneously.
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"pageRenderer"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"Collect"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"preparePagesForRender"})
  ▸ mcp__grove__source({"id":"go:hugolib/site_render.go#pageRenderer@123"})
  ▸ mcp__grove__source({"id":"go:hugolib/pages_capture.go#Collect@84"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites.go#preparePagesForRender@682"})

💬 Good. Now let me trace the content ingestion path (`AddFi`) and the render path (`renderAndWritePage`) in parallel with the Markdown conversion in `page__con...
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"AddFi"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"renderAndWritePage"})
  ▸ mcp__grove__outline({"file":"hugolib/page__content.go","detail":0})
  ▸ mcp__grove__source({"id":"go:hugolib/content_map.go#AddFi@240"})
  ▸ mcp__grove__source({"id":"go:hugolib/site.go#renderAndWritePage@1647"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#contentRendered@492"})

💬 Now let me look at `contentToC` (the parse-to-AST step) and `parseSource` (the file-read step), plus the goldmark `RenderContent`.
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#contentToC@646"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#parseSource@271"})
  ▸ mcp__grove__symbols({"dir":"markup","kind":"method","name":"RenderContent"})

💬 Now let me look at the goldmark converter — specifically `ParseContent` and `RenderContent`.
  ▸ mcp__grove__symbols({"dir":"markup/goldmark","kind":"method","name":"ParseContent"})
  ▸ mcp__grove__symbols({"dir":"markup/goldmark","kind":"method","name":"RenderContent"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"readSourceAll"})
  ▸ mcp__grove__symbols({"dir":"markup","kind":"method","name":"ParseContent"})
  ▸ mcp__grove__symbols({"dir":"markup","kind":"method","name":"RenderContent"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#readSourceAll@434"})
  ▸ mcp__grove__outline({"file":"markup/goldmark/convert.go","detail":0})
  ▸ mcp__grove__symbols({"dir":"markup/converter","kind":"method","name":"ParseContent"})
  ▸ mcp__grove__source({"id":"go:markup/goldmark/convert.go#Parse@273"})
  ▸ mcp__grove__source({"id":"go:markup/goldmark/convert.go#Render@289"})
  ▸ mcp__grove__source({"id":"go:markup/goldmark/convert.go#Convert@312"})

💬 Now let me find the `contentRenderer` type and its `ParseContent`/`RenderContent` methods — the bridge between `page__content.go` and the goldmark converter.
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"ParseContent"})
  ▸ mcp__grove__symbols({"dir":"markup/converter","kind":"method","name":"Convert"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"contentSource"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__per_output.go#ParseContent@420"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#contentSource@410"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"RenderContent"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__per_output.go#RenderContent@439"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"newPageMetaSourceFromFile"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"newPagesCollector"})

💬 Now let me look at `renderForTemplate` (Go template execution step) and `newPageMetaSourceFromFile` (file-to-page wiring).
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"renderForTemplate"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__meta.go#newPageMetaSourceFromFile@330"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#contentToRender@224"})
  ▸ mcp__grove__source({"id":"go:hugolib/site.go#renderForTemplate@1743"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"newCachedContent"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#newCachedContent@108"})
  ▸ mcp__grove__symbols({"dir":"parser/pageparser","kind":"function","name":"Collect"})

💬 Now let me find where `pageparser` is invoked to lex the file and where the `contentParseInfo` items are populated.
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#parseFrontMatter@68"})
  ▸ mcp__grove__symbols({"dir":"parser/pageparser","kind":"function","name":"ParseBytes"})
  ▸ mcp__grove__source({"id":"go:parser/pageparser/pageparser.go#ParseBytes@38"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"assemblePagesStep1"})

💬 Let me check what triggers `parseFrontMatter` and how `createAllPages` works.
  ▸ mcp__grove__callers({"dir":"hugolib","name":"parseFrontMatter"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"createAllPages"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"initFrontMatter"})
  ▸ mcp__grove__source({"id":"go:hugolib/content_map_page_assembler.go#createAllPages@102"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__meta.go#initFrontMatter@215"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"doCreatePages"})
  ▸ mcp__grove__source({"id":"go:hugolib/content_map_page_assembler.go#doCreatePages@146"})

💬 I have all the pieces now. Let me verify the `initEarly` call that bridges `doCreatePages` to `initFrontMatter`.
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"initEarly"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"newPageFromPageMetasource"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__meta.go#initEarly@157"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"doInitEarly"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__meta.go#doInitEarly@164"})

💬 I now have the complete picture. Here is the full trace, in order, from source file bytes to written HTML.  ---  ## Hugo: Markdown file → rendered HTML  The ...

──────── RESULT (success, 275431ms, 77 turns) ────────
I now have the complete picture. Here is the full trace, in order, from source file bytes to written HTML.

---

## Hugo: Markdown file → rendered HTML

The pipeline has six phases. File coordinates are `package/file.go:line`.

---

### Phase 1 — File collection

| # | Function | Location | What it does |
|---|---|---|---|
| 1 | `HugoSites.Build` | `hugolib/hugo_sites_build.go:64` | Top-level entry point. Calls `process`, `assemble`, `render` in sequence. |
| 2 | `HugoSites.process` | `hugolib/hugo_sites_build.go:283` | Fresh build: delegates straight to `processFull`. |
| 3 | `HugoSites.processFull` | `hugolib/hugo_sites_build.go:1274` | Calls `processFiles`. |
| 4 | `HugoSites.processFiles` | `hugolib/hugo_sites_build.go:1346` | Creates a `pagesCollector`, calls `Collect()`. |
| 5 | `pagesCollector.Collect` | `hugolib/pages_capture.go:84` | Walks the content filesystem via `collectDir`; for each file dispatches to a worker that calls `pageMap.AddFi`. |
| 6 | `pageMap.AddFi` | `hugolib/content_map.go:240` | For a regular `.md` file: calls `newPageMetaSourceFromFile`, inserts the resulting `pageMetaSource` into `treePages`. File is **not yet read**. |
| 7 | `HugoSites.newPageMetaSourceFromFile` | `hugolib/page__meta.go:330` | Wraps the `hugofs.FileMetaInfo` in a `pageMetaSource`; stores an `openSource` closure (`meta.Open()`) for later lazy reads. |

---

### Phase 2 — Assembly: `pageMetaSource` → `pageState`, first file read, front matter parsing

| # | Function | Location | What it does |
|---|---|---|---|
| 8 | `HugoSites.assemble` | `hugolib/hugo_sites_build.go:302` | Drives `createAllPages`, `assemblePagesStep1/2/Final`. |
| 9 | `allPagesAssembler.createAllPages` | `hugolib/content_map_page_assembler.go:102` | Calls `doCreatePages`. |
| 10 | `allPagesAssembler.doCreatePages` | `hugolib/content_map_page_assembler.go:146` | Walks the page tree; for each `*pageMetaSource` calls `ms.initEarly` then `site.newPageFromPageMetasource`. |
| 11 | `pageMetaSource.initEarly` → `doInitEarly` | `hugolib/page__meta.go:157,164` | Calls `initFrontMatter`, resolves kind, calls `pageConfigSource.CompileEarly`. |
| 12 | `pageMetaSource.initFrontMatter` | `hugolib/page__meta.go:215` | **First actual read of the `.md` file.** Calls `pi.contentSource` to get the raw bytes, then `pageparser.ParseBytes`, then `pi.parseSource`. |
| 13 | `contentParseInfo.contentSource` | `hugolib/page__content.go:410` | Caches raw bytes; on miss calls `readSourceAll`. |
| 14 | `contentParseInfo.readSourceAll` | `hugolib/page__content.go:434` | Calls `openSource()` → `meta.Open()` → `io.ReadAll(r)`. **Raw `.md` bytes are now in memory.** |
| 15 | `pageparser.ParseBytes` | `parser/pageparser/pageparser.go:38` | Lexes the byte stream into `Items` using the `lexIntroSection` state machine: front matter block, content tokens, shortcode delimiters. |
| 16 | `contentParseInfo.parseSource` | `hugolib/page__content.go:271` | Iterates items: calls `parseFrontMatter` to decode YAML/TOML/JSON, records shortcodes via `extractShortcode`, records summary dividers, accumulates remaining content into `itemsStep2`. |
| 17 | `pageConfigSource.SetMetaPreFromMap` | (called from `initFrontMatter`) | Applies front matter fields (title, date, draft, …) to the page config. |

---

### Phase 3 — Render preparation

| # | Function | Location | What it does |
|---|---|---|---|
| 18 | `Site.preparePagesForRender` | `hugolib/hugo_sites.go:682` | Called at the start of each output-format pass. Calls `p.shiftToOutputFormat` for each page, binding the correct `pageContentOutput` (which holds the configured content converter). |

---

### Phase 4 — Template execution

| # | Function | Location | What it does |
|---|---|---|---|
| 19 | `HugoSites.render` | `hugolib/hugo_sites_build.go:399` | Iterates sites × output formats; calls `preparePagesForRender` then `s.render`. |
| 20 | `Site.render` | `hugolib/site.go:1787` | Calls `renderPages`. |
| 21 | `Site.renderPages` | `hugolib/site_render.go:71` | Walks `pageMap.treePages`; sends each `*pageState` to a pool of worker goroutines. |
| 22 | `pageRenderer` | `hugolib/site_render.go:123` | Per-page worker: resolves the layout template via `p.resolveTemplate()`, calls `s.renderAndWritePage`. |
| 23 | `Site.renderAndWritePage` | `hugolib/site.go:1647` | Allocates a render buffer, builds the template context, calls `renderForTemplate`. |
| 24 | `Site.renderForTemplate` | `hugolib/site.go:1743` | Calls `TemplateStore.ExecuteWithContext(ctx, templ, buf, page)`. **Go template execution begins.** |

---

### Phase 5 — Content rendering (triggered when the template accesses `.Content`)

| # | Function | Location | What it does |
|---|---|---|---|
| 25 | `cachedContentScope.Content` | `hugolib/page__content.go:854` | Template accessor for `.Content`; calls `contentRendered`. |
| 26 | `cachedContentScope.contentRendered` | `hugolib/page__content.go:492` | Cache wrapper; on miss calls `contentToC`, then runs `RenderContent`/token expansion. |
| 27 | `cachedContentScope.contentToC` | `hugolib/page__content.go:646` | (a) Gets cached source bytes; (b) builds shortcode placeholder map via `prepareShortcodesForPage`; (c) calls `pi.contentToRender` to splice raw Markdown with shortcode placeholder strings; (d) calls `po.contentRenderer.ParseContent` to parse into an AST. |
| 28 | `contentParseInfo.contentToRender` | `hugolib/page__content.go:224` | Iterates `itemsStep2`; inline-rendered shortcodes are substituted directly, Goldmark-opaque ones get a placeholder token. Returns the final Markdown bytes to feed the converter. |
| 29 | `pageContentOutput.ParseContent` | `hugolib/page__per_output.go:420` | Gets the Goldmark converter (via `getContentConverter`), casts to `converter.ParseRenderer`, builds a `converter.RenderContext{Src: markdownBytes}`, calls `p.Parse(rctx)`. |
| 30 | `goldmarkConverter.Parse` | `markup/goldmark/convert.go:273` | Creates a `text.Reader` over the Markdown bytes; calls `c.md.Parser().Parse(reader, parser.WithContext(pctx))`. **Markdown is parsed into a goldmark `ast.Node` tree.** Also populates the table of contents from heading nodes. |
| 31 | `pageContentOutput.RenderContent` | `hugolib/page__per_output.go:439` | Calls `p.Render(rctx, astDoc)` on the same Goldmark converter. |
| 32 | `goldmarkConverter.Render` | `markup/goldmark/convert.go:289` | Calls `c.md.Renderer().Render(w, src, astNode)`. **AST → HTML**: the goldmark renderer walks the node tree, writing HTML to a `BufWriter`. Render hooks (custom link/heading/codeblock templates) fire during this walk if configured. |
| 33 | `expandShortcodeTokens` | `hugolib/page__content.go` (called from `contentRendered`) | Scans the rendered HTML buffer for placeholder tokens; replaces each with its shortcode's rendered output. |

---

### Phase 6 — Post-processing and write

| # | Function | Location | What it does |
|---|---|---|---|
| 34 | `publisher.Publish` | (called from `renderAndWritePage`) | Passes the full-page HTML buffer through URL canonification, live-reload script injection, Hugo generator `<meta>` tag insertion, then writes the final file to the output filesystem. |

---

### Key structural notes

- **Two-pass content handling**: the file is *lexed* once in Phase 2 (`pageparser.ParseBytes` + `parseSource`) storing token items; the actual Markdown→HTML *conversion* is deferred until Phase 5 when the template first reads `.Content`. Results are cached so repeated template accesses are free.
- **Goldmark separates parse and render**: `Parse` builds the AST (and the ToC), `Render` walks it. Hugo stores the AST between the two calls so render hooks can fire mid-walk without re-parsing.
- **Shortcodes straddle both**: shortcodes that produce Markdown-opaque output (e.g. raw HTML) are replaced with placeholder tokens before the goldmark pass; `expandShortcodeTokens` (step 33) reinserts their output into the already-rendered HTML buffer.
