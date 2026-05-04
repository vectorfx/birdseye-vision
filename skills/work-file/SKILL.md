---
name: work-file
description: Convert an implementation intent into a templated, shippable folder of artifacts (VISION → REALITY → GAP-TABLE → PROCESS → AGENTS → DONE). Branches from birdseye-vision when the picked path is real cross-file shipping. Scans actual code reality, builds want-vs-is gap table, dispatches parallel agents per slice, crosses off as shipped, moves to completed/ when done. Anti-graveyard: one-and-done artifacts, never lingering chat plans. Works for every project.
type: process
---

# work-file

> **Plans rot. Shipping artifacts compound.**
>
> **Reference example:** if a worked instance exists in `<root>/completed/`, read one before scaffolding a new work-file. Pattern-matching from a real shipped artifact beats reading rules. A bundled reference example ships at `examples/healthz-endpoint/` in the birdseye-vision repo.

A **work-file** is a templated folder that turns an intent ("I want X") into a real shipping artifact. It scans the actual codebase, tables want-vs-is, breaks into parallelizable slices, and *moves to `completed/` the moment it ships*. Plans that linger become noise. Work-files are one-and-done.

This skill is the **execution branch** of `birdseye-vision`. birdseye-vision picks the path; work-file builds the artifact and ships it.

---

## When to fire

You arrive here only when birdseye-vision branched to you. That means the picked path passed birdseye Step 1.5's hard-floor check:
- >4 files OR new files in >2 directories, OR
- Spans >1 session OR has a deploy-gate / observation window, OR
- Introduces a new convention, folder, template, hook, skill, or contract, OR
- Cross-package or cross-repo change, OR
- Strategic feature with parallel-able slices, OR
- An unresolved architecture/product decision must be preserved across sessions

If none of those fire — you're in the wrong skill, return to inline plan.

---

## Step 1 — Locate the work-file root

Resolve the active project's work-file root **dynamically** based on the current working directory:

1. If `<cwd>/.planning/` exists → root = `<cwd>/.planning/work-files/`
2. Else if `<cwd>/.git/` exists (or any git repo root above cwd) → root = `<repo-root>/.work-files/`
3. Else → root = `<cwd>/.work-files/`

Inside root, the layout is fixed:
```
<root>/
├── INDEX.md         # rolling ledger (see Step 1.1)
├── active/          # in-flight work-files
│   └── <slug>/      # one folder per work-file
└── completed/       # shipped + retired work-files
    └── <slug>/
```

`<slug>` = `YYYY-MM-DD-<kebab-case-title>`. Example: `2026-05-04-healthz-endpoint`.

Create `active/`, `completed/`, and `INDEX.md` if missing.

---

## Step 1.1 — Maintain root INDEX.md (compounding ledger)

`<root>/INDEX.md` is a single rolling ledger of every work-file. Not a planning surface — a *receipt log*. Future work-files grep it for similar gap patterns instead of reinventing.

Format:

```markdown
# Work-files index

| Status | Slug | Outcome | Started | Completed | Reusable pattern |
|--------|------|---------|---------|-----------|------------------|
| active | 2026-05-04-foo | <1 sentence> | 2026-05-04 | — | — |
| completed | 2026-05-03-bar | <1 sentence> | 2026-05-03 | 2026-05-04 | <optional reusable insight> |
| retired | 2026-05-02-baz | <why retired in 1 sentence> | 2026-05-02 | 2026-05-03 | — |
```

**Rules:**
- New work-file → add row, Status = `active`
- Shipped → update Status = `completed`, fill Completed date
- Retired → update Status = `retired` (see Retire Path), fill Completed date
- Outcome = ONE sentence (not a paragraph)
- Reusable pattern = optional, only when something is genuinely worth stealing
- **Before scaffolding a new work-file, scan INDEX.md for similar completed work** — copy proven patterns, don't reinvent

INDEX.md never gets a "current status" or "next action" column. Those live in each folder. INDEX is the ledger; folders are the work.

---

## Step 2 — Scaffold the folder

Inside `active/<slug>/` create exactly these files (use the templates below):

```
active/<slug>/
├── README.md         # one-screen overview + status header
├── VISION.md         # deeper goal, success signal, why now
├── REALITY.md        # codebase scan — what currently exists
├── GAP-TABLE.md      # want vs is, per row
├── PROCESS.md        # numbered steps + parallel-agent map
├── AGENTS.md         # subagent assignments per slice
└── DONE.md           # cross-off log + retro (filled as you ship)
```

No other files. No nesting unless a slice produces real artifacts (then `slices/<name>/`).

---

## Step 3 — Fill VISION.md first

This is the only file you must complete *before* writing code. It locks the brain.

Pull from the active birdseye-vision Stance if one exists. Otherwise extract from the user's message:
- **The deeper goal** (not a paraphrase of what they asked for)
- **Why now** (constraint, deadline, compounding)
- **Success signal** (concrete observable outcome — what makes this DONE)
- **Out of scope** (what this work-file explicitly will not do, to prevent creep)
- **Bloodline notes** (any feel/vibe/aesthetic constraints)

If VISION.md feels thin or paraphrased, make the best grounded assumption and state it inline. Ask one sharp question only if implementation correctness depends on the answer. Do not park the work just because the first draft of the vision is imperfect — vision sharpens through reality scan.

---

## Step 4 — Scan reality (REALITY.md)

**Read the actual code, do not guess.** Use Grep, Glob, Read. Use Explore agent for broad sweeps (>3 query searches).

Document for every system the work touches:
- File paths (absolute or repo-relative)
- Current behavior in 1–3 sentences per surface
- Conventions in use (naming, folder shape, type contracts)
- Gotchas, dead code, half-finished pieces, mocks
- Dependencies (downstream consumers, hooks, settings)

Style: terse, link-rich, no fluff. Quote line numbers for critical anchors.

If the reality scan reveals the goal is wrong or already partially built — STOP, surface to user, update VISION.md before continuing.

---

## Step 5 — Build the gap table (GAP-TABLE.md)

A markdown table with one row per concrete deliverable. Columns:

| # | Phase | Surface | Current (IS) | Target (WANT) | Gap | Blocks-on | Slice |
|---|-------|---------|--------------|---------------|-----|-----------|-------|

**Status vocabulary** — every row carries a state, prefix the `#` cell:

- `[ ]` not started
- `[~]` in flight
- `[s]` shipped to staging (commit landed, deploy-gate not yet fired)
- `[x]` shipped to prod (phase-gate confirmed in target environment)
- `[r]` retired (won't ship; reason in DONE.md)

**Rules:**
- **Phase** — phase number for staged work (1, 2, 3...). Use `0` if no phasing. Each phase has a phase-gate defined in PROCESS.md (e.g. "phase-2 gate = 7 days zero-old-token traffic in metrics").
- **Surface** — specific file, endpoint, component, skill, or convention. Not a vague area.
- **Current (IS)** — references real code (file:line)
- **Target (WANT)** — observable and testable
- **Gap** — names the *delta*, not the steps. Steps live in PROCESS.md.
- **Blocks-on** — row IDs this row depends on (e.g. `#3, #5`) OR a phase-gate (e.g. `phase-1-gate`). Empty if independent.
- **Slice** — slice name owning this row (set in Step 6).

**Critical:** a row only goes `[x]` when its phase-gate fires *in the target environment* — not when the commit lands. This kills the "shipped on paper, not in prod" failure mode.

The gap table IS the spec. If a row is fuzzy, fix it before any code is written.

---

## Step 6 — Slice for parallel agents (AGENTS.md + PROCESS.md)

**PROCESS.md** = ordered numbered steps for the *whole* work-file. Each step references gap-table row(s) it closes.

**AGENTS.md** = which subagent owns which slice. Use this when slices are independent (no shared state, no sequential dependency).

For each slice:
- **Name** (kebab-case)
- **Scope** (which gap-table rows)
- **Files in/out**
- **Deliverable** (what the agent returns)
- **Verification** (how you confirm it's real, not LARP)

**Subagent rule (not religion):** Use subagents only when slices are genuinely independent AND the coordination cost is lower than doing it directly yourself. Two parallel agents that need to cross-check each other's output cost more than one sequential pass. Default to direct execution; reach for subagents when the parallelism actually pays.

When 2+ slices truly are independent, dispatch them in a single message with multiple Agent tool calls in parallel.

If slices have dependencies, note the order in PROCESS.md and run sequentially.

---

## Step 7 — Ship (with slice receipts)

Execute slice by slice. After each slice:

1. **Verify** the deliverable against the gap-table WANT column. Actually run the verification — don't claim it works.
2. **Receipt** — every closed gap row gets either an atomic commit OR a structured receipt in DONE.md. Never both, never neither.

   **Use atomic commit** when slice is multi-file, risky, architecture-touching, or affects shared contracts:
   ```
   git commit -m "slice(<work-file-slug>): close #<gap-row> — <surface>"
   ```
   This makes git history mirror GAP-TABLE.md. `git blame` on a future bug lands on the exact gap row.

   **Use DONE.md receipt** when slice is small, contained, or commit boundary doesn't fit:
   ```
   - [x] #<row-id> <surface>
     - Files changed: <list>
     - Verification: <command run>
     - Result: <observable outcome>
     - Remaining risk: <or "none">
     - Timestamp: YYYY-MM-DD HH:MM
   ```

3. **Strike the row** in GAP-TABLE.md (`[x]` or `~~strikethrough~~`)
4. **New work that surfaced** → add new rows to GAP-TABLE.md (visible scope creep, never silent)

**Never mark a row done without a commit OR a receipt. "Should work" is not done.**

When ALL gap-table rows are crossed off:
1. Write a short retro at the bottom of DONE.md (what changed vs plan, what surprised you, what's reusable)
2. **Move the entire folder from `active/` to `completed/`**
3. Update INDEX.md row: Status = `completed`, fill Completed date, add Reusable pattern if any
4. Update birdseye-vision Stance memory: retire if success signal fired, update if partial
5. Surface to user: "Work-file `<slug>` shipped, moved to completed/. INDEX.md updated."

---

## Retire path (clean death for ideas that shouldn't ship)

Not every active work-file should ship. Some die because reality changed, the goal got invalidated, or the cost-benefit flipped. **Killing weak work cleanly is just as valuable as shipping good work.** A retired work-file did its job by *preventing bad work*.

When a work-file becomes obsolete, invalid, or not worth shipping:

1. Add a `## Retired` section to DONE.md
2. State the *real* reason in 1–3 sentences (don't dress it up — "scope was wrong", "blocked by external dep", "cheaper path found via X")
3. Mark unresolved gap rows as `~~retired~~` in GAP-TABLE.md (NOT done — be honest)
4. Update INDEX.md row: Status = `retired`, fill Completed date
5. Move folder from `active/` to `completed/` (retired work-files live alongside shipped ones — both are "done as artifacts")
6. Update or retire birdseye-vision Stance memory accordingly
7. Surface to user: "Work-file `<slug>` retired (<reason>). Moved to completed/."

**Never leave dead work in `active/`.** It becomes guilt sludge and contaminates the active list with noise. Kill cleanly.

---

## Anti-graveyard rules

These are the rules that make work-files different from chat plans:

1. **One-and-done.** Never edit a work-file after it's in `completed/`. New work = new work-file.
2. **No lingering active.** If a work-file in `active/` hasn't moved in 2+ weeks, surface it next session: ship, retire, or delete.
3. **No phantom rows.** Every gap-table row gets crossed off OR explicitly deleted with a note. No row left ambiguous.
4. **No silent scope creep.** New work surfaces as new rows in GAP-TABLE.md, visible to the user.
5. **No fake done.** A row is crossed off only when verification ran. "Should work" is not done.
6. **No mock fallbacks in VISION.** If the reality scan exposes a mock or stub, that goes in REALITY.md and gets a gap row, not glossed over.
7. **Real reality.** REALITY.md must reference actual file paths and lines. If you wrote it without reading code, redo it.

---

## Templates

### README.md
```markdown
# <Title>

**Status:** active | shipped | retired
**Started:** YYYY-MM-DD
**Slug:** <slug>
**Stance:** <one-line — pulled from birdseye-vision memory>

## Operator view

**What we are changing:** <one sentence>
**Why it matters:** <one sentence>
**Current blocker:** <one sentence or "none">
**Next action:** <one concrete action — file/command/decision>

## Files
- [VISION.md](VISION.md) — deeper goal + success signal
- [REALITY.md](REALITY.md) — codebase as-is
- [GAP-TABLE.md](GAP-TABLE.md) — want vs is
- [PROCESS.md](PROCESS.md) — ordered steps
- [AGENTS.md](AGENTS.md) — parallel slice assignments
- [DONE.md](DONE.md) — ship log + retro

## Quick status
<2-3 lines: what's shipped, what's next, blockers>
```

**Operator view rule:** This is the cockpit. Update it after every shipped slice (or when blocker changes). When birdseye does Step 0.6 active resume, it reads this section first. If Operator view is stale or empty, the work-file is failing its job.

### VISION.md
```markdown
# Vision — <Title>

## Deeper goal
<not a paraphrase — the real outcome>

## Why now
<constraint, deadline, compounding reason>

## Success signal
<concrete observable — what makes this DONE>

## Out of scope
- <thing this work-file will NOT do>
- <thing>

## Bloodline notes
<feel/vibe/aesthetic/decision-style constraints>
```

### REALITY.md
```markdown
# Reality scan — <Title>

> Last scanned: YYYY-MM-DD
> Method: Grep/Glob/Read on <which paths>

## Surface 1: <name>
- File: `path/to/file.ts:L120-L180`
- Behavior: <1-3 sentences>
- Convention: <naming, types, patterns>
- Gotchas: <mocks, dead code, half-finished>
- Consumers: <who depends on this>

## Surface 2: ...

## Cross-cutting findings
- <pattern observed across surfaces>
```

### GAP-TABLE.md
```markdown
# Gap table — <Title>

| # | Phase | Surface | Current (IS) | Target (WANT) | Gap | Blocks-on | Slice |
|---|-------|---------|--------------|---------------|-----|-----------|-------|
| [ ] 1 | 0 | `file.ts:42` <name> | <current behavior> | <target behavior> | <delta> | — | slice-a |
| [ ] 2 | 0 | ... | ... | ... | ... | #1 or — | slice-b |

## Phase gates
- Phase 0 gate: no staged rollout required; verification command passes
- Phase 1 gate: <condition that proves this phase is live-safe in target env>

## Status
- Total rows: N
- Not started `[ ]`: N
- In flight `[~]`: 0
- Staged `[s]`: 0
- Shipped to prod `[x]`: 0
- Retired `[r]`: 0
```

### PROCESS.md
```markdown
# Process — <Title>

Ordered steps. Each step closes one or more gap-table rows.

1. <step> — closes #1, #2
2. <step> — closes #3
3. <step> — closes #4–#7 (parallel via AGENTS.md)
...

## Dependencies
- Step 3 depends on step 1 finishing (shared file)
- Steps 4–7 are independent → parallel agents
```

### AGENTS.md
```markdown
# Agent slices — <Title>

## slice-a: <name>
- Scope: gap rows #1, #2
- Files in: `a.ts`, `b.ts`
- Files out: `a.ts` (modified)
- Deliverable: <what the agent returns>
- Verification: <run command / observable>
- Subagent: general-purpose | Explore | feature-dev | ...

## slice-b: ...
```

### DONE.md
```markdown
# Ship log — <Title>

## Crossed off
- [x] #1 `file.ts:42` — shipped <sha> @ YYYY-MM-DD HH:MM
- [x] #2 ...

## Retro (filled when all rows shipped)
**What changed vs plan:** <surprises>
**What's reusable:** <patterns, snippets, conventions>
**What I'd do differently:** <one line>
**Stance update:** retired | updated | unchanged
```

---

## Routing back

When the work-file ships:
- Tell user the slug + completed/ path
- If birdseye-vision has an active Stance for this goal → retire or update
- If retro surfaced a reusable convention → save as Bloodline memory
- If retro surfaced a non-obvious pick that worked → save as Process memory

Never re-open a completed work-file. New work, new file.
