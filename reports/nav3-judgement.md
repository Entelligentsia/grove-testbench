# nav-3way — Judgement of the L1 + L5 cells (redis, django)

**Scope:** the four cells run so far — `L1-redis`, `L1-django`, `L5-redis`,
`L5-django` — each across all three arms (**baseline** = bash/text, **grove** =
structural MCP, **lsp** = Claude Code native LSP tool). n=1 per cell (descriptive,
not statistical).

**Method.** Each cell was graded by an independent blind judge against its offline
reference key (`experiment/prompts/<repo>/<rung>.reference.md`), with every sampled
citation re-verified against the pinned source (`experiment/repos/<repo>`). Two
axes, each 0–1:
- **completeness** — fraction of the key's required-spine elements correctly hit.
- **grounding** — fraction of the answer's `file:line` citations that resolve
  exactly in the pinned source (loose/❌ line numbers penalized).

Process metrics (context tokens, wall seconds) come from `side-metrics.sh` over the
stream-json transcripts in `evidence/nav3/`. Tooling: frozen all-language base,
**grove v0.1.9**, native LSP via `--plugin-dir experiment/lsp-plugin` (clangd for
redis, pyright for django), model **sonnet**. Judge records live in
`experiment/state.json` (`judge.*`); raw + readable transcripts in `evidence/nav3/`.

---

## Scoreboard

| cell | arm | completeness | grounding | context (tok) | run_s |
|---|---|---|---|---|---|
| **L1-redis** | baseline | 1.00 | 0.93 | 126,393 | 61 |
|  | grove | 1.00 | **0.97** | 275,201 | 71 |
|  | lsp | 1.00 | 0.95 | 192,777 | 70 |
| **L1-django** | baseline | 1.00 | 0.95 | 72,102 | 34 |
|  | grove | 1.00 | 0.80 | 103,084 | 44 |
|  | lsp | 1.00 | **1.00** | 127,173 | 42 |
| **L5-redis** | baseline | 1.00 | 0.88 | **1,578,920** | 191 |
|  | grove | 1.00 | **0.98** | 299,865 | 134 |
|  | lsp | 1.00 | 0.93 | 398,131 | 128 |
| **L5-django** | baseline | 1.00 | 1.00 | 182,567 | 110 |
|  | grove | 1.00 | 1.00 | 475,687 | 138 |
|  | lsp | 1.00 | 1.00 | 621,281 | 132 |

Every arm of every cell is **Full** on completeness. No key revisions were required
(the judges confirmed the keys accurate against source).

---

## Per-cell judgement

### L1-redis — the `redisObject` value container
All three Full; each centered the **type (logical) vs encoding (concrete)**
distinction and covered refcount / lru / ptr + the kvobj extras.
- **baseline (g 0.93):** grep→full Read; complete, a couple of loose lines
  (refcount sentinels `object.h:96-98`; `objectSetLRUOrLFU` at 189 not 188-190).
- **grove (g 0.97):** tightest cites via symbol/source tools; only `decrRefCount`
  off (gave 129-130, decr is at 128).
- **lsp (g 0.95):** clangd `workspaceSymbol` was empty cold, so it grep+Read
  anchored — still complete, correctly pinned type constants at `server.h:856`.

### L1-django — the `ResolverMatch` URL match object
All three Full; all correctly identify `ResolverMatch` (`urls/resolvers.py:34`).
- **lsp (g 1.00):** most line-precise — `func:48`, `view_class:64`, `url_name:51`,
  `_func_path:70-71`, `__getitem__:76-77` all exact; pyright resolved by name.
- **baseline (g 0.95):** accurate range cites, full spine.
- **grove (g 0.80):** content fully correct with verbatim excerpts, but **fewest
  explicit line numbers** — the only sub-0.9 grounding in the set.

### L5-redis — write → replication journey (cross-cutting)
All three traced the crux — `call` dirty-detection → deferred `alsoPropagate` →
`afterCommand`/`postExec`/`propagatePendingCommands` flush → `propagateNow` →
`replicationFeedSlaves`/`feedReplicationBuffer` — and named the queue-then-flush
indirection.
- **grove (g 0.98):** every sampled cite exact; cleanest bridge of propagation +
  transport subsystems.
- **lsp (g 0.93):** full chain; a couple of approximate line ranges (SELECT
  injection, RESP encoding).
- **baseline (g 0.88):** equally complete (went furthest into the per-replica
  socket write) but two loose cites; **cost 1.58M context tokens** (see below).

### L5-django — model save journey (cross-cutting)
Three-way tie at **1.00 / 1.00**. All traced `save → save_base → _save_table →
_do_update`/`_do_insert` → `QuerySet._update`/`_insert` → `compiler.execute_sql` →
`cursor.execute`.
- **lsp** marginally most granular (cited the exact `pre_save` signal line
  `base.py:976`, base `execute_sql:1595`); baseline/grove cite fewer signal lines
  but the difference is cosmetic.

---

## Cross-cell findings

1. **Answer quality does not separate the tools.** Completeness is at ceiling
   (Full) for all 12 arm-answers, including both L5 cross-cutting chains. With a
   capable model, text / structural / semantic navigation all *reach the complete,
   correct answer*.
2. **The only quality axis that moves is grounding (cite precision), and it is
   small and repo-dependent:**
   - redis (C): **grove tightest** (0.97 / 0.98) — structural symbol tools emit
     exact line cites; baseline loosest.
   - django (Python): **lsp tightest** (1.00 / 1.00) — pyright pins exact
     signal/attribute lines; **grove was the weakest single score (0.80, L1)** by
     giving verbatim code with few line numbers.
3. **The real differentiator is COST, not correctness.** The standout is
   **L5-redis baseline at 1.58M context tokens** (grep+read sprawl + a spawned
   subagent) vs grove 300k / lsp 398k — text search is ~4–5× more expensive to
   reach the same answer on a dense C cross-cutting trace.
4. **The cost advantage is repo/language-dependent, not universal.** On
   **L5-django the ordering inverts**: baseline is *cheapest* (183k) while
   grove/lsp cost more (476k / 621k) — Python's import structure let a few
   greps+reads suffice, whereas the tools fanned out across many symbols.
5. **lsp is consistently the heaviest-context tool arm** at L5 (398k / 621k), and
   **621k (L5-django lsp) is the most expensive tool-arm cell** measured.

---

## Caveats (read before citing these numbers)

- **n=1 per cell** — directional, not statistical; two repos, two rungs.
- **grove version:** all four cells' grove arm is **v0.1.9**; the redis L1 grove
  cell was re-run on v0.1.9 (leaner than the original v0.1.8: 275k vs 300k).
- **lsp ergonomics differ by server (documented):** clangd's `workspaceSymbol` is
  empty on a cold index, so the redis lsp arm grep/Read-anchors a position then
  `goToDefinition`; pyright resolves by name directly. This is the honest "LSP as
  deployed in Claude Code" behavior and is reflected in the transcripts.
- **Runaway watchdog is byte-based** (1.5 MB of jsonl) and did **not** catch
  L5-redis baseline's 1.58M-token blowup (its jsonl was only 272 KB) — token-cost
  and output-bytes diverge; a token-based guard would be needed to bound that.
- **Blind grading, objective criteria:** judges graded each answer on cite
  accuracy + spine coverage regardless of arm label; cites verified against the
  pinned source, not taken from the answers or the key.

Evidence: `evidence/nav3/{L1,L5}/{raw,readable}/`. Judge records:
`experiment/state.json` → `judge.{L1-redis,L1-django,L5-redis,L5-django}`.
