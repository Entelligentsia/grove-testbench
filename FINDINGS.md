# grove-testbench — findings

Evaluation log. One section per repo. Each records the prompt-complexity sweep
(context tokens), time/turns, and **blind-judged answer quality verified against
the pinned source**. Candidate grove fixes surfaced here are tracked in
[GROVE-ISSUES.md](GROVE-ISSUES.md) and filed against the grove repo in a batch
once all repos are evaluated.

## Method

- **Setup:** same agent (Claude, `--model sonnet`), same prompt, grove off (`baseline`)
  vs on (`grove`). Fair base steering (`claude-md/<repo>.base.md`) on **both** sides;
  `grove` additionally carries its `grove init` block. Grove is the only variable.
- **Ladder:** `scenes/<repo>.ladder.tsv`, escalating reading breadth —
  L1 single symbol → L2 call sites → L3 flow trace → L4 subsystem → L5 architecture.
- **Driver:** `scripts/optimize-prompt.sh <repo> --model sonnet --keep` → races
  both sides per rung, writes `out/<repo>.optimize.json`.
- **Axes:** context tokens (`input+cache_read+cache_creation`), `duration_ms`,
  `num_turns`, and answer quality (independent judge per rung, claims verified
  against the pinned source in the `grove` image).
- **Caveat:** results below are **n=1 per rung** unless noted. Variance is large;
  treat single-rung wins as directional until reproduced (≥3×/side).

---

## redis (C) — evaluated 2026-06-23, model sonnet

### Context tokens (lower = better)

| Rung | Prompt class | baseline ctx | grove ctx | Δ | ctx winner |
|---|---|---|---|---|---|
| L1 | single symbol def | 73,499 | 77,182 | +5% | baseline |
| L2 | def + all call sites | 53,725 | 82,093 | +53% | baseline |
| **L3** | **flow trace (dispatch→keyspace)** | **455,508** | **265,396** | **−42%** | **grove** |
| L4 | subsystem end-to-end | 160,897 | 289,163 | +80% | baseline |
| **L5** | **cross-cutting architecture** | **1,541,835** | **631,035** | **−59%** | **grove** |

Grove's context wins are **prompt-class-specific, not complexity-monotonic**:
L3 (flow trace — forces the baseline to read whole files chasing a call chain) and
L5 (architecture — the baseline delegates to a haiku `Explore` subagent that
churns 1.49M tokens, dwarfing grove's own over-read). It loses L1/L2 (cheap grep)
and L4. L5's "win" is hollow: grove's own 631k is a GI-3 over-read — it only beats baseline
because baseline was worse (1.54M via subagent), not because grove was efficient.

### Time & turns (lower = better)

| Rung | baseline time | grove time | time winner | baseline turns | grove turns | turns winner |
|---|---|---|---|---|---|---|
| L1 | 8s | 10s | baseline | 3 | 3 | tie |
| L2 | 66s | 66s | baseline | 2 | 4 | baseline |
| L3 | 78s | 94s | baseline | 24 | 19 | **grove** |
| L4 | 55s | 101s | baseline | 9 | 16 | baseline |
| L5 | 181s | 182s | baseline | 2* | 30 | baseline |

**Baseline wins wall-clock on every rung**, including L3. Grove wins turns only at
L3. (*L5 baseline's 2 turns / 47 tools = 1 parent `Agent` call delegating to a haiku
`Explore` subagent that ran 46 greps; the subagent's turns aren't in `num_turns`,
but its 1.49M context is counted in the ctx column above.)

### Answer quality (blind judges; A=baseline, B=grove; verified vs pinned source)

| Rung | Better | Margin | Key finding |
|---|---|---|---|
| L3 | **baseline** | wide | grove **fabricated** `db->dict` (real: `db->keys`) and `dbAddByLink→dictAdd`; stopped short of the dict insert the prompt demanded. baseline traced it correctly (9/9 claims verified). |
| L4 | **baseline** | modest | Both call graphs correct; grove had a **systematic −1 off-by-one** on nearly every line cite. No fabrications. |
| L5 | baseline | slight (~tie) | grove more detailed (extra replica-side) but **fabricated** `handleClientsWithPendingWritesUsingThreads` (nonexistent). baseline: zero fabrications. |

### Verdict (redis)

Grove's measurable context wins are L3 (−42%) and L5 (−59%) — and both winning
rungs produced grove's **worst** answers: L3 fabricated `db->dict`/
`dbAddByLink→dictAdd`, L5 fabricated `handleClientsWithPendingWritesUsingThreads`.
The L5 context win is hollow — grove's own 631k is a GI-3 over-read; it only beats baseline
because baseline delegated 1.49M to a subagent. Grove was **slower on every rung** and
**lower-quality on every deep rung**. The "grove wins" premise does **not** hold on
redis as configured.

### Grove issues surfaced → [GROVE-ISSUES.md](GROVE-ISSUES.md)

- **GI-1 off-by-one line numbers** — agent echoes grove's `@row` symbol-id (likely
  0-indexed) as a 1-indexed line; consistent −1 drift across L4.
- **GI-2 thin slices → weak grounding → confabulation** — grove's token-cheap
  slices omit the surrounding context the model needs, so it invents the gaps
  (`db->dict`, `dictAdd`, `handleClientsWithPendingWritesUsingThreads`); the
  whole-file baseline stayed correct. Core tension: fewer tokens, weaker grounding.
- **GI-3 over-read blow-ups** — on broad prompts (L5) grove usage ballooned to
  631k context (29 tool calls). (The baseline was worse: baseline delegated to a haiku
  subagent that churned 1.49M — so grove won L5 context only by comparison, not on
  merit.) Structural navigation is not converging on broad/architecture questions.

---

## L1 single-symbol — all 9 other repos (evaluated 2026-06-23, model sonnet)

Rung run in parallel across repos (`scripts/run-rung-parallel.sh L1_symbol sonnet …`).
Prompt class: "Where is the `<iconic symbol>` defined? Give the exact file and
line." Quality is objective here (one fact), verified vs pinned source with
`grep -n`. Evidence: `evidence/L1.eval.json`.

| Repo | baseline ctx | grove ctx | ctx Δ | ctx win | baseline t | grove t | time win | baseline line | grove line | true | quality |
|---|---|---|---|---|---|---|---|---|---|---|---|
| tokio | 152,106 | 478,568 | +215% | baseline | 18s | 68s | baseline | 174 ✓ | 174 ✓ | 174 | both right |
| hugo | 48,722 | 133,584 | +174% | baseline | 5s | 24s | baseline | 103 ✓ | 103 ✓ | 103 | both right |
| django | 73,638 | 80,376 | +9% | baseline | 7s | 17s | baseline | 326 ✓ | **325 ✗** | 326 | **grove off −1** |
| typescript | 73,346 | 128,986 | +76% | baseline | 8s | **321s** | baseline | 1022 ✓ | 1022 ✓ | 1022 | both right |
| webpack | 48,763 | 91,389 | +87% | baseline | 6s | 24s | baseline | 175 ✓ | **174 ✗** | 175 | **grove off −1** |
| bitcoin | 48,951 | 130,860 | +167% | baseline | 5s | 109s | baseline | 280 ✓ | 280 ✓ | 280 | both right |
| spring-boot | 73,785 | 81,359 | +10% | baseline | 8s | 28s | baseline | 191 ✓ | **190 ✗** | 191 | **grove off −1** |
| rails | 48,719 | 78,852 | +62% | baseline | 5s | 22s | baseline | 5 ✓ | **4 ✗** | 5 | **grove off −1** |
| laravel | 148,649 | 131,737 | **−11%** | **grove** | 22s | 27s | baseline | 42 ✓ | **41 ✗** | 42 | **grove off −1** |

### Verdict (L1, cross-repo)

On the trivial single-symbol lookup, **grove loses on every axis**:

- **Context:** baseline wins **8/9** (often 2–3×: tokio +215%, hugo +174%, bitcoin
  +167%). grove wins only laravel (−11%). The baseline just greps one symbol; grove's
  steering + tool schema + over-reading dwarfs that.
- **Time:** baseline wins **9/9**. Two grove pathologies: typescript **321s** (vs 8s)
  and bitcoin **109s** (vs 5s) — grove navigation failed to converge on a
  one-symbol question.
- **Quality:** baseline **9/9 correct**; grove **4/9** — a systematic **−1 off-by-one**
  on django, webpack, spring-boot, rails, laravel. Clustering is suggestive:
  grove was correct on tokio/hugo/typescript/bitcoin (rust/go/ts/cpp) and off on the
  python/js/java/ruby/php set — a likely **grammar-specific row-indexing** bug.

This is a clean cross-language confirmation of redis L1/L2: grove is pure overhead
for simple lookups, and the off-by-one (GI-1) reproduces across **5 more repos**.

### R2 plan — re-run L1 after grove#31 fix

[grove#31](https://github.com/Entelligentsia/grove/issues/31) (off-by-one) is being
fixed; because it corrupts every line citation it must be fixed before deeper rungs.
R1 baseline is preserved: image `grove-testbench/grove:r1`, transcripts `out/r1/`,
distilled `evidence/L1.lines.r1.json` (baseline 9/9, grove 4/9, off-by-one on django,
webpack, spring-boot, rails, laravel).

Once the fixed binary is built, R2 is:

```bash
# 1. build the fixed grove, then rebuild grove from THAT binary (not host PATH)
(cd ../grove && cargo build --release)
GROVE_BIN=../grove/target/release/grove scripts/build-grove.sh

# 2. re-race L1 across all 9, then evaluate line accuracy (truth derived from source)
scripts/run-rung-parallel.sh L1_symbol sonnet tokio hugo django typescript webpack bitcoin spring-boot rails laravel
scripts/eval-l1-lines.sh --grove-img grove-testbench/grove:latest --label r2

# 3. before/after
diff <(jq .summary evidence/L1.lines.r1.json) <(jq .summary evidence/L1.lines.r2.json)
```

Success = grove line accuracy 4/9 → **9/9**, `grove_off_by_one` empty. (Context/time
deltas may also shift; re-aggregate with the same flow if needed.)

**Update — #31 already verified fixed via Tier-1 probe (no agent, no tokens).**
The fix is in the grove binary (host == `../grove/target/release/grove`, both
"0.1.5" but the post-fix build). `scripts/run-probes.sh` on the same probe-image
grammars, binary the only variable: pre-fix `evidence/probes.buggy.json` = **0/9**,
fixed `evidence/probes.fixed.json` = **9/9**. The bug was **uniform across all
grammars** (binary-side); the agent-level "clustering" in the L1 table was an
agent self-correction artifact. So the agent R2 is now only about the *bite*
(answer quality/context), not confirming the line fix.

## L2 def + call sites — all 10 repos (evaluated 2026-06-23, model sonnet, FIXED grove)

> Full standalone write-up: [reports/L2-callsites.md](reports/L2-callsites.md).

First rung run with the post-#31 binary (grove rebuilt → `grove:r2`; `grove:r1` = pre-fix).
Prompt class: "Where is `<symbol>` defined, and list every place it is referenced
or called across the source tree, with file and line." Throttled to MAXP=4 (20
concurrent containers OOM'd a 16 GB box — see Ops notes). Evidence:
`evidence/L2.eval.json`. Context is summed across all models the agent system uses
(orchestrator + any `Task`/`Explore` subagent), so delegating greps to a subagent
is not free.

| Repo | baseline ctx | grove ctx | ctx Δ | ctx win | baseline→grove time | time win | baseline→grove tools | tool win |
|---|---|---|---|---|---|---|---|---|
| redis | 53,725 | 82,093 | +53% | baseline | 19→41s | baseline | 1→3 | baseline |
| tokio | 539,234 | 128,016 | −76% | grove | 126→79s | grove | 23→4 | grove |
| hugo | 513,389 | 185,590 | −64% | grove | 110→110s | tie | 23→8 | grove |
| django | 269,980 | 275,357 | +2% | baseline | 86→218s | baseline | 14→15 | baseline |
| typescript | 659,726 | 139,405 | −79% | grove | 115→144s | baseline | 34→6 | grove |
| webpack | 422,259 | 162,809 | −61% | grove | 118→52s | grove | 23→5 | grove |
| bitcoin | 187,573 | 183,986 | −2% | grove | 138→201s | baseline | 9→6 | grove |
| **spring-boot** | 776,458 | 196,539 | −75% | **grove** | 107→125s | baseline | 25→12 | grove |
| rails | 79,764 | 185,486 | +133% | baseline | 50→176s | baseline | 3→10 | baseline |
| laravel | 422,842 | 486,001 | +15% | baseline | 136→226s | baseline | 16→39 | baseline |

### Verdict (L2, cross-repo)

- **Context:** **grove wins 6/10**. On the broad-search repos baseline delegates to a haiku
  `Explore` subagent whose grep churn (135k–649k per repo) dwarfs grove's top-level
  structural results, so grove is 2–5× cheaper there (tokio 539k→128k, typescript
  660k→139k, webpack 422k→163k). baseline only wins where it didn't delegate (redis, rails)
  or where grove also over-delegated and over-read (django tie, laravel GI-3).
- **Time:** baseline wins **8/10** (grove faster only on tokio, webpack).
- **Tools:** grove wins **6/10** (fewer calls — `callers`/`definition` vs many greps;
  e.g. typescript 34→6, tokio 23→4). The lone consistent grove advantage so far.
- **Caveat:** n=1 per cell; large variance (laravel grove 39 tools / 226s is a GI-3
  over-read blow-up). spring-boot's win needs reproduction before it means anything.

### L2 quality (blind judges, claims verified vs pinned source) — `evidence/L2.quality.json`

Blind A=baseline / B=grove. **5–5 split**, but the *kind* of win differs by side:

| grove won | baseline won |
|---|---|
| redis, tokio, bitcoin, rails, laravel | hugo, django, typescript, webpack, spring-boot |

- **Where grove wins it's on precision + non-obvious references:** it found real call
  sites grep-style answers missed — redis's vendored `deps/hiredis` copy, rails bare-
  `Relation` subclasses/factory calls, bitcoin `interfaces/wallet.h`, plus enclosing
  function names; and it fabricated less (tokio: the baseline invented "50+ call
  sites", real 18; grove gave verified lines).
- **Where grove loses it's on recall / wrong target:**
  - **points at generated declaration files** instead of source — typescript refs
    landed in `tests/baselines/**/*.d.ts`, webpack in `types.d.ts`, dropping the real
    `lib/`/`src/` call sites. → **GI-5**.
  - **`callers` under-covers common symbols** — spring-boot grove covered <25% of real
    references (only grove-tagged cross-refs); hugo/django grove undercounted ~3×. → **GI-6**.
- **The spring-boot irony:** grove "won" L2 *context* (−13%) **and** lost quality there —
  its cheaper run was cheaper because it did **less** (covered <25% of call sites). So
  that lone context win is not a real win.

**Net L2 (all axes, fixed grove):** grove **wins context 6/10** (all models incl.
subagents), loses time 8/10, wins tool-calls 6/10, ties quality 5/5. The real
blockers are GI-5/GI-6 recall, and several of grove's context wins are cheap because
recall was low ("did less"). For "list all call sites", grove buys fewer tool calls,
less context, and better precision — uneven recall is what still costs it quality
wins. See [`reports/L2-callsites.md`](reports/L2-callsites.md).

## Ops notes (harness lessons from the L2 run)

- **Auth:** the baseline/grove images bake OAuth creds that **expire** (access token ~hours)
  and whose refresh token **rotates** — so isolated `--rm` containers can't share a
  refresh (first wins, rest 401). Fix: `run-race.sh` now mounts the **host's live
  creds** read-only (staged to mode 0644 because the container runs as `bench`
  uid 1001 and can't read the host's 0600 file). Set `CLAUDE_CREDS` to override.
  Occasional transient 401 on a single cell still happens — just re-run that cell.
- **Concurrency:** 20 concurrent claude containers (~0.5 GB each) OOM'd a 16 GB
  box and crashed the session. `run-rung-parallel.sh` now throttles to `MAXP`
  (default 4) concurrent races. Keep it ≤ free_GB / 0.5.

## Remaining rungs (pending)

- [x] L1 — single symbol
- [x] L2 — def + all call sites (this section)
- [ ] L3 — flow trace
- [ ] L4 — subsystem end-to-end
- [ ] L5 — cross-cutting architecture
