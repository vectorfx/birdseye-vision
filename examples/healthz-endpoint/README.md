# /healthz endpoint

**Status:** shipped
**Started:** 2026-05-04
**Completed:** 2026-05-04
**Slug:** 2026-05-04-healthz-endpoint
**Stance:** Ops needs a single read-only endpoint to confirm the API is alive and on the expected build, so deploy verification stops requiring log-diving.

## Operator view

**What we are changing:** Adding `GET /healthz` returning `{ status, version, uptime_seconds, commit_sha }`.
**Why it matters:** Deploy verification today means tailing logs; load balancer health checks need a stable target.
**Current blocker:** none — shipped.
**Next action:** none — shipped. Future work-file may add `/readyz` for dependency checks (out of scope here).

## Files
- [VISION.md](VISION.md) — deeper goal + success signal
- [REALITY.md](REALITY.md) — codebase as-is at start
- [GAP-TABLE.md](GAP-TABLE.md) — want vs is, with phase + status
- [PROCESS.md](PROCESS.md) — ordered steps + phase-gate
- [AGENTS.md](AGENTS.md) — slice assignments (none — direct execution)
- [DONE.md](DONE.md) — ship log + retro

## Quick status
3 gap rows, all `[x]`. Endpoint live in dev + staging + prod. INDEX.md updated. Stance retired.

> This is a **reference example** bundled with birdseye-vision. Read it before scaffolding your first work-file. Pattern-matching from a shipped artifact beats reading rules.
