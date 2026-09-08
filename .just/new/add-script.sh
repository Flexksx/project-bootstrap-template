#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

target="$1"
script_name="$2"
script_cmd="$3"

pkg="$target/package.json"
node -e '
  var fs = require("fs");
  var p = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  p.scripts = p.scripts || {};
  p.scripts[process.argv[2]] = process.argv[3];
  fs.writeFileSync(process.argv[1], JSON.stringify(p, null, 2) + "\n");
' "$pkg" "$script_name" "$script_cmd"
