# grove-testbench

**An evaluation harness for grove on real-world code.** It runs the *same* coding
agent (Claude) on the *same* prompt with grove off (`baseline`) and grove on (`grove`),
across 10 large popular codebases, and measures grove's actual impact on four
axes — **context tokens, wall-clock time, turns, and answer quality** — so we
learn where grove genuinely helps and where it regresses.

> **Purpose (redefined).** This is not a "grove wins" highlight reel. It is a
> benchmark whose primary output is **evidence**: per-repo measurements plus
> blind-judged answer-quality verdicts, verified against the pinned source. The
> findings feed a structured backlog of fixes for the grove repo
> ([GROVE-ISSUES.md](GROVE-ISSUES.md)). Any side-by-side video is a *secondary*
> artifact, produced only for cases the data actually supports.

Same agent both sides (Claude-vs-Claude). Grove is the only variable. Each run is
**headless** (`claude -p --output-format stream-json`) — reliable, no TUI startup
gates — and that stream-json is the source for both metrics and (optionally) a
synthesized visual.

> Live findings: [FINDINGS.md](FINDINGS.md). Original vision: [PLAN.md](PLAN.md).

> **Single source of truth.** This harness supersedes the earlier `grove-test`
> bed (a single pinned ripgrep clone used for manual MCP poking). Both the
> deterministic regression checks *and* the agent evals now live here, over the
> 10 pinned repos in [`repos.manifest`](repos.manifest), with results committed
> under [`evidence/`](evidence) and [`reports/`](reports) as the definitive data
> for any future research write-up. The Rust def-count anchor that ripgrep used
> to provide (3317 defs) now rides on tokio via
> [`probes/def-count.tsv`](probes/def-count.tsv).

## Image lineage (built locally; baseline/grove never published — they hold creds)

```
base    Dockerfile.base    node22 + Claude Code + pi + 10 repos (pinned) + tooling
  │     scripts/build-base.sh
  ▼     (manual: claude login, commit)
baseline  grove OFF — authed, vanilla repos
  │     scripts/build-grove.sh
  ▼     (grove binary + grammars + `grove init --as mcp` steering in every repo)
grove   grove ON  — grove set up properly (CLAUDE.md steering + .mcp.json)
```

`baseline` = the baseline. `grove` = "grove is set up." That asymmetry (grove steered, baseline
vanilla) is the **realistic** comparison — disclose it when publishing.

## The pipeline

```
run-race.sh   <id>   →  out/<id>.claude.{baseline,grove}.jsonl   (headless stream-json, 1 run/side)
extract-metrics.sh <id>  →  out/<id>.claude.metrics.json  (context/time/tools/turns + winner)
render.sh     <id>   →  out/<id>.{baseline,grove}.mp4            (synth-cast.py → agg → mp4)
compose.sh    <id>   →  out/<id>.race.mp4              (side-by-side; faster side waits = wins)
```

`synth-cast.py` turns a side's stream-json into an asciinema cast (header badge,
prompt, tool calls revealed in order, answer, metrics ticker), scaled to the
real duration so the composed race is honest.

## Two-tier verification (cheap probes before expensive races)

Most grove bugs are defects in grove's **raw output** (e.g. #31's off-by-one
lines) and are testable **deterministically, with no agent and no tokens**. Only
the "does an agent actually benefit?" question needs the LLM. So verification is
two tiers:

- **Tier 1 — probes (`scripts/run-probes.sh`)**: assert grove's CLI output against
  the 10 testbench repos. No agent, no tokens, seconds, CI-friendly exit code.
  Run on every grove build/fix.
- **Tier 2 — agent race (`scripts/run-race.sh`)**: the headless LLM run. Expensive;
  run only after Tier 1 passes, to measure the *bite* (context/time/quality).

### The probe container

```
base  ──(scripts/build-probe.sh)──▶  grove-testbench/probe  (base + baked grammars)
```

`probe` has the 10 repos + grammars but **no grove binary pinned** — the binary
under test is **bind-mounted at runtime**, so iterating on a fix is just
`cargo build` + `run-probes.sh`, with **no image rebuild**:

```bash
scripts/build-probe.sh                                   # once (grammars baked)
GROVE_BIN=../grove/target/release/grove \
  scripts/run-probes.sh --label fixed                    # verify a build, no tokens
```

Probes live in `probes/<name>.tsv`; the container-side check is
`scripts/probe-inside.sh`; results are written to `evidence/probes.<label>.json`.
The first probe, `probes/line-accuracy.tsv`, asserts `grove outline`'s reported
line equals the real `grep -n` line for one definition per language (the #31
regression). Worked example — pre-fix vs fixed binary, same grammars:
`evidence/probes.buggy.json` (0/9) vs `evidence/probes.fixed.json` (9/9).

Other specs: `generated-decls.tsv` (GI-5), `callers-recall.tsv` (GI-6),
`map-graph.tsv` (GI-3/#34), and `def-count.tsv` — the Rust def-count regression
anchor inherited from the retired grove-test bed, asserting `grove symbols`
returns a stable definition total for tokio (lock its exact count after a run).

## Fair base steering (`claude-md/`)

`claude-md/<repo>.base.md` is a realistic, grove-free contributor guide a
maintainer would actually write for that project (layout, build/test,
conventions). When present, `run-race.sh` injects it as the repo's `CLAUDE.md` on
**both** sides before the run:

- **baseline** gets the base only.
- **grove** gets the base **plus** its baked `<!-- grove:start -->…<!-- grove:end -->`
  block (what `grove init` wrote).

So both sides share identical project guidance and **grove is the only
variable** — instead of comparing "steered grove vs vanilla baseline". With no base file,
behaviour is unchanged (baseline vanilla, grove grove-only). All ten repos have a base
file under `claude-md/`.

## Finding the prompt complexity where grove wins (`optimize-prompt.sh`)

Grove's steering + tool-schema tax is ~fixed (~30k context); the baseline's cost
grows with how much source it must read. So grove's *context* win appears only
once a prompt forces broad reading. `optimize-prompt.sh` finds that threshold
automatically:

```bash
scripts/optimize-prompt.sh redis --model sonnet            # walk the whole ladder
scripts/optimize-prompt.sh redis --model sonnet --until-win  # stop at first grove win
```

It reads `scenes/<repo>.ladder.tsv` (`LABEL<TAB>PROMPT`, escalating reading
breadth: single symbol → call sites → flow trace → subsystem summary →
cross-cutting architecture), races **both sides** at each rung, extracts
`context_tokens`, prints a live table, and writes `out/<repo>.optimize.json` with
the first rung where `grove.context < baseline.context`. This is the self-evaluating loop:
it *measures* the relative gain rather than asserting it.

## Quick start

```bash
# 1. base (publishable, no secrets)
scripts/build-base.sh

# 2. baseline: authenticate, commit (manual — your creds, kept local)
docker run -it --name baselinesetup grove-testbench/base bash   # inside: claude login; exit
docker commit baselinesetup grove-testbench/baseline:latest && docker rm baselinesetup

# 3. grove: grove + grammars + per-repo steering
scripts/build-grove.sh

# 4. race + measure + render one scene
scripts/run-race.sh redis --model sonnet     # pin a model for consistency
scripts/extract-metrics.sh redis
scripts/render.sh redis && scripts/compose.sh redis
```

`--backend local --repo-dir <path>` runs against host `claude` for quick tests
(no Docker).

## Metrics (lower = better; from each run's stream-json `result`)

- **context** — `input + cache_read + cache_creation`: what the model actually
  ingests. Grove's core pitch (no whole-file dumps). With prompt caching raw
  `input_tokens ≈ 0`, so this — *not* input+output — is the meaningful "tokens".
- **time** — `duration_ms`
- **tool_calls** — number of tool invocations
- **turns** — `num_turns`

Output verbosity is tracked separately (`output_tokens_only`) so a richer answer
isn't mistaken for inefficiency.

## Honesty notes (read before publishing)

- **Pin the model** (`--model`): containers default to whatever Claude Code
  picks; pin it so both sides and all scenes match.
- **Prompt design drives the token story.** On small "find one symbol" prompts
  the baseline can just grep cheaply, so grove's steering + tool-schema overhead
  makes its *context* larger — grove wins time/tool-calls but not context.
  Grove's context win needs prompts that force broad reading (multi-symbol,
  "trace the flow", "summarize how X interacts with Y").
- **baseline is provably grove-free**: `--strict-mcp-config` + empty MCP config, and
  the baseline image has no grove binary or steering.

## What gets published vs not

- **Publish:** this repo (Dockerfiles, scripts, scenes), and per-run `out/`
  transcripts + videos when you do real runs.
- **Never publish:** `baseline`/`grove` images and any auth material.

## Layout

```
Dockerfile.base   Dockerfile.grove   repos.manifest
scripts/   build-base.sh build-grove.sh clone-repos.sh
           run-race.sh extract-metrics.sh synth-cast.py render.sh compose.sh
scenes/    <id>.prompt.txt (×10)  scenes.yaml  README.md
out/       generated artifacts (gitignored)
```
