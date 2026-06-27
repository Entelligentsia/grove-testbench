# HANDOFF — nav-3way experiment (resume point)

**Branch:** `experiment/nav-3way` (off `master`). Not pushed.
**Last milestone:** **L1-redis is COMPLETE across all 3 arms + blind-judged.** The
LSP per-repo setup is productionized (warmed `lsp:redis` image + bridge config +
verification gate, setup recorded in the ledger). All 15 redis cells: 3 harvested
(L1×3), 12 pending (L2–L5×3).
**Immediate task:** fan out — `/exp-prep` the other 9 repos, then run the matrix.
Before automating multi-repo LSP warm: rebuild `base` so `bear` is baked in (the
redis warm image got `bear` ad-hoc; base still lacks it — verified).

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
- **Tool-arm steering is SYMMETRIC (fairness).** The two tooled arms each get a
  steering `CLAUDE.md` that points the agent at its capability — grove's block is
  baked by `grove init`; lsp's is `claude-md/lsp-steering.md`, injected by
  `run-side.sh` (base.md + block). baseline stays VANILLA (text only) by design.
  This was discovered the hard way: without lsp steering the agent ignored the
  (deferred, ToolSearch-gated) `mcp__lsp__*` tools and just grepped → 0 engagement.
  Both arms' MCP tools are deferred; steering is what makes the agent load+use them.
- Build tools (make/gcc/bear, later go/rust/jdk/ruby) live in **base** = uniform
  across all arms; only the build *execution* is LSP's per-repo setup cost.

## Key artifacts (where things are)
- **Spine/ledger:** `experiment/spine.json` (def), `experiment/state.json` (progress).
- **State CLI:** `experiment/statectl/` (TS+zod, run via `statectl` wrapper).
- **Prompts (redis):** `experiment/prompts/redis/{L1..5.txt, L*.reference.md, RATIONALE.md}` — proven template/anchor.
- **Pinned source:** `experiment/repos/<repo>` (gitignored, SHA-verified == images). Re-clone: `experiment/clone-source.sh [--repo NAME]`.
- **Skills:** `.claude/skills/exp-prep/` (onboard a repo: clone→generate→verify→register), `.claude/skills/runarm/` (drive one cell: preflight→run→verify→harvest→record).
- **Runners:** `scripts/run-side.sh` (`--prompt`, arms baseline|grove|lsp, tmpfs), `experiment/side-metrics.sh` (per-side metrics + engagement signals).
- **Subagent activity & metrics:** in claude 2.1.193 a Task/Agent subagent's tool
  calls + tool_results ARE interleaved into the parent stream-json as assistant
  events tagged `parent_tool_use_id` (NOT flagged `isSidechain`). So `side-metrics.sh`
  (counts all assistant `tool_use`) and `context_tokens` (session-level `modelUsage`,
  multi-model) ALREADY reflect subagent work — the engagement gate counts delegated
  grove/lsp/bash calls, so delegation won't falsely block a cell. Verified on a forced
  delegation: subagent's 2 Bash calls showed up as parent `bash_calls=2`.
- **Subagent standalone transcripts:** claude ALSO writes each subagent's isolated
  session to `~/.claude/projects/**/subagents/agent-*.jsonl` (the tmpfs destroys it on
  `--rm`). `run-side.sh` copies these out (inside the container, chmod a+r) to
  `out/exp/<scene>.claude.<arm>.subagents/` and prints the count; runarm step 4 files
  them into `evidence/nav3/<rung>/raw/subagents/`. These are REDUNDANT for metrics
  (same calls already counted in the parent stream — do NOT add them to side-metrics,
  it would double-count) — kept as clean human-readable evidence + a fallback if a
  future claude stops interleaving. (L1-redis spawned none.)
- **Evidence:** harvested to `evidence/nav3/<rung>/{raw,readable}/` (none kept yet — L1-redis was a reset dry run).
- **LSP:** `Dockerfile.lsp`, `experiment/lsp/lsp-seed.py` (seed-open proxy).

## The LSP recipe — PRODUCTIONIZED for redis (template for the other 9)
Three obstacles solved (see `LSP_SETUP.md`): (1) real build for a complete index,
(2) `--compile-commands-dir`, (3) seed a `didOpen` so cold `workspace/symbol`
resolves. **redis is done end-to-end:**
- **Warmed image** `grove-testbench/lsp:redis` (digest in `state.json` setup) =
  committed from the `warm-redis` container (real `bear` `compile_commands.json`
  + 9.5M clangd `.cache`), then layered with `lsp-seed.py`. setup_s≈2749 (build+warm wall).
- **Bridge config** `experiment/lsp/mcp-redis.json` (seed = `src/server.c`); pass to
  `run-side.sh --lsp grove-testbench/lsp:redis --mcp-config experiment/lsp/mcp-redis.json`.
- **Verification gate** `experiment/lsp/verify-bridge.py <symbol> <expect> -- <bridge…>`
  drives the real MCP path (NDJSON transport!) and asserts line-exact resolution.
  Proven: `definition(dictAdd)` → `src/dict.c:493`. `time-bridge.py` measures cold
  readiness (≈1s to tools+first resolve on the warm image — NOT a timeout risk).
- **CAVEAT (transport):** the bridge speaks MCP = newline-delimited JSON-RPC upstream,
  LSP Content-Length framing downstream to the server. Test clients must use NDJSON.

Per-repo runtime bridge invocation (what the MCP config encodes):
```
LSP_SEED_FILE=/home/bench/repos/<repo>/<a-source-file>
mcp-language-server -workspace /home/bench/repos/<repo> \
  -lsp python3 -- /usr/local/bin/lsp-seed.py clangd \
  --background-index --compile-commands-dir=/home/bench/repos/<repo>
```

## DONE (this session)
- ✅ Warmed `grove-testbench/lsp:redis` committed + seed proxy layered; bridge
  config `experiment/lsp/mcp-redis.json`; gate proven (`verify-bridge.py`).
  `statectl setup-set lsp/redis ready=true setup_s=2749 image_digest=…`.
- ✅ Discovered + fixed the lsp **steering** fairness gap (`claude-md/lsp-steering.md`
  + `run-side.sh` injection). See the symmetric-steering invariant above.
- ✅ Ran **L1-redis all 3 arms** (grove/baseline/lsp), all engaged, all harvested to
  `evidence/nav3/L1/`. Metrics in `state.json`: baseline 126k/61s, grove 300k/108s,
  lsp 213k/76s.
- ✅ **Judged L1-redis** (`statectl judge-set L1-redis`): all three Full;
  differentiation is in process metrics not L1 quality. Key revision recorded:
  type constants pinned to `src/server.h:856` (key had omitted the location).

## NEXT STEPS (ordered, actionable)
1. **Rebuild `base`** so `bear` is baked in (verified missing), then `grove` →
   `lsp` (`FROM base`). Needed before automating other-repo LSP warm. Does NOT
   affect the self-contained `lsp:redis`. Re-verify grove `cargo`-clean / v0.1.8.
2. **Automate per-repo LSP setup** — script/skill that, from `lsp:latest`: real
   build (`bear -- make` for C / language-appropriate for others), warm the server
   (didOpen, persist cache), pick seed file, `docker commit grove-testbench/lsp:<repo>`,
   write `experiment/lsp/mcp-<repo>.json`, run `verify-bridge.py` gate, record
   `setup_s` + `statectl setup-set`. (redis is the worked template.)
3. **Run L2–L5 redis** (12 cells) — same runarm flow; L3/L4/L5 need the 1.5MB
   runaway watchdog (`spine.watchdog`; generalize the L5 one) before they run.
   Judge each (rung,repo) once all 3 arms harvested.
4. **Fan out:** `/exp-prep <repo>` for the other 9 (GENERATOR_BRIEF + redis as
   calibration anchor); run the matrix one cell at a time, paced over 5-hr windows.

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
