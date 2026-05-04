# Gap table — /healthz endpoint

| # | Phase | Surface | Current (IS) | Target (WANT) | Gap | Blocks-on | Slice |
|---|-------|---------|--------------|---------------|-----|-----------|-------|
| [x] 1 | 0 | `src/lib/build-info.ts` | does not exist | exports `{ version, commitSha }` reading from `package.json` and `BUILD_SHA` env (with `dev` fallback) | new file, ~12 lines | — | direct |
| [x] 2 | 0 | `src/routes/health/handler.ts` | does not exist | exports default handler returning `{ status: "ok", version, uptime_seconds, commit_sha }` | new file using helper from #1 + `process.uptime()` | #1 | direct |
| [x] 3 | 0 | `src/routes/index.ts:L20-L80` | no `/healthz` registered | `router.get("/healthz", healthzHandler)` registered at root | one line + import | #2 | direct |

## Phase gates
- Phase 0 gate (only phase): `curl https://<prod>.example.com/healthz` returns 200 with all four fields populated AND load-balancer health check transitions from TCP to HTTP probe successfully.

## Status
- Total rows: 3
- Not started `[ ]`: 0
- In flight `[~]`: 0
- Staged `[s]`: 0
- Shipped to prod `[x]`: 3
- Retired `[r]`: 0
