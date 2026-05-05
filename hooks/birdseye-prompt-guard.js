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
  "[birdseye-vision] Pre-flight check: classify this request (Step 0) BEFORE invoking any Skill tool. " +
  "If Type C or D → run the pre-action block first. " +
  "Birdseye is a process pre-flight, not an option — it runs before office-leader, work-file, or any other skill.\n"
);
