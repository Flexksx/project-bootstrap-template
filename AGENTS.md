# AGENTS.md

This file is the template stub for agent instructions. Replace it per-project.

## Project map

Describe here, once real units exist:

- What each `apps/*` unit is and what it does.
- What each `libs/*` lib is for and which apps consume it.
- Any `infra/*` project boundaries an agent should know about.

## Entry points

All developer actions go through `just`. `just` delegates per-unit work to `moon`.

- `just build all` / `just build unit <name>` — build.
- `just test all` / `just test unit <name>` / `just test affected` — test.
- `just lint all`, `just format all` — repo-wide.

Run `just --list --list-submodules` to see everything currently wired up.

Never call `moon run` directly in docs or scripts. Add a `just` recipe instead.

## Task definitions

`.moon/tasks/<language>.yml` holds the real commands. A project inherits them
through `inheritedBy.tags`, so a unit's `moon.yml` only declares metadata:

```yaml
language: 'python'
layer: 'library'
tags: ['python']
```

Every task sets `toolchains: 'system'`. moon must not install its own runtimes.

For Python, nix provides only `uv`. Everything else — the interpreter, `ruff`,
`ty`, `pytest` — comes from `uv`, so every task is `uv run <tool>` and depends on
`install`. Lint and type rules live in each unit's `ruff.toml` and `ty.toml`,
never in `pyproject.toml`.

Scaffold a unit with `moon generate`, then `git add` it:

```bash
moon generate python --to libs/<name> -- --name <name> --kind lib
moon generate python --to apps/<name> -- --name <name> --kind app
git add libs/<name>
```

Both kinds render the same `.moon/templates/python` template. Edit the one
template; do not fork it.

## Overriding an inherited task

Redefine the task in the unit's `moon.yml`. Args **append** by default, so a bare
`command:` override concatenates with the inherited args. Set `mergeArgs` to
`replace` when you want to drop them:

```yaml
tasks:
  lint:
    command: 'ruff check --select ALL .'
    options:
      mergeArgs: 'replace'
  test:
    args: '--maxfail=1'
```

Drop or rename an inherited task under `workspace.inheritedTasks`:

```yaml
workspace:
  inheritedTasks:
    exclude: ['build']
    rename:
      typecheck: 'types'
```

## Dev environment

`direnv allow` (or `nix develop`) loads the pinned toolchain.

The flake imports `./nix`, `./apps` and `./libs`. Repo-wide tools go in
`nix/`; a unit's own toolchain goes in `<unit>/nix/devshell.nix`.

Two rules an agent will otherwise get wrong:

- A new `.nix` file is invisible to `nix develop` until `git add`. Flakes ignore
  untracked files.
- `import-tree` loads every `.nix` file under those trees as a flake-parts
  module. A `callPackage` expression must be named `_package.nix`, because
  import-tree skips any path containing `/_`.

## Conventions an agent can't derive from the code

Add anything here that isn't obvious from reading the repo: naming conventions,
ownership boundaries, things that look like dead code but aren't, etc.
