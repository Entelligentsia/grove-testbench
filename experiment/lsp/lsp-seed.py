#!/usr/bin/env python3
# Seed-open LSP proxy.
#
# Why this exists: clangd (and likely other servers) does NOT serve
# `workspace/symbol` from its static/background index until a file in the project
# has been opened (`textDocument/didOpen`). The MCP->LSP bridge's name-based
# `definition`/`references` tools call `workspace/symbol` WITHOUT first opening a
# file, so on a cold server they return empty ("not found") forever — a
# chicken-and-egg (the lookup needs the index active, activation needs a didOpen).
# Verified on redis: cold `workspace/symbol(dictAdd)` -> []; after one didOpen ->
# 6 results across the whole project.
#
# This process sits transparently between the bridge and the real LSP server:
# it forwards every framed LSP message both ways unchanged, and injects exactly
# ONE `textDocument/didOpen` for $LSP_SEED_FILE right after it sees the client's
# `initialized` notification. One open activates project-wide lookup, so the
# agent's first name-based query already works.
#
# Usage (as the bridge's -lsp command):
#   LSP_SEED_FILE=/abs/path/to/a/source/file \
#   mcp-language-server -workspace <ws> -lsp python3 -- /usr/local/bin/lsp-seed.py <server> [server-args...]
import sys, os, json, subprocess, threading

EXT = {".c": "c", ".h": "c", ".cc": "cpp", ".cpp": "cpp", ".hpp": "cpp",
       ".py": "python", ".ts": "typescript", ".tsx": "typescriptreact",
       ".js": "javascript", ".jsx": "javascriptreact", ".go": "go",
       ".rs": "rust", ".java": "java", ".rb": "ruby", ".php": "php"}

def read_frame(f):
    """Read one Content-Length-framed LSP message; return (raw_bytes, body_bytes) or (None, None) at EOF."""
    h = b""
    while not h.endswith(b"\r\n\r\n"):
        c = f.read(1)
        if not c:
            return None, None
        h += c
    n = 0
    for line in h.split(b"\r\n"):
        if line.lower().startswith(b"content-length:"):
            n = int(line.split(b":")[1])
    body = f.read(n)
    return h + body, body

def frame(obj):
    b = json.dumps(obj).encode()
    return b"Content-Length: %d\r\n\r\n" % len(b) + b

server = subprocess.Popen(sys.argv[1:], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
SEED = os.environ.get("LSP_SEED_FILE")
state = {"seeded": False}

def client_to_server(cin, sout):
    while True:
        raw, body = read_frame(cin)
        if raw is None:
            break
        sout.write(raw); sout.flush()
        if body and SEED and not state["seeded"]:
            try:
                msg = json.loads(body)
            except Exception:
                msg = None
            if msg and msg.get("method") == "initialized":
                state["seeded"] = True
                try:
                    txt = open(SEED, encoding="utf-8", errors="replace").read()
                    lang = EXT.get(os.path.splitext(SEED)[1], "plaintext")
                    sout.write(frame({"jsonrpc": "2.0", "method": "textDocument/didOpen",
                        "params": {"textDocument": {"uri": "file://" + SEED,
                            "languageId": lang, "version": 1, "text": txt}}}))
                    sout.flush()
                except Exception:
                    pass  # best-effort; if the seed file is missing the agent still works once it opens any file

def server_to_client(sin, cout):
    while True:
        raw, _ = read_frame(sin)
        if raw is None:
            break
        cout.write(raw); cout.flush()

s_in, s_out = server.stdin, server.stdout
assert s_in is not None and s_out is not None  # stdin/stdout=PIPE => present
threading.Thread(target=client_to_server, args=(sys.stdin.buffer, s_in), daemon=True).start()
threading.Thread(target=server_to_client, args=(s_out, sys.stdout.buffer), daemon=True).start()
server.wait()
