#!/usr/bin/env bash
# Build the publishable base image (no secrets, no grove).
# Run from anywhere; resolves the repo root from this script's location.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"

TAG="${1:-grove-testbench/base:latest}"

echo ">> building $TAG from $root"
docker build \
  -f "$root/Dockerfile.base" \
  -t "$TAG" \
  "$root"

cat <<EOF

base built: $TAG

Next (manual, kept LOCAL — never publish these):
  1. Run it, authenticate the agent(s), commit -> baseline   (grove OFF)
       docker run -it --name baselinesetup $TAG bash
       #   (inside) claude login  /  pi auth ...
       docker commit baselinesetup grove-testbench/baseline:latest
  2. From baseline, install + wire grove, commit -> grove    (grove ON)
       #   (inside) install grove, register 'grove serve' MCP for Claude,
       #            add pi grove-CLI skill
       docker commit <container> grove-testbench/grove:latest

Then race:  scripts/run-race.sh <repo>
EOF
