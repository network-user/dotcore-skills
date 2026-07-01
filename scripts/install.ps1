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

if ($Skill -and $Skill -notmatch '^[A-Za-z0-9._-]+$') {
    Write-Error "Invalid skill name '$Skill'. Allowed: letters, digits, '.', '_', '-'."
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

# Reject a target dir that escapes the user's home boundary (path traversal).
function Test-WithinBoundary {
    param([string]$Path, [string]$Boundary)
    try {
        $full = [IO.Path]::GetFullPath($Path)
        $base = [IO.Path]::GetFullPath($Boundary)
    } catch {
        return $false
    }
    $sep = [IO.Path]::DirectorySeparatorChar
    if (-not $base.EndsWith($sep)) { $base += $sep }
    return $full.StartsWith($base, [StringComparison]::OrdinalIgnoreCase)
}

# Reject dir values that are absolute, drive-qualified, or contain traversal.
function Test-SafeRelativeDir {
    param([string]$Dir)
    if ([string]::IsNullOrWhiteSpace($Dir)) { return $false }
    if ($Dir -match '(^|[\\/])\.\.([\\/]|$)') { return $false }
    if ($Dir -match '^[\\/]') { return $false }
    if ($Dir -match ':') { return $false }
    if ([IO.Path]::IsPathRooted($Dir)) { return $false }
    return $true
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
    if (-not (Test-WithinBoundary $Dst $TargetDir)) {
        Write-Warning "Skip $SkillName - resolved path escapes target dir"
        return
    }
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

$HomeBoundary = $env:USERPROFILE

foreach ($target in $selectedTargets) {
    if (-not (Test-SafeRelativeDir $target.dir)) {
        Write-Warning "Skip $($target.id) - unsafe dir '$($target.dir)'"
        continue
    }
    $dir = Get-UserPath $target.dir
    if (-not (Test-WithinBoundary $dir $HomeBoundary)) {
        Write-Warning "Skip $($target.id) - dir '$($target.dir)' escapes home boundary"
        continue
    }
    Write-Host "$($target.name) ($($target.id)):"
    foreach ($name in $SkillNames) {
        Install-OneSkill -SkillName $name -TargetDir $dir -AgentName $target.name
    }

    if ($target.promptsDir -and $target.promptSource) {
        if (-not (Test-SafeRelativeDir $target.promptsDir)) {
            Write-Warning "Skip prompts for $($target.id) - unsafe promptsDir '$($target.promptsDir)'"
            Write-Host ""
            continue
        }
        $PromptsDir = Get-UserPath $target.promptsDir
        if (-not (Test-WithinBoundary $PromptsDir $HomeBoundary)) {
            Write-Warning "Skip prompts for $($target.id) - promptsDir '$($target.promptsDir)' escapes home boundary"
            Write-Host ""
            continue
        }
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
