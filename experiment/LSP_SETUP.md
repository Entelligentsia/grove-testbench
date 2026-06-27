# LSP arm — setup approach & complexity discovered

**Status:** bridge proven; per-repo indexing is the open work. This note records
the architecture, what's verified, the friction we hit, and the spec for the
per-repo LSP setup step. It is also primary evidence for the experiment's
**complexity / setup-time** axis (the LSP arm's defining cost).

## Architecture

The `lsp` arm gives a Claude Code agent **semantic** navigation (the language
server's own go-to-definition / find-references, resolved through the compiler's
type model) via an MCP→LSP bridge.

- **Bridge:** `isaacphi/mcp-language-server` (Go; built with Go 1.24 in
  `Dockerfile.lsp`, ~7.6 MB binary). Wraps exactly ONE LSP server per process.
- **Image:** `grove-testbench/lsp:latest` = base + the bridge + servers:
  `clangd` (apt), `typescript-language-server` + `typescript`, `pyright`,
  `intelephense` (npm global). Heavier toolchains (`gopls`/Go, `rust-analyzer`/Rust,
  `ruby-lsp`/Ruby, `jdtls`/Java) layer on as those repos are wired.
- **Bridge CLI:** `mcp-language-server -workspace <dir> -lsp <cmd> -- <lsp-args>`.
- **Per-repo MCP config** (what the lsp setup writes; runtime passes it via
  `run-side.sh --mcp-config`):
  ```json
  { "mcpServers": { "lsp": { "command": "mcp-language-server",
      "args": ["-workspace","/home/bench/repos/<repo>","-lsp","<server>","--","<args>"] } } }
  ```
- **Tools exposed** (verified via `tools/list`): `definition`(symbolName),
  `references`(symbolName), `hover`(filePath,line,column), `diagnostics`(filePath),
  `rename_symbol`, `edit_file`. We use the **read-only** subset
  (definition/references/hover); the agent is steered away from rename/edit.
  `definition`/`references` are **name-based** — the agent asks for a symbol by
  name and the bridge resolves it (via `workspace/symbol`) then queries the
  server. No file:line:col needed — clean ergonomics, and tool calls surface as
  `mcp__lsp__*` (counted as `mcp_nongrove_tools` by `side-metrics.sh`).

## Verified

On a controlled 2-file TS project (`a.ts` defines `class Foo`, `b.ts` uses it):
- `definition(Foo)` → `a.ts L1:C1–L3:C2`, with the source quoted. Line-exact.
- `references(Foo)` → `b.ts`, both use sites. Correct.

So the **bridge mechanism is sound**: name-based, line-exact, source-quoted. The
MCP↔LSP↔server path works end to end.

## Complexity discovered (the core finding)

The bridge is the easy part. The cost — and it is large and uneven — is getting
each language server to **index its (large, real) repo** before it can answer.
Concrete observations on `grove-testbench/lsp`:

| pairing | result | cause |
|---|---|---|
| typescript-language-server × webpack (JS) | `definition(Compiler)` → **"not found"** | no `tsconfig`/`jsconfig` at root → tsserver runs files in "inferred project" mode, no whole-repo `workspace/symbol` |
| pyright × django (Python) | `definition(QuerySet)` → **timeout (>120 s)** | large codebase; pyright workspace indexing not finished when queried |
| clangd × redis/bitcoin (C/C++) | (not yet) | clangd needs a **compile DB** (`compile_flags.txt` or `compile_commands.json`) before it resolves anything cross-file |

The failure mode matters for **fairness**: an un-warmed server doesn't just answer
*slowly*, it answers *wrong/empty* (races the index). Recording such a run would
understate LSP quality. So the LSP arm **must** warm up + configure each repo
before the agent runs — a per-repo setup the other two arms simply don't have
(baseline ≈ 0 setup; grove = one uniform `grove serve`).

This asymmetry IS the result: **semantic tooling buys precision at a real,
uneven, per-language operational cost.** That cost is captured as `setup_s` + the
complexity scorecard, and reported alongside context/time/quality.

## Per-repo setup matrix

| repo | lang | server | extra toolchain | per-repo config | index weight |
|---|---|---|---|---|---|
| redis | C | clangd | — (clangd in image) | `compile_flags.txt` (or `compile_commands.json`) | moderate (~150k LOC) |
| bitcoin | C++ | clangd | — | `compile_commands.json` (cmake) | heavy |
| django | Python | pyright | — (node) | none; pyright infers | slow index |
| webpack | JS | typescript-language-server | — (node) | add `jsconfig.json` | moderate |
| typescript | TS | typescript-language-server | — (node) | `tsconfig` present | heavy (huge repo) |
| laravel | PHP | intelephense | — (node) | none; intelephense indexes | moderate |
| rails | Ruby | ruby-lsp | + ruby/gem | install `ruby-lsp` | moderate |
| hugo | Go | gopls | + go | go modules resolved | moderate |
| tokio | Rust | rust-analyzer | + rust | `cargo metadata` | heavy |
| spring-boot | Java | jdtls | + java | gradle/maven import | heavy |

## The per-repo LSP setup step (spec)

For each `(lsp, <repo>)`, the setup step does, in order:

1. **Toolchain** — ensure the server + its language runtime exist (node servers are
   already in the image; go/rust/ruby/java repos add their toolchain in an image layer).
2. **Configure** — write the per-repo config the server needs (`compile_flags.txt`
   for clangd, `jsconfig.json` for webpack, etc.).
3. **Warm up + persist** — start the server and let it fully index, persisting the
   index cache (clangd `.cache/clangd/`, pyright/tsserver caches, etc.) so runtime
   queries are fast and correct. **Clock this as `setup_s`.** Persistence path:
   bake the warmed index into a per-repo image layer, or mount a host-built cache —
   decided per server.
4. **Cheap verification run** — drive the bridge directly (MCP `tools/call`,
   like `experiment/repos`-grounded probes) and assert a known symbol resolves
   **line-exact** before the arm is allowed to run. Gate: no warm, no run.
5. **Record (validated state)** — `statectl setup-set lsp/<repo> ready=true
   setup_s=<n> index_log="..."` and store the bridge MCP-config path. Only then
   does `statectl next` consider that repo's lsp cells runnable
   (`sideReady` checks `setup[lsp/<repo>].ready`).

Runtime (`/runarm` lsp cell): `run-side.sh ... lsp --lsp grove-testbench/lsp:latest
--mcp-config <bridge-config>`, with the warmed index available in-container.

## Complexity scorecard (emerging)

| arm | setup per repo | uniformity | one-time vs per-repo |
|---|---|---|---|
| baseline | none | n/a | none |
| grove | `grove serve` | uniform across all 10 | one-time |
| **lsp** | toolchain + config + warm index + verify | **highly uneven** (node-only vs clangd/cargo/gradle) | **per-repo** |

## Open items

- redis/clangd: generate `compile_flags.txt`, warm clangd, verify, wire — first cell.
- Index persistence mechanism per server (image layer vs mounted cache).
- Add go/rust/ruby/java toolchains + their servers as those repos are wired.
- Confirm `mcp-language-server` waits for / surfaces index readiness, or add a
  warm-up gate so the agent never queries an un-indexed server.
