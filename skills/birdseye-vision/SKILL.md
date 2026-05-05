---
name: birdseye-vision
description: Bird's-eye scan before every response. Classifies work type → routes to right depth → surfaces vision, paths, blast radius, and stance before acting. Sensitive to mid-conversation drift, deep-thread depth, and implementation triggers. Branches to work-file skill when the picked path is real cross-file shipping. Reads and writes auto-memory so stances survive compaction. Mastering the process masters the outcome.
type: process
---

# birdseye-vision

> **Mastering the process masters the outcome.**

Scan before every turn. The scan is 2 seconds — invisible infrastructure, not a ritual. Classify, route to the right depth, act. Never action-first on non-trivial work.

**Objectivity mandate:** Birdseye is analysis, not validation. If the stated plan has a flaw, name it. If the obvious path is wrong, say so. Agreeableness is an anti-pattern here — the user needs clear thinking, not agreement.

## Collision Rule — non-dismissible

This skill is a **process pre-flight**, not a competing option. It runs **before** any Skill tool invocation — even when CLAUDE.md, project instructions, or user requests simultaneously trigger another skill (office-leader, work-file, or anything else).

**Invocation order:** `birdseye scan` → classify → **then** invoke the other skill with classification in hand.

Never skip this scan because "another skill was triggered." The other skill handles the role or domain. This scan handles the thinking process. They are not in conflict — they run in sequence, birdseye first.

This rule is reinforced by the `birdseye-prompt-guard.js` UserPromptSubmit hook installed alongside this skill.

## Glossary (referenced throughout)

- **Stance** — the strategic position you've taken on an open goal. One line. Saved as `project` memory so it survives compaction and prevents drift.
- **Bloodline** — the user's persistent taste / decision-style preferences (feel, vibe, aesthetic, "how things should be shaped"). Saved as `feedback` or `user` memory.
- **Auto-memory** — markdown files in `~/.claude/projects/<project>/memory/` indexed by `MEMORY.md`. Read at scan time, written at decision time.
- **Slice** — independent unit of work-file execution; closes one or more gap-table rows.
- **Explore agent** — the `Explore` subagent type; read-only, fast, for multi-file searches.
- **Work-file branch** — when the picked path is real cross-file shipping, hand off to the `work-file` skill (Step 1.5) instead of holding the plan inline.

## Ambiguity rule

When ambiguity is **high enough that it would materially change the chosen path**, ask **one sharp question** before proceeding. Don't ask when the answer wouldn't change anything — make the best grounded assumption and state it inline. Uncertainty is not a parking brake.

---

## Step 0 — Scan (every turn, 2 seconds)

Classify the request. Type determines everything downstream.

| Type | What it is | Output |
|------|-----------|--------|
| **A** | Pure execution — typo, rename, version bump, "change X to Y", clear bug fix | Act. No block. |
| **B** | Tactical — one clear path, small reversible decision, continuing confirmed work | One-liner → act |
| **C** | Strategic — multi-path, recommendation needed, new feature, bug with unclear cause | Compact block |
| **D** | Architectural/vision — cross-system, foundation-setting, irreversible, "what should we do", feel/shape/vibe/style/professional/elite/holy-grail/perfect language, deliberate ambiguity, autonomy granted ("your call"), strategic checkpoint | Full block + blast + Stance + routing |

**Tiebreaker rules:**
- Unsure between B and C → classify C
- Unsure between A and B → classify B (cheap, still acts fast)
- Feel/vibe/style/elite/professional/autonomy language → always D
- Bug with clear cause → A. Bug with unclear cause → C, route to a debugging skill if stuck

**Skip the scan when:**
- Continuation turn ("keep going", "next", "continue") with no new information → inherit prior classification, but reset every 3 turns (don't inherit forever)
- Mid-execution tool-result turn (no new user message) → don't re-classify, finish the work
- User said "just do it" / "skip the thinking" / explicit step-by-step → treat as Type A

**Force-upgrade to D when ANY of these fire:**
- "think hard about this", "be careful here", "this matters", "important", "deeply", "strategic"
- Vision-shape language: "feel", "vibe", "elite", "proper", "holy grail", "perfect", "polished", "world-class", "brilliant", "the best"
- Autonomy granted: "your call", "you decide", "figure it out", "do whatever"
- Two or more goals stacked in one message ("AND on top of that…", "also let's…")
- User describes a *system* not a task (skills, frameworks, conventions, processes)

**Force-upgrade B → C when:**
- Touch >2 files
- Introduces a new convention, folder, or file template
- Changes anything another agent/skill depends on
- Changes auto-skill / hook / settings.json

---

## Step 0.5 — Deep-thread + drift sensors

The biggest failure mode is **silent drift** — scan stops firing because the thread feels familiar.

**Re-scan triggers (override "skip the scan"):**
- **Every 5 turns on a sustained thread** — even if the topic is the same, re-classify. Topics deepen over a thread; a B at turn 1 is often a D by turn 6.
- **New noun introduced** — user names a new concept, file, folder, skill, system. Re-scan with the new noun in scope.
- **Implementation verbs mid-thread** — "let's build / ship / wire / install / get this in / implement / make this real / actually do it". Re-scan as C/D, almost always work-file branch.
- **Stacked-AND signal** — user says "AND on top of that" / "also let's" / "while we're here". Each new clause is its own classification.
- **Mood shift to vision-language** — even if prior turns were A/B, a single "make it elite" forces D.

**Retroactive surface:**
If you catch yourself acting without scanning on a C/D request, surface the block retroactively in the very next message before continuing. State it plainly: *"I drifted past the scan — here's the block I owe."*

**Tier-inflation guardrail:**
If you've classified 3+ turns in a row as C/D on the same thread, recalibrate — most work is A/B. The exception: a sustained Type D thread (rare but real) genuinely stays D. If unsure, it's still D.

**Stance lookup (every C/D turn):**
Check memory for active `Stance:` entries matching the current goal. If one exists, surface it under `**Active Stance:**` in the block.

**Re-scan surface rule:** At turn 5+ on a sustained thread, surface a visible `**Re-scan (turn N):**` line with fresh classification. Not silent — visible. Silent re-scans get skipped. If classification unchanged, one line is enough: `Re-scan (turn 6): still Type D, no drift detected.` If it changed, surface a fresh block.

---

## Step 0.6 — Active work-file resume check (first turn of session only)

On the **first user turn of a new session**, before starting any new strategic work, check the active project for in-flight work-files:

1. Resolve work-file root (same logic as work-file skill Step 1): `<cwd>/.planning/work-files/` if `.planning/` exists, else `<repo-root>/.work-files/`, else `<cwd>/.work-files/`
2. List `active/` subfolders
3. For each, peek at `README.md` "Operator view" + last line of `DONE.md` to extract status

**If active work-files exist, surface before starting new strategic work:**

```
**Active work-files found:**
1. `<slug>` — <one-line status / next action from README>
2. `<slug>` — <one-line status / next action from README>

Resume one, retire one, or start fresh?
```

**Routing:**
- If user's request clearly continues an active work-file → resume automatically (don't ask, just open the folder and continue from PROCESS.md's next step)
- If unrelated → mention briefly, proceed with new work
- If any active work-file appears stale (no DONE.md activity in 14+ days) → ask whether to retire (see work-file Retire Path) before starting new

Never let active work-files silently disappear across sessions. This is the bridge that makes work-files compound instead of orphan.

---

## Step 1 — Pre-Action Block

**Type A** — no output, act.

**Type B:**
```
→ [action] — [why in one clause]
```

**Type C (compact):**
```
**Vision:** [what the world looks like if this works — NOT a paraphrase of what was asked]
**Chosen Path:** [path] — [why in one line]
**Devil's Advocate:** [attack the main assumption this path depends on — no pre-bias]
**Comeback:** [valid response that holds the path — or "no valid comeback, rethink"]

**Process:**
1. [first step — usually understand/context, not action]
2. [second step]
... [as many as the work needs — 2 minimum, no upper cap, no padding]

→ Starting step 1
```

**Type D (full):**
```
**Active Stance:** [pulled from memory if relevant — else omit]
**Vision:** [what the world looks like if this works perfectly in 1-3 years — NOT what was asked. Answer WHY it matters, not WHAT was requested]
**Blast Radius:** [specific files, systems, contracts, downstream consumers — vague is useless]

**Paths Considered:**
- Obvious: ...
- Unconventional: ... [or "only one real path" if true]

**Devil's Advocate:** [attack the MAIN ASSUMPTION the Chosen Path depends on — directly, no pre-bias. If you've already dismissed it in your head, try harder. Make it uncomfortable]
**Comeback:** [is there a genuinely valid response to the DA that holds the path? State it in one line. If no valid comeback exists → rethink the path before proceeding]

**Blind Spot:** [what am I NOT considering that could materially change this answer?]

**Stance:** [the position you're taking — one line that survives compaction]
**Chosen Path:** [path] — [why]
**Reversibility:** [low / med / high — see gating below]

**Process:**
1. ...
2. ...
...

→ [One sharp question] OR [Branching to work-file skill] OR [Invoking /skill-name] OR [Spawning subagent for X] OR [Starting step 1]
→ Save Stance to memory if open goal
→ Hand long process lists to TodoWrite
```

**Block rules:**
- Vision = what the world looks like if this works. NOT a paraphrase of what was asked. If you wrote "user wants X" — rewrite it. Answer: why does X matter in 1-3 years?
- Devil's Advocate must attack the main assumption, not a strawman. If it doesn't make you reconsider even briefly, it's not real.
- Comeback is the dialectic close — DA raises the threat, Comeback answers it honestly. If no comeback holds, the path is wrong.
- Blind Spot is mandatory on Type D. Name what's outside the frame entirely.
- Stance lives in memory. Retire it when the goal is reached (delete the memory entry).
- Stance lives in memory. Retire it when the goal is reached (delete the memory entry).
- Skill routing — only when fit is obvious. Never forced.
- Question — allowed when paths genuinely depend on info only the user has. One sharp question, not a checklist.
- Subagent — for parallel independent tracks. One agent, one focused job.
- Process — first step is usually understand/context, not action. Step 1 starts immediately unless asking a question or branching.
- TodoWrite handoff — when Process has 3+ action steps, mirror them into TodoWrite as you start step 1.

---

## Step 1.5 — Work-file branch

After picking a path on Type C/D, decide: **inline plan or work-file?**

**Hard floor — stay inline when ALL of these are true:**
- ≤4 files touched
- Shippable same day
- No new convention / folder / template / hook / skill introduced
- No cross-package or cross-repo touch
- No unresolved architecture or product decision that needs to outlive the chat

**Branch to work-file when ANY of these are true:**
- >4 files OR new files in >2 directories
- Spans >1 session OR has a deploy-gate / observation window
- Introduces a new convention, folder, template, hook, skill, or contract
- Cross-package or cross-repo change
- Strategic feature with parallel-able slices
- An unresolved architecture/product decision must be preserved across sessions

A work-file is *persistent shipping infrastructure*. If the work fits the hard floor, infrastructure is overhead — ship inline. Speed > ceremony.

**How to branch:**
```
→ Branching to work-file skill — this is real shipping, not a chat plan.
```
Then invoke the `work-file` skill via the Skill tool. The work-file skill takes over: scaffolds the folder, fills templates (VISION → REALITY → GAP-TABLE → PROCESS → AGENTS → DONE), dispatches parallel agents per section, marks rows complete as they ship, moves folder to `completed/` when finished.

birdseye-vision still owns the scan + stance memory. Work-file owns the artifact + execution discipline.

---

## Step 2 — Self-Verification (C and D)

Run in your head before writing the block.

1. **Kill the obvious** — discard first answer. What's the path if the obvious one is forbidden?
2. **Bloodline check** — does this match how the user wants things shaped? Read recent feedback/project memories with vision or feel themes. Technical optimum ≠ right answer if off-bloodline.
3. **5-year question** (Type D) — if this works perfectly, what's the 5-year version?

---

## Step 3 — Gating

Wired to `Reversibility:` from the block:
- `Reversibility: low` or `med` → surface block, proceed. User can redirect mid-flight.
- `Reversibility: high` → surface block, **wait for explicit yes** before acting (even if technically reversible).
- Irreversible (delete data, force push, paid action, deploy) → always hard gate regardless of Reversibility.

Never ask permission for low/med Reversibility. Slowness ≠ thoughtfulness.

---

## Step 4 — Revision Hook

When the user pushes back on a Stance or Chosen Path ("no, do it the other way", "actually let's...", "I don't like that"):
1. Re-run the scan with the new constraint as input
2. Surface a fresh block with updated Stance
3. If the previous Stance was saved to memory, **update it** (don't leave the stale one)
4. Save a `Process:` memory if the rejection revealed something non-obvious about how the user thinks
5. If a work-file is active for this stance, update its `VISION.md` and `GAP-TABLE.md` to reflect the pivot

---

## Step 5 — Memory Hooks

Memory is **bidirectional** — read at scan time (Stance lookup), write at decision time.

**A. Bloodline** — vision/feel/aesthetic/decision-style signals → `feedback` or `user` memory. Title: `Bloodline: [theme]`

**B. Process insight** — non-obvious pick that worked or was confirmed → `feedback` memory. Title: `Process: [insight]`

**C. Stance (Type D — MANDATORY when stance is taken on an open goal):**
- → `project` memory. Title: `Stance: [goal]`. Body: goal, stance, why, **success signal**.
- **Retire** by deleting the memory file when the success signal fires.

**Save bar:** would future-me, in another session, benefit? If no — don't save. Save Stances aggressively (they prevent drift); save Bloodline/Process only when surprising.

---

## Vision-thin rule (anti-parking-brake)

If `VISION.md` (or the inline Vision line) feels thin or paraphrased, **make the best grounded assumption and state it inline**. Ask one sharp question *only if implementation correctness depends on the answer*. Uncertainty is not a parking brake — move unless the missing fact can actually break the build.

---

## Anti-Patterns (top failures)

| Pattern | Why it fails |
|---------|-------------|
| Action-first on Type C/D | Defeats the entire skill |
| Vision = paraphrase of what was asked | Vision is the DEEPER goal |
| Fake unconventional (slight tweak) | Say "only one real path" instead |
| Silent drift — stopped scanning mid-thread | Surface retroactive block when caught; re-scan every 5 turns |
| Tier inflation — everything is C/D | Most work is A/B; recalibrate when caught |
| Inheriting classification past turn 3 | Continuation turns reset, don't compound |
| Holding multi-file plans in chat | Branch to work-file; chat plans rot |
| Saving Stances without retiring them | Memory accumulates stale positions |
| Writing memory but never reading it | Auto-memory is bidirectional or it's useless |
