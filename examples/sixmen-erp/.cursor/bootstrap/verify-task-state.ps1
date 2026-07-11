param(
    [string]$TaskId = "",
    [switch]$Sign,
    [switch]$Verify,
    [switch]$SignAll
)

# HMAC integrity verifier for task-state.json - SIXMEN AI OS v2, Item 2
# Usage:
#   -TaskId TASK-GD0-011 -Sign    : sign after creating/updating task-state.json
#   -TaskId TASK-GD0-011 -Verify  : verify before trusting task-state.json
#   -SignAll                       : sign all existing task-state.json (first-time setup)
# Setup: add TASK_STATE_HMAC_KEY=<32-char-random> to .env

$EnvFile = ".env"

function Get-HmacKey {
    if (-not (Test-Path $EnvFile)) {
        Write-Warning "VERIFY-STATE: .env not found - integrity check skipped"
        return $null
    }
    foreach ($line in Get-Content $EnvFile) {
        if ($line -match '^TASK_STATE_HMAC_KEY=(.+)$') {
            return $Matches[1].Trim()
        }
    }
    Write-Warning "VERIFY-STATE: TASK_STATE_HMAC_KEY not set in .env - integrity check skipped"
    return $null
}

function Get-FileHmac {
    param([string]$FilePath, [string]$Key)

    $content = Get-Content $FilePath -Raw
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($Key)
    $contentBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keyBytes
    return [BitConverter]::ToString($hmac.ComputeHash($contentBytes)).Replace("-", "").ToLower()
}

function Invoke-Sign {
    param([string]$Id)

    $stateFile = "artifacts/$Id/task-state.json"
    $sigFile   = "artifacts/$Id/task-state.sig"

    if (-not (Test-Path $stateFile)) {
        Write-Warning "SIGN: $stateFile not found - skipping"
        return
    }

    $key = Get-HmacKey
    if (-not $key) { return }

    $hash = Get-FileHmac -FilePath $stateFile -Key $key
    Set-Content $sigFile $hash -NoNewline
    Write-Host "SIGNED: $Id => $($hash.Substring(0,16))..."
}

function Invoke-Verify {
    param([string]$Id)

    $stateFile = "artifacts/$Id/task-state.json"
    $sigFile   = "artifacts/$Id/task-state.sig"

    if (-not (Test-Path $stateFile)) {
        Write-Warning "VERIFY: $stateFile not found - skipping"
        return $true
    }

    $key = Get-HmacKey
    if (-not $key) { return $true }

    $currentHash = Get-FileHmac -FilePath $stateFile -Key $key

    if (-not (Test-Path $sigFile)) {
        Write-Warning "VERIFY: No .sig for $Id - first run, signing now"
        Set-Content $sigFile $currentHash -NoNewline
        return $true
    }

    $expectedHash = (Get-Content $sigFile -Raw).Trim()

    if ($currentHash -ne $expectedHash) {
        Write-Error "INTEGRITY FAIL: artifacts/$Id/task-state.json was modified outside agent flow!"
        Write-Error "  Expected : $($expectedHash.Substring(0,16))..."
        Write-Error "  Got      : $($currentHash.Substring(0,16))..."
        Write-Error "  Action   : review changes, then re-sign with -Sign if intentional."
        return $false
    }

    Write-Host "INTEGRITY OK: $Id"
    return $true
}

# --- Main ---

if ($SignAll) {
    $tasks = Get-ChildItem -Path "artifacts" -Directory | Where-Object { $_.Name -match '^TASK-' }
    foreach ($t in $tasks) {
        Invoke-Sign -Id $t.Name
    }
    exit 0
}

if (-not $TaskId) {
    Write-Host "Usage: -TaskId TASK-GD0-XXX [-Sign|-Verify] or -SignAll"
    exit 0
}

if ($Sign)   { Invoke-Sign -Id $TaskId }
if ($Verify) {
    $ok = Invoke-Verify -Id $TaskId
    exit ([int](-not $ok))
}
