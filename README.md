# grove-testbench

A reproducible harness that races a coding agent **with grove** against the
**same agent without grove**, on the **same prompt**, across 10 large popular
codebases — and renders a side-by-side video of each race.

Same agent both sides (Claude-vs-Claude). Grove is the only variable. The race
is run **headless** (`claude -p --output-format stream-json`) — reliable, no TUI
startup gates — and the visual is **synthesized** from that stream-json into a
clean, branded terminal animation timed to the real run duration.

> The original vision and locked decisions live in [PLAN.md](PLAN.md).

## Image lineage (built locally; db/dg never published — they hold creds)

```
base0   Dockerfile.base0   node22 + Claude Code + pi + 10 repos (pinned) + tooling
  │     scripts/build-base0.sh
  ▼     (manual: claude login, commit)
db      grove OFF — authed, vanilla repos
  │     scripts/build-dg.sh
  ▼     (grove binary + grammars + `grove init --as mcp` steering in every repo)
dg      grove ON  — grove set up properly (CLAUDE.md steering + .mcp.json)
```

`db` = the baseline. `dg` = "grove is set up." That asymmetry (dg steered, db
vanilla) is the **realistic** comparison — disclose it when publishing.

## The pipeline

```
run-race.sh   <id>   →  out/<id>.claude.{db,dg}.jsonl   (headless stream-json, 1 run/side)
extract-metrics.sh <id>  →  out/<id>.claude.metrics.json  (context/time/tools/turns + winner)
render.sh     <id>   →  out/<id>.{db,dg}.mp4            (synth-cast.py → agg → mp4)
compose.sh    <id>   →  out/<id>.race.mp4              (side-by-side; faster side waits = wins)
```

`synth-cast.py` turns a side's stream-json into an asciinema cast (header badge,
prompt, tool calls revealed in order, answer, metrics ticker), scaled to the
real duration so the composed race is honest.

## Fair base steering (`claude-md/`)

`claude-md/<repo>.base.md` is a realistic, grove-free contributor guide a
maintainer would actually write for that project (layout, build/test,
conventions). When present, `run-race.sh` injects it as the repo's `CLAUDE.md` on
**both** sides before the run:

- **db** gets the base only.
- **dg** gets the base **plus** its baked `<!-- grove:start -->…<!-- grove:end -->`
  block (what `grove init` wrote).

So both sides share identical project guidance and **grove is the only
variable** — instead of comparing "steered dg vs vanilla db". With no base file,
behaviour is unchanged (db vanilla, dg grove-only). All ten repos have a base
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
the first rung where `dg.context < db.context`. This is the self-evaluating loop:
it *measures* the relative gain rather than asserting it.

## Quick start

```bash
# 1. base0 (publishable, no secrets)
scripts/build-base0.sh

# 2. db: authenticate, commit (manual — your creds, kept local)
docker run -it --name dbsetup grove-testbench/base0 bash   # inside: claude login; exit
docker commit dbsetup grove-testbench/db:latest && docker rm dbsetup

# 3. dg: grove + grammars + per-repo steering
scripts/build-dg.sh

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
- **db is provably grove-free**: `--strict-mcp-config` + empty MCP config, and
  the db image has no grove binary or steering.

## What gets published vs not

- **Publish:** this repo (Dockerfiles, scripts, scenes), and per-run `out/`
  transcripts + videos when you do real runs.
- **Never publish:** `db`/`dg` images and any auth material.

## Layout

```
Dockerfile.base0  Dockerfile.dg   repos.manifest
scripts/   build-base0.sh build-dg.sh clone-repos.sh
           run-race.sh extract-metrics.sh synth-cast.py render.sh compose.sh
scenes/    <id>.prompt.txt (×10)  scenes.yaml  README.md
out/       generated artifacts (gitignored)
```
