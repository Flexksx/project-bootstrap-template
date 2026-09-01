#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

moon generate python

TARGET="$(.just/new/target.sh)"
export TARGET
trap '.just/new/undo.sh "$TARGET"' ERR INT

git add "$TARGET"

trap - ERR INT
just sync
echo "$TARGET is ready. Without direnv, re-enter nix develop before you run a task on it." >&2
