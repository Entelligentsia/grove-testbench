#!/usr/bin/env bash
# Build the probe image (base + baked grammars). Run RARELY — only when base or
# the grammar set changes. The binary under test is mounted at runtime by
# run-probes.sh, so a grove fix does NOT require rebuilding this image.
#
#   scripts/build-probe.sh                 # grammars baked using host `grove`
#   GROVE_BIN=path scripts/build-probe.sh  # ...using a specific grove to fetch
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
BASE="${BASE:-grove-testbench/base:latest}"
TAG="${1:-grove-testbench/probe:latest}"

grove_bin="${GROVE_BIN:-$(command -v grove || true)}"
[[ -n "$grove_bin" && -x "$grove_bin" ]] || { echo "need a grove to fetch grammars (GROVE_BIN=path or grove on PATH)" >&2; exit 1; }

ctx="$root/.probectx"; mkdir -p "$ctx"
cp "$grove_bin" "$ctx/grove"
cp "$root/Dockerfile.probe" "$ctx/Dockerfile.probe"
echo ">> building $TAG from $BASE (grammars via $($grove_bin --version 2>/dev/null))"
docker build --build-arg "BASE=$BASE" -f "$ctx/Dockerfile.probe" -t "$TAG" "$ctx"
rm -rf "$ctx"
echo "probe built: $TAG"
echo "verify:  GROVE_BIN=../grove/target/release/grove scripts/run-probes.sh --label r2"
