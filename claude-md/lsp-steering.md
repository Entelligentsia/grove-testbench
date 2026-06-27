<!-- lsp:start -->
## INVARIANT — code navigation goes through the LSP server

Every where-is / who-calls / what-is-the-type action in this project goes through
the **lsp** MCP server (a real language server — clangd/pyright/etc — resolving
symbols through the compiler's own type model). This is not a preference. `grep`,
`rg`, `read`, `cat`, and `sed` on a source file are FALLBACKS, allowed only after
the lsp server has been tried and returned insufficient content. Running
`grep -rn '<symbol>'`, or reading a whole source file, as your first action on a
code question is a steering violation.

The lsp tools are **deferred** MCP tools — the moment a code question arrives,
load their schemas with ToolSearch (do not default to a search agent or grep):
`mcp__lsp__definition`, `mcp__lsp__references`, `mcp__lsp__hover`. Use only this
read-only subset; do NOT use `rename_symbol` or `edit_file`.

**Trigger — check before every tool call.** If the prompt contains any of — a
file path, a function / type / struct / macro name, or the words "where is",
"what does X define", "who calls", "show me", "find", "list" — your FIRST tool
call MUST be an lsp tool. Otherwise the lsp server is optional.

**Procedure.**
1. Symbol by name (function, type, struct, macro, constant) → `mcp__lsp__definition`
   with `symbolName`. Returns the definition's file, line range, and source body —
   resolved by the compiler, not by string match.
2. "who calls" / "where is this used" → `mcp__lsp__references` with `symbolName`.
   Returns every use site across the whole project.
3. "what is the type of X here" / "what does this expression resolve to" →
   `mcp__lsp__hover` with `filePath`, `line`, `column` (the exact position).
4. The server is name-based for definition/references: ask for the symbol by name,
   it resolves via the project index — no file:line needed for those two.

**Cross-file.** `mcp__lsp__definition` (jump to the canonical definition) →
`mcp__lsp__references` (all use sites, type-resolved). Do NOT `grep -rn '<type>' .`
instead — grep returns string matches; the lsp server returns the actual
compiler-resolved definition and references, disambiguating overloads, shadowing,
and same-named symbols in different scopes.

**Recovery (empty / not-found).** A single lsp miss does NOT justify switching to
grep for later questions — retry the query (the symbol name exactly as declared),
or use `mcp__lsp__hover` at a known occurrence to anchor resolution, then continue.
Only after a genuine miss may you fall back to `read` with `offset`/`limit` (never
the whole file).

`read` on a 1700-line file floods context with ~50 KB you don't need; `grep`
misses struct/function boundaries and conflates same-named symbols. The lsp server
answers from the compiler's type model — precise, line-exact, and source-quoted.
<!-- lsp:end -->
