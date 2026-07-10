# project-bootstrap-template

Template repository for bootstrapping new projects. Companion to the
`project-bootstrap` Claude Code skill — this repo is that skill's conventions
made into a copyable starting point.

Use it as a GitHub template ("Use this template" / `gh repo create --template`)
or copy the tree manually into a fresh repo.

## What's already wired up

- **Nix dev shell** — `flake.nix` + `nix/` (dendritic pattern: one file per domain,
  auto-imported via `import-tree`). `nix/devtools.nix` pins the repo-wide tools
  (`just`, `alejandra`, `lefthook`, `rumdl`). Run `direnv allow` or `nix develop`
  to enter the shell.
- **Task running** — root `Justfile` only delegates into `.just/{build,format,lint,test}/`
  submodules. Run `just --list --list-submodules` to see everything available.
  Invoke as `just <verb> <unit>`, e.g. `just format all`.
- **Pre-commit hooks** — `lefthook.yml` runs `alejandra` on staged `.nix` files and
  `rumdl` on staged `.md` files. Run `lefthook install` once after cloning.
- **Agent instructions** — `AGENTS.md` (with `CLAUDE.md` symlinked to it) is the
  single source of instructions every AI coding agent reads.

## What's a placeholder

`apps/`, `libs/`, `tests/`, `openapi/`, and `infra/` each contain only a `README.md`
stub explaining their purpose. Per the bootstrap skill's own rule: **don't pre-create
structure without a real occupant.** Delete a stub README the moment you add real
content to that directory; delete the whole directory if a project never needs it
(e.g. a single-binary CLI has no `libs/`, `openapi/`, or `infra/`).

| Directory | Put here |
|---|---|
| `apps/` | Deployable units — services, SPAs, mobile apps, CLIs. One dir per unit. |
| `libs/` | Code shared by 2+ apps. Contract-library pattern for service clients (`*-client`, `*-client-starter`, `*-client-ts`). |
| `tests/` | Blackbox/e2e tests spanning multiple units. Single-unit tests live inside that unit. |
| `openapi/` | API specs — source of truth for generated `-client-*` libs. |
| `infra/projects/` | Infra for a group of deployables that ship together. |
| `infra/shared/` | Infra shared across projects (networking, IAM, shared buckets). |
| `nix/examples/` | Copy-and-rename (`*.nix.example` → `*.nix`) per-stack dev-shell modules for Go, Java/Kotlin, Python, TypeScript. |

## Bootstrapping a new project from this template

1. Create the new repo from this template, or copy the tree in.
2. Update `flake.nix`'s `description` and the `nix/devtools.nix` devShell `name`.
3. For each language the project needs, copy the matching file from `nix/examples/`
   to `nix/<lang>.nix` (drop the `.example` suffix) and adjust the package list.
4. Add the first unit under `apps/` (or `libs/` if it's a pure library repo),
   delete that directory's stub `README.md`, and wire its build/format/lint/test
   commands into the `.just/*/Justfile` submodules.
5. Uncomment/add the matching hooks in `lefthook.yml`, then run `lefthook install`.
6. Fill in `AGENTS.md` with the real project map and entry points.
7. Only add `.moon/` once a second unit depends on the first — it's deliberately
   not pre-wired here.

## Deliberately omitted

- **`.moon/`** — dependency-graph tool for cross-unit builds. Add it the day a
  second unit actually depends on a first one; it's overhead before that.
- **`.prototools` / proto** — this template pins toolchain versions through Nix
  only (`nix/*.nix`). proto's main value in the bootstrap skill comes from
  `moon`'s `versionFromPrototools` wiring; without `moon`, running both Nix and
  proto pins the same versions twice with no mechanism keeping them in sync.
