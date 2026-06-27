# nav-3way — Judgement of the completed cells (L1/L4/L5 · redis, django)

**Scope.** The five completed (rung,repo) cells — `L1-redis`, `L1-django`,
`L4-redis`, `L5-redis`, `L5-django` — each across all three arms (**baseline** =
bash/text, **grove** = structural MCP, **lsp** = Claude Code native LSP tool). 15
arm-cells, **n=1 per arm-cell (descriptive, not statistical)**. Format is locked —
see [`REPORT_FORMAT.md`](REPORT_FORMAT.md). L2/L3 not yet run.

**Method.** Each answer was graded **blind** against its offline reference key
(`experiment/prompts/<repo>/<rung>.reference.md`) by an independent judge, with
**every sampled citation re-verified against the pinned source**
(`experiment/repos/<repo>`). Two axes, each 0–1:
- **completeness** — fraction of the key's required-spine elements correctly hit
  (Full = 1.00).
- **grounding** — fraction of the answer's `file:line` cites that resolve exactly in
  pinned source (cite *accuracy*, not density).

**Provenance.**
- Model **sonnet**; base = frozen all-language `grove-testbench/base:latest`.
- **grove arm: all five cells re-run on grove v0.1.11** (image
  `grove-testbench/grove:v0.1.11`, the route-by-task steering) and **judged on those
  v0.1.11 transcripts**.
- **baseline + lsp arms: original runs** (not re-executed; neither uses the grove
  binary). lsp = native LSP via `--plugin-dir experiment/lsp-plugin` (clangd for
  redis, pyright for django).
- Repo pins: per-repo SHAs in `repos.manifest`. Evidence: `evidence/nav3/`. Judge
  records: `experiment/state.json` → `judge.*`.

---

## Scoreboard

| cell | arm | ctx (tok) | wall_s | turns | tool calls | capability calls | bash | read | compl | grnd |
|---|---|--:|--:|--:|--:|--:|--:|--:|:--:|:--:|
| **L1-redis** | baseline | 126,393 | 61 | 7 | 6 | – | 5 | 1 | 1.00 | 0.93 |
|  | grove | 267,978 | 84 | 13 | 12 | 3 | 7 | 1 | 1.00 | **1.00** |
|  | lsp | 192,777 | 70 | 9 | 8 | 1 | 5 | 1 | 1.00 | 0.95 |
| **L1-django** | baseline | 72,102 | 34 | 3 | 2 | – | 1 | 1 | 1.00 | 0.95 |
|  | grove | 101,968 | 65 | 4 | 3 | 2 | 0 | 0 | 1.00 | **1.00** |
|  | lsp | 127,173 | 42 | 5 | 4 | 2 | 0 | 1 | 1.00 | 1.00 |
| **L4-redis** | baseline | 309,894 | 113 | 19 | 18 | – | 7 | 11 | 1.00 | 0.98 |
|  | grove | 359,299 | 119 | 23 | 22 | 21 | 0 | 0 | 1.00 | 0.98 |
|  | lsp | 566,133 | 153 | 29 | 28 | 13 | 3 | 11 | 1.00 | 0.97 |
| **L5-redis** | baseline | **1,578,920** | 191 | 2 | 51 | – | 27 | 23 | 1.00 | 0.88 |
|  | grove | 387,167 | 189 | 24 | 23 | 18 | 1 | 3 | 1.00 | **1.00** |
|  | lsp | 398,131 | 128 | 22 | 21 | 10 | 0 | 10 | 1.00 | 0.93 |
| **L5-django** | baseline | 182,567 | 110 | 9 | 8 | – | 3 | 5 | 1.00 | 1.00 |
|  | grove | 515,693 | 143 | 26 | 25 | 23 | 0 | 0 | 1.00 | 1.00 |
|  | lsp | 621,281 | 132 | 16 | 15 | 6 | 1 | 7 | 1.00 | 1.00 |

Every arm of every cell is **Full** on completeness. grove grounding is exact
(1.00) on four of five cells and 0.98 on L4 (one loose extra-credit cite).

---

## Per-cell judgement

### L1-redis — the `redisObject` value container
All Full. **grove (g 1.00):** struct at `object.h:100`, type/encoding constants
`75-88`, all six spine fields with the type-vs-encoding distinction; every cite
exact. **lsp (0.95):** grep+Read-anchored after a cold clangd index, type constants
at `server.h:856`. **baseline (0.93):** complete, a couple of loose lines.

### L1-django — the `ResolverMatch` URL match object
All Full. **grove (g 1.00):** `ResolverMatch` at `resolvers.py:34` exact, the
namespacing chain and `__getitem__` triple verbatim-correct — line-number-light but
every cite resolves (up from 0.80 on the v0.1.9 run, which was docked for cite
density; grounding scores accuracy, not density). **lsp (1.00):** most line-precise.
**baseline (0.95):** accurate ranges, full spine.

### L4-redis — non-blocking RDB snapshot (background save)
All Full. **grove (g 0.98):** all four pieces (launch/fork → child `rdbSave` →
childinfo progress pipe → reap+finalize); pure-grove navigation (21 calls), every
cite exact bar one loose extra-credit (`dismissKvstoreBucketsMemory` labelled 1913,
actual 1904). **baseline (0.98):** cheapest (310k); best on the progress throttle
(`rdb.c:1855`). **lsp (0.97):** strong child-write depth. Deep-dive:
[`nav3-L4-redis-judgement.md`](nav3-L4-redis-judgement.md).

### L5-redis — write → replication journey (cross-cutting)
All Full. **grove (g 1.00):** the full `call`→dirty→deferred `alsoPropagate`→
`afterCommand`/`postExec`/`propagatePendingCommands`→`propagateNow`→
`replicationFeedSlaves` chain, every sampled cite exact — tightest grounding here.
**lsp (0.93):** full chain, a couple approximate ranges. **baseline (0.88):** equally
complete but **1.58 M context tokens** (grep+read sprawl) and two loose cites.

### L5-django — model save journey (cross-cutting)
All Full, grove/lsp/baseline all 1.00 grounding. **grove:** `save`→`save_base`→
`_save_table` update-first/insert-fallback → `_do_insert`/`_insert`→
`compiler.execute_sql`→`cursor.execute`, with the insert-vs-update compiler split
confirmed; every cite exact.

---

## Findings

1. **Answer quality never separates the tools.** Completeness is at ceiling (Full)
   for all 15 arm-answers, including both L5 cross-cutting chains. With a capable
   model, text / structural / semantic navigation all reach the complete answer.
2. **Grounding is high everywhere and now exact for grove** (1.00 on four of five
   cells, 0.98 on L4). On the v0.1.11 steering grove gives fewer but exact cites; the
   old grove weak spot (L1-django 0.80) was a cite-*density* artifact, not inaccuracy.
3. **The real differentiator is COST, and it is task-shaped, not tool-shaped:**
   - **L5-redis baseline = 1.58 M tokens** (51 tool calls, 27 bash + 23 read in 2
     parallel-fan turns) vs grove 387 k / lsp 398 k — text search is ~4× more
     expensive on a dense C cross-cutting trace.
   - **L4-redis inverts none of that but L4 is where structural tooling's *old*
     rigidity hurt:** under the pre-v0.1.11 steering grove fanned out to 560 k; the
     route-by-task steering brought it to 359 k (−36%) at no quality cost.
   - **L1 and L5-django:** baseline is *cheapest* (72 k, 183 k) — few greps suffice on
     small/well-named targets; the tools fan out for more.
4. **grove combines opportunistically under v0.1.11 — variably.** L1-redis grove used
   7 bash + 1 read alongside 3 grove; L5-redis 1 bash + 3 read; but L4-redis and both
   django grove runs went pure-grove (0 shell). The shell-combine is available and
   used when it's the shortest path, not uniformly — n=1 stochastic.
5. **lsp consistently read-anchors** (every lsp cell pairs LSP calls with 1–11 reads
   to get a position) and is the heaviest tool-arm at L5 (621 k django).
6. **`turns` can mislead** — L5-redis baseline shows 2 turns / 51 tool calls (huge
   parallel grep+read fans). Read `tool calls`, not `turns`, for effort.

---

## Caveats

- **n=1 per arm-cell** — directional, not statistical; two repos, three rungs.
- **Engagement gate ≠ completeness** — the run gate only confirms the arm used its
  capability + no harness error; quality is the judging above.
- **Mixed provenance** — grove rows are v0.1.11 (re-run + re-judged); baseline/lsp
  rows are original runs (neither uses grove, so version is moot for them, but they
  were not re-executed).
- **Byte-watchdog is byte-based** (1.5 MB jsonl) and did **not** catch L5-redis
  baseline's 1.58 M-token blow-up (jsonl ~270 KB) — token cost and output bytes
  diverge; a token-based guard would be needed to bound that.
- **Blind grading, objective criteria** — cites verified against pinned source, not
  taken from the answers or the key.

---

Evidence: `evidence/nav3/{L1,L4,L5}/{raw,readable}/`.
Judge records: `experiment/state.json` → `judge.{L1,L4,L5}-{redis,django}`.
