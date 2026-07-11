<#
.SYNOPSIS
    KNOWN-ISSUES.md format validator — SIXMEN GD0-010 P1-5
    Validates each registry row for correct column count, ID format, and allowed field values.

.USAGE
    Manual : .\.cursor\bootstrap\validate-known-issues.ps1
    CI     : powershell -NonInteractive -File .cursor/bootstrap/validate-known-issues.ps1
    Exit 0 = valid, Exit 1 = format errors found.
#>

$KnownIssuesPath = "artifacts/KNOWN-ISSUES.md"

$AllowedEnv      = @('dev-win', 'dev-linux', 'dev-docker', 'staging', 'prod')
$AllowedType     = @('ENV', 'CODE')
$AllowedSeverity = @('P0', 'P1', 'P2')
$AllowedStatus   = @('OPEN', 'RESOLVED', 'WONTFIX', 'DEFERRED')

$EXPECTED_COLS = 11
$ID_PATTERN    = '^ERR-\d{3}$'
$DATE_PATTERN  = '^\d{4}-\d{2}-\d{2}$'

if (-not (Test-Path $KnownIssuesPath)) {
    Write-Error "KNOWN-ISSUES: File not found at $KnownIssuesPath"
    exit 1
}

$lines  = Get-Content $KnownIssuesPath
$errors = 0
$rowNum = 0

foreach ($line in $lines) {
    # Only check table data rows (start with | ERR-)
    if ($line -notmatch '^\|\s*ERR-') { continue }

    $rowNum++
    $cols = $line -split '\|' | Where-Object { $_ -ne '' } | ForEach-Object { $_.Trim() }

    # Column count check
    if ($cols.Count -ne $EXPECTED_COLS) {
        Write-Warning "Row $rowNum ($($cols[0])): expected $EXPECTED_COLS columns, got $($cols.Count)"
        $errors++
        continue
    }

    $id       = $cols[0]
    $date     = $cols[1]
    $env      = $cols[2]
    $type     = $cols[3]
    $severity = $cols[4]
    $status   = $cols[8]

    if ($id -notmatch $ID_PATTERN) {
        Write-Warning "Row $rowNum: ID '$id' does not match ERR-NNN format"
        $errors++
    }
    if ($date -notmatch $DATE_PATTERN) {
        Write-Warning "Row $rowNum ($id): date '$date' is not YYYY-MM-DD"
        $errors++
    }
    if ($AllowedEnv -notcontains $env) {
        Write-Warning "Row $rowNum ($id): Env '$env' not in allowed values: $($AllowedEnv -join ', ')"
        $errors++
    }
    if ($AllowedType -notcontains $type) {
        Write-Warning "Row $rowNum ($id): Type '$type' not in allowed values: $($AllowedType -join ', ')"
        $errors++
    }
    if ($AllowedSeverity -notcontains $severity) {
        Write-Warning "Row $rowNum ($id): Severity '$severity' not in allowed values: $($AllowedSeverity -join ', ')"
        $errors++
    }
    if ($AllowedStatus -notcontains $status) {
        Write-Warning "Row $rowNum ($id): Status '$status' not in allowed values: $($AllowedStatus -join ', ')"
        $errors++
    }
}

if ($rowNum -eq 0) {
    Write-Warning "KNOWN-ISSUES: No registry rows found — is the file empty?"
}

if ($errors -gt 0) {
    Write-Error "KNOWN-ISSUES validation FAILED: $errors error(s) in $rowNum rows"
    exit 1
} else {
    Write-Host "KNOWN-ISSUES validation PASS: $rowNum rows checked, 0 errors"
    exit 0
}
