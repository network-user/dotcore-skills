#Requires -Version 5.1
<#
.SYNOPSIS
  Copy DotCore skills from monorepo into a target project's agent skill directories.

.EXAMPLE
  .\scripts\sync-to-project.ps1 -Target C:\path\to\DotCoreBot
  .\scripts\sync-to-project.ps1 -Target . -Skill generate-readme -Link
  .\scripts\sync-to-project.ps1 -Target . -AllAgents -Link
  .\scripts\sync-to-project.ps1 -Target . -Agent cursor,claude,agents
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$Skill = "",
    [switch]$Link,
    [switch]$AllAgents,
    [string[]]$Agent = @("cursor"),
    [switch]$ListAgents
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path $PSScriptRoot -Parent
$SkillsSrc = Join-Path $RepoRoot "skills"
$ConfigPath = Join-Path $PSScriptRoot "agents.targets.json"
$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json

if ($ListAgents) {
    Write-Host "Supported project agent IDs:"
    foreach ($t in $config.projectTargets) {
        Write-Host ("  {0,-10} {1} -> ./{2}" -f $t.id, $t.name, $t.dir)
    }
    exit 0
}

if ($Skill -and $Skill -notmatch '^[A-Za-z0-9._-]+$') {
    Write-Error "Invalid skill name '$Skill'. Allowed: letters, digits, '.', '_', '-'."
}

$TargetRoot = (Resolve-Path $Target).Path

# Reject a target dir that escapes the target repo root (path traversal).
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

$selectedTargets = if ($AllAgents) {
    @($config.projectTargets)
} elseif ($Agent.Count -gt 0) {
    $ids = $Agent | ForEach-Object { $_.Trim().ToLower() }
    @($config.projectTargets | Where-Object { $ids -contains $_.id })
} else {
    @($config.projectTargets | Where-Object { $_.id -eq "cursor" })
}

if ($selectedTargets.Count -eq 0) {
    Write-Error "No matching agents. Use -ListAgents."
}

$SkillNames = if ($Skill) {
    @($Skill)
} else {
    Get-ChildItem $SkillsSrc -Directory |
        Where-Object { -not $_.Name.StartsWith('_') } |
        ForEach-Object { $_.Name }
}

Write-Host "sync-to-project"
Write-Host "  from:   $SkillsSrc"
Write-Host "  target: $TargetRoot"
Write-Host "  agents: $($selectedTargets.id -join ', ')"
Write-Host "  skills: $($SkillNames -join ', ')"
Write-Host ""

foreach ($target in $selectedTargets) {
    if (-not (Test-SafeRelativeDir $target.dir)) {
        Write-Error "Unsafe dir '$($target.dir)' for agent '$($target.id)' - aborting."
    }
    $destSkills = Join-Path $TargetRoot ($target.dir -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-WithinBoundary $destSkills $TargetRoot)) {
        Write-Error "dir '$($target.dir)' for agent '$($target.id)' escapes target root - aborting."
    }
    New-Item -ItemType Directory -Force -Path $destSkills | Out-Null
    Write-Host "$($target.name) -> $($target.dir)"

    foreach ($name in $SkillNames) {
        $src = Join-Path $SkillsSrc $name
        $dst = Join-Path $destSkills $name
        if (-not (Test-Path $src)) {
            Write-Warning "Skip $name - not found"
            continue
        }
        if (-not (Test-WithinBoundary $dst $destSkills)) {
            Write-Error "Skill '$name' resolves outside target dir - aborting."
        }
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        if ($Link) {
            New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
            Write-Host "  junction $name"
        } else {
            Copy-Item -Recurse -Force $src $dst
            Write-Host "  copy $name"
        }
    }
    Write-Host ""
}

Write-Host "Done."
