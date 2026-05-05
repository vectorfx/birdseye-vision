#!/usr/bin/env bash
# birdseye-vision installer — Linux / macOS
# Wires the auto-active skill into Claude Code by:
#  1. Copying skills to ~/.claude/skills/{birdseye-vision,work-file}/
#  2. Copying the SessionStart injector hook to ~/.claude/hooks/
#  3. Patching ~/.claude/settings.json to register the hook (idempotent)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/<your-user>/birdseye-vision/main/install.sh | bash
#   # or, from a local clone:
#   ./install.sh

set -euo pipefail

# Resolve script directory (works for curl-piped and local-clone invocations)
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Pipe install: clone to a temp dir
  SCRIPT_DIR="$(mktemp -d)"
  echo "→ Cloning repo to $SCRIPT_DIR..."
  git clone --depth 1 https://github.com/vectorfx/birdseye-vision.git "$SCRIPT_DIR/repo"
  SCRIPT_DIR="$SCRIPT_DIR/repo"
fi

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "→ Installing birdseye-vision into $CLAUDE_DIR"

mkdir -p "$SKILLS_DIR/birdseye-vision" "$SKILLS_DIR/work-file" "$HOOKS_DIR"

cp "$SCRIPT_DIR/skills/birdseye-vision/SKILL.md" "$SKILLS_DIR/birdseye-vision/SKILL.md"
cp "$SCRIPT_DIR/skills/work-file/SKILL.md"        "$SKILLS_DIR/work-file/SKILL.md"
cp "$SCRIPT_DIR/hooks/birdseye-vision-injector.js" "$HOOKS_DIR/birdseye-vision-injector.js"
cp "$SCRIPT_DIR/hooks/birdseye-prompt-guard.js"    "$HOOKS_DIR/birdseye-prompt-guard.js"

echo "  ✓ Skills + hooks copied"

# Patch settings.json with SessionStart + UserPromptSubmit hooks
if [ ! -f "$SETTINGS" ]; then
  echo '{"hooks":{"SessionStart":[],"UserPromptSubmit":[]}}' > "$SETTINGS"
fi

# Use node for safe JSON manipulation (already a Claude Code dep)
node - "$SETTINGS" <<'NODE'
const fs = require("fs");
const path = process.argv[2];
const home = require("os").homedir();
const injectorCmd = `node "${home}/.claude/hooks/birdseye-vision-injector.js"`;
const guardCmd    = `node "${home}/.claude/hooks/birdseye-prompt-guard.js"`;

const cfg = JSON.parse(fs.readFileSync(path, "utf8"));
cfg.hooks = cfg.hooks || {};
cfg.hooks.SessionStart     = cfg.hooks.SessionStart     || [];
cfg.hooks.UserPromptSubmit = cfg.hooks.UserPromptSubmit || [];

const alreadySession = cfg.hooks.SessionStart.some(group =>
  (group.hooks || []).some(h => (h.command || "").includes("birdseye-vision-injector"))
);
if (!alreadySession) {
  cfg.hooks.SessionStart.push({ hooks: [{ type: "command", command: injectorCmd }] });
  console.log("  ✓ SessionStart hook registered in settings.json");
} else {
  console.log("  ✓ SessionStart hook already registered (skipped)");
}

const alreadyGuard = cfg.hooks.UserPromptSubmit.some(group =>
  (group.hooks || []).some(h => (h.command || "").includes("birdseye-prompt-guard"))
);
if (!alreadyGuard) {
  cfg.hooks.UserPromptSubmit.push({ hooks: [{ type: "command", command: guardCmd }] });
  console.log("  ✓ UserPromptSubmit guard registered in settings.json");
} else {
  console.log("  ✓ UserPromptSubmit guard already registered (skipped)");
}

fs.writeFileSync(path, JSON.stringify(cfg, null, 2));
NODE

echo ""
echo "✅ Done. Restart Claude Code to activate."
echo ""
echo "Test it: open any project, say 'I want to add elite session-token auth across the API and 4 SDKs.'"
echo "You should see a Type D pre-action block before any action is taken."
