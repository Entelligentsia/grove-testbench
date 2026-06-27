# HANDOFF — nav-3way experiment (resume point)

**Branch:** `experiment/nav-3way` (off `master`). Not pushed.
**Last milestone:** the **LSP arm works end-to-end** (redis/clangd, line-exact).
**Immediate task:** productionize the LSP per-repo setup, then run `L1-redis`
across all 3 arms and judge it; then fan out.

Read these first (they are the source of truth, don't re-derive):
`experiment/DESIGN.md` · `experiment/PROMPT_GENESIS.md` · `experiment/LSP_SETUP.md`
· `experiment/GENERATOR_BRIEF.md` · `experiment/spine.json`.

---

## What the experiment is
Authoritative-as-to-what-it-reveals blog: **which code-introspection tooling
serves coding agents best, and why** — three arms, only the navigation capability
differs, across a 5-level task ladder over 10 pinned repos. n=1/cell (descriptive,
not statistical). 4 weighed metrics: context, time (run+setup), complexity, blind
answer quality.

- **baseline** = bash+coreutils (text). Image `grove-testbench/base:latest`, no MCP.
- **grove** = + grove MCP/CLI (structural). Image `grove-testbench/grove:v0.1.8`.
- **lsp** = + LSP via MCP→LSP bridge (semantic). Image `grove-testbench/lsp:latest`.

Matrix = 5 rungs × 3 arms × 10 repos = **150 per-side cells**. Only **redis** is
prepped + registered so far (15 cells, all `pending`).

## Hard invariants (do NOT violate)
- **`experiment/statectl/statectl` is the ONLY writer of `state.json`.** Never
  Edit/Write/jq it. Verbs: validate, register, status, next, reset, block,
  set-status, record, setup-set, judge-set, reconcile. (zod-validated, atomic.)
- **Prompt genesis is walled off from runtime.** Runtime sees ONLY
  `experiment/prompts/<repo>/<rung>.txt`. Reference keys / rationale stay offline.
- **Run one side at a time, pristine.** `run-side.sh` mounts `/home/bench/.claude`
  as a fresh tmpfs per run (fixed two fairness bugs: Bash EACCES, and cross-arm
  `.claude` contamination). The verify gate checks `eacces==0` + engagement.
- **Security:** `base`/`grove`/`lsp` images are NEVER published (creds mounted at
  runtime). Commits: no `Co-Authored-By`/agent attribution. Branch before
  committing to master. Conventional commits. Files end with newline.
- Build tools (make/gcc/bear, later go/rust/jdk/ruby) live in **base** = uniform
  across all arms; only the build *execution* is LSP's per-repo setup cost.

## Key artifacts (where things are)
- **Spine/ledger:** `experiment/spine.json` (def), `experiment/state.json` (progress).
- **State CLI:** `experiment/statectl/` (TS+zod, run via `statectl` wrapper).
- **Prompts (redis):** `experiment/prompts/redis/{L1..5.txt, L*.reference.md, RATIONALE.md}` — proven template/anchor.
- **Pinned source:** `experiment/repos/<repo>` (gitignored, SHA-verified == images). Re-clone: `experiment/clone-source.sh [--repo NAME]`.
- **Skills:** `.claude/skills/exp-prep/` (onboard a repo: clone→generate→verify→register), `.claude/skills/runarm/` (drive one cell: preflight→run→verify→harvest→record).
- **Runners:** `scripts/run-side.sh` (`--prompt`, arms baseline|grove|lsp, tmpfs), `experiment/side-metrics.sh` (per-side metrics + engagement signals).
- **Evidence:** harvested to `evidence/nav3/<rung>/{raw,readable}/` (none kept yet — L1-redis was a reset dry run).
- **LSP:** `Dockerfile.lsp`, `experiment/lsp/lsp-seed.py` (seed-open proxy).

## The proven LSP recipe (redis/clangd) — productionize this
Three obstacles solved (see `LSP_SETUP.md`): (1) real build for a complete index,
(2) `--compile-commands-dir`, (3) seed a `didOpen` so cold `workspace/symbol`
resolves. Runtime bridge config per repo:
```
LSP_SEED_FILE=/home/bench/repos/<repo>/<a-source-file>
mcp-language-server -workspace /home/bench/repos/<repo> \
  -lsp python3 -- /usr/local/bin/lsp-seed.py clangd \
  --background-index --compile-commands-dir=/home/bench/repos/<repo>
```
(`warm-redis` container still holds a built+warmed redis — but prefer a clean
rebuild + automated warm over committing that ad-hoc container.)

## NEXT STEPS (ordered, actionable)
1. **Rebuild images** (build tools moved to base): rebuild `base` → `grove` → `lsp`
   (both are `FROM base`). `Dockerfile.base` now installs `bear`.
2. **Automate per-repo LSP setup** — a script/skill that, in a container from
   `lsp:latest`: runs the real build (`bear -- make` for C), warms clangd
   (didOpen, persist `.cache/clangd`), picks a seed file, **`docker commit`s a
   warmed `grove-testbench/lsp:<repo>` image**, writes the per-repo bridge MCP
   config, records `setup_s`, and `statectl setup-set lsp/<repo> ready=true
   image_digest=...`. (Decision: one-time baked warmed image per repo, amortized
   over its 5 lsp rungs — settles DESIGN's setup_s-amortization open item.)
3. **Run `L1-redis` all 3 arms** via the runarm flow (grove first = MCP route):
   `statectl set-status` → `run-side.sh redis-L1 redis <arm> --model sonnet
   --out out/exp --prompt experiment/prompts/redis/L1.txt [--grove <img> | --lsp
   <warmed-img> --mcp-config <bridge-cfg>]` → verify gate via `side-metrics.sh`
   (has_result, eacces==0, engagement: baseline bash>0 / grove grove_tools>0 / lsp
   mcp_nongrove>0) → harvest to `evidence/nav3/L1/` → `statectl record` +
   `set-status harvested`. (lsp engagement = mcp_nongrove_tools>0.)
4. **Judge** the redis-L1 cell (all 3 arms) blind against `L1.reference.md`
   (judge may revise the key under audit — see PROMPT_GENESIS).
5. **Fan out:** `/exp-prep <repo>` for the other 9 (uses GENERATOR_BRIEF + redis
   as calibration anchor), then run the matrix one cell at a time, paced over
   5-hr windows. L3/L4/L5 need a 1.5MB runaway watchdog (generalize the L5 one).

## Open (mostly resolved; confirm if re-deciding)
- setup_s persistence → **warmed per-repo image** (recommended above).
- per-language LSP toolchains (go/rust/jdk/ruby) added to base as repos are wired.
- blind-judge mechanism (in-runarm vs separate pass); complexity scorecard fields;
  planned order (L1-first shakedown). See DESIGN "Open red-lines".

## Resume prompt (paste after compaction)
> Resume the nav-3way experiment from `experiment/HANDOFF.md` on branch
> `experiment/nav-3way`. Proceed with NEXT STEPS: rebuild base→grove→lsp, then
> productionize the per-repo LSP setup (warmed image), then run L1-redis across all
> three arms and judge it.
