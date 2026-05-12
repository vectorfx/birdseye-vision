// UserPromptSubmit hook: birdseye-vision collision guard
//
// Fires on every user message before Claude generates a response.
// Injects a one-line reminder that birdseye scan is mandatory on C/D
// requests, even when another skill is simultaneously triggered.
//
// This prevents the "competing skill dismissal" failure mode where an
// explicit trigger (e.g. CLAUDE.md → office-leader) causes the model
// to skip the birdseye pre-action scan entirely.
//
// Installed by: install.sh / install.ps1 (UserPromptSubmit hook)

process.stdout.write(
  "[birdseye-vision] Pre-flight: classify Step 0 BEFORE any Skill tool. " +
  "Type A (pure execution / single obvious answer) → SKIP the block, just act. No compute waste. " +
  "Type B → one visible line. " +
  "Type C → full compact block (Vision + Chosen Path + Devil's Advocate + Comeback + Process) VISIBLE before first non-trivial tool call. " +
  "Type D → full block (Vision + Blast Radius + 2-4 named Paths + Devil's Advocate + Comeback + Blind Spot + Stance + Chosen Path + Reversibility + Process) VISIBLE before first non-trivial tool call. " +
  "HALF-ARSE FAILURE: 'Pre-flight' header followed by tool calls within 2 lines on a C/D turn = violation. Owe a retroactive block. " +
  "Birdseye runs BEFORE office-leader, work-file, or any other skill — not instead of, not skipped because another skill triggered.\n"
);
