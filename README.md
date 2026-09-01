# project-bootstrap-template

Template for new projects. Companion to the `project-bootstrap` Claude Code skill.

## Tools

- **nix** — dev shell and toolchain pinning
- **direnv** — auto-loads the nix shell on `cd`
- **moon** — owns the per-unit tasks and the dependency graph
- **uv** — Python runtime, dependencies, and the Python tools
- **just** — high-level entry point; wraps `moon` and the repo-wide chores
- **lefthook** — pre-commit hooks
- **alejandra** — Nix formatter
- **rumdl** — Markdown linter/formatter

## Directories

- [`apps/`](apps/) — deployable units
- [`libs/`](libs/) — shared libs
- [`.moon/`](.moon/) — workspace config, inherited tasks, and `moon generate` templates
- [`.just/`](.just/) — one module per action
- [`tests/`](tests/) — cross-unit e2e tests
- [`openapi/`](openapi/) — API specs
- [`infra/`](infra/) — infrastructure as code
- [`nix/`](nix/) — repo-wide dev-shell modules

## Scaffolding a new unit

```bash
moon generate python -- --name billing --kind lib
moon generate python -- --name checkout --kind app
git add libs/billing apps/checkout
```

Both units render the same `.moon/templates/python` template. `kind` picks the
destination (`libs/` or `apps/`), the `layer`, the `start` task, and whether
`__main__.py` is written.

`git add` is not optional. Nix flakes ignore untracked files, so a new unit and
its `nix/devshell.nix` stay invisible to the dev shell until they are tracked.

## Tasks

`just` is the entry point. It delegates per-unit work to `moon`.

```bash
just format             # fix + format, whole repo
just lint               # lint + type-check, whole repo
just test all
just test unit billing
just build all
```

`format` and `lint` are repo-wide only. moon reads the input hashes and runs
them on the units that changed, so there is no per-unit recipe to pick. Add `-f`
to bypass the cache and run every unit: `just format -f`.

Every recipe body lives under `.just/<verb>/`. `format` and `lint` come in with
`import` instead of `mod`, because a `mod` default recipe cannot take arguments.

For `test` and `build`, any flag after the recipe goes straight to `moon`.

Every task is a moon task, including the repo-wide ones. The root `moon.yml`
owns `alejandra` and `rumdl` as the `repo` project, so `just` never special-cases
them and a unit-free repo still has tasks to run.

A new unit needs no change here. A new *language* needs one file:
`.moon/tasks/<language>.yml`.

`lefthook.yml` runs `just format` and `just lint` on every commit, with no globs
and no per-language hooks. Whole-repo runs stay cheap because moon caches on
input hashes: `alejandra` takes 12ms, `rumdl` 45ms, and a fully cached
`moon run :format` 230ms.

Task bodies live in `.moon/tasks/python.yml` and apply to every project tagged
`python`. Give each one an `inheritedBy.tags` condition.

Python tasks run through `uv run`. Nix supplies `uv`; `uv` supplies Python 3.14,
`ruff`, `ty` and `pytest`, pinned per unit in `uv.lock`. Each unit carries its own
`ruff.toml`, `ty.toml` and `.python-version`.

## Dev environment

`direnv allow` (or `nix develop`) loads the shell.

`.envrc` watches `apps/`, `libs/` and every `nix/*.nix` file, so the shell
reloads when a unit lands or changes its toolchain. Editing source in a unit does
not reload it. Without direnv, run `nix develop` again after `git add`.

The flake imports nix modules from three trees: `./nix`, `./apps` and `./libs`.
A unit declares its own toolchain in `<unit>/nix/devshell.nix`:

```nix
{
  perSystem = {pkgs, ...}: {
    shellPackages = [pkgs.uv];
  };
}
```

Every `shellPackages` list in the repo concatenates into one dev shell.
`lib.unique` drops exact duplicates, so two units can both ask for `python313`.
It does not resolve conflicts: if one unit asks for `python312` and another for
`python313`, both land on `PATH` and the first one wins, silently.

`import-tree` skips any path containing `/_`. Name a `callPackage` expression
`_package.nix` so it is not loaded as a flake-parts module.

`nix/examples/` holds per-stack stubs for languages that have no template yet.
Drop the `.example` suffix and move the file to `nix/` to activate it.

Two pins those stubs leave implicit:

- Java: name the exact JDK (`jdk21`), never the floating `jdk`.
- TypeScript: `nodejs_22` pins the Node major. pnpm's own version belongs in
  `package.json` under `packageManager`, fetched through corepack.

Every pre-commit hook in `lefthook.yml` calls a `just` recipe, never a tool
directly, so the recipe stays the single definition. The Python hooks run
`moon run` across all units rather than a staged-file list, because each unit's
tools live in its own venv. moon caches on input hashes, so untouched units cost
nothing.
