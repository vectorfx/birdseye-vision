# birdseye-vision installer — Windows PowerShell
# Wires the auto-active skill into Claude Code.
#
# Usage:
#   irm https://raw.githubusercontent.com/<your-user>/birdseye-vision/main/install.ps1 | iex
#   # or, from a local clone:
#   .\install.ps1

$ErrorActionPreference = "Stop"

# Resolve script directory (or clone temp if piped)
if ($PSCommandPath) {
    $ScriptDir = Split-Path -Parent $PSCommandPath
} else {
    $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "birdseye-vision-install"
    if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force }
    Write-Host "-> Cloning repo to $TempDir..."
    git clone --depth 1 https://github.com/vectorfx/birdseye-vision.git $TempDir
    $ScriptDir = $TempDir
}

$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsDir = Join-Path $ClaudeDir "skills"
$HooksDir  = Join-Path $ClaudeDir "hooks"
$Settings  = Join-Path $ClaudeDir "settings.json"

Write-Host "-> Installing birdseye-vision into $ClaudeDir"

New-Item -ItemType Directory -Force -Path (Join-Path $SkillsDir "birdseye-vision") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $SkillsDir "work-file")        | Out-Null
New-Item -ItemType Directory -Force -Path $HooksDir                                  | Out-Null

Copy-Item -Force (Join-Path $ScriptDir "skills\birdseye-vision\SKILL.md") (Join-Path $SkillsDir "birdseye-vision\SKILL.md")
Copy-Item -Force (Join-Path $ScriptDir "skills\work-file\SKILL.md")        (Join-Path $SkillsDir "work-file\SKILL.md")
Copy-Item -Force (Join-Path $ScriptDir "hooks\birdseye-vision-injector.js") (Join-Path $HooksDir "birdseye-vision-injector.js")
Copy-Item -Force (Join-Path $ScriptDir "hooks\birdseye-prompt-guard.js")    (Join-Path $HooksDir "birdseye-prompt-guard.js")

Write-Host "  [OK] Skills + hooks copied"

# Patch settings.json
if (-not (Test-Path $Settings)) {
    '{"hooks":{"SessionStart":[],"UserPromptSubmit":[]}}' | Out-File -FilePath $Settings -Encoding utf8
}

$home_posix = ($env:USERPROFILE -replace '\\', '/')
$injectorCmd = 'node "' + $home_posix + '/.claude/hooks/birdseye-vision-injector.js"'
$guardCmd    = 'node "' + $home_posix + '/.claude/hooks/birdseye-prompt-guard.js"'

$cfg = Get-Content $Settings -Raw | ConvertFrom-Json
if (-not $cfg.hooks)                  { $cfg | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) }
if (-not $cfg.hooks.SessionStart)     { $cfg.hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue @() }
if (-not $cfg.hooks.UserPromptSubmit) { $cfg.hooks | Add-Member -NotePropertyName UserPromptSubmit -NotePropertyValue @() }

# Register SessionStart injector (idempotent)
$alreadySession = $false
foreach ($group in $cfg.hooks.SessionStart) {
    if ($group.hooks) {
        foreach ($h in $group.hooks) {
            if ($h.command -and $h.command.Contains("birdseye-vision-injector")) { $alreadySession = $true }
        }
    }
}
if (-not $alreadySession) {
    $newGroup = [PSCustomObject]@{
        hooks = @([PSCustomObject]@{ type = "command"; command = $injectorCmd })
    }
    $cfg.hooks.SessionStart = @($cfg.hooks.SessionStart) + $newGroup
    Write-Host "  [OK] SessionStart hook registered in settings.json"
} else {
    Write-Host "  [OK] SessionStart hook already registered (skipped)"
}

# Register UserPromptSubmit guard (idempotent)
$alreadyGuard = $false
foreach ($group in $cfg.hooks.UserPromptSubmit) {
    if ($group.hooks) {
        foreach ($h in $group.hooks) {
            if ($h.command -and $h.command.Contains("birdseye-prompt-guard")) { $alreadyGuard = $true }
        }
    }
}
if (-not $alreadyGuard) {
    $newGroup = [PSCustomObject]@{
        hooks = @([PSCustomObject]@{ type = "command"; command = $guardCmd })
    }
    $cfg.hooks.UserPromptSubmit = @($cfg.hooks.UserPromptSubmit) + $newGroup
    Write-Host "  [OK] UserPromptSubmit guard registered in settings.json"
} else {
    Write-Host "  [OK] UserPromptSubmit guard already registered (skipped)"
}

$cfg | ConvertTo-Json -Depth 20 | Out-File -FilePath $Settings -Encoding utf8

Write-Host ""
Write-Host "[DONE] Restart Claude Code to activate."
Write-Host ""
Write-Host "Test it: open any project, say 'I want to add elite session-token auth across the API and 4 SDKs.'"
Write-Host "You should see a Type D pre-action block before any action is taken."
