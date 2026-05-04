# Vision — /healthz endpoint

## Deeper goal
Make API liveness *self-attesting*. Today, "is the API up?" requires SSH-ing to a box and tailing logs. We need a single read-only endpoint that returns `{ status: "ok", version, uptime, commit_sha }` so a load balancer, ops dashboard, or curl one-liner answers the question definitively.

## Why now
Two consumers landing this week need it:
- New load-balancer health check (currently uses TCP-only — no app-level signal)
- Deploy script needs `commit_sha` round-trip to confirm the right artifact is running

## Success signal
`curl https://<env>.example.com/healthz` returns 200 with the four fields populated, and the load balancer marks the instance healthy. Phase-0 gate fires when the endpoint is verified live in **production** (not just staging).

## Out of scope
- Dependency checks (DB / cache / downstream services) — that's `/readyz`, separate work-file
- Auth — `/healthz` is intentionally public
- Detailed metrics — endpoint stays small; metrics live in the metrics surface
- Retry / circuit-breaker logic — pure read of in-process state

## Bloodline notes
Endpoint should be boring. No clever response shapes, no nested objects, no version-history. Health checks live in the load-balancer's hot loop — every byte and millisecond counts. Match the shape of `/healthz` endpoints that have been battle-tested in similar APIs (Stripe, Vercel, Heroku) — flat JSON, one millisecond response, never throws.
