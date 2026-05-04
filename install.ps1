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

Write-Host "  [OK] Skills + hook copied"

# Patch settings.json
if (-not (Test-Path $Settings)) {
    '{"hooks":{"SessionStart":[]}}' | Out-File -FilePath $Settings -Encoding utf8
}

$home_posix = ($env:USERPROFILE -replace '\\', '/')
$hookCmd = 'node "' + $home_posix + '/.claude/hooks/birdseye-vision-injector.js"'

$cfg = Get-Content $Settings -Raw | ConvertFrom-Json
if (-not $cfg.hooks)              { $cfg | Add-Member -NotePropertyName hooks -NotePropertyValue ([PSCustomObject]@{}) }
if (-not $cfg.hooks.SessionStart) { $cfg.hooks | Add-Member -NotePropertyName SessionStart -NotePropertyValue @() }

$already = $false
foreach ($group in $cfg.hooks.SessionStart) {
    if ($group.hooks) {
        foreach ($h in $group.hooks) {
            if ($h.command -and $h.command.Contains("birdseye-vision-injector")) { $already = $true }
        }
    }
}

if (-not $already) {
    $newGroup = [PSCustomObject]@{
        hooks = @([PSCustomObject]@{ type = "command"; command = $hookCmd })
    }
    $cfg.hooks.SessionStart = @($cfg.hooks.SessionStart) + $newGroup
    $cfg | ConvertTo-Json -Depth 20 | Out-File -FilePath $Settings -Encoding utf8
    Write-Host "  [OK] SessionStart hook registered in settings.json"
} else {
    Write-Host "  [OK] SessionStart hook already registered (skipped)"
}

Write-Host ""
Write-Host "[DONE] Restart Claude Code to activate."
Write-Host ""
Write-Host "Test it: open any project, say 'I want to add elite session-token auth across the API and 4 SDKs.'"
Write-Host "You should see a Type D pre-action block before any action is taken."
