<#
.SYNOPSIS
    Validate SIXMEN task artifacts before declaring task complete.
.DESCRIPTION
    Checks artifacts/{Task-ID}/ for required files and qa_gate status.
    Exit 0 = PASS or review-ready; Exit 1 = FAIL (blocker).
.EXAMPLE
    .\.cursor\bootstrap\validate-artifacts.ps1 -TaskId PILOT-GD0-B1
    .\.cursor\bootstrap\validate-artifacts.ps1 -TaskId TASK-20260616-ui-gd0-walkthrough -Strict
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskId,

    [switch]$Strict,

    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
$taskDir = Join-Path $RepoRoot "artifacts\$TaskId"
if (-not (Test-Path $taskDir)) {
    $taskDir = Join-Path $RepoRoot "artifacts\archive\GD0\$TaskId"
}

if (-not (Test-Path $taskDir)) {
    Write-Error "Artifact folder not found: artifacts\$TaskId (also checked artifacts\archive\GD0\)"
}

$failures = @()
$warnings = @()

function Test-ArtifactFile {
    param([string]$RelativePath, [string]$Label)
    $path = Join-Path $taskDir $RelativePath
    if (-not (Test-Path $path)) {
        $script:failures += "Missing: $Label ($RelativePath)"
        return $false
    }
    return $true
}

# Always required
Test-ArtifactFile "00-gate-status.md" "Gate status" | Out-Null
Test-ArtifactFile "01-task-brief.md" "Task brief" | Out-Null

$gatePath = Join-Path $taskDir "00-gate-status.md"
$gateContent = if (Test-Path $gatePath) { Get-Content $gatePath -Raw } else { "" }

# Detect task type from gate-status
$isCodeTask = $gateContent -match 'task type.*`code`' -or
              $gateContent -match 'Task type.*code' -or
              (Test-Path (Join-Path $taskDir "06-test-plan.md")) -or
              (Test-Path (Join-Path $taskDir "07-architecture-compliance-checklist.md"))

$isDocsOnly = $gateContent -match 'docs-only' -and -not $isCodeTask

if (-not $isDocsOnly -and -not $isCodeTask) {
    # Infer: if 06 or 07 exists → code task
    if ((Test-Path (Join-Path $taskDir "06-test-plan.md")) -or
        (Test-Path (Join-Path $taskDir "07-architecture-compliance-checklist.md"))) {
        $isCodeTask = $true
    } else {
        $isDocsOnly = $true
    }
}

if ($isCodeTask) {
    Test-ArtifactFile "06-test-plan.md" "Test plan (code task)" | Out-Null
    Test-ArtifactFile "07-architecture-compliance-checklist.md" "Architecture compliance (code task)" | Out-Null

    if ($gateContent -notmatch 'qa_gate.*PASS' -and $gateContent -notmatch 'qa_gate tổng.*PASS') {
        if ($Strict) {
            $failures += "qa_gate not PASS in 00-gate-status.md (code task)"
        } else {
            $warnings += "qa_gate not PASS - review may be blocked"
        }
    }
} else {
    if ($gateContent -notmatch 'qa_gate.*N/A' -and $gateContent -notmatch 'qa_gate tổng.*N/A') {
        $warnings += "docs-only task: consider setting qa_gate: N/A in gate-status"
    }
}

# Human Owner pending gates (Strict only)
if ($Strict -and $gateContent -match 'PENDING') {
    if ($gateContent -match '\|\s*[^|]+\|\s*[^|]+\|\s*`PENDING`') {
        $warnings += "Human Owner gate still PENDING - confirm intentional stop"
    }
}

# Review readiness checkbox
if ($Strict -and $gateContent -notmatch 'Sẵn sàng xin review') {
    $warnings += "Review readiness section may be incomplete"
}

Write-Host "=== SIXMEN Artifact Validation ===" -ForegroundColor Cyan
Write-Host "Task ID:  $TaskId"
Write-Host "Folder:   $taskDir"
Write-Host "Type:     $(if ($isCodeTask) { 'code' } else { 'docs-only' })"
Write-Host ""

if ($warnings.Count -gt 0) {
    Write-Host "Warnings:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
}

if ($failures.Count -gt 0) {
    Write-Host "FAIL ($($failures.Count) blocker(s)):" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  - $_" }
    exit 1
}

Write-Host "PASS - artifact structure OK" -ForegroundColor Green
exit 0
