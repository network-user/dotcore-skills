#Requires -Version 5.1
<#
.SYNOPSIS
  Copy DotCore skills from monorepo into a target project's .cursor/skills/

.EXAMPLE
  .\scripts\sync-to-project.ps1 -Target C:\path\to\DotCoreBot
  .\scripts\sync-to-project.ps1 -Target . -Skill generate-readme
  .\scripts\sync-to-project.ps1 -Target . -Link
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$Skill = "",
    [switch]$Link,
    [switch]$ClaudeMirror
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path $PSScriptRoot -Parent
$SkillsSrc = Join-Path $RepoRoot "skills"
$TargetRoot = Resolve-Path $Target
$CursorDst = Join-Path $TargetRoot ".cursor\skills"

$SkillNames = if ($Skill) {
    @($Skill)
} else {
    Get-ChildItem $SkillsSrc -Directory |
        Where-Object { $_.Name -notlike "_*" } |
        ForEach-Object { $_.Name }
}

Write-Host "sync-to-project"
Write-Host "  from: $SkillsSrc"
Write-Host "  to:   $CursorDst"
Write-Host "  skills: $($SkillNames -join ', ')"
Write-Host ""

New-Item -ItemType Directory -Force -Path $CursorDst | Out-Null

foreach ($name in $SkillNames) {
    $src = Join-Path $SkillsSrc $name
    $dst = Join-Path $CursorDst $name
    if (-not (Test-Path $src)) {
        Write-Warning "Skip $name - not found"
        continue
    }
    if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
    if ($Link) {
        New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
        Write-Host "  junction $name"
    } else {
        Copy-Item -Recurse -Force $src $dst
        Write-Host "  copy $name"
    }
    if ($ClaudeMirror) {
        $claudeDst = Join-Path $TargetRoot ".claude\skills\$name"
        New-Item -ItemType Directory -Force -Path (Split-Path $claudeDst) | Out-Null
        if (Test-Path $claudeDst) { Remove-Item -Recurse -Force $claudeDst }
        if ($Link) {
            New-Item -ItemType Junction -Path $claudeDst -Target $src | Out-Null
        } else {
            Copy-Item -Recurse -Force $src $claudeDst
        }
        Write-Host "  mirror -> .claude/skills/$name"
    }
}

Write-Host "Done."
