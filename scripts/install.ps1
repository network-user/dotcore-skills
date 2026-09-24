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

# Resolve the deepest existing path component so junctions/reparse points cannot
# make a lexical in-bound path write outside the intended boundary.
function Get-ResolvedExistingPath {
    param([string]$Path)
    try {
        $candidate = [IO.Path]::GetFullPath($Path)
        while (-not (Test-Path -LiteralPath $candidate)) {
            $parent = Split-Path -LiteralPath $candidate -Parent
            if ([string]::IsNullOrEmpty($parent) -or $parent -eq $candidate) { return $null }
            $candidate = $parent
        }
        return (Resolve-Path -LiteralPath $candidate -ErrorAction Stop).Path
    } catch {
        return $null
    }
}

# Reject a target dir that escapes the user's home boundary (path traversal).
function Test-WithinBoundary {
    param([string]$Path, [string]$Boundary)
    try {
        $full = [IO.Path]::GetFullPath($Path)
        $base = Get-ResolvedExistingPath $Boundary
        $existing = Get-ResolvedExistingPath $Path
        if (-not $base -or -not $existing) { return $false }
        $base = [IO.Path]::GetFullPath($base)
        $existing = [IO.Path]::GetFullPath($existing)
    } catch {
        return $false
    }
    $sep = [IO.Path]::DirectorySeparatorChar
    if ($existing -ne $base -and -not $existing.StartsWith($base.TrimEnd($sep) + $sep, [StringComparison]::OrdinalIgnoreCase)) { return $false }
    if ($full -eq $base) { return $true }
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

function Test-NoReparsePoints {
    param([string]$Path)
    try {
        $reparse = [IO.FileAttributes]::ReparsePoint
        $root = Get-Item -LiteralPath $Path -Force
        if (($root.Attributes -band $reparse) -ne 0) { return $false }
        foreach ($item in @(Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorAction Stop)) {
            if (($item.Attributes -band $reparse) -ne 0) { return $false }
        }
        return $true
    } catch {
        return $false
    }
}

function Install-OneSkill {
    param(
        [string]$SkillName,
        [string]$TargetDir,
        [string]$AgentName
    )
    $Src = Join-Path $SkillsSrc $SkillName
    $Dst = Join-Path $TargetDir $SkillName
    if (-not (Test-Path -LiteralPath $Src)) {
        Write-Warning "Skip $SkillName - source not found"
        return
    }
    if (-not (Test-NoReparsePoints $Src)) {
        Write-Warning "Skip $SkillName - source contains a reparse point"
        return
    }
    if (-not (Test-WithinBoundary $TargetDir $HomeBoundary) -or
        -not (Test-WithinBoundary $Dst $HomeBoundary) -or
        -not (Test-WithinBoundary $Dst $TargetDir)) {
        Write-Warning "Skip $SkillName - resolved path escapes target dir"
        return
    }
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    if (Test-Path -LiteralPath $Dst) { Remove-Item -LiteralPath $Dst -Recurse -Force }
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
        if (-not (Test-SafeRelativeDir $target.promptsDir) -or
            -not (Test-SafeRelativeDir $target.promptSource)) {
            Write-Warning "Skip prompts for $($target.id) - unsafe prompt path"
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
            $SkillRoot = Join-Path $SkillsSrc $name
            $PromptSrc = Join-Path $SkillRoot $target.promptSource
            $PromptDst = Join-Path $PromptsDir "$name.md"
            if (-not (Test-Path -LiteralPath $PromptSrc) -or
                -not (Test-WithinBoundary $PromptSrc $SkillRoot) -or
                -not (Test-NoReparsePoints $PromptSrc) -or
                -not (Test-WithinBoundary $PromptDst $HomeBoundary)) {
                Write-Warning "Skip prompt for $name - source or destination is outside the safe boundary"
                continue
            }
            Copy-Item -LiteralPath $PromptSrc -Destination $PromptDst -Force
            Write-Host "  [$($target.name) prompt] $name.md -> $PromptsDir"
        }
    }
    Write-Host ""
}

Write-Host "Done."
