#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

wizard="$1"

moon generate frontend

TARGET="$(.just/new/target.sh)"
export TARGET
trap '.just/new/undo.sh "$TARGET"' ERR INT

git add "$TARGET"
nix develop --command bash -c "$wizard"
moon generate frontend --to "$TARGET" --force --defaults -- --name "$(basename "$TARGET")"

trap - ERR INT
just sync
echo "$TARGET is ready. Without direnv, re-enter nix develop before you run a task on it." >&2
