# Relocate the ERP .cursor/.claude dirs out of the repo root once the IDE lock is released.
# Run from the repo root: pwsh examples/sixmen-erp/finish-move.ps1
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..\..")
$dest = "examples/sixmen-erp"
foreach ($d in @(".cursor", ".claude")) {
  if (Test-Path $d) {
    if (Test-Path "$dest/$d") {
      Write-Host "skip $d - already present in $dest (root copy left in place)"
    } else {
      Move-Item $d "$dest/$d"
      Write-Host "moved $d -> $dest/$d"
    }
  }
}
Write-Host "Done. The universal kit generates its own .claude/.cursor via: node tools/kitgen/kitgen.mjs build"
