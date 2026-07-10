# apps/

Deployable units: services, SPAs, mobile apps, CLIs — anything that ships on its own.

One directory per unit, e.g. `apps/backend-service/`, `apps/webapp-spa/`.

Each unit owns its own `.gitignore`, build config, and language tooling.
Wire its build/format/lint/test commands into the matching `.just/*/Justfile` submodule.

Delete this file once the first unit lands.
