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

`format` and `lint` are repo-wide, and each language decides what they mean. A
Python unit runs `ruff` and `ty`. A frontend unit runs its own `package.json`
scripts.

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

`build`, `test`, `start` and `new` are submodules. `build`, `test` and `start`
each hold an `all` recipe and one recipe per unit:

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

`new` holds one recipe per language wizard, and each recipe takes a workspace
path as an argument. It gets no generated index, because it runs no per-unit
moon task.

A new unit needs no change to `.just/` or `lefthook.yml`. A new language needs
one `.moon/tasks/<language>.yml`. A new verb needs one directory under `.just/`.
A verb with a per-unit recipe also needs one entry in the `verbs` list in
`.just/units.sh`.

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

## Scaffolding a unit

Every language uses one pattern, and no recipe takes an argument:

```bash
just new python
just new sveltekit
just new nuxt
git add <path>
```

Each recipe runs four steps:

1. `moon generate` asks for the name, and for Python also for the kind. The
   template's `destination` puts a `lib` in `libs/<name>` and an `app` in
   `apps/<name>`.
2. `.just/new/target.sh` finds that directory. The unit that has a `moon.yml`
   but no `pyproject.toml` and no `package.json` is the one that still waits for
   a wizard. The script fails if it finds none, or more than one.
3. The language wizard runs in that directory.
4. `just sync` rebuilds the unit indexes.

A template holds the wiring only, never application code:

- `.moon/templates/python` writes `moon.yml`, `README.md`, `.gitignore`,
  `ruff.toml`, `ty.toml` and one starter test.
- `.moon/templates/frontend` writes `moon.yml` and `README.md`.

The wizard owns everything else, including the linter, the formatter and the
test runner. The Python recipe also runs `uv add --dev pytest ruff ty`, because
a template cannot add a dependency.

Each wizard needs a different flag to accept a directory that is not empty:

- `uv init` needs no flag. It keeps every file that it did not write.
- `sv create` needs `--no-dir-check`, or it stops and asks.
- `create-nuxt` needs `--force`. It keeps `moon.yml` but overwrites `README.md`.

Both frontend recipes therefore call `moon generate` a second time with
`--force`, to put the unit `README.md` back after the wizard.

Two rules for the `moon generate` call:

- moon flags go before the `--`, and template variables go after it. A `--to`
  after the `--` fails with `unexpected argument`.
- `--force` overwrites a file that the wizard wrote, and it leaves every other
  file alone.

`moon generate` copies files and cannot run a command, so it can never call the
wizard itself. The recipe does that.

## Frontend units

`.moon/tasks/typescript.yml` holds the tasks for tag `typescript`. Each task
calls a script in the unit's `package.json`:

| moon task | package.json script |
| --------- | ------------------- |
| `format`  | `format`            |
| `lint`    | `lint`              |
| `test`    | `test`              |
| `build`   | `build`             |
| `start`   | `dev`               |

`format`, `lint` and `test` use `pnpm run --if-present`, because a wizard does
not always write those scripts. To change what a task does, edit the script. To
add a task to a unit, add a script with the name in the table.

The `build` task declares no `outputs`, because each framework writes a
different directory. To let moon cache the artifacts, add `outputs` to the
unit's `moon.yml`.

Frontend units are members of one pnpm workspace. `pnpm-workspace.yaml` and the
root `package.json` declare it. The lockfile stays at the repo root. The root
`moon.yml` owns the `install` task. Every frontend task depends on
`repo:install`, so `just` needs no separate install step.

Three traps the wizards leave behind:

- `sv create` defaults to `@sveltejs/adapter-auto`. On a machine that adapter
  does not recognise, it writes no output and the build still reports success.
  Pick a real adapter before you deploy.
- `sv create` writes a `check` script for `svelte-check`, but the `lint` script
  does not call it. To type-check in `just lint`, append `&& pnpm run check` to
  the `lint` script.
- The Nuxt minimal template writes no `lint`, `format` or `test` script. Those
  moon tasks then do nothing. Add the scripts, or add the Nuxt ESLint module.

nix supplies pnpm, not corepack. Do not add a `packageManager` field to a
`package.json`. pnpm can self-install the version in that field, which defeats
the nix pin.

pnpm blocks the build script of a dependency until you list it. The `allowBuilds`
map in `pnpm-workspace.yaml` holds that list.

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

The flake imports `./nix`, `./apps` and `./libs`. Repo-wide tools go in `nix/`.
`nix/python.nix` holds `uv`, and `nix/node.nix` holds Node and pnpm. Those two
are repo-wide because `just new` must run a wizard before the unit exists.

A unit can still declare its own toolchain in `<unit>/nix/devshell.nix`. Every
`shellPackages` list in the repo concatenates into one dev shell.

Two rules an agent will otherwise get wrong:

- A new `.nix` file is invisible to `nix develop` until `git add`. Flakes ignore
  untracked files. With direnv the shell then reloads on its own, because
  `.envrc` watches `apps/`, `libs/` and every `nix/*.nix` file. Without direnv,
  re-enter `nix develop`.
- `import-tree` loads every `.nix` file under those trees as a flake-parts
  module. A `callPackage` expression must be named `_package.nix`, because
  import-tree skips any path containing `/_`.

## Known trap: proto shims

moon puts `~/.proto/shims` at the front of the PATH of every task. A global proto
install with a `pnpm` or `node` shim therefore wins over the nix version. If the
proto binary is absent, every frontend task fails with `proto-shim: Failed to
execute proto`. To repair it, install proto or delete the stale shims.

## Conventions an agent can't derive from the code

Add anything here that isn't obvious from reading the repo: naming conventions,
ownership boundaries, things that look like dead code but aren't, etc.
