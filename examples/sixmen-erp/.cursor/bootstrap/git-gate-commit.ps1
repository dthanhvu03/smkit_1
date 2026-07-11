<#
.SYNOPSIS
    Git-gate commit — SIXMEN AI OS v2, Item 3
    Creates an immutable git checkpoint after each Human Owner gate approval.
    Git's hash chain = tamper-proof audit trail at zero infra cost.

.USAGE
    # After Human Owner approves a gate:
    .\git-gate-commit.ps1 -TaskId TASK-GD0-011 -GateName "schema_gate" -ApprovedBy "Vu"

    # After QA gate passes:
    .\git-gate-commit.ps1 -TaskId TASK-GD0-010 -GateName "qa_gate" -ApprovedBy "QA-auto"
#>
param(
    [Parameter(Mandatory)][string]$TaskId,
    [Parameter(Mandatory)][string]$GateName,
    [Parameter(Mandatory)][string]$ApprovedBy,
    [string]$Note = ""
)

$TaskDir = "artifacts/$TaskId"
if (-not (Test-Path $TaskDir)) {
    $TaskDir = "artifacts/archive/GD0/$TaskId"
}

if (-not (Test-Path $TaskDir)) {
    Write-Error "GIT-GATE: Task directory not found: artifacts/$TaskId"
    exit 1
}

# Stage task artifacts (gate-status + task-state if exists)
$filesToStage = @(
    "$TaskDir/00-gate-status.md",
    "$TaskDir/01-task-brief.md"
)

$optionalFiles = @(
    "$TaskDir/task-state.json",
    "$TaskDir/task-state.sig",
    "$TaskDir/06-test-plan.md",
    "$TaskDir/07-architecture-compliance-checklist.md"
)

foreach ($f in $optionalFiles) {
    if (Test-Path $f) { $filesToStage += $f }
}

# Stage files
foreach ($f in $filesToStage) {
    if (Test-Path $f) {
        git add $f 2>$null
    }
}

# Also stage PROGRESS.md if it changed
if (Test-Path "artifacts/PROGRESS.md") {
    git add "artifacts/PROGRESS.md" 2>$null
}

# Build commit message
$date = (Get-Date -Format "yyyy-MM-dd HH:mm")
$noteStr = if ($Note) { " — $Note" } else { "" }
$commitMsg = "gate: $TaskId/$GateName approved by $ApprovedBy [$date]$noteStr"

# Re-sign task-state.json BEFORE committing (so sig is consistent)
$verifyScript = ".cursor/bootstrap/verify-task-state.ps1"
if (Test-Path $verifyScript) {
    & powershell -File $verifyScript -TaskId $TaskId -Sign 2>$null
    if (Test-Path "$TaskDir/task-state.sig") {
        git add "$TaskDir/task-state.sig" 2>$null
    }
}

# Commit
git commit -m $commitMsg

if ($LASTEXITCODE -eq 0) {
    Write-Host "GIT-GATE: Committed checkpoint for $TaskId/$GateName"
    Write-Host "  Approved by: $ApprovedBy"
    Write-Host "  Message: $commitMsg"
} else {
    Write-Warning "GIT-GATE: Nothing staged for $TaskId/$GateName (no changes detected)"
}
