# libs/

Code shared across two or more `apps/` units. Avoid micro-libraries —
a lib needs a real second consumer to earn its place here.

Follows the contract-library pattern for services another unit consumes:

- `<name>-client` — public DTOs, request/response types, HTTP-exchange interfaces. No business logic.
- `<name>-client-starter` — auto-config wiring for consumers (Java/Spring-style DI setups).
- `<name>-client-ts` — generated TS client; only `src/generated/` is generated, never hand-edited.

If an OpenAPI spec exists in `openapi/`, generate the `-client-*` libs from it — it's the source of truth.

Delete this file once the first lib lands.
