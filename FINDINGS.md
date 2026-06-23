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

## Remaining repos (pending)

Run: `scripts/optimize-prompt.sh <repo> --model sonnet --keep`, then judge L3–L5.

- [ ] tokio (rust)
- [ ] hugo (go)
- [ ] django (python)
- [ ] typescript (typescript)
- [ ] webpack (javascript)
- [ ] bitcoin (cpp)
- [ ] spring-boot (java)
- [ ] rails (ruby)
- [ ] laravel (php)
