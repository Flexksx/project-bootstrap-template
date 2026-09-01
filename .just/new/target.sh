#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

mapfile -t waiting < <(git ls-files --others --exclude-standard -- 'apps/*/moon.yml' 'libs/*/moon.yml')

case "${#waiting[@]}" in
    1) dirname "${waiting[0]}" ;;
    0) echo "no new unit is waiting" >&2; exit 1 ;;
    *) echo "more than one new unit is waiting: ${waiting[*]}" >&2; exit 1 ;;
esac
