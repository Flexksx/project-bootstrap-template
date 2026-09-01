# AGENTS.md

This file is the template stub for agent instructions. Replace it per-project.

## Project map

Describe here, once real units exist:

- What each `apps/*` unit is and what it does.
- What each `libs/*` lib is for and which apps consume it.
- Any `infra/*` project boundaries an agent should know about.

## Entry points

Every developer action uses `just`. `just` sends the work to `moon`.

The whole repo:

- `just format`
- `just lint`
- `just build all`
- `just test all`

`just lint` runs `ruff check` and `ty check`. `just format` applies ruff's safe
fixes, then formats.

One unit:

- `just build <unit>`
- `just test <unit>`
- `just start <app>`

moon compares input hashes. It runs a task only on the units that changed, so
the repo-wide form is the normal one. To bypass the cache, add `-f`:
`just build all -f`. `just` sends all flags to `moon`.

To show every recipe, run `just --list --list-submodules`.

Never call `moon run` in docs or scripts. Add a `just` recipe instead.

### How the wiring works

`format` and `lint` are repo-wide on purpose, so a per-unit recipe adds nothing.
The root `Justfile` imports them and does not use `mod`. `mod` cannot pass
arguments to a submodule default recipe, so `just format -f` fails under `mod`.
Recipes from an imported file run from the root directory, so they need no
`set working-directory`.

`build`, `test`, and `start` are submodules. Each one holds an `all` recipe and
one recipe per unit:

```just
alpha *FLAGS:
    moon run alpha:build {{FLAGS}}
```

`.just/units.sh` reads `moon query tasks` and writes those unit recipes to
`.just/<verb>/units.just`. `.gitignore` lists the three files, and each verb
`Justfile` imports its own file with `import?`. A fresh clone works before the
files exist.

The script rewrites each file from the start every time, so a deleted unit
disappears without a separate step. A stale entry never breaks `just`, because
the recipe still parses. It fails only when you run it.

`.envrc` runs the script on every direnv reload. direnv already watches `apps/`
and `libs/`, so the indexes refresh when you add or remove a unit. To force a
rebuild, run `just sync`.

Do not name a unit `all`. The name collides with the repo-wide recipe in every
submodule.

A new unit needs no change to `.just/` or `lefthook.yml`. A new language needs
one `.moon/tasks/<language>.yml`. A new verb needs one directory under `.just/`
and one entry in the `verbs` list in `.just/units.sh`.

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
moon generate python -- --name <name> --kind lib   # -> libs/<name>
moon generate python -- --name <name> --kind app   # -> apps/<name>
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
  build:
    command: 'uv build --sdist'
    options:
      mergeArgs: 'replace'
  test:
    args: '--maxfail=1'
```

`format` and `lint` use `script:`, not `command:`, because each one runs two
tools. To override a `script` task, the unit must also use `script:`. moon
ignores a `command:` override on a `script` task, and it reports no error:

```yaml
tasks:
  lint:
    script: 'uv run ruff check .'
```

Drop or rename an inherited task under `workspace.inheritedTasks`:

```yaml
workspace:
  inheritedTasks:
    exclude: ['build']
    rename:
      test: 'check'
```

## Dev environment

`direnv allow` (or `nix develop`) loads the pinned toolchain.

The flake imports `./nix`, `./apps` and `./libs`. Repo-wide tools go in
`nix/`; a unit's own toolchain goes in `<unit>/nix/devshell.nix`.

Two rules an agent will otherwise get wrong:

- A new `.nix` file is invisible to `nix develop` until `git add`. Flakes ignore
  untracked files. With direnv the shell then reloads on its own, because
  `.envrc` watches `apps/`, `libs/` and every `nix/*.nix` file. Without direnv,
  re-enter `nix develop`.
- `import-tree` loads every `.nix` file under those trees as a flake-parts
  module. A `callPackage` expression must be named `_package.nix`, because
  import-tree skips any path containing `/_`.

## Conventions an agent can't derive from the code

Add anything here that isn't obvious from reading the repo: naming conventions,
ownership boundaries, things that look like dead code but aren't, etc.
