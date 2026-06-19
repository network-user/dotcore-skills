#Requires -Version 5.1
<#
.SYNOPSIS
  Install DotCore Agent Skills to supported AI coding agents.

.EXAMPLE
  .\scripts\install.ps1
  .\scripts\install.ps1 -Skill generate-readme
  .\scripts\install.ps1 -Link
  .\scripts\install.ps1 -Agent cursor,claude,agents
  .\scripts\install.ps1 -ListAgents
#>
param(
    [string]$Skill = "",
    [switch]$Link,
    [string[]]$Agent = @(),
    [switch]$ListAgents
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path $PSScriptRoot -Parent
$SkillsSrc = Join-Path $RepoRoot "skills"
$ConfigPath = Join-Path $PSScriptRoot "agents.targets.json"

if (-not (Test-Path $SkillsSrc)) {
    Write-Error "skills/ not found at $SkillsSrc"
}
if (-not (Test-Path $ConfigPath)) {
    Write-Error "agents.targets.json not found at $ConfigPath"
}

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
$allTargets = @($config.userTargets)

if ($ListAgents) {
    Write-Host "Supported agent IDs (user-level):"
    foreach ($t in $allTargets) {
        $extra = if ($t.aliases) { " [" + ($t.aliases -join ", ") + "]" } else { "" }
        Write-Host ("  {0,-10} {1} -> ~/{2}{3}" -f $t.id, $t.name, $t.dir, $extra)
    }
    exit 0
}

$selectedTargets = if ($Agent.Count -gt 0) {
    $ids = $Agent | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ }
    $allTargets | Where-Object { $ids -contains $_.id }
} else {
    $allTargets
}

if ($selectedTargets.Count -eq 0) {
    Write-Error "No matching agents. Use -ListAgents for IDs."
}

$SkillNames = if ($Skill) {
    @($Skill)
} else {
    Get-ChildItem $SkillsSrc -Directory |
        Where-Object { -not $_.Name.StartsWith('_') } |
        ForEach-Object { $_.Name }
}

function Get-UserPath {
    param([string]$RelativeDir)
    $parts = $RelativeDir -split '/'
    $path = $env:USERPROFILE
    foreach ($part in $parts) {
        $path = Join-Path $path $part
    }
    return $path
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
Write-Host "Agents: $($selectedTargets.id -join ', ')"
Write-Host ""

foreach ($target in $selectedTargets) {
    $dir = Get-UserPath $target.dir
    Write-Host "$($target.name) ($($target.id)):"
    foreach ($name in $SkillNames) {
        Install-OneSkill -SkillName $name -TargetDir $dir -AgentName $target.name
    }

    if ($target.promptsDir -and $target.promptSource) {
        $PromptsDir = Get-UserPath $target.promptsDir
        New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null
        foreach ($name in $SkillNames) {
            $PromptSrc = Join-Path (Join-Path $SkillsSrc $name) $target.promptSource
            if (Test-Path $PromptSrc) {
                Copy-Item -Force $PromptSrc (Join-Path $PromptsDir "$name.md")
                Write-Host "  [$($target.name) prompt] $name.md -> $PromptsDir"
            }
        }
    }
    Write-Host ""
}

Write-Host "Done."
