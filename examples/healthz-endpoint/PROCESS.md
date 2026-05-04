# Process — /healthz endpoint

Sequential, no parallel slices needed (single small feature, three dependent rows in three files).

1. Add `src/lib/build-info.ts` — closes #1
2. Add `src/routes/health/handler.ts` using the helper — closes #2
3. Register `/healthz` in `src/routes/index.ts` — closes #3
4. Verify locally: `curl http://localhost:3000/healthz` returns the four fields
5. Deploy to staging, verify
6. Deploy to prod, verify, repoint load balancer from `/status` to `/healthz` — phase-0 gate fires

## Dependencies
- Step 2 depends on Step 1 (handler imports the helper)
- Step 3 depends on Step 2 (route registration imports the handler)
- Steps 1–3 commit boundary: one atomic commit per slice, format `slice(2026-05-04-healthz-endpoint): close #N — <surface>`

## Phase-gate (Phase 0)
Endpoint live in production AND load balancer transitioned. Until BOTH fire, rows stay `[s]` (staged). When both fire, rows go `[x]`.
