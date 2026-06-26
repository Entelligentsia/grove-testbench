# transcript: Give the complete end-to-end picture of how Hugo renders site content as a subsystem: from assembling pages and resolving content (page bundles), through sho...


💬 I'll load the grove tools first, then systematically trace the rendering pipeline.
  ▸ ToolSearch(select:mcp__grove__outline,mcp__grove__symbols,mcp__grove__source,mcp__grove__callers,mcp__grove__definition,mcp__grove__map)

💬 Now let me fan out several grove queries in parallel to map the rendering pipeline across all major subsystems.
  ▸ mcp__grove__map({"dir":"hugolib","kind":"method","nameContains":true})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"struct"})
  ▸ mcp__grove__symbols({"dir":"markup/goldmark","kind":"function"})

💬 The hugolib map is too large. I'll trace the pipeline in targeted stages — starting with the build entry point, then content assembly, shortcodes, and Goldmark.
  ▸ mcp__grove__outline({"file":"hugolib/hugolib.go","detail":0})
  ▸ mcp__grove__outline({"file":"hugolib/site.go","detail":0})
  ▸ mcp__grove__outline({"file":"markup/goldmark/convert.go","detail":1})

💬 Now let me read the key pipeline methods in parallel.
  ▸ mcp__grove__source({"file":"hugolib/site.go","name":"renderAndWritePage"})
  ▸ mcp__grove__source({"file":"hugolib/site.go","name":"render"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"Build"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"Build"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"renderPages"})
  ▸ mcp__grove__source({"file":"hugolib/site.go","name":"renderForTemplate"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites_build.go#Build@64"})
  ▸ mcp__grove__source({"id":"go:hugolib/site_render.go#renderPages@71"})
  ▸ mcp__grove__outline({"file":"hugolib/hugo_sites_build.go","detail":0})

💬 Now I need `process`, `assemble`, `render`, and `pageRenderer` — and simultaneously start tracing page content/shortcode paths.
  ▸ mcp__grove__source({"file":"hugolib/hugo_sites_build.go","name":"process"})
  ▸ mcp__grove__source({"file":"hugolib/hugo_sites_build.go","name":"assemble"})
  ▸ mcp__grove__source({"file":"hugolib/hugo_sites_build.go","name":"render"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"pageRenderer"})
  ▸ mcp__grove__source({"id":"go:hugolib/site_render.go#pageRenderer@123"})
  ▸ mcp__grove__source({"file":"hugolib/hugo_sites_build.go","name":"processFull"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"preparePagesForRender"})
  ▸ mcp__grove__source({"file":"hugolib/hugo_sites_build.go","name":"processFiles"})
  ▸ mcp__grove__source({"id":"go:hugolib/hugo_sites.go#preparePagesForRender@682"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"assemblePagesStep1"})

💬 Now let me trace the content collection, page content rendering, and shortcode pipeline.
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"newPagesCollector"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"Collect"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"shiftToOutputFormat"})
  ▸ mcp__grove__source({"id":"go:hugolib/pages_capture.go#Collect@84"})
  ▸ mcp__grove__source({"id":"go:hugolib/page.go#shiftToOutputFormat@872"})
  ▸ mcp__grove__outline({"file":"hugolib/pages_capture.go","detail":0})

💬 Now the critical path — `newPageContentOutput` and the content rendering layer (shortcodes + Goldmark).
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"newPageContentOutput"})
  ▸ mcp__grove__outline({"file":"hugolib/page_content.go","detail":0})
  ▸ mcp__grove__outline({"file":"markup/converter/converter.go","detail":1})
  ▸ mcp__grove__outline({"file":"hugolib/page__per_output.go","detail":0})
  ▸ mcp__grove__source({"id":"go:hugolib/page__per_output.go#newPageContentOutput@65"})
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"Content"})
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"ParseAndRenderContent"})
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"renderContentWithConverter"})
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"Render"})
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"RenderShortcodes"})
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"initRenderHooks"})

💬 Now let me trace the shortcode pipeline and the content rendering cache system.
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"c"})
  ▸ mcp__grove__outline({"file":"hugolib/page_content_cache.go","detail":0})
  ▸ mcp__grove__outline({"file":"hugolib/shortcode.go","detail":0})

💬 Now I'll read the core shortcode functions and trace how source content flows through them.
  ▸ mcp__grove__source({"file":"hugolib/shortcode.go","name":"prepareShortcodesForPage"})
  ▸ mcp__grove__source({"file":"hugolib/shortcode.go","name":"doRenderShortcode"})
  ▸ mcp__grove__source({"file":"hugolib/shortcode.go","name":"expandShortcodeTokens"})
  ▸ mcp__grove__source({"file":"hugolib/shortcode.go","name":"prepareShortcode"})
  ▸ mcp__grove__source({"file":"hugolib/shortcode.go","name":"renderShortcodeWithPage"})
  ▸ mcp__grove__source({"file":"hugolib/shortcode.go","name":"extractShortcode"})

💬 Now let me trace how content flows from `pageMap.AddFi` through the content source into shortcode parsing.
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"Markup"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"newShortcodeHandler"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"RenderContent"})
  ▸ mcp__grove__source({"id":"go:hugolib/page__per_output.go#RenderContent@439"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"getOrCreateScope"})
  ▸ mcp__grove__outline({"file":"hugolib/page_markup.go","detail":0})
  ▸ mcp__grove__outline({"file":"hugolib/page__content.go","detail":0})
  ▸ mcp__grove__outline({"file":"hugolib/page__content_render.go","detail":0})
  ▸ mcp__grove__source({"file":"hugolib/page__content.go","name":"contentRendered"})
  ▸ mcp__grove__source({"file":"hugolib/page__content.go","name":"parseSource"})
  ▸ mcp__grove__source({"file":"hugolib/page__content.go","name":"contentToRender"})

💬 Now let me get the `contentToC` function and the full Goldmark `Convert`/`Parse`/`Render` path.
  ▸ mcp__grove__source({"file":"hugolib/page__content.go","name":"contentToC"})
  ▸ mcp__grove__source({"file":"markup/goldmark/convert.go","name":"Convert"})
  ▸ mcp__grove__source({"file":"markup/goldmark/convert.go","name":"Parse"})

💬 Now the Goldmark `Render` method, `newMarkdown`, and the `ParseContent` bridge.
  ▸ mcp__grove__source({"file":"markup/goldmark/convert.go","name":"Render"})
  ▸ mcp__grove__source({"file":"markup/goldmark/convert.go","name":"newMarkdown"})
  ▸ mcp__grove__source({"file":"hugolib/page__per_output.go","name":"ParseContent"})

💬 Now let me trace the render hook dispatch in Goldmark and the template execution path.
  ▸ mcp__grove__outline({"file":"markup/goldmark/render_hooks.go","detail":1})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"method","name":"ExecuteWithContext"})
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"method","name":"PrepareTopLevelRenderCtx"})
  ▸ mcp__grove__source({"id":"go:tpl/tplimpl/templatestore.go#ExecuteWithContext@503"})
  ▸ mcp__grove__source({"id":"go:tpl/tplimpl/templatestore.go#PrepareTopLevelRenderCtx@495"})
  ▸ mcp__grove__source({"file":"hugolib/site.go","name":"renderForTemplate"})

💬 Now I'll get the `ExecuteWithContextAndKey`, the hook dispatcher from `hookRendererTemplate`, and the render hook dispatch in Goldmark's `renderLink`/`render...
  ▸ mcp__grove__symbols({"dir":"tpl/tplimpl","kind":"method","name":"ExecuteWithContextAndKey"})
  ▸ mcp__grove__source({"file":"hugolib/site.go","name":"RenderLink"})
  ▸ mcp__grove__source({"file":"markup/goldmark/render_hooks.go","name":"renderLink"})
  ▸ mcp__grove__source({"id":"go:tpl/tplimpl/templatestore.go#ExecuteWithContextAndKey@507"})
  ▸ mcp__grove__source({"file":"markup/goldmark/render_hooks.go","name":"renderHeading"})
  ▸ mcp__grove__source({"file":"markup/goldmark/codeblocks/render.go","name":"New"})

💬 Now let me look at the codeblock render hook dispatch and the pageparser tokenizer to complete the picture.
  ▸ mcp__grove__outline({"file":"markup/goldmark/codeblocks/render.go","detail":1})
  ▸ mcp__grove__symbols({"dir":"parser/pageparser","kind":"function","name":"ParseBytes"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"readSourceAll"})
  ▸ mcp__grove__source({"id":"go:markup/goldmark/codeblocks/render.go#renderCodeBlock@59"})
  ▸ mcp__grove__source({"file":"hugolib/page__content.go","name":"newCachedContent"})
  ▸ mcp__grove__source({"file":"hugolib/page__content.go","name":"contentSource"})

💬 Let me get the final missing pieces: `readSourceAll`, `hookRendererTemplate.RenderCodeblock`, and `AddFi` for the content map.
  ▸ mcp__grove__source({"id":"go:hugolib/page__content.go#readSourceAll@434"})
  ▸ mcp__grove__source({"file":"hugolib/site.go","name":"RenderCodeblock"})
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"method","name":"AddFi"})
  ▸ mcp__grove__source({"id":"go:hugolib/content_map.go#AddFi@240"})
  ▸ mcp__grove__source({"file":"hugolib/shortcode.go","name":"newShortcodeHandler"})

💬 Let me now look at the front-matter parse setup and publisher output stage.
  ▸ mcp__grove__symbols({"dir":"hugolib","kind":"function","name":"newPageMetaSourceFromFile"})
  ▸ mcp__grove__outline({"file":"publisher/publisher.go","detail":0})

💬 I have enough data now to write the complete picture. Let me verify one last link — when `parseSource` is actually called during assembly.
  ▸ mcp__grove__callers({"dir":"hugolib","name":"parseSource"})
  ▸ mcp__grove__source({"file":"publisher/publisher.go","name":"Publish"})
  ▸ mcp__grove__source({"file":"hugolib/page__content.go","name":"parseFrontMatter"})

💬 I have all the information I need. Here is the complete end-to-end rendering picture.  ---  ## Hugo Content Rendering Pipeline — End-to-End  ### Key Types  |...

──────── RESULT (success, 403790ms, 98 turns) ────────
I have all the information I need. Here is the complete end-to-end rendering picture.

---

## Hugo Content Rendering Pipeline — End-to-End

### Key Types

| Type | File | Role |
|---|---|---|
| `HugoSites` | `hugolib/hugo_sites.go` | Top-level orchestrator |
| `Site` | `hugolib/site.go` | Per-language build/render |
| `pageState` | `hugolib/page.go` | Mutable build-time page |
| `pageOutput` | `hugolib/page_output.go` | One per output format |
| `pageContentOutput` | `hugolib/page__per_output.go` | Content renderer for one output |
| `cachedContent` / `cachedContentScope` | `hugolib/page__content.go` | Cached, lazy content pipeline |
| `contentParseInfo` | `hugolib/page__content.go` | Parsed token stream + source map |
| `shortcodeParseInfo` | `hugolib/shortcode.go` | Shortcode AST from the lexer |
| `goldmarkConverter` | `markup/goldmark/convert.go` | Goldmark Markdown → HTML |
| `hookedRenderer` | `markup/goldmark/render_hooks.go` | Dispatches link/heading/image to hooks |
| `htmlRenderer` | `markup/goldmark/codeblocks/render.go` | Dispatches code fences to hooks |
| `hookRendererTemplate` | `hugolib/site.go:1705` | Bridges hook → Go template |
| `TemplateStore` | `tpl/tplimpl/templatestore.go` | Template lookup + execution |
| `DestinationPublisher` | `publisher/publisher.go` | Post-process + write to disk |

---

## Phase 1 — Content Collection

```
HugoSites.Build               hugo_sites_build.go:64
  └─ HugoSites.process        hugo_sites_build.go:283
       └─ HugoSites.processFull   hugo_sites_build.go:1274
            └─ HugoSites.processFiles   hugo_sites_build.go:1346
                 newPagesCollector       pages_capture.go:37
                 pagesCollector.Collect  pages_capture.go:84
                   (worker goroutines)
                   pageMap.AddFi         content_map.go:240
                     ├─ (page file)  → newPageMetaSourceFromFile → treePages.Insert
                     └─ (resource)   → treeResources.Insert
```

Each content file (`.md`, `index.md`, `_index.md`) ends up as a `pageMetaSource` in the radix `treePages`.

---

## Phase 2 — Front-matter Parsing & Shortcode Tokenisation

Happens eagerly during collection, called on each `pageMetaSource`:

```
pageMetaSource.parseFrontMatter(h, sid)       page__content.go:68
  │
  ├─ contentParseInfo{...}                     ← created here
  │    openSource  = file opener
  │    shortcodeParseInfo = newShortcodeHandler(filename, deps)  shortcode.go:304
  │
  ├─ contentParseInfo.contentSource(m)          page__content.go:410
  │    readSourceAll()                          page__content.go:434
  │      pi.openSource() → io.ReadAll(r)        ← raw bytes from hugofs VFS
  │
  ├─ pageparser.ParseBytes(source, Config{})    parser/pageparser/pageparser.go:38
  │    parseBytes(b, cfg, lexIntroduction)      pageparser.go:122
  │    ← lexer (state-machine) → Items stream
  │    Items: TypeFrontMatter | TypeText | TypeLeftShortcodeDelim | TypeEOF …
  │    stored as pi.itemsStep1
  │
  └─ contentParseInfo.parseSource(source, skip) page__content.go:271
       iterates itemsStep1 via pageparser.Iterator
       ├─ IsFrontMatter → pi.parseFrontMatter   → Hugo config/params
       ├─ IsLeftShortcodeDelim
       │    shortcodeParseInfo.extractShortcode(ordinal, 0, source, iter)  shortcode.go:572
       │      recursive descent: {{< name params >}}…{{< /name >}}
       │      builds *shortcode{name, params, inner[], doMarkup, placeholder}
       │      pi.AddShortcode(currShortcode)  → placeholder token in itemsStep2
       └─ IsText → pi.AddBytes(it)             → raw text chunk in itemsStep2
```

After this phase `contentParseInfo.itemsStep2` holds an ordered slice of `[text|replacement|*shortcode]` items, and `shortcodeParseInfo.shortcodes` holds all `*shortcode` structs.

---

## Phase 3 — Assembly

```
HugoSites.assemble               hugo_sites_build.go:302
  allPagesAssembler.createAllPages()      ← populates pageState tree from treePages
  sitePagesAssembler.assemblePagesStep1() content_map_page_assembler.go:1348
    pageMeta.newCachedContent(s)          page__content.go:108
      cachedContent{ pi, scopes, … }
  assemblePagesStep2()    ← taxonomies, cascade
  assemblePagesStepFinal()
  s.initRenderFormats()   ← determines output formats per site
```

---

## Phase 4 — Render Preparation

```
HugoSites.render(l, config)       hugo_sites_build.go:399
  (for each site × output-format)
  Site.preparePagesForRender(isRenderingSite, outIdx)   hugo_sites.go:682
    pageMap.forEeachPageIncludingBundledPages
      pageState.shiftToOutputFormat(isRenderingSite, idx)  page.go:872
        pageState.initPage()
        newPageContentOutput(po)                page__per_output.go:65
          pageContentOutput{ po, renderHooks{}, otherOutputs }
        po.setContentProvider(cp)   ← wires .Content/.RenderShortcodes/…
```

---

## Phase 5 — Per-page Layout Rendering

```
Site.render(ctx)             site.go:1787
  Site.renderPages(ctx)      site_render.go:71
    (numWorkers goroutines)
    pageRenderer(ctx, s, pages, results, wg)   site_render.go:123
      p.resolveTemplate(layout...)   ← TemplateStore.LookupPagesLayout(q)
      Site.renderAndWritePage(&stats, targetPath, p, d, templ)   site.go:1647
        TemplateStore.PrepareTopLevelRenderCtx(ctx, p)           templatestore.go:495
          ctx ← tpl.Context.Page.Set(ctx, p)
          ctx ← tpl.Context.PartialDecoratorIDStack.Set(ctx, …)
        Site.renderForTemplate(ctx, kind, format, d, buf, templ) site.go:1743
          TemplateStore.ExecuteWithContext(ctx, templ, buf, data) templatestore.go:503
            TemplateStore.ExecuteWithContextAndKey(ctx,"", …)    templatestore.go:507
              ctx ← tpl.Context.CurrentTemplate.Set(ctx, …)
              storeSite.executer.ExecuteWithContext(ctx, ti, wr, data)
              ← Go text/template engine executes the page layout
        DestinationPublisher.Publish(pd)                         publisher/publisher.go:94
          createTransformerChain(d)   ← URL rewriting, live-reload inject, etc.
          transformers.Apply(b, src)
          io.Copy(f, src)             ← write final HTML to hugofs destination
```

The layout template receives a `*pageState` as `.` and eventually calls `.Content`.

---

## Phase 6 — Content Rendering (lazy, on first `.Content` access)

### 6a — Shortcode preparation + Goldmark parse

```
pageContentOutput.Content(ctx)             page__per_output.go:151
  pco.c()                                  ← returns cachedContentScope (page.Markup)
  cachedContentScope.contentRendered(ctx)  page__content.go:492
    cachedContentScope.contentToC(ctx)     page__content.go:646
      contentParseInfo.contentSource(c)    ← raw source bytes (cached)

      pageContentOutput.initRenderHooks()  page__per_output.go:227
        ← builds renderHooks.getRenderer closure:
           for each RendererType (Link/Image/Heading/Passthrough/Blockquote/Table/CodeBlock):
             TemplateStore.LookupPagesLayout(q)   ← looks up _default/render-*.html
             if found → hookRendererTemplate{ templ, templateHandler }
             if CodeBlock and no template → ContentSpec.Converters.GetHighlighter()
             result cached in renderCache[{type,id,format}]

      shortcodeParseInfo.prepareShortcodesForPage(po, false)  shortcode.go:536
        for each *shortcode in pi.shortcodes:
          prepareShortcode(0, sc, nil, po, false)              shortcode.go:322
            returns shortcodeRenderFunc (lazy closure over doRenderShortcode)
        → map[placeholder → shortcodeRenderer]

      contentParseInfo.contentToRender(ctx, source, renderedSCs)  page__content.go:224
        iterates itemsStep2:
          text/replacement → append bytes directly
          *shortcode where !insertPlaceholder() → render immediately
          *shortcode where  insertPlaceholder() → append placeholder token
        → contentToRender []byte + []sourceMapEntry

      hugocontext.DedentMarkers(contentToRender)   ← strip Hugo context wrappers

      pageContentOutput.ParseContent(ctx, contentToRender)   page__per_output.go:420
        goldmarkConverter.Parse(ctx)                          convert.go:273
          c.newParserContext(ctx)        ← parserContext{toc: *Fragments}
          text.NewReader(ctx.Src)
          c.md.Parser().Parse(reader, parser.WithContext(pctx))
          ← full CommonMark + extension parsing → ast.Document
          returns parserResult{ doc: ast.Document, toc: *Fragments }
      ct.astDoc  = parseResult.Doc()
      ct.tableOfContents = parseResult.TableOfContents()
      ct.tableOfContentsHTML = toc.ToHTML(startLevel, endLevel, ordered)
```

### 6b — Goldmark AST → HTML (render hooks fire here)

```
      pageContentOutput.RenderContent(ctx, contentToRender, sourceInfo, astDoc)
                                                            page__per_output.go:439
        goldmarkConverter.Render(ctx, astDoc)              convert.go:289
          render.BufWriter{Buffer: &bytes.Buffer{}}
          render.Context{ BufWriter, ContextData{Rctx, Dctx} }
          c.md.Renderer().Render(w, ctx.Src, astDoc)
          ← Goldmark AST walk; per node type:

          LINKS / IMAGES
          hookedRenderer.renderLink(w, src, node, entering)   render_hooks.go:229
            ctx.RenderContext().GetRenderer(LinkRendererType, nil)
            → hookRendererTemplate
            lr.RenderLink(cctx, w, linkContext{dest,title,text,plainText,…})
              hookRendererTemplate.RenderLink                  site.go:1711
                TemplateStore.ExecuteWithContext(ctx, templ, w, linkContext)

          hookedRenderer.renderImage(w, src, node, entering)  render_hooks.go:126
            → hookRendererTemplate.RenderLink (same path, image variant)

          HEADINGS
          hookedRenderer.renderHeading(w, src, node, entering) render_hooks.go:452
            ctx.RenderContext().GetRenderer(HeadingRendererType, nil)
            → hookRendererTemplate
            hr.RenderHeading(cctx, w, headingContext{level,anchor,text,attrs})
              hookRendererTemplate.RenderHeading               site.go:1715
                TemplateStore.ExecuteWithContext(ctx, templ, w, headingContext)

          CODE FENCES
          htmlRenderer.renderCodeBlock(w, src, node, entering) codeblocks/render.go:59
            ctx.RenderContext().GetRenderer(CodeBlockRendererType, lang)
            → hookRendererTemplate  OR  native Chroma highlighter
            cr.RenderCodeblock(cctx, w, codeBlockContext{lang,code,attrs,position})
              hookRendererTemplate.RenderCodeblock             site.go:1719
                TemplateStore.ExecuteWithContext(ctx, templ, w, codeBlockContext)
              OR
              Chroma highlighter.RenderCodeblock(…)

          BLOCKQUOTES, TABLES, PASSTHROUGH
          (same dispatch pattern via hookedRenderer / tables.htmlRenderer /
           passthrough.htmlRenderer → hookRendererTemplate.Render*)
```

Every `hookRendererTemplate.Render*` call ultimately lands at:

```
TemplateStore.ExecuteWithContext(ctx, templ, w, hookCtx)     templatestore.go:503
  TemplateStore.ExecuteWithContextAndKey(ctx, "", templ, w, hookCtx) templatestore.go:507
    storeSite.executer.ExecuteWithContext(ctx, ti, w, hookCtx)
    ← Go template engine executes e.g. layouts/_default/render-link.html
```

### 6c — Shortcode token expansion

```
      expandShortcodeTokens(ctx, renderedHTML, tokenHandler)  shortcode.go:725
        scan for HAHAHUGOSHORTCODE…HBHB tokens
        tokenHandler(ctx, token):
          find shortcodeRenderer in ct.contentPlaceholders
          shortcodeRenderer.renderShortcode(ctx)
            shortcodeRenderFunc(ctx)
              doRenderShortcode(ctx, level, ts, sc, parent, po, false) shortcode.go:357
                named shortcode:
                  ts.LookupShortcode(q)   ← TemplateStore lookup by name+output+site
                  tmpl = *TemplInfo for shortcodes/foo.html
                inline shortcode:
                  ts.TextParse(templatePath, sc.innerString())
                inner content needing markup (doMarkup && level>0):
                  po.contentRenderer.ParseAndRenderContent(ctx, inner, false)
                    page__per_output.go:409
                    goldmarkConverter.Convert(ctx)    convert.go:312
                      goldmarkConverter.Parse(ctx)
                      goldmarkConverter.Render(ctx, doc)
                renderShortcodeWithPage(ctx, ts, tmpl, &ShortcodeWithPage{…})
                  shortcode.go:772
                  h.ExecuteWithContext(ctx, tmpl, buffer, data)
                  ← Go template engine executes shortcodes/foo.html

      page.ExtractSummaryFromHTMLWithDivider / ExtractSummaryFromHTML
      ← produces contentSummary{ content, summary, contentWithoutSummary }
```

---

## Goldmark Instance Construction (`newMarkdown`)

`markup/goldmark/convert.go:84` — called once per `goldmarkConverter`:

| Extension | Condition |
|---|---|
| `hugocontext.New(logger)` | always — wraps source in Hugo context markers |
| `newLinks(cfg)` → `hookedRenderer` | always — link/image/heading hooks |
| `newTocExtension(tocOpts)` | always — collects heading fragments |
| `blockquotes.New()` | always — blockquote hook support |
| `images.New(wrapStandAlone)` | always — image handling |
| `extras.New(...)` | always — del/ins/mark/sub/sup |
| `codeblocks.New()` | when `Highlight.CodeFences` |
| `extension.Table` + `tables.New()` | when `Extensions.Table` |
| `extension.Strikethrough/Linkify/TaskList` | per config |
| `extension.NewTypographer(...)` | when not disabled |
| `extension.DefinitionList` | per config |
| `extension.NewFootnote(...)` | per config |
| `extension.NewCJK(...)` | per config |
| `passthrough.New(cfg)` | per config |
| `emoji.Emoji` | when `EnableEmoji` |
| `attributes.New(cfg.Parser)` | when block attrs or auto heading IDs |

---

## Unified Call Graph

```
HugoSites.Build (hugo_sites_build.go:64)
├─ HugoSites.process (283)
│   └─ HugoSites.processFull (1274)
│        └─ HugoSites.processFiles (1346)
│             pagesCollector.Collect (pages_capture.go:84)
│               pageMap.AddFi (content_map.go:240)
│                 pageMetaSource.parseFrontMatter (page__content.go:68)
│                   newShortcodeHandler (shortcode.go:304)
│                   contentParseInfo.contentSource (page__content.go:410)
│                     readSourceAll → openSource → io.ReadAll
│                   pageparser.ParseBytes (pageparser/pageparser.go:38)
│                   contentParseInfo.parseSource (page__content.go:271)
│                     shortcodeParseInfo.extractShortcode (shortcode.go:572)  [recursive]
│
├─ HugoSites.assemble (302)
│   allPagesAssembler.createAllPages
│   sitePagesAssembler.assemblePagesStep1 (content_map_page_assembler.go:1348)
│     pageMeta.newCachedContent (page__content.go:108)
│   assemblePagesStep2, assemblePagesStepFinal
│
└─ HugoSites.render (399)
     Site.preparePagesForRender (hugo_sites.go:682)
       pageState.shiftToOutputFormat (page.go:872)
         newPageContentOutput (page__per_output.go:65)
     Site.render (site.go:1787)
       Site.renderPages (site_render.go:71)
         pageRenderer (site_render.go:123)
           pageState.resolveTemplate
           Site.renderAndWritePage (site.go:1647)
             TemplateStore.PrepareTopLevelRenderCtx (templatestore.go:495)
             Site.renderForTemplate (site.go:1743)
               TemplateStore.ExecuteWithContext (templatestore.go:503)
                 ExecuteWithContextAndKey (507)
                   storeSite.executer.ExecuteWithContext
                   ← layout template runs; on .Content access:
                   │
                   pageContentOutput.Content (page__per_output.go:151)
                     cachedContentScope.contentRendered (page__content.go:492)
                       cachedContentScope.contentToC (646)
                         contentParseInfo.contentSource
                         pageContentOutput.initRenderHooks (page__per_output.go:227)
                           TemplateStore.LookupPagesLayout → hookRendererTemplate
                         shortcodeParseInfo.prepareShortcodesForPage (shortcode.go:536)
                           prepareShortcode (322) → shortcodeRenderFunc [lazy]
                         contentParseInfo.contentToRender (page__content.go:224)
                         hugocontext.DedentMarkers
                         pageContentOutput.ParseContent (page__per_output.go:420)
                           goldmarkConverter.Parse (convert.go:273)
                             goldmark.Parser().Parse → ast.Document
                       pageContentOutput.RenderContent (page__per_output.go:439)
                         goldmarkConverter.Render (convert.go:289)
                           goldmark.Renderer().Render (AST walk)
                             hookedRenderer.renderLink (render_hooks.go:229)
                               hookRendererTemplate.RenderLink (site.go:1711)
                                 TemplateStore.ExecuteWithContext ← render-link.html
                             hookedRenderer.renderHeading (render_hooks.go:452)
                               hookRendererTemplate.RenderHeading (site.go:1715)
                                 TemplateStore.ExecuteWithContext ← render-heading.html
                             htmlRenderer.renderCodeBlock (codeblocks/render.go:59)
                               hookRendererTemplate.RenderCodeblock (site.go:1719)
                                 TemplateStore.ExecuteWithContext ← render-codeblock.html
                               OR Chroma.RenderCodeblock
                       expandShortcodeTokens (shortcode.go:725)
                         shortcodeRenderFunc (shortcode.go:322)
                           doRenderShortcode (shortcode.go:357)
                             TemplateStore.LookupShortcode
                             [if inner+doMarkup]
                               goldmarkConverter.Convert (convert.go:312)
                                 goldmarkConverter.Parse
                                 goldmarkConverter.Render
                             renderShortcodeWithPage (shortcode.go:772)
                               TemplateStore.ExecuteWithContext ← shortcodes/foo.html
                       page.ExtractSummaryFromHTML*
             DestinationPublisher.Publish (publisher/publisher.go:94)
               createTransformerChain → URL rewriting, live-reload injection
               io.Copy → hugofs destination filesystem
```

---

### Key design observations

1. **Parse-then-render split for Goldmark.** `ParseContent` runs the Goldmark parser to produce an `ast.Document` (and the TOC) before any rendering happens. `RenderContent` then walks the already-parsed AST. This means TOC data is available without a full render.

2. **Two-pass shortcodes.** Shortcodes are first tokenised by `pageparser` (Phase 2) and replaced with placeholder tokens. Only after Goldmark has converted the surrounding Markdown to HTML are the tokens substituted back (`expandShortcodeTokens`). This lets Goldmark see the natural text flow (with placeholders) while shortcode HTML is injected post-render — which is why `{{% shortcode %}}` (doMarkup) inner content can itself pass through Goldmark.

3. **Render hooks bridge Goldmark → Go templates.** `hookRendererTemplate` is the glue: Goldmark's AST renderer calls it, and it calls `TemplateStore.ExecuteWithContext` with a typed context struct (`linkContext`, `headingContext`, `codeBlockContext`). If no user template exists, the default renderer or Chroma fires instead.

4. **Everything is lazy and cached.** `contentRendered` and `contentToC` both go through `GetOrCreate` cache keyed by scope + dependency version. Re-renders in server mode invalidate cache entries by bumping the `StaleVersion`.
