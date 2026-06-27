#!/usr/bin/env python3
# Measure cold-process bridge readiness: time from mcp-language-server spawn to
# (a) MCP initialize reply and (b) tools/list returning the tool set. Run inside
# a container from the warmed per-repo image. Tells us how long claude must wait
# for the lsp MCP server to connect before the agent turn starts.
import json, subprocess, time, sys, os, threading

WS = os.environ.get("WS", "/home/bench/repos/redis")
SEED = os.environ.get("LSP_SEED_FILE", WS + "/src/server.c")
os.environ["LSP_SEED_FILE"] = SEED
CMD = ["mcp-language-server", "-workspace", WS, "-lsp", "python3", "--",
       "/usr/local/bin/lsp-seed.py", "clangd", "--background-index",
       "--compile-commands-dir=" + WS]

p = subprocess.Popen(CMD, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     stderr=subprocess.DEVNULL, bufsize=0)
t0 = time.time()

def send(o):
    p.stdin.write((json.dumps(o) + "\n").encode()); p.stdin.flush()

def rl(timeout=90):
    out = [None]
    def rd(): out[0] = p.stdout.readline()
    th = threading.Thread(target=rd); th.daemon = True; th.start(); th.join(timeout)
    return out[0]

def wait_id(_id):
    while True:
        l = rl()
        if not l:
            return None
        try:
            m = json.loads(l)
        except Exception:
            continue
        if m.get("id") == _id:
            return m

send({"jsonrpc": "2.0", "id": 1, "method": "initialize",
      "params": {"protocolVersion": "2024-11-05", "capabilities": {},
                 "clientInfo": {"name": "t", "version": "0"}}})
if wait_id(1) is None:
    print("INIT TIMEOUT"); sys.exit(1)
print(f"initialize_reply_s={time.time()-t0:.2f}")

send({"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}})
send({"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}})
m = wait_id(2)
if m is None:
    print("TOOLS TIMEOUT"); sys.exit(1)
print(f"tools_list_s={time.time()-t0:.2f} n_tools={len(m['result']['tools'])}")

# how long until a real definition query actually resolves?
send({"jsonrpc": "2.0", "id": 3, "method": "tools/call",
      "params": {"name": "definition", "arguments": {"symbolName": "dictAdd"}}})
m = wait_id(3)
ok = m and "dict.c" in json.dumps(m)
print(f"definition_resolves_s={time.time()-t0:.2f} hit={bool(ok)}")
p.terminate()
