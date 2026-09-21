#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs threat-modeling-skills SKILL.md folders into an agent skills directory.

.EXAMPLE
    ./scripts/install-skills.ps1
    Installs all seven skills into $HOME/.agents/skills

.EXAMPLE
    ./scripts/install-skills.ps1 -Dir C:\custom\path -Skills threat-model-stride,threat-model-linddun
    Installs only the named skills into a custom directory

.NOTES
    Requires Node.js (uses `npx degit`), which fetches each skill folder without
    cloning git history and without touching unrelated skills already present in
    the target directory.
#>
param(
    [string]$Dir = $(if ($env:AGENT_SKILLS_DIR) { $env:AGENT_SKILLS_DIR } else { Join-Path $HOME ".agents/skills" }),
    [string[]]$Skills
)

$ErrorActionPreference = "Stop"

$Repo = "JohnXu/threat-modeling-skills"
$Branch = "main"

$AllSkills = @(
    "threat-model-stride",
    "threat-model-linddun",
    "threat-model-pasta",
    "threat-model-attack-tree",
    "threat-model-dfd",
    "threat-model-trust-boundary",
    "threat-model-abuse-case"
)

if (-not $Skills -or $Skills.Count -eq 0) {
    $Skills = $AllSkills
}

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    Write-Error "npx (Node.js) is required to run this installer."
    exit 1
}

New-Item -ItemType Directory -Force -Path $Dir | Out-Null

foreach ($skill in $Skills) {
    $dest = Join-Path $Dir $skill
    Write-Host "Installing $skill -> $dest"
    npx --yes degit "$Repo/skills/$skill#$Branch" "$dest" --force
}

Write-Host ""
Write-Host "Installed $($Skills.Count) skill(s) into $Dir"
