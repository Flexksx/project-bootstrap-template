# AGENTS.md

This file is the template stub for agent instructions. Replace it per-project.

## Project map

Describe here, once real units exist:

- What each `apps/*` unit is and what it does.
- What each `libs/*` lib is for and which apps consume it.
- Any `infra/*` project boundaries an agent should know about.

## Entry points

All developer actions go through `just`. List the recipes an agent should use, e.g.:

- `just build <unit>` — build a specific unit.
- `just format all` / `just lint all` — repo-wide formatting and linting.
- `just test <unit>` — run a unit's test suite.

Run `just --list --list-submodules` to see everything currently wired up.

## Dev environment

`direnv allow` (or `nix develop`) loads the pinned toolchain from `flake.nix` + `nix/`.
Add a `nix/<lang>.nix` file (see `nix/examples/`) the first time a unit needs that language.

## Conventions an agent can't derive from the code

Add anything here that isn't obvious from reading the repo: naming conventions,
ownership boundaries, things that look like dead code but aren't, etc.
