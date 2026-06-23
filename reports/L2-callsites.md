# L2 report — "definition + all call sites" across 10 repos

**Rung:** L2 (def + every reference/call site) · **Date:** 2026-06-23 ·
**Agent:** Claude, `--model sonnet` · **grove:** fixed, post-[#31](https://github.com/Entelligentsia/grove/issues/31) (`dg:r2`) ·
**Sides:** `db` = grove OFF, `dg` = grove ON (grove the only variable).

Evidence: [`evidence/L2.eval.json`](../evidence/L2.eval.json) (metrics),
[`evidence/L2.quality.json`](../evidence/L2.quality.json) (blind quality).
Raw transcripts: `out/opt-<repo>-L2_callsites.claude.{db,dg}.jsonl`.

---

## Headline

On "where is `X` defined and list every call site," with the off-by-one bug fixed:

| axis (lower/ better) | winner | tally |
|---|---|---|
| **context tokens** | **grove** | **dg 6/10** (db: redis, django, rails, laravel) |
| **wall-clock time** | baseline | **db 8/10** |
| **tool calls** | **grove** | **dg 6/10** |
| **answer quality** (blind) | tie | **5–5** |

Grove buys **fewer tool calls, less context, and higher precision** at the cost of
**more time and uneven recall**. Context is summed across all models the agent
system uses (orchestrator + any `Task`/`Explore` subagents), so offloading greps to
a subagent is not free. On the broad-search repos grove's structural results beat
the baseline's subagent churn; where grove loses context (django, laravel) it's
because grove *also* over-delegated and over-read (GI-3).

---

## Method

- **Prompt** (identical both sides): *"Where is `<symbol>` defined, and list every
  place it is referenced or called across the source tree, with file and line."*
- **Symbols** (one iconic per repo): redis `dictAdd`, tokio `Runtime`, hugo `Site`,
  django `QuerySet`, typescript `Scanner`, webpack `Compiler`, bitcoin
  `CMutableTransaction`, spring-boot `SpringApplication`, rails
  `ActiveRecord::Relation`, laravel Eloquent `Model`.
- **Fair baseline:** both sides get the same realistic `claude-md/<repo>.base.md`;
  `dg` additionally carries its `grove init` block. Grove is the only variable.
- **Context** = `input + cache_read + cache_creation` summed across **all models**
  in the result event's `modelUsage` — what the agent *system* ingests, including
  any `Task`/`Explore` subagent (which runs on its own model). The breakdown into
  orchestrator vs subagent context is in the evidence file (`subagent_ctx`,
  `delegated`, `*_subagent_tools`).
- **Quality** = blind judge per repo, A/B unlabeled, **every cited location verified
  against the pinned `dg:r2` source** with `grep -n` / `sed -n`.
- **Run:** `MAXP=4 scripts/run-rung-parallel.sh L2_callsites sonnet <10 repos>`
  (throttled — 20 concurrent containers OOM a 16 GB box).

---

## Metrics (per repo)

`ctx` = context (all models). `sub` = subagent context (the part run inside a
`Task`/`Explore` subagent). `del` = did that side delegate to a subagent.

| Repo | db ctx | dg ctx | ctx Δ | ctx win | db sub | dg sub | del | db→dg time | time win | db→dg tools | tool win |
|---|---|---|---|---|---|---|---|---|---|---|---|
| redis | 53,725 | 82,093 | +53% | db | 527 | 527 | —/— | 19→41s | db | 1→3 | db |
| tokio | 539,234 | 128,016 | **−76%** | **dg** | 488,046 | 526 | db/— | 126→79s | dg | 23→4 | dg |
| hugo | 513,389 | 185,590 | **−64%** | **dg** | 437,096 | 43,093 | db/dg | 110→110s | tie | 23→8 | dg |
| django | 269,980 | 275,357 | +2% | db | 185,172 | 154,665 | db/dg | 86→218s | db | 14→15 | db |
| typescript | 659,726 | 139,405 | **−79%** | **dg** | 609,454 | 526 | db/— | 115→144s | db | 34→6 | dg |
| webpack | 422,259 | 162,809 | **−61%** | **dg** | 269,766 | 527 | db/— | 118→52s | dg | 23→5 | dg |
| bitcoin | 187,573 | 183,986 | −2% | **dg** | 135,068 | 528 | db/— | 138→201s | db | 9→6 | dg |
| spring-boot | 776,458 | 196,539 | **−75%** | **dg** | 649,412 | 85,888 | db/dg | 107→125s | db | 25→12 | dg |
| rails | 79,764 | 185,486 | +133% | db | 530 | 64,769 | —/dg | 50→176s | db | 3→10 | db |
| laravel | 422,842 | 486,001 | +15% | db | 367,196 | 305,191 | db/dg | 136→226s | db | 16→39 | db |

**Context:** dg wins 6/10. On the broad-search repos db delegates to a haiku
`Explore` subagent whose grep churn (135k–649k per repo) dwarfs grove's top-level
structural results, so grove is 2–5× cheaper there (tokio 539k→128k, typescript
660k→139k, webpack 422k→163k). db only wins where it didn't delegate (redis, rails)
or where dg *also* delegated heavily and over-read (django tie, laravel GI-3).

**Tool calls (grove's edge):** dg wins 6/10, sometimes dramatically (typescript
34→6, tokio 23→4) — structural `callers`/`definition` replaces many greps. But it
can also blow up (laravel 16→**39**, a GI-3 over-read). db's high counts (tokio 23,
typescript 34) are the subagent's greps — counted, and now their context is counted
too.

---

## Quality (blind judges, claims verified vs source)

Blind A=db / B=dg. **5–5**, but the *kind* of win differs.

| Repo | quality winner | why |
|---|---|---|
| redis | **dg** | strict superset; found vendored `deps/hiredis` call site + enclosing fn names; both 6/6 precision |
| tokio | **dg** | db **fabricated** aggregate counts ("50+", real 18); dg gave verified file:line, better recall |
| hugo | db | both 6/6 precision; db covered all 4 `Site` def variants + accurate ~497 count; dg undercounted ~3× |
| django | db | dg **fabricated** `query.py:304` (PreventQuerySetCloning ≠ QuerySet); undercovered source, buried in tests |
| typescript | db | dg pointed at generated `*.d.ts`; missed checker/parser/nodeFactory call sites (GI-5) |
| webpack | db | dg substituted `types.d.ts` for real `lib/`; silently dropped ~199 typedef refs (GI-5) |
| bitcoin | **dg** | higher recall (132 vs ~115 files), caught `interfaces/wallet.h` etc.; fewer wrong lines |
| spring-boot | db | dg precision-perfect but covered **<25%** of refs (GI-6); db broad categorical coverage |
| rails | **dg** | found bare-`Relation` refs db missed (subclasses, factory calls, constants) |
| laravel | **dg** | zero fabrications + unique real refs (Facade alias, DB-provider injection); db had a fabricated column |

**Pattern:**
- **Grove wins on precision + non-obvious references** — vendored copies,
  subclasses, factory calls, enclosing functions; and it fabricates less.
- **Grove loses on recall / wrong target** — two concrete, fixable defects below.

---

## Grove issues surfaced (→ [GROVE-ISSUES.md](../GROVE-ISSUES.md))

- **GI-3 — over-read / non-convergence:** laravel dg ran 39 tool calls / 226 s vs
  db 16 / 136 s, and its context (486k) exceeds db (423k) — dg delegated to a
  sonnet subagent (305k) *and* over-read at top level. Present since L1; worst on
  broad asks.
- **GI-5 — references resolve to generated declaration files:** typescript refs
  landed in `tests/baselines/**/*.d.ts`, webpack in `types.d.ts`, instead of real
  source → the agent answers from the wrong file and drops real call sites.
- **GI-6 — `callers` under-covers common symbols:** spring-boot dg covered <25% of
  real references (only grove-tagged cross-refs); hugo/django undercounted ~3×.
  Precision-first, low recall on "every reference" asks.

### Context-cheap ≠ complete (read before citing any context win)

A low context number is good **only if coverage is complete**. Several of dg's
context wins coincide with quality losses: hugo dg undercounted ~3×, typescript/
webpack dg answered from the wrong (`.d.ts`) files, spring-boot dg covered <25%.
In those cases "cheaper" partly means **did less**, not "more efficient." The clean
dg context wins — where dg also won or tied quality — are **tokio, bitcoin** (redis
is a db win on both). This is why every rung pairs cost metrics with verified
quality, and why the recall fixes below matter more than the context tally.

---

## Net verdict

For "list all call sites," grove (as of `dg:r2`):
- **uses less context** on 6/10 — the broad-search repos where the baseline's
  subagent churn dwarfs grove's structural results;
- **issues fewer tool calls** (6/10) — its other robust advantage;
- **costs more time** (db 8/10);
- **ties on answer quality** (5/5), trading higher precision for lower/uneven recall.

The real blockers to grove winning this rung outright are **GI-5** (stop indexing
generated `.d.ts`) and **GI-6** (recall on `callers`): 4 of grove's 5 quality losses
were recall/target failures, and several of dg's context "wins" are cheap precisely
because recall was low. Fix recall and the context advantage becomes a genuine one.

---

## Caveats

- **n=1 per cell.** Variance is large (e.g. rails db 50 s vs dg 176 s; laravel dg
  blow-up). Treat single-cell results as directional; reproduce before citing.
- redis's first batch cell hit a transient 401 (expired baked creds) and was
  re-run single; see [FINDINGS.md](../FINDINGS.md) ops notes (auth + concurrency).

## Reproduce

```bash
# fixed grove into dg, then race + judge
GROVE_BIN=../grove/target/release/grove scripts/build-dg.sh
MAXP=4 scripts/run-rung-parallel.sh L2_callsites sonnet \
  redis tokio hugo django typescript webpack bitcoin spring-boot rails laravel
# metrics (context + subagent decomposition): out/opt-<repo>-L2_callsites.claude.metrics.json
# aggregate evidence:  scripts/build-eval.sh L2_callsites --out evidence/L2.eval.json \
#   redis tokio hugo django typescript webpack bitcoin spring-boot rails laravel
```
