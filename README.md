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
- [`tests/`](tests/) — cross-unit e2e tests
- [`openapi/`](openapi/) — API specs
- [`infra/`](infra/) — infrastructure as code
- [`nix/`](nix/) — repo-wide dev-shell modules
- [`.just/`](.just/) — top-level command groups

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
just test all          # moon run :test
just test unit billing # moon run billing:test
just lint all          # markdown + moon run :lint + moon run :typecheck
just format all        # nix + markdown + moon run :format
```

Task bodies live in `.moon/tasks/python.yml` and apply to every project tagged
`python`. Add one file per language, and give it an `inheritedBy.tags` condition.

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
