#!/usr/bin/env bash
# Retag existing local images from the old naming to the new naming.
# Safe to run multiple times; old tags are left in place (not removed).
# Run once after pulling/building with the old names, or when upgrading
# from a clone that predates the base0/db/dg → base/baseline/grove rename.
#
# Old → new:
#   grove-testbench/base0   → grove-testbench/base
#   grove-testbench/db      → grove-testbench/baseline
#   grove-testbench/dg      → grove-testbench/grove
#   grove-testbench/probe   → (unchanged)
set -euo pipefail

retag() {
  local old="$1" new="$2"
  if docker image inspect "$old" >/dev/null 2>&1; then
    docker tag "$old" "$new"
    echo "retagged: $old  →  $new"
  else
    echo "skip (not found): $old"
  fi
}

retag grove-testbench/base0:latest   grove-testbench/base:latest
retag grove-testbench/db:latest      grove-testbench/baseline:latest
retag grove-testbench/dg:latest      grove-testbench/grove:latest

# Tagged releases (e.g. dg:r1, dg:r2)
for tag in $(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null \
             | grep -E '^grove-testbench/(base0|db|dg):' || true); do
  repo="${tag%%:*}"
  ver="${tag##*:}"
  case "$repo" in
    grove-testbench/base0) new_repo=grove-testbench/base ;;
    grove-testbench/db)    new_repo=grove-testbench/baseline ;;
    grove-testbench/dg)    new_repo=grove-testbench/grove ;;
    *) continue ;;
  esac
  retag "$tag" "$new_repo:$ver"
done

echo "done. old tags still exist; remove them with 'docker rmi <old>' when ready."
