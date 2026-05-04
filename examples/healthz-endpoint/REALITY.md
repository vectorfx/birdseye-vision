# Reality scan — /healthz endpoint

> Last scanned: 2026-05-04
> Method: Grep on `health`, Read on API route directory + middleware config

## Surface 1: API routing layer
- File: `src/routes/index.ts:L20-L80`
- Behavior: Express-style router registers all routes via `router.use(<prefix>, <handler>)`. Health endpoints conventionally live at the root (no prefix).
- Convention: route handlers live at `src/routes/<resource>/handler.ts`, exported as `default async (req, res) => {}`. Errors thrown — global error middleware catches.
- Gotchas: `src/routes/health/` directory does not exist. Closest sibling is `src/routes/status/` which currently returns a hardcoded `{ ok: true }` string — not what we want and not consumed by anything live.
- Consumers: load balancer config (file: `infra/lb.yaml`) currently points at `/status`; will need to repoint to `/healthz` after ship.

## Surface 2: Build metadata
- Source: `package.json` has `version`. Build pipeline writes `BUILD_SHA` env var at deploy time (file: `infra/deploy.sh:L42`).
- File: `src/lib/build-info.ts` — does not exist. Will be a tiny new module.
- Convention: env-var reads happen via `src/lib/env.ts` which throws if a required var is missing. Use it for `BUILD_SHA` (with a `dev` fallback when running locally).

## Surface 3: Process uptime
- Available via `process.uptime()` (Node built-in, returns seconds since process start).
- No existing helper. Trivial — inline.

## Cross-cutting findings
- The pre-existing `/status` endpoint is dead code. Consider retiring it in this work-file or leaving for a separate cleanup. **Decision:** leave for separate cleanup — out of scope for vision. Add a note in DONE.md retro.
- No phasing needed beyond "deploy and verify in prod." Endpoint is additive, no migration.
- Convention: handler returns plain object, framework JSON-serializes. Keep response shape flat.
