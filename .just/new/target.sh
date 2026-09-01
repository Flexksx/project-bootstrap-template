#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

waiting=()

for dir in apps/* libs/*; do
    if [ ! -f "$dir/moon.yml" ]; then
        continue
    fi
    if [ -f "$dir/pyproject.toml" ] || [ -f "$dir/package.json" ]; then
        continue
    fi
    waiting+=("$dir")
done

case "${#waiting[@]}" in
    1) echo "${waiting[0]}" ;;
    0) echo "no unit is waiting for a wizard" >&2; exit 1 ;;
    *) echo "more than one unit is waiting for a wizard: ${waiting[*]}" >&2; exit 1 ;;
esac
