#!/usr/bin/env bash
# Build dg = db + grove. Stages the host `grove` binary into the build context.
# Requires the db image to exist (created manually after auth — see build-base0.sh).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
DB_IMAGE="${1:-grove-testbench/db:latest}"
TAG="${2:-grove-testbench/dg:latest}"

grove_bin="$(command -v grove || true)"
[[ -n "$grove_bin" ]] || { echo "grove not found on host PATH" >&2; exit 1; }

ctx="$root/.dgctx"; mkdir -p "$ctx"
cp "$grove_bin" "$ctx/grove"
cp "$root/Dockerfile.dg" "$ctx/Dockerfile.dg"

echo ">> building $TAG from $DB_IMAGE (grove: $grove_bin)"
docker build --build-arg "DB_IMAGE=$DB_IMAGE" -f "$ctx/Dockerfile.dg" -t "$TAG" "$ctx"
rm -rf "$ctx"

echo
echo "dg built: $TAG"
echo "race:  scripts/run-race.sh <scene-id>   # uses db + dg by default"
