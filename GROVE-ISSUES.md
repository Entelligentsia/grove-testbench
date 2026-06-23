# Grove issues — backlog from testbench evals

Candidate fixes for the **grove** repo (`Entelligentsia/grove`), surfaced by
evaluating grove on real-world code via this testbench. These are **draft
findings**, not yet filed. Once all 10 repos are evaluated ([FINDINGS.md](FINDINGS.md)),
the confirmed ones (reproduced across repos / ≥3× per rung) are filed as GitHub
issues in a single structured batch.

Status legend: `draft` (seen once) · `confirmed` (seen in ≥2 repos or reproduced)
· `filed` (issue link) · `wontfix` (intended behavior).

---

## GI-1 — Off-by-one line numbers from `@row` symbol-ids

- **Status:** **FIXED — verified** ([grove#31](https://github.com/Entelligentsia/grove/issues/31))
- **Tier-1 verification (no agent, no tokens):** same probe image (fixed grammars),
  binary the only variable — pre-fix build `evidence/probes.buggy.json` = **0/9**
  (every line −1); release build `evidence/probes.fixed.json` = **9/9** correct.
- **Correction to the original report:** the bug was **uniform across ALL grammars**
  at grove's raw output (binary-side), **not** grammar-clustered. The earlier
  "right on rust/go/ts/cpp, wrong on python/js/java/ruby/php" pattern was an
  **agent artifact** — for some languages the agent self-corrected by reading the
  source, masking grove's −1; the raw `grove outline` was −1 on all 9. Isolation
  proof: pre-fix binary + any grammars → −1; fixed binary + the *same old* grammars
  → correct. The grove `CLAUDE.md` now documents "lines/cols 1-based across the
  whole surface".
- **Note for R2:** because the fix is binary-side and Tier-1 already confirms line
  accuracy, the expensive agent R2 is **only** needed to measure the *bite* (does
  the agent answer better), not to confirm the fix.
- **Seen in:** redis (L4) + L1 single-symbol on **django, webpack, spring-boot,
  rails, laravel** — dg reported the definition exactly **−1** vs the true
  `grep -n` line (django 325 vs 326, webpack 174 vs 175, spring-boot 190 vs 191,
  rails 4 vs 5, laravel 41 vs 42). db got all 9 right.
- **Symptom:** grove-steered answers report source locations one line low.
- **Hypothesis:** grove's `symbol-id` (`<lang>:<relpath>#<name>@<row>`) uses a
  **0-indexed** row; consumers treat it as a 1-indexed line. **Clustering clue:**
  dg was *correct* on tokio/hugo/typescript/bitcoin (rust/go/ts/cpp) and *wrong*
  on python/js/java/ruby/php — suggests the off-by-one is **grammar/language
  specific** (some grammars' node start-row already matches, others are −1), not a
  global constant. Worth checking per-grammar row handling in the tags/query path.
- **Impact:** every grove-sourced citation can be off by one → erodes the precise-
  navigation value that is grove's whole pitch; reviewers stop trusting cites.
- **Proposed fix:** normalize to 1-indexed lines at the CLI/MCP boundary for ALL
  grammars (add a per-grammar regression test asserting reported line == real line).
- **Evidence:** `evidence/L1.eval.json`, `out/opt-{django,webpack,spring-boot,rails,laravel}-L1_symbol.claude.dg.jsonl`, `out/opt-redis-L4_subsystem.claude.dg.jsonl`.

## GI-2 — Thin slices cause confabulation (grounding gap)

- **Status:** draft
- **Seen in:** redis (L3 fabricated `db->dict`/`dbAddByLink→dictAdd`; L5 fabricated
  `handleClientsWithPendingWritesUsingThreads`)
- **Symptom:** With grove on, the agent invents plausible-but-nonexistent
  functions/fields when the structural slice omits the surrounding context; the
  whole-file baseline answers the same prompts correctly.
- **Hypothesis:** `source`-by-symbol returns the body but too little neighbouring
  context (caller bodies, adjacent decls, struct definitions), so the model fills
  gaps from priors instead of source.
- **Impact:** grove trades tokens for **correctness** — its cheapest answers are
  its least reliable. This is the central risk for grove as an agent tool.
- **Proposed fix (options):** configurable context window around a symbol; a
  "verify symbol exists" affordance; encourage `outline`+`source` pairing in the
  steering; return struct/field definitions alongside the function that uses them.
- **Evidence:** `out/opt-redis-L3_flow.claude.dg.jsonl`, `...L5_arch...dg.jsonl`
  + the blind-judge verdicts in [FINDINGS.md](FINDINGS.md).

## GI-3 — Over-read blow-ups / non-convergence

- **Status:** **confirmed** (multiple repos, even at L1)
- **Seen in:** redis (L5: dg 630,475 ctx / 29 tools vs db 52,497) AND **L1
  single-symbol**: tokio dg 478,568 ctx (+215%), bitcoin dg 130,860 (+167%) /
  109s, typescript dg **321s** (vs db 8s), hugo +174%. On a *one-symbol* question
  grove navigation ballooned context 2–3× and ran 10–40× longer.
- **Symptom:** grove-driven navigation expands context/time far beyond the
  baseline instead of converging — present even on trivial lookups, worst on
  broad questions.
- **Hypothesis:** no breadth budget / dedup; the agent fans out `symbols`+`source`
  across many candidates without pruning.
- **Impact:** the context-savings story inverts exactly where big codebases need
  it most.
- **Proposed fix:** investigate steering guidance for breadth control; consider a
  grove affordance for "summarize/outline a subsystem" that returns a compact map
  rather than many full bodies.
- **Evidence:** `out/opt-redis-L5_arch.claude.dg.jsonl`, `out/redis.optimize.json`.

## GI-4 — Definitions not tagged (outline gaps), found via Tier-1 probe

- **Status:** draft (found while authoring `probes/line-accuracy.tsv`)
- **Symptom:** `grove outline` omits some real definitions:
  - **rust:** items inside a function-like macro block aren't tagged — e.g.
    `tokio/src/task/spawn.rs` has `pub fn spawn` inside `cfg_rt! { … }`, and
    `grove outline` on that file returns **nothing**.
  - **typescript:** `export function createScanner` in `src/compiler/scanner.ts`
    isn't tagged (the `interface Scanner` in the same file is).
  - **cpp:** `class CTransaction` in `src/primitives/transaction.h` isn't tagged
    (nearby `struct` definitions are).
- **Impact:** go-to-def / outline silently miss symbols → agent falls back to grep
  (or worse, confabulates, cf. GI-2). Quietly narrows grove's coverage.
- **Next:** confirm per-grammar against pinned source, then file. Likely a
  `tags.scm` coverage gap per language (macro bodies, `export function`, `class`
  vs `struct`).
- **Evidence:** `probes/line-accuracy.tsv` history (these symbols were swapped out
  for tagged ones); reproduce with `grove outline <file>` in the probe image.

---

## Filing checklist (after all repos)

1. Promote `draft` → `confirmed` only with reproduction (≥3×/side) or a 2nd repo.
2. One GitHub issue per confirmed item in `Entelligentsia/grove`, each with:
   minimal repro (repo + pinned SHA + prompt), measured numbers, the offending
   stream-json excerpt, and the proposed fix.
3. Link the filed issue back here (`Status: filed <url>`).
