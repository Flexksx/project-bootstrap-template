#!/usr/bin/env bash
set -euo pipefail

target="$1"
script_name="$2"
script_cmd="$3"

node -e '
  var p = require("./" + process.argv[1] + "/package.json");
  p.scripts = p.scripts || {};
  p.scripts[process.argv[2]] = process.argv[3];
  require("fs").writeFileSync(process.argv[1] + "/package.json", JSON.stringify(p, null, 2) + "\n");
' "$target" "$script_name" "$script_cmd"
