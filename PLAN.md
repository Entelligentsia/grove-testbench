# grove-testbench — Plan (finalized)

> **Purpose redefined (2026-06-23):** the testbench is now an **evaluation harness
> for grove on real-world code**, not a "grove wins" video project. Its output is
> evidence — per-repo context/time/turns + blind-judged answer quality — feeding a
> structured grove fix backlog ([GROVE-ISSUES.md](GROVE-ISSUES.md)). Findings live
> in [FINDINGS.md](FINDINGS.md). The mechanics below (image lineage, ladder,
> metrics) still hold; any video is now a secondary artifact for data-supported wins.
>
> **Implementation note (locked):** the *capture* approach evolved. Live-TUI/tmux
> capture was superseded — the pipeline runs **headless** (`claude -p` stream-json)
> and **synthesizes** the visual from that. See [README.md](README.md).

A reproducible, publishable harness that races a coding agent **with grove**
against the **same agent without grove**, on the same prompt, over 10 large
popular codebases — and produces a side-by-side screencast for YouTube.

## Decisions locked (from interview)

| Topic | Decision |
|---|---|
| Matchup | **Same agent vs same agent** — Claude-vs-Claude *or* pi-vs-pi. Grove is the only variable. Never Claude-vs-pi. |
| What I deliver | **base** — the un-authenticated, no-grove image + full host harness. Publishable (no secrets). |
| What you do manually | Auth (claude/pi login), grove wiring for pi (skill over grove CLI), then commit local `baseline` / `grove` images. |
| Win metrics (on screen) | **Tokens/context, wall-clock time, tool-calls/turns.** |
| Correctness | **Not scored / not gated** — pure speed+token+turns race. Prompts must be unambiguous. |
| Orchestration | **Two containers, one host orchestrator** fires identical prompt at both, captures casts + metrics. |
| Recording | **asciinema cast → agg render → ffmpeg side-by-side compose.** |
| Task type | **Comprehension / navigation only** (grove's home turf). |
| Codebases | **10, one per language, all grammar-backed** (list below; you edit). |

## Image lineage

```
base  (I deliver — Dockerfile, publishable, NO secrets, NO grove)
  ├─ node 20 + Claude Code CLI + pi CLI
  ├─ asciinema, git, build basics
  ├─ /repos/<name> — 10 codebases cloned at pinned SHAs
  └─ /harness — prompt runner, metrics extractor, scene config
        │
        ▼  (you: claude/pi auth, commit)           → kept LOCAL, never published (creds)
   baseline = base + auth
        │
        ▼  (you: install grove, register `grove serve` MCP for Claude,
        │       add pi grove-CLI skill, commit)    → kept LOCAL
   grove = baseline + grove
```

`baseline` = grove **off**. `grove` = grove **on**. Both authed. Race = `baseline` vs `grove`.

## The 10 codebases (one per language, all in grove-registry)

| # | Language | Repo | Why |
|---|---|---|---|
| 1 | Rust | `tokio-rs/tokio` | Large async runtime, deep call graphs |
| 2 | Go | `gohugoio/hugo` | Big, popular, many packages |
| 3 | Python | `django/django` | Huge, ubiquitous |
| 4 | TypeScript | `microsoft/TypeScript` | Massive TS self-host |
| 5 | JavaScript | `webpack/webpack` | Large pure-JS |
| 6 | C | `redis/redis` | Iconic C, dense |
| 7 | C++ | `bitcoin/bitcoin` | Large, well-known C++ |
| 8 | Java | `spring-projects/spring-boot` | Enterprise-scale Java |
| 9 | Ruby | `rails/rails` | Huge Ruby monorepo |
| 10 | PHP | `laravel/framework` | Popular PHP framework |

All pinned to explicit SHAs in `repos.manifest` for byte-reproducibility.
Clones are **shallow + single-rev** to keep the image lean.

## Prompts (comprehension/navigation — one per repo)

Template family, all unambiguous and grove-favourable:
- "Where is `<symbol>` defined and list every call site."
- "Trace how `<feature>` flows from `<entrypoint>` to `<sink>`."
- "List all implementors of `<trait/interface>`."

Concrete per-repo prompts live in `scenes/<repo>.yaml` (placeholders now;
finalize once repos are pinned). Each scene yaml carries: repo, language,
big-font prompt text, intro blurb, expected-shape note (for your manual sanity
check, not scored).

## Host harness (delivered in this repo)

```
grove-testbench/
├─ Dockerfile.base             # the publishable image
├─ repos.manifest             # repo → URL + pinned SHA
├─ scripts/
│  ├─ build-base.sh           # build + clone repos into image
│  ├─ run-race.sh <repo>      # launch baseline & grove containers, same prompt, record casts
│  ├─ extract-metrics.sh      # tokens/turns from transcripts; time from cast
│  ├─ render.sh               # agg: cast → mp4/gif per pane
│  └─ compose.sh <repo>       # ffmpeg: intro card + prompt card + hstack race + results card
├─ scenes/<repo>.yaml         # per-repo prompt + intro + result template
├─ overlays/                  # title/prompt/result card templates (SVG/PNG)
├─ out/                       # casts, transcripts, rendered scenes (published)
└─ README.md                  # full reproduce-it instructions
```

### Metrics capture
- **Tokens**: from each agent's own usage output (Claude `--print`/session JSON;
  pi history export). Run is TUI-recorded for visuals; metrics parsed from the
  session transcript so numbers are honest, not eyeballed.
- **Time**: asciinema cast duration (first-keystroke → final-answer marker).
- **Turns / tool-calls**: count tool invocations in the transcript.
- Emitted as `out/<repo>.metrics.json` → drives the results card.

### Video, per repo (one scene)
1. **Repo intro card** — name, language, size/def-count.
2. **Prompt card** — large font, the exact prompt.
3. **Race** — two asciinema panes side by side (baseline left, grove right).
4. **Results card** — bar chart: tokens / time / turns; winner stamp.

Scenes concatenated → final reel → YouTube.

## What gets published vs not

- **Published**: this whole repo (Dockerfile.base, harness, scenes), all
  `out/` casts + transcripts + metrics, and the final video.
- **Never published**: `baseline`/`grove` images and any auth material (contain creds).

## Open items for you (manual)

1. Confirm/edit the 10 repos + pin SHAs.
2. Auth Claude + pi inside `base` → commit `baseline`.
3. Wire grove for pi (skill over `grove <verb>`) + register `grove serve` MCP for
   Claude in `grove` → commit `grove`.
4. Approve per-repo prompts in `scenes/`.

## Build order I'll follow once approved

1. `repos.manifest` + `Dockerfile.base` + `build-base.sh`.
2. `run-race.sh` + `extract-metrics.sh` (the orchestration core).
3. `scenes/*.yaml` skeletons + overlay card templates.
4. `render.sh` + `compose.sh` (asciinema→agg→ffmpeg).
5. `README.md` reproduce guide.
