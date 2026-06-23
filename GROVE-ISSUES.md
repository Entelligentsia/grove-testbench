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

- **Status:** draft
- **Seen in:** redis (L4 — systematic −1 across nearly every citation)
- **Symptom:** When grove steers the agent, cited source locations are
  consistently one line low (e.g. `lookupKey` cited at `db.c:278`, actually 279).
- **Hypothesis:** grove's `symbol-id` (`<lang>:<relpath>#<name>@<row>`) uses a
  **0-indexed** row; consumers (and the agent) treat it as a 1-indexed line.
- **Impact:** every grove-sourced citation is off by one → erodes the precise-
  navigation value that is grove's whole pitch; reviewers stop trusting cites.
- **Proposed fix:** emit/display 1-indexed lines (or clearly label `@row` as
  0-indexed and convert at the CLI/MCP boundary).
- **Evidence to attach when filing:** `out/opt-redis-L4_subsystem.claude.dg.jsonl`.

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

## GI-3 — Over-read blow-ups on broad/architecture prompts

- **Status:** draft
- **Seen in:** redis (L5 architecture: dg 630,475 ctx / 29 tools vs db 52,497 / 47
  cheap greps)
- **Symptom:** On broad questions, grove-driven navigation expands context far
  beyond the baseline instead of converging.
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
