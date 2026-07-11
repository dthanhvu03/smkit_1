<#
.SYNOPSIS
    Validate Task_Log_ERPSIXMEN.csv before paste to Sheet.
.EXAMPLE
    .\.cursor\bootstrap\validate-task-log.ps1
#>
param(
    [string]$CsvPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path "docs\erp\sheets\data\Task_Log_ERPSIXMEN.csv")
)

$ErrorActionPreference = "Stop"
$failures = @()
$warnings = @()

$projectCode = "PRJ-202606-ERPSIXMEN"
$taskIdPattern = '^TASK-ERPSIXMEN-\d{3}$'
$asciiHeader = @(
    'Task_ID', 'Project', 'Milestone', 'Priority', 'Title', 'Description',
    'Dept', 'Status', 'Owner', 'Start', 'Deadline', 'End', 'ExpectedResult',
    'Evidence', 'Col15', 'Col16', 'Col17', 'Approver', 'ApproveStatus',
    'ApproveLink', 'NextDeadline', 'Round', 'Col23', 'Col24'
) -join ','

if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV not found: $CsvPath"
}

$lines = Get-Content -Path $CsvPath -Encoding UTF8
if ($lines.Count -lt 2) {
    Write-Error "CSV must have header + at least one data row"
}

$dataBlock = $asciiHeader + "`n" + (($lines | Select-Object -Skip 1) -join "`n")
$rows = $dataBlock | ConvertFrom-Csv
$seenTaskIds = @{}
$rowNum = 1

foreach ($row in $rows) {
    $rowNum++
    $tid = $row.Task_ID.Trim()
    $line = "Task_ID=$tid (row $rowNum)"

    if ([string]::IsNullOrWhiteSpace($tid)) { continue }

    if ($seenTaskIds.ContainsKey($tid)) {
        $failures += "$line - duplicate Task_ID (first at row $($seenTaskIds[$tid]))"
    } else {
        $seenTaskIds[$tid] = $rowNum
    }

    if ($tid -notmatch $taskIdPattern) {
        $failures += "$line - Task_ID must match TASK-ERPSIXMEN-NNN"
    }

    if ($row.Project.Trim() -ne $projectCode) {
        $failures += "$line - project code must be $projectCode"
    }

    if ($row.Milestone.Trim() -notmatch '^M-ERP-') {
        $failures += "$line - milestone must start with M-ERP-"
    }

    $desc = $row.Description
    if ($desc -match 'Hiện trạng|Ảnh hưởng|Cần làm') {
        $warnings += "$line - Description uses template labels"
    }

    foreach ($term in @('deploy', 'CRUD', '403', 'POC', 'UC-00', 'seed', 'nạp')) {
        if ($desc -match $term) {
            $warnings += "$line - Description contains discouraged term: $term"
        }
    }

    if ($row.ExpectedResult -notmatch '\(1\)') {
        $warnings += "$line - ExpectedResult should use 5-step checklist with (1)"
    }
}

Write-Host "=== Task_Log Validation ===" -ForegroundColor Cyan
Write-Host "File: $CsvPath"
Write-Host "Rows: $($rows.Count)"
Write-Host ""

if ($warnings.Count -gt 0) {
    Write-Host "Warnings ($($warnings.Count)):" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
}

if ($failures.Count -gt 0) {
    Write-Host "FAIL ($($failures.Count)):" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "  - $_" }
    exit 1
}

Write-Host "PASS - Task_Log structure OK" -ForegroundColor Green
if ($warnings.Count -gt 0) { exit 2 }
exit 0
