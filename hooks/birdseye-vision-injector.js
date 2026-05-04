// SessionStart hook: injects birdseye-vision skill into every Claude Code session.
// Output goes into context as additional system reminder, forcing the skill
// to be active across all projects globally.
//
// Skill source of truth: ~/.claude/skills/birdseye-vision/SKILL.md
// Edit the SKILL.md to change behavior — this script just dumps it.

const fs = require("fs");
const path = require("path");
const os = require("os");

try {
  const skillPath = path.join(
    os.homedir(),
    ".claude",
    "skills",
    "birdseye-vision",
    "SKILL.md"
  );
  const content = fs.readFileSync(skillPath, "utf8");

  process.stdout.write(
    `<EXTREMELY-IMPORTANT>\n` +
    `birdseye-vision skill is AUTO-ACTIVE this session — applies in every project, every turn.\n` +
    `\n` +
    `Operating principle: VISION → PROCESS → ACTION (never action-first on strategic tasks).\n` +
    `Hybrid trigger: fire on goal/multi-path/architectural/vision-language; skip on trivial execution.\n` +
    `Sensitivity: re-scan every 5 turns on sustained threads, on new nouns, on implementation verbs, on stacked-AND, on mood shift to vision-language. Inheritance resets every 3 continuation turns.\n` +
    `Branch to work-file skill when picked path is real cross-file shipping (>4 files, >1 session, "let's build/ship/implement", new convention/folder/template/hook/skill, cross-package, unresolved architecture decision).\n` +
    `Soft-surface: show pre-action block, proceed unless irreversible.\n` +
    `Auto-save: bloodline themes + surprising process insights + Stances to memory.\n` +
    `\n` +
    `Full skill below. Apply it whenever the trigger check fires this turn.\n` +
    `\n---\n\n` +
    content +
    `\n</EXTREMELY-IMPORTANT>\n`
  );
} catch (err) {
  // Fail silent — don't break sessions if the skill file is missing.
  process.stderr.write(`birdseye-vision injector skipped: ${err.message}\n`);
}
