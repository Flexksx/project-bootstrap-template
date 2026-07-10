# openapi/

API specs — the source of truth for any generated client library in `libs/`.

One spec per service, e.g. `openapi/backend-service.yaml`.

Never hand-edit a generated `-client-*` lib; regenerate it from the spec instead.

Delete this file once the first spec lands.
