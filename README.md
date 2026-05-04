# birdseye-vision

> **Mastering the process masters the outcome.**

A two-skill stack for [Claude Code](https://claude.com/claude-code) that stops action-first drift and kills plan-rot. Every project. Every session. Every turn.

---

## What it does

**The problem:** Claude is fast — but action-first. It jumps to implementation before understanding the deeper goal. In long threads it drifts away from "bird's-eye thinking" into "head-down typing." Plans you make in chat *rot* because they live in scrollback and disappear after compaction.

**The fix — two skills, one stack:**

- **`birdseye-vision`** — auto-active strategic-scan brain. Classifies every turn (A/B/C/D), surfaces a structured pre-action block before non-trivial work, persists *Stances* to memory so they survive compaction, and re-scans on drift triggers.
- **`work-file`** — on-demand branch skill. When the picked path is real cross-file shipping, scaffolds a templated folder of artifacts (VISION → REALITY → GAP-TABLE → PROCESS → AGENTS → DONE), tracks status with phase-aware row states (`[ ]/[~]/[s]/[x]/[r]`), dispatches parallel agents per slice, and *moves to `completed/` the moment it ships*. Anti-graveyard rules built in.

```
Session starts
   ↓
SessionStart hook injects birdseye-vision into context
   ↓
User asks something
   ↓
birdseye classifies (A/B/C/D) + drift check
   ↓
   ├─ A/B → act
   └─ C/D → surface pre-action block (Vision, Blast Radius, Devil's Advocate, Stance, Reversibility…)
            ↓
            Hard-floor check on Step 1.5
            ↓
            ├─ Stay inline (≤4 files, same-day, no new convention)
            └─ Branch to work-file
                  ↓
                  Scaffold folder → scan reality → gap table → ship slice-by-slice → move to completed/
                  ↓
                  Update INDEX.md ledger; retire/update Stance
```

---

## Why it works

| Symptom | What this stack does |
|---|---|
| Claude jumps to code before understanding the goal | Pre-action block forces vision + devil's advocate before action |
| Strategic decisions get lost in long threads | `Stance:` memory survives compaction; re-scans every 5 turns catch drift |
| Multi-file plans rot in chat scrollback | Real shipping artifacts on disk: VISION/REALITY/GAP-TABLE folder per work-file |
| "Should work" claims that aren't actually shipped | Status vocab `[s]` (staging) vs `[x]` (prod with phase-gate fired in target env) |
| Half-done work clogs `active/` forever | Explicit retire path; clean death is honest |
| Process tax on small features | Quantified hard-floor: ≤4 files + same-day + no new convention → stay inline |

The classifier (A/B/C/D) is the brain. The hard-floor is the brake. The work-file is the ledger.

---

## Install

### macOS / Linux
```bash
git clone https://github.com/vectorfx/birdseye-vision.git
cd birdseye-vision
./install.sh
```

### Windows (PowerShell)
```powershell
git clone https://github.com/vectorfx/birdseye-vision.git
cd birdseye-vision
.\install.ps1
```

The installer:
1. Copies skills to `~/.claude/skills/birdseye-vision/` and `~/.claude/skills/work-file/`
2. Copies the SessionStart injector to `~/.claude/hooks/birdseye-vision-injector.js`
3. Patches `~/.claude/settings.json` to register the hook (idempotent — safe to re-run)

Restart Claude Code. The skill is now active in every project.

### Uninstall
Delete the three files the installer placed, plus the SessionStart hook entry in `~/.claude/settings.json`. No state to clean up.

---

## How it works under the hood

### birdseye-vision is preloaded every session
A `SessionStart` hook in `~/.claude/settings.json` runs `birdseye-vision-injector.js`. The injector reads `~/.claude/skills/birdseye-vision/SKILL.md` and writes its content to stdout wrapped in `<EXTREMELY-IMPORTANT>` tags. Claude Code treats stdout from SessionStart hooks as additional system context. Result: birdseye is non-skippable, every project, every session, every turn.

The hook re-fires on `clear` and `compact` events, so the skill survives context compaction.

### work-file is lazy-loaded
work-file is a normal Claude Code skill — discovered via the standard skill registry. birdseye's Step 1.5 invokes it via the `Skill` tool only when the hard-floor branch criteria fire. Not preloaded → no token tax when you don't need it.

### The Pre-Action Block
For Type C (strategic) and Type D (architectural / vision) requests, birdseye outputs a structured block before any tool call:

**Type C (compact):**
```
Vision: <deeper goal>
Chosen Path: <path> — <why>
Devil's Advocate: <strongest case against>

Process:
1. ...
2. ...

→ Starting step 1
```

**Type D (full):** adds *Active Stance, Blast Radius, Paths Considered, Stance, Reversibility*. Stance saves to memory; survives compaction; retires when goal ships.

### Drift sensors
Re-scan triggers on a sustained thread:
- Every 5 turns (silently — only surface if classification changed)
- New noun introduced
- Implementation verbs ("let's build / ship / wire")
- Stacked-AND ("and on top of that…")
- Mood shift to vision-language ("make it elite")

Inheritance from continuation turns ("keep going") resets every 3 turns. No infinite compounding.

### Work-file folder layout
```
.planning/work-files/                        (or .work-files/ if no .planning/)
├── INDEX.md                                 # rolling ledger of all work-files
├── active/
│   └── 2026-05-04-feature-slug/
│       ├── README.md                        # operator view + status
│       ├── VISION.md                        # deeper goal, success signal, why now
│       ├── REALITY.md                       # codebase scan with file:line refs
│       ├── GAP-TABLE.md                     # phase-aware want-vs-is, status vocab
│       ├── PROCESS.md                       # ordered steps + phase-gates
│       ├── AGENTS.md                        # subagent slice assignments
│       └── DONE.md                          # ship log + retro
└── completed/                               # shipped + retired (never edited)
```

A reference example ships at [`examples/healthz-endpoint/`](examples/healthz-endpoint/) — read it before scaffolding your first one. Pattern-matching from a real artifact beats reading rules.

---

## Comparison to alternatives

| Dimension | birdseye-vision + work-file | Plain Claude Code | Plan-in-chat |
|---|---|---|---|
| Strategic scan before action | ✓ A/B/C/D classifier, every turn | ✗ acts immediately | partial — depends on prompt |
| Drift resistance in long threads | ✓ re-scan triggers + retroactive surface | ✗ | ✗ |
| Multi-file plan persistence | ✓ on-disk work-file folders | ✗ | ✗ rots in scrollback |
| Phase-aware "shipped" tracking | ✓ `[ ]/[~]/[s]/[x]/[r]` | ✗ | ✗ |
| Cross-session resume | ✓ Step 0.6 active resume + INDEX.md | ✗ | ✗ |
| Anti-bloat brake | ✓ quantified hard-floor | ✗ | ✗ |
| Compounding learning | ✓ INDEX.md ledger of all completed | ✗ | ✗ |

---

## When NOT to use it

- **You ship single-file changes 90% of the time.** birdseye still helps (Type A goes fast), but work-file rarely fires. Maybe overkill.
- **You hate process frameworks.** This *is* a process framework, even though it's lean. If "discipline" feels like ceremony to you, you'll fight the rules.
- **You don't use Claude Code.** This is Claude Code-specific. The skills and the SessionStart hook mechanism are CC primitives.

---

## Reference example

[`examples/healthz-endpoint/`](examples/healthz-endpoint/) — a complete worked instance: shipping a `/healthz` endpoint that returns build version + uptime across an API + middleware. Three gap rows, all `[x]`. Phase 0 (no staged rollout). Read this before scaffolding your first work-file.

---

## Tested with
- Claude Code (CLI)
- Claude 4.x family (Opus / Sonnet / Haiku)

Skills are markdown — they work with any Claude model. The SessionStart hook mechanism is Claude Code-specific.

---

## License

MIT — see [LICENSE](LICENSE).

---

## Credits

Built and battle-tested in real projects. Distilled from many cycles of:
1. Claude jumps to code → vision lost
2. Add a process → process bloats
3. Cut process → drift returns
4. Quantify the brake → finally lean enough to ship

The stack is *finalized* — no more tuning. The proof is in real use, not more audits. If you find a real failure mode, open an issue with the prompt that broke it.
