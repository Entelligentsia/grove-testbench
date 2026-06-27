"""Minimal synchronous LSP client over stdio — just enough to drive a language
server's textDocument/definition for the cross-file hit-rate probe.

Authoritative go-to-def oracle: the server resolves names through its own
type/import model, which is exactly the semantic ground truth grove's lexical
import-edge resolution is being measured against.
"""

import json
import os
import subprocess
import threading


class LspClient:
    def __init__(self, cmd, root_path):
        self.proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )
        self.root_path = os.path.abspath(root_path)
        self._id = 0
        self._responses = {}
        self._cv = threading.Condition()
        self._reader = threading.Thread(target=self._read_loop, daemon=True)
        self._reader.start()

    # ---- wire protocol ----
    def _send(self, payload):
        body = json.dumps(payload).encode("utf-8")
        header = f"Content-Length: {len(body)}\r\n\r\n".encode("ascii")
        self.proc.stdin.write(header + body)
        self.proc.stdin.flush()

    def _read_loop(self):
        out = self.proc.stdout
        while True:
            # read headers
            headers = {}
            line = out.readline()
            if not line:
                return
            while line not in (b"\r\n", b"\n", b""):
                if b":" in line:
                    k, v = line.split(b":", 1)
                    headers[k.strip().lower()] = v.strip()
                line = out.readline()
            n = int(headers.get(b"content-length", b"0"))
            body = out.read(n)
            if not body:
                return
            try:
                msg = json.loads(body)
            except Exception:
                continue
            if "id" in msg and ("result" in msg or "error" in msg):
                with self._cv:
                    self._responses[msg["id"]] = msg
                    self._cv.notify_all()

    def _request(self, method, params, timeout=120):
        self._id += 1
        rid = self._id
        self._send({"jsonrpc": "2.0", "id": rid, "method": method, "params": params})
        with self._cv:
            while rid not in self._responses:
                if not self._cv.wait(timeout=timeout):
                    raise TimeoutError(f"{method} timed out")
            return self._responses.pop(rid)

    def _notify(self, method, params):
        self._send({"jsonrpc": "2.0", "method": method, "params": params})

    # ---- LSP lifecycle ----
    def initialize(self):
        root_uri = "file://" + self.root_path
        self._request(
            "initialize",
            {
                "processId": os.getpid(),
                "rootUri": root_uri,
                "workspaceFolders": [{"uri": root_uri, "name": "root"}],
                "capabilities": {"textDocument": {"definition": {}}},
            },
        )
        self._notify("initialized", {})

    def did_open(self, path, language_id, text):
        self._notify(
            "textDocument/didOpen",
            {
                "textDocument": {
                    "uri": "file://" + os.path.abspath(path),
                    "languageId": language_id,
                    "version": 1,
                    "text": text,
                }
            },
        )

    def definition(self, path, line0, char0, timeout=120):
        """Return list of (file_path, line0) the position resolves to."""
        resp = self._request(
            "textDocument/definition",
            {
                "textDocument": {"uri": "file://" + os.path.abspath(path)},
                "position": {"line": line0, "character": char0},
            },
            timeout=timeout,
        )
        result = resp.get("result") or []
        if isinstance(result, dict):
            result = [result]
        out = []
        for loc in result:
            uri = loc.get("uri") or loc.get("targetUri")
            rng = loc.get("range") or loc.get("targetSelectionRange") or loc.get("targetRange")
            if not uri or not rng:
                continue
            fp = uri[len("file://"):] if uri.startswith("file://") else uri
            out.append((fp, rng["start"]["line"]))
        return out

    def shutdown(self):
        try:
            self._request("shutdown", None, timeout=10)
            self._notify("exit", {})
        except Exception:
            pass
        try:
            self.proc.terminate()
        except Exception:
            pass
