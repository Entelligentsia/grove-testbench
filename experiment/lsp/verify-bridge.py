#!/usr/bin/env python3
# Cheap LSP-arm verification gate: drives the real MCP->LSP bridge path
# (mcp-language-server -> lsp-seed.py -> clangd) for ONE repo and asserts a known
# symbol resolves line-exact. Run INSIDE a container started from the warmed
# per-repo image. Exits 0 only if the expected file is hit.
#
# NOTE: the bridge speaks the MCP stdio transport upstream = newline-delimited
# JSON-RPC (one JSON object per line), NOT the LSP Content-Length framing it uses
# downstream to clangd. This client therefore writes/reads NDJSON.
#
#   LSP_SEED_FILE=... ./verify-bridge.py <symbol> <expect-substr> -- <bridge cmd...>
import sys, os, json, subprocess, threading, time

argv = sys.argv[1:]
sep = argv.index("--")
SYMBOL, EXPECT = argv[0], argv[1]
CMD = argv[sep + 1:]
DEBUG = os.environ.get("VERIFY_DEBUG") == "1"

p = subprocess.Popen(CMD, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     stderr=(None if DEBUG else subprocess.DEVNULL),
                     bufsize=0)

def send(obj):
    p.stdin.write((json.dumps(obj) + "\n").encode())
    p.stdin.flush()

def read_line(timeout):
    out = [None]
    def rd():
        out[0] = p.stdout.readline()
    t = threading.Thread(target=rd); t.daemon = True; t.start(); t.join(timeout)
    return out[0]

def rpc(method, params, _id, timeout=60):
    send({"jsonrpc": "2.0", "id": _id, "method": method, "params": params})
    deadline = time.time() + timeout
    while time.time() < deadline:
        line = read_line(deadline - time.time())
        if not line:
            return None
        line = line.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except Exception:
            if DEBUG:
                sys.stderr.write("?? " + line.decode(errors="replace")[:200] + "\n")
            continue
        if DEBUG:
            sys.stderr.write("<< " + json.dumps(msg)[:300] + "\n")
        if msg.get("id") == _id:
            return msg

    return None

# MCP handshake (newline-delimited JSON-RPC)
init = rpc("initialize", {"protocolVersion": "2024-11-05", "capabilities": {},
                          "clientInfo": {"name": "verify", "version": "0"}}, 1)
if DEBUG:
    sys.stderr.write(f"initialize -> {'ok' if init else 'TIMEOUT'}\n")
send({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})

# let clangd finish processing the seed didOpen + settle the in-memory index
WARM = int(os.environ.get("VERIFY_WARM_S", "15"))
time.sleep(WARM)

if DEBUG:
    tl = rpc("tools/list", {}, 99, timeout=30)
    names = [t["name"] for t in (tl or {}).get("result", {}).get("tools", [])]
    sys.stderr.write(f"tools: {names}\n")

res, text = None, ""
for attempt in range(4):
    res = rpc("tools/call", {"name": "definition",
                             "arguments": {"symbolName": SYMBOL}}, 200 + attempt,
              timeout=90)
    text = json.dumps(res) if res else ""
    if EXPECT in text:
        break
    if DEBUG:
        sys.stderr.write(f"attempt {attempt}: no hit, got {text[:200]}\n")
    time.sleep(8)

p.terminate()
ok = EXPECT in text
print(f"symbol={SYMBOL} expect={EXPECT} hit={ok}")
print(text[:1000])
sys.exit(0 if ok else 1)
