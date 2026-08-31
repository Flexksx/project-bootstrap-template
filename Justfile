[private]
default:
    just --list

[private]
[no-cd]
moon-run *TARGETS:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "$(moon query tasks | jaq '.tasks | length')" -eq 0 ]; then
      exit 0
    fi
    moon run {{TARGETS}}

# Format the repo, or one unit. Pass -c to bypass the cache.
format *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    force=""
    unit=""
    for arg in {{ARGS}}; do
      case "$arg" in
        -c|--clean) force="--force" ;;
        *) unit="$arg" ;;
      esac
    done
    if [ -n "$unit" ]; then
      just moon-run "$unit:format" $force
    else
      alejandra .
      rumdl check --fix .
      just moon-run :format $force
    fi

# Lint and type-check the repo, or one unit. Pass -c to bypass the cache.
lint *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    force=""
    unit=""
    for arg in {{ARGS}}; do
      case "$arg" in
        -c|--clean) force="--force" ;;
        *) unit="$arg" ;;
      esac
    done
    if [ -n "$unit" ]; then
      just moon-run "$unit:lint" "$unit:typecheck" $force
    else
      rumdl check .
      just moon-run :lint :typecheck $force
    fi

# Test the repo, or one unit. Pass -c to bypass the cache.
test *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    force=""
    unit=""
    for arg in {{ARGS}}; do
      case "$arg" in
        -c|--clean) force="--force" ;;
        *) unit="$arg" ;;
      esac
    done
    if [ -n "$unit" ]; then
      just moon-run "$unit:test" $force
    else
      just moon-run :test $force
    fi

# Build every unit, or one unit. Pass -c to bypass the cache.
build *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    force=""
    unit=""
    for arg in {{ARGS}}; do
      case "$arg" in
        -c|--clean) force="--force" ;;
        *) unit="$arg" ;;
      esac
    done
    if [ -n "$unit" ]; then
      just moon-run "$unit:build" $force
    else
      just moon-run :build $force
    fi
