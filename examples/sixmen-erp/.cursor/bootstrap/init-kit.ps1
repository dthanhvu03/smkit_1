<#
.SYNOPSIS
    Local kit health check — run after kit changes or before sync to Laravel repo.
.EXAMPLE
    .\.cursor\bootstrap\init-kit.ps1
#>
$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Push-Location $root

Write-Host "=== SIXMEN Kit Init / Health Check ===" -ForegroundColor Cyan
Write-Host "Root: $root"
Write-Host ""

$exitCode = 0

@("EXAMPLE-TASK", "PILOT-GD0-B1") | ForEach-Object {
    Write-Host "--- validate-artifacts: $_ ---" -ForegroundColor DarkCyan
    & "$PSScriptRoot\validate-artifacts.ps1" -TaskId $_
    if ($LASTEXITCODE -ne 0) { $exitCode = 1 }
    Write-Host ""
}

Write-Host "--- validate-task-log ---" -ForegroundColor DarkCyan
& "$PSScriptRoot\validate-task-log.ps1"
if ($LASTEXITCODE -gt 1) { $exitCode = 1 }
Write-Host ""

# Always-on rules line count estimate
$alwaysOn = Get-ChildItem ".cursor\rules\*.mdc" | Where-Object {
    (Get-Content $_.FullName -Raw) -match 'alwaysApply:\s*true'
}
$lines = ($alwaysOn | ForEach-Object { (Get-Content $_.FullName).Count } | Measure-Object -Sum).Sum
Write-Host "Always-on rules: $($alwaysOn.Count) files, ~$lines lines total" -ForegroundColor Yellow
Write-Host "  $($alwaysOn.Name -join ', ')"
Write-Host ""

if ($exitCode -eq 0) {
    Write-Host "Kit health: PASS" -ForegroundColor Green
} else {
    Write-Host "Kit health: FAIL" -ForegroundColor Red
}

Pop-Location
exit $exitCode
