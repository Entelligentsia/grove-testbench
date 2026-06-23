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

## Remaining rungs (pending)

Per the rung-by-rung-in-parallel plan, next: L2 across all 9, then L3, L4, L5.

- [x] L1 — single symbol (this section)
- [ ] L2 — def + all call sites
- [ ] L3 — flow trace
- [ ] L4 — subsystem end-to-end
- [ ] L5 — cross-cutting architecture
