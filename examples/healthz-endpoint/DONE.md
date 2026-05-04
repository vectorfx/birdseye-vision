# Ship log — /healthz endpoint

## Crossed off
- [x] #1 `src/lib/build-info.ts` — shipped (atomic commit)
  - Files changed: `src/lib/build-info.ts` (new, 14 lines)
  - Verification: type-check passed, helper imported from handler in step 2
  - Result: returns `{ version: "1.4.2", commitSha: "abc123" }` in dev with fallback
  - Remaining risk: none
  - Timestamp: 2026-05-04 14:12

- [x] #2 `src/routes/health/handler.ts` — shipped (atomic commit)
  - Files changed: `src/routes/health/handler.ts` (new, 11 lines)
  - Verification: unit test calling handler with mock req/res returns expected shape
  - Result: handler returns the four fields, never throws
  - Remaining risk: none for v1 (read-only)
  - Timestamp: 2026-05-04 14:18

- [x] #3 `src/routes/index.ts` — shipped (atomic commit)
  - Files changed: `src/routes/index.ts` (1-line addition + import)
  - Verification: `curl http://localhost:3000/healthz` → 200 with correct shape; deployed to staging, then prod
  - Result: phase-0 gate fired — load balancer repointed from `/status` to `/healthz`, all instances marked healthy
  - Remaining risk: none. Old `/status` endpoint is now dead code; cleanup tracked in a separate work-file.
  - Timestamp: 2026-05-04 14:35

## Retro
**What changed vs plan:** Nothing — plan held, three rows shipped sequentially in the predicted order. Atomic commits made `git log --oneline` mirror the gap table precisely.

**What's reusable:** The `src/lib/<resource>-info.ts` pattern (tiny helper module that wraps env-var reads with sensible dev fallbacks) is reusable for any future read-only endpoint that needs build/runtime metadata. Captured in INDEX.md "Reusable pattern" column.

**What I'd do differently:** The dead `/status` endpoint should have been a fourth gap row with status `[r]` (retired) so it didn't slip into a separate work-file. Lesson: when reality scan exposes obsolete code that's *adjacent* to the new work, retire it in the same work-file unless cost is real.

**Stance update:** retired (deploy verification self-attestation goal reached).
