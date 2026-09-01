#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

moon generate python

TARGET="$(.just/new/target.sh)"
export TARGET
trap '.just/new/undo.sh "$TARGET"' ERR INT

NAME="$(basename "$TARGET")"
export NAME
git add "$TARGET"

nix develop --command bash -c '
    set -euo pipefail
    case "$TARGET" in
        libs/*) uv init --lib --vcs none --no-description --name "$NAME" "$TARGET" ;;
        *) uv init --package --vcs none --no-description --name "$NAME" "$TARGET" ;;
    esac
    cd "$TARGET"
    uv add --quiet --dev pytest ruff ty
'

trap - ERR INT
just sync
echo "$TARGET is ready. Without direnv, re-enter nix develop before you run a task on it." >&2
