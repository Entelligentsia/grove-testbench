#!/usr/bin/env bash
# Build the publishable base0 image (no secrets, no grove).
# Run from anywhere; resolves the repo root from this script's location.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

TAG="${1:-grove-testbench/base0:latest}"

echo ">> building $TAG from $root"
docker build \
  -f "$root/Dockerfile.base0" \
  -t "$TAG" \
  "$root"

cat <<EOF

base0 built: $TAG

Next (manual, kept LOCAL — never publish these):
  1. Run it, authenticate the agent(s), commit -> db   (grove OFF)
       docker run -it --name dbsetup $TAG bash
       #   (inside) claude login  /  pi auth ...
       docker commit dbsetup grove-testbench/db:latest
  2. From db, install + wire grove, commit -> dg        (grove ON)
       #   (inside) install grove, register 'grove serve' MCP for Claude,
       #            add pi grove-CLI skill
       docker commit <container> grove-testbench/dg:latest

Then race:  scripts/run-race.sh <repo>
EOF
