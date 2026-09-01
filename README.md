# project-bootstrap-template

A monorepo template that runs on nix, moon and `just`.
`AGENTS.md` holds the detail.

## Layout

- [`apps/`](apps/) deployable units
- [`libs/`](libs/) shared libs
- [`tests/`](tests/) cross-unit e2e tests
- [`openapi/`](openapi/) API specs
- [`infra/`](infra/) infrastructure as code
- [`nix/`](nix/) dev-shell modules
- [`.moon/`](.moon/) tasks and templates
- [`.just/`](.just/) one directory per verb

## Start a project

```bash
git clone git@github.com:Flexksx/project-bootstrap-template.git <name>
cd <name> && ./init && direnv allow
```

`./init` clears the template docs, resets git history, then deletes itself.

## Commands

```bash
just format        # repo-wide, fixes
just lint          # repo-wide, gates
just build all
just test billing  # one unit
just start shop
just sync          # rebuild the unit indexes
just --list --list-submodules
```

`just` is the golden path.
Route every development action through it.
Anything outside `just` must be strongly justifiable.
Low-level work can use its own commands, or you can automate it.

`format` and `lint` run on the changed units only.
To bypass the cache, add `-f`.

If a task fails with `proto-shim: Failed to execute proto`, delete
`~/.proto/shims`.

## Add a unit

```bash
just new python      # asks for the name, and for lib or app
just new sveltekit
just new nuxt
```

The recipe scaffolds the unit, stages it with `git add`, and rebuilds the indexes.
Reload the shell before you run a task on the new unit.

Do not name a unit `all`.
The name collides with the repo-wide recipe.

## Add a language

One file: `.moon/tasks/<language>.yml`.
It holds the commands and applies by tag.
A unit `moon.yml` declares metadata only.

`nix/examples/` holds stubs for a language with no `just new` recipe.

## Dev shell

A repo-wide tool goes in `nix/`.
A unit toolchain goes in `<unit>/nix/devshell.nix`:

```nix
{
  perSystem = {pkgs, ...}: {
    shellPackages = [pkgs.uv];
  };
}
```

Every `shellPackages` list concatenates into one shell.
nix drops exact duplicates, but it does not resolve a conflict.
If two units ask for a different Python, the first one wins with no message.
