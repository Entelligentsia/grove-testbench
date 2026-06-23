# grove-testbench — findings

Evaluation log. One section per repo. Each records the prompt-complexity sweep
(context tokens), time/turns, and **blind-judged answer quality verified against
the pinned source**. Candidate grove fixes surfaced here are tracked in
[GROVE-ISSUES.md](GROVE-ISSUES.md) and filed against the grove repo in a batch
once all repos are evaluated.

## Method

- **Setup:** same agent (Claude, `--model sonnet`), same prompt, grove off (`db`)
  vs on (`dg`). Fair base steering (`claude-md/<repo>.base.md`) on **both** sides;
  `dg` additionally carries its `grove init` block. Grove is the only variable.
- **Ladder:** `scenes/<repo>.ladder.tsv`, escalating reading breadth —
  L1 single symbol → L2 call sites → L3 flow trace → L4 subsystem → L5 architecture.
- **Driver:** `scripts/optimize-prompt.sh <repo> --model sonnet --keep` → races
  both sides per rung, writes `out/<repo>.optimize.json`.
- **Axes:** context tokens (`input+cache_read+cache_creation`), `duration_ms`,
  `num_turns`, and answer quality (independent judge per rung, claims verified
  against the pinned source in the `dg` image).
- **Caveat:** results below are **n=1 per rung** unless noted. Variance is large;
  treat single-rung wins as directional until reproduced (≥3×/side).

---

## redis (C) — evaluated 2026-06-23, model sonnet

### Context tokens (lower = better)

| Rung | Prompt class | db ctx | dg ctx | Δ | ctx winner |
|---|---|---|---|---|---|
| L1 | single symbol def | 72,983 | 76,666 | +5% | db |
| L2 | def + all call sites | 52,072 | 81,983 | +57% | db |
| **L3** | **flow trace (dispatch→keyspace)** | **454,969** | **264,857** | **−42%** | **dg** |
| L4 | subsystem end-to-end | 160,350 | 288,616 | +80% | db |
| L5 | cross-cutting architecture | 52,497 | 630,475 | +1101% | db |

Grove's context win is **prompt-class-specific, not complexity-monotonic**: it
appears only on the L3 *flow-trace* shape (which forces the baseline to read whole
files chasing a call chain), and reverses on L1/L2 (cheap grep) and L4/L5 (where
`dg` over-read — L5 ballooned to 630k).

### Time & turns (lower = better)

| Rung | db time | dg time | time winner | db turns | dg turns | turns winner |
|---|---|---|---|---|---|---|
| L1 | 8s | 10s | db | 3 | 3 | tie |
| L2 | 66s | 66s | db | 2 | 4 | db |
| L3 | 78s | 94s | db | 24 | 19 | **dg** |
| L4 | 55s | 101s | db | 9 | 16 | db |
| L5 | 181s | 182s | db | 2* | 30 | db |

**Baseline wins wall-clock on every rung**, including L3. Grove wins turns only at
L3. (*L5 db's 2 turns / 47 tools is a metric quirk — many cheap greps batched.)

### Answer quality (blind judges; A=db, B=dg; verified vs pinned source)

| Rung | Better | Margin | Key finding |
|---|---|---|---|
| L3 | **db** | wide | dg **fabricated** `db->dict` (real: `db->keys`) and `dbAddByLink→dictAdd`; stopped short of the dict insert the prompt demanded. db traced it correctly (9/9 claims verified). |
| L4 | **db** | modest | Both call graphs correct; dg had a **systematic −1 off-by-one** on nearly every line cite. No fabrications. |
| L5 | db | slight (~tie) | dg more detailed (extra replica-side) but **fabricated** `handleClientsWithPendingWritesUsingThreads` (nonexistent). db: zero fabrications. |

### Verdict (redis)

Grove's **only** measurable win is context tokens on the L3 flow-trace class
(−42%) — and that same rung produced grove's **worst, partly-fabricated** answer.
Grove was **slower on every rung** and **lower-quality on every deep rung**. The
"grove wins" premise does **not** hold on redis as configured.

### Grove issues surfaced → [GROVE-ISSUES.md](GROVE-ISSUES.md)

- **GI-1 off-by-one line numbers** — agent echoes grove's `@row` symbol-id (likely
  0-indexed) as a 1-indexed line; consistent −1 drift across L4.
- **GI-2 thin slices → weak grounding → confabulation** — grove's token-cheap
  slices omit the surrounding context the model needs, so it invents the gaps
  (`db->dict`, `dictAdd`, `handleClientsWithPendingWritesUsingThreads`); the
  whole-file baseline stayed correct. Core tension: fewer tokens, weaker grounding.
- **GI-3 over-read blow-ups** — on broad prompts (L5) grove usage ballooned to
  630k context (29 tool calls), far above the baseline's 52k. Structural
  navigation is not converging on broad/architecture questions.

---

## L1 single-symbol — all 9 other repos (evaluated 2026-06-23, model sonnet)

Rung run in parallel across repos (`scripts/run-rung-parallel.sh L1_symbol sonnet …`).
Prompt class: "Where is the `<iconic symbol>` defined? Give the exact file and
line." Quality is objective here (one fact), verified vs pinned source with
`grep -n`. Evidence: `evidence/L1.eval.json`.

| Repo | db ctx | dg ctx | ctx Δ | ctx win | db t | dg t | time win | db line | dg line | true | quality |
|---|---|---|---|---|---|---|---|---|---|---|---|
| tokio | 152,106 | 478,568 | +215% | db | 18s | 68s | db | 174 ✓ | 174 ✓ | 174 | both right |
| hugo | 48,722 | 133,584 | +174% | db | 5s | 24s | db | 103 ✓ | 103 ✓ | 103 | both right |
| django | 73,638 | 80,376 | +9% | db | 7s | 17s | db | 326 ✓ | **325 ✗** | 326 | **dg off −1** |
| typescript | 73,346 | 128,986 | +76% | db | 8s | **321s** | db | 1022 ✓ | 1022 ✓ | 1022 | both right |
| webpack | 48,763 | 91,389 | +87% | db | 6s | 24s | db | 175 ✓ | **174 ✗** | 175 | **dg off −1** |
| bitcoin | 48,951 | 130,860 | +167% | db | 5s | 109s | db | 280 ✓ | 280 ✓ | 280 | both right |
| spring-boot | 73,785 | 81,359 | +10% | db | 8s | 28s | db | 191 ✓ | **190 ✗** | 191 | **dg off −1** |
| rails | 48,719 | 78,852 | +62% | db | 5s | 22s | db | 5 ✓ | **4 ✗** | 5 | **dg off −1** |
| laravel | 148,649 | 131,737 | **−11%** | **dg** | 22s | 27s | db | 42 ✓ | **41 ✗** | 42 | **dg off −1** |

### Verdict (L1, cross-repo)

On the trivial single-symbol lookup, **grove loses on every axis**:

- **Context:** db wins **8/9** (often 2–3×: tokio +215%, hugo +174%, bitcoin
  +167%). dg wins only laravel (−11%). The baseline just greps one symbol; grove's
  steering + tool schema + over-reading dwarfs that.
- **Time:** db wins **9/9**. Two grove pathologies: typescript **321s** (vs 8s)
  and bitcoin **109s** (vs 5s) — grove navigation failed to converge on a
  one-symbol question.
- **Quality:** db **9/9 correct**; dg **4/9** — a systematic **−1 off-by-one**
  on django, webpack, spring-boot, rails, laravel. Clustering is suggestive:
  dg was correct on tokio/hugo/typescript/bitcoin (rust/go/ts/cpp) and off on the
  python/js/java/ruby/php set — a likely **grammar-specific row-indexing** bug.

This is a clean cross-language confirmation of redis L1/L2: grove is pure overhead
for simple lookups, and the off-by-one (GI-1) reproduces across **5 more repos**.

### R2 plan — re-run L1 after grove#31 fix

[grove#31](https://github.com/Entelligentsia/grove/issues/31) (off-by-one) is being
fixed; because it corrupts every line citation it must be fixed before deeper rungs.
R1 baseline is preserved: image `grove-testbench/dg:r1`, transcripts `out/r1/`,
distilled `evidence/L1.lines.r1.json` (db 9/9, dg 4/9, off-by-one on django,
webpack, spring-boot, rails, laravel).

Once the fixed binary is built, R2 is:

```bash
# 1. build the fixed grove, then rebuild dg from THAT binary (not host PATH)
(cd ../grove && cargo build --release)
GROVE_BIN=../grove/target/release/grove scripts/build-dg.sh

# 2. re-race L1 across all 9, then evaluate line accuracy (truth derived from source)
scripts/run-rung-parallel.sh L1_symbol sonnet tokio hugo django typescript webpack bitcoin spring-boot rails laravel
scripts/eval-l1-lines.sh --label r2

# 3. before/after
diff <(jq .summary evidence/L1.lines.r1.json) <(jq .summary evidence/L1.lines.r2.json)
```

Success = dg line accuracy 4/9 → **9/9**, `dg_off_by_one` empty. (Context/time
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

First rung run with the post-#31 binary (dg rebuilt → `dg:r2`; `dg:r1` = pre-fix).
Prompt class: "Where is `<symbol>` defined, and list every place it is referenced
or called across the source tree, with file and line." Throttled to MAXP=4 (20
concurrent containers OOM'd a 16 GB box — see Ops notes). Evidence:
`evidence/L2.eval.json`. Context is summed across all models the agent system uses
(orchestrator + any `Task`/`Explore` subagent), so delegating greps to a subagent
is not free.

| Repo | db ctx | dg ctx | ctx Δ | ctx win | db→dg time | time win | db→dg tools | tool win |
|---|---|---|---|---|---|---|---|---|
| redis | 53,725 | 82,093 | +53% | db | 19→41s | db | 1→3 | db |
| tokio | 539,234 | 128,016 | −76% | dg | 126→79s | dg | 23→4 | dg |
| hugo | 513,389 | 185,590 | −64% | dg | 110→110s | tie | 23→8 | dg |
| django | 269,980 | 275,357 | +2% | db | 86→218s | db | 14→15 | db |
| typescript | 659,726 | 139,405 | −79% | dg | 115→144s | db | 34→6 | dg |
| webpack | 422,259 | 162,809 | −61% | dg | 118→52s | dg | 23→5 | dg |
| bitcoin | 187,573 | 183,986 | −2% | dg | 138→201s | db | 9→6 | dg |
| **spring-boot** | 776,458 | 196,539 | −75% | **dg** | 107→125s | db | 25→12 | dg |
| rails | 79,764 | 185,486 | +133% | db | 50→176s | db | 3→10 | db |
| laravel | 422,842 | 486,001 | +15% | db | 136→226s | db | 16→39 | db |

### Verdict (L2, cross-repo)

- **Context:** **dg wins 6/10**. On the broad-search repos db delegates to a haiku
  `Explore` subagent whose grep churn (135k–649k per repo) dwarfs grove's top-level
  structural results, so grove is 2–5× cheaper there (tokio 539k→128k, typescript
  660k→139k, webpack 422k→163k). db only wins where it didn't delegate (redis, rails)
  or where dg also over-delegated and over-read (django tie, laravel GI-3).
- **Time:** db wins **8/10** (dg faster only on tokio, webpack).
- **Tools:** dg wins **6/10** (fewer calls — `callers`/`definition` vs many greps;
  e.g. typescript 34→6, tokio 23→4). The lone consistent grove advantage so far.
- **Caveat:** n=1 per cell; large variance (laravel dg 39 tools / 226s is a GI-3
  over-read blow-up). spring-boot's win needs reproduction before it means anything.

### L2 quality (blind judges, claims verified vs pinned source) — `evidence/L2.quality.json`

Blind A=db / B=dg. **5–5 split**, but the *kind* of win differs by side:

| grove (dg) won | baseline (db) won |
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
  - **`callers` under-covers common symbols** — spring-boot dg covered <25% of real
    references (only grove-tagged cross-refs); hugo/django dg undercounted ~3×. → **GI-6**.
- **The spring-boot irony:** dg "won" L2 *context* (−13%) **and** lost quality there —
  its cheaper run was cheaper because it did **less** (covered <25% of call sites). So
  that lone context win is not a real win.

**Net L2 (all axes, fixed grove):** grove **wins context 6/10** (all models incl.
subagents), loses time 8/10, wins tool-calls 6/10, ties quality 5/5. The real
blockers are GI-5/GI-6 recall, and several of dg's context wins are cheap because
recall was low ("did less"). For "list all call sites", grove buys fewer tool calls,
less context, and better precision — uneven recall is what still costs it quality
wins. See [`reports/L2-callsites.md`](reports/L2-callsites.md).

## Ops notes (harness lessons from the L2 run)

- **Auth:** the db/dg images bake OAuth creds that **expire** (access token ~hours)
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
