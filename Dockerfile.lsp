# grove-testbench :: lsp
# ---------------------------------------------------------------------------
# The `lsp` arm: base + the MCP<->LSP bridge + per-language LSP servers, so a
# Claude Code agent gets SEMANTIC navigation (go-to-def / find-refs / hover)
# through MCP. Like base/grove this is NEVER published — creds are mounted at
# runtime; this image only adds tooling.
#
# Bridge: isaacphi/mcp-language-server — wraps ONE LSP server and exposes
# name-based definition/references/hover MCP tools. The per-repo MCP config
# (written by the lsp setup step) points it at that repo's server + workspace.
#
# Build (from repo root):  docker build -f Dockerfile.lsp -t grove-testbench/lsp:latest .
# ---------------------------------------------------------------------------

# --- stage 1: build the MCP<->LSP bridge -----------------------------------
FROM golang:1.24-bookworm AS bridge
RUN GOBIN=/out go install github.com/isaacphi/mcp-language-server@latest

# --- stage 2: base + bridge + language servers -----------------------------
FROM grove-testbench/base:latest
USER root

# the bridge binary
COPY --from=bridge /out/mcp-language-server /usr/local/bin/mcp-language-server

# C / C++ semantic server (redis, bitcoin) — needs a per-repo compile DB,
# generated at the lsp setup step (compile_flags.txt or compile_commands.json).
RUN apt-get update && apt-get install -y --no-install-recommends clangd \
    && rm -rf /var/lib/apt/lists/*

# node-based servers (node already in base): TS/JS (webpack, typescript),
# Python (django), PHP (laravel). Heavier toolchains (go/rust/ruby/java) are
# layered on later as those repos are wired.
RUN npm install -g typescript-language-server typescript pyright intelephense

USER bench
CMD ["bash"]
