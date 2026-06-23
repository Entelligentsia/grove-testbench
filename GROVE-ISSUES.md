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

- **Status:** **filed** — [grove#31](https://github.com/Entelligentsia/grove/issues/31) (confirmed, 6 repos)
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

---

## Filing checklist (after all repos)

1. Promote `draft` → `confirmed` only with reproduction (≥3×/side) or a 2nd repo.
2. One GitHub issue per confirmed item in `Entelligentsia/grove`, each with:
   minimal repro (repo + pinned SHA + prompt), measured numbers, the offending
   stream-json excerpt, and the proposed fix.
3. Link the filed issue back here (`Status: filed <url>`).
