#!/usr/bin/env bash
# Build grove = baseline + grove. Stages the host `grove` binary into the build context.
# Requires the baseline image to exist (created manually after auth — see build-base.sh).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
DB_IMAGE="${1:-grove-testbench/baseline:latest}"
TAG="${2:-grove-testbench/grove:latest}"

# Prefer an explicit binary (e.g. the freshly-built fixed one for R2):
#   GROVE_BIN=../grove/target/release/grove scripts/build-grove.sh
grove_bin="${GROVE_BIN:-$(command -v grove || true)}"
[[ -n "$grove_bin" && -x "$grove_bin" ]] || { echo "grove binary not found (set GROVE_BIN=path or put grove on PATH)" >&2; exit 1; }
echo ">> grove version: $("$grove_bin" --version 2>/dev/null || echo '(no --version)')"

ctx="$root/.grovectx"; mkdir -p "$ctx"
cp "$grove_bin" "$ctx/grove"
cp "$root/Dockerfile.grove" "$ctx/Dockerfile.grove"

echo ">> building $TAG from $DB_IMAGE (grove: $grove_bin)"
docker build --build-arg "DB_IMAGE=$DB_IMAGE" -f "$ctx/Dockerfile.grove" -t "$TAG" "$ctx"
rm -rf "$ctx"

echo
echo "grove built: $TAG"
echo "race:  scripts/run-race.sh <scene-id>   # uses baseline + grove by default"
