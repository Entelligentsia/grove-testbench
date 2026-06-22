#!/usr/bin/env python3
"""
Synthesize a clean, branded asciinema v2 cast from a Claude Code stream-json
transcript. Reliable alternative to capturing the live TUI (no startup gates,
no terminal quirks) and fully under our control for production quality.

The cast reveals: a header badge (repo / grove ON|OFF), the prompt typed in,
each tool call appearing in order, the answer, and a final metrics ticker.
Total cast duration is scaled from the REAL run duration so a side-by-side
compose preserves the actual race (grove usually finishes first).

Usage:
  synth-cast.py --jsonl F --out CAST --repo redis --lang C --side dg
                --prompt-file P [--cols 92] [--rows 30] [--speed 0.45]
"""
import argparse, json, re

# ---- palette (truecolor) --------------------------------------------------
RESET = "\x1b[0m"; BOLD = "\x1b[1m"; DIM = "\x1b[2m"
def fg(r, g, b): return f"\x1b[38;2;{r};{g};{b}m"
GREEN = fg(126, 211, 133); RED = fg(229, 115, 115); GREY = fg(150, 150, 160)
CYAN = fg(120, 200, 230); WHITE = fg(235, 235, 240); GOLD = fg(230, 180, 80)
ORANGE = fg(220, 120, 70)


def pretty_tool(name):
    if name.startswith("mcp__grove__"):
        return f"{GREEN}grove{RESET} {DIM}▸{RESET} {name[len('mcp__grove__'):]}"
    low = name.lower()
    if low in ("bash",): return f"{GREY}bash{RESET}"
    if low in ("read",): return f"{GREY}read{RESET}"
    if low in ("grep", "glob"): return f"{GREY}{low}{RESET}"
    if name == "ToolSearch": return f"{GREY}tool-search{RESET}"
    return f"{GREY}{name}{RESET}"


def parse(jsonl):
    tools, answer, usage, turns, dur_ms = [], "", {}, 0, 0
    with open(jsonl) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except Exception:
                continue
            if ev.get("type") == "assistant":
                for b in ev.get("message", {}).get("content", []):
                    if b.get("type") == "tool_use":
                        tools.append(b.get("name", "?"))
            elif ev.get("type") == "result":
                usage = ev.get("usage", {}) or {}
                turns = ev.get("num_turns", 0)
                dur_ms = ev.get("duration_ms", 0)
                answer = ev.get("result", "") or ""
    return tools, answer, usage, turns, dur_ms


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--jsonl", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--repo", required=True)
    ap.add_argument("--lang", default="")
    ap.add_argument("--side", required=True, choices=["db", "dg"])
    ap.add_argument("--prompt-file", required=True)
    ap.add_argument("--cols", type=int, default=92)
    ap.add_argument("--rows", type=int, default=30)
    ap.add_argument("--speed", type=float, default=0.45, help="cast_seconds = real_seconds * speed")
    a = ap.parse_args()

    prompt = open(a.prompt_file).read().strip()
    tools, answer, usage, turns, dur_ms = parse(a.jsonl)
    grove_on = a.side == "dg"
    tok = usage.get("input_tokens", 0) + usage.get("output_tokens", 0)
    real_s = max(dur_ms / 1000.0, 1.0)
    cast_s = min(max(real_s * a.speed, 5.0), 32.0)

    badge = (GREEN + "grove ON " + RESET) if grove_on else (RED + "grove OFF" + RESET)
    accent = GREEN if grove_on else RED

    events = []  # (t, text)
    def at(t, s): events.append((round(t, 3), s))

    W = a.cols
    bar = "─" * (W - 2)
    # header panel
    head = []
    head.append(f"{accent}╭{bar}╮{RESET}\r\n")
    label = f" grove-testbench   {WHITE}{a.repo}{RESET}{GREY}" + (f" ({a.lang})" if a.lang else "") + RESET
    right = f"{badge} "
    pad = max(1, (W - 2) - (len(re.sub(r'\x1b\[[0-9;]*m', '', label)) + len(re.sub(r'\x1b\[[0-9;]*m', '', right))))
    head.append(f"{accent}│{RESET}{label}{' '*pad}{right}{accent}│{RESET}\r\n")
    head.append(f"{accent}╰{bar}╯{RESET}\r\n\r\n")
    at(0.0, "".join(head))

    # prompt typed in
    at(0.3, f"{accent}❯ {RESET}{WHITE}")
    tstart = 0.5
    type_span = min(1.6, cast_s * 0.18)
    for i, ch in enumerate(prompt):
        at(tstart + type_span * (i / max(1, len(prompt))), ch)
    at(tstart + type_span + 0.1, f"{RESET}\r\n\r\n")

    # tool calls revealed over the run window
    win_start = tstart + type_span + 0.4
    win_end = cast_s - 1.6
    n = max(1, len(tools))
    for i, name in enumerate(tools):
        t = win_start + (win_end - win_start) * (i / n)
        at(t, f"  {accent}▸{RESET} {pretty_tool(name)}\r\n")
    if not tools:
        at(win_start, f"  {GREY}(no tool calls){RESET}\r\n")

    # answer (first lines, lightly de-marked)
    ans_lines = [re.sub(r"[*`#|]", "", l).rstrip() for l in answer.splitlines()]
    ans_lines = [l for l in ans_lines if l.strip()][:8]
    at(cast_s - 1.4, f"\r\n  {accent}✦{RESET} {DIM}answer{RESET}\r\n")
    for i, l in enumerate(ans_lines):
        at(cast_s - 1.2 + 0.12 * i, f"  {WHITE}{l[:W-4]}{RESET}\r\n")

    # footer ticker
    grv = "ON" if grove_on else "OFF"
    ticker = (f"\r\n{accent}{bar}{RESET}\r\n"
              f" {badge}{GREY}·{RESET} {GOLD}{tok:,}{RESET} tok {GREY}·{RESET} "
              f"{turns} turns {GREY}·{RESET} {len(tools)} tools {GREY}·{RESET} "
              f"{CYAN}{real_s:.0f}s{RESET}\r\n")
    at(cast_s, ticker)

    # write asciinema v2
    events.sort(key=lambda e: e[0])
    with open(a.out, "w") as f:
        f.write(json.dumps({"version": 2, "width": a.cols, "height": a.rows}) + "\n")
        for t, s in events:
            f.write(json.dumps([t, "o", s]) + "\n")
    print(f"wrote {a.out}  (real {real_s:.0f}s -> cast {cast_s:.0f}s, {len(tools)} tools, {tok:,} tok)")


if __name__ == "__main__":
    main()
