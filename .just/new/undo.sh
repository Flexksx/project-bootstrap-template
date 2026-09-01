#!/usr/bin/env bash
# Removes a half-made unit after a wizard fails, and unstages what `just new`
# staged for the flake.
set -euo pipefail
cd "$(dirname "$0")/../.."

target="${1:-}"
[ -n "$target" ] || exit 0

git reset --quiet -- "$target" 2>/dev/null || true
rm -rf "$target"
echo "removed the half-made unit $target" >&2
