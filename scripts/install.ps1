#Requires -Version 5.1
<#
.SYNOPSIS
  Install DotCore Agent Skills to Cursor, Claude Code, and Codex.

.EXAMPLE
  .\scripts\install.ps1
  .\scripts\install.ps1 -Skill generate-readme
  .\scripts\install.ps1 -Link
#>
param(
    [string]$Skill = "",
    [switch]$Link,
    [switch]$Cursor = $true,
    [switch]$Claude = $true,
    [switch]$Codex = $true
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path $PSScriptRoot -Parent

$SkillsSrc = Join-Path $RepoRoot "skills"
if (-not (Test-Path $SkillsSrc)) {
    Write-Error "skills/ not found at $SkillsSrc"
}

$Targets = @()
if ($Cursor) { $Targets += @{ Name = "Cursor"; Dir = Join-Path $env:USERPROFILE ".cursor\skills" } }
if ($Claude) { $Targets += @{ Name = "Claude Code"; Dir = Join-Path $env:USERPROFILE ".claude\skills" } }
if ($Codex) { $Targets += @{ Name = "Codex"; Dir = Join-Path $env:USERPROFILE ".codex\skills" } }

$SkillNames = if ($Skill) {
    @($Skill)
} else {
    Get-ChildItem $SkillsSrc -Directory |
        Where-Object { -not $_.Name.StartsWith('_') } |
        ForEach-Object { $_.Name }
}

function Install-OneSkill {
    param(
        [string]$SkillName,
        [string]$TargetDir,
        [string]$AgentName
    )
    $Src = Join-Path $SkillsSrc $SkillName
    $Dst = Join-Path $TargetDir $SkillName
    if (-not (Test-Path $Src)) {
        Write-Warning "Skip $SkillName - source not found"
        return
    }
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    if (Test-Path $Dst) { Remove-Item -Recurse -Force $Dst }
    if ($Link) {
        New-Item -ItemType Junction -Path $Dst -Target $Src | Out-Null
        Write-Host "  [$AgentName] junction -> $Dst"
    } else {
        Copy-Item -Recurse -Force $Src $Dst
        Write-Host "  [$AgentName] copy -> $Dst"
    }
}

Write-Host "dotcore-skills install"
Write-Host "Source: $SkillsSrc"
Write-Host "Skills: $($SkillNames -join ', ')"
Write-Host ""

foreach ($t in $Targets) {
    Write-Host "$($t.Name):"
    foreach ($name in $SkillNames) {
        Install-OneSkill -SkillName $name -TargetDir $t.Dir -AgentName $t.Name
    }
    Write-Host ""
}

# Codex slash prompts
if ($Codex) {
    $PromptsDir = Join-Path $env:USERPROFILE ".codex\prompts"
    New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null
    foreach ($name in $SkillNames) {
        $PromptSrc = Join-Path (Join-Path $SkillsSrc $name) "codex-prompt.md"
        if (Test-Path $PromptSrc) {
            Copy-Item -Force $PromptSrc (Join-Path $PromptsDir "$name.md")
            Write-Host "  [Codex prompt] $name.md -> $PromptsDir"
        }
    }
}

Write-Host "Done."
