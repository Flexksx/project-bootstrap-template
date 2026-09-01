#!/usr/bin/env bash
# Prints the unit that has a moon.yml but no pyproject.toml and no package.json.
# `just new` calls it to find the directory that `moon generate` just wrote, so
# the wizard knows where to run.
set -euo pipefail
cd "$(dirname "$0")/../.."

found=()

for dir in apps/* libs/*; do
    if [ ! -f "$dir/moon.yml" ]; then
        continue
    fi
    if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/package.json" ]; then
        continue
    fi
    found+=("$dir")
done

case "${#found[@]}" in
    1) echo "${found[0]}" ;;
    0) echo "no unit is waiting for a wizard" >&2; exit 1 ;;
    *) echo "more than one unit is waiting for a wizard: ${found[*]}" >&2; exit 1 ;;
esac
