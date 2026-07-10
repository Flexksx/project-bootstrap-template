# project-bootstrap-template

Template for new projects. Companion to the `project-bootstrap` Claude Code skill.

## Tools

- **nix** — dev shell and toolchain pinning
- **direnv** — auto-loads the nix shell on `cd`
- **just** — task runner; all build/format/lint/test actions go through it
- **lefthook** — pre-commit hooks
- **alejandra** — Nix formatter
- **rumdl** — Markdown linter/formatter

## Directories

- [`apps/`](apps/) — deployable units
- [`libs/`](libs/) — shared libs
- [`tests/`](tests/) — cross-unit e2e tests
- [`openapi/`](openapi/) — API specs
- [`infra/`](infra/) — infrastructure as code
- [`nix/`](nix/) — dev-shell modules (`nix/examples/` has per-stack stubs)
- [`.just/`](.just/) — build/format/lint/test recipes

Run `./init` after cloning to strip the template down to a blank project.
