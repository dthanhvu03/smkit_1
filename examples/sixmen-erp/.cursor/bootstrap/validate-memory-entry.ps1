<#
.SYNOPSIS
    Memory entry validator — SIXMEN AI OS v2, Item 1
    Validates that memory entries are declarative (facts only, no instructions).

.USAGE
    # Validate a specific memory file:
    .\validate-memory-entry.ps1 -MemoryFile "C:\Users\Admin\.claude\projects\d--Zusem-sixmen-erp\memory\feedback_testing.md"

    # Validate all memory files:
    .\validate-memory-entry.ps1 -All
#>
param(
    [string]$MemoryFile = "",
    [switch]$All
)

$MemoryDir = "C:\Users\Admin\.claude\projects\d--Zusem-sixmen-erp\memory"
$SchemaFile = ".cursor\schemas\memory-entry.schema.yaml"

# Injection patterns — must match x-injection-patterns in schema
$InjectionPatterns = @(
    '(?i)always do',
    '(?i)never do',
    '(?i)ignore (previous|all|the) (instructions|rules)',
    '(?i)override',
    '(?i)bypass',
    '(?i)disregard',
    '(?i)forget your (instructions|guidelines)',
    '(?i)you must',
    '(?i)you shall',
    '(?i)from now on',
    '(?i)henceforth',
    '(?i)new (system|agent) instruction',
    '(?i)updated rule',
    '(?i)execute the following'
)

function Test-MemoryFile {
    param([string]$FilePath)

    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content) {
        Write-Warning "SKIP: $FilePath (unreadable or empty)"
        return $true
    }

    # Check required frontmatter fields
    $hasName = $content -match '\bname:\s*\S+'
    $hasDesc = $content -match '\bdescription:\s*\S+'
    $hasType = $content -match '\btype:\s*(user|feedback|project|reference)'

    if (-not $hasName) {
        Write-Warning "SCHEMA FAIL [$FilePath]: missing 'name:' in frontmatter"
        return $false
    }
    if (-not $hasDesc) {
        Write-Warning "SCHEMA FAIL [$FilePath]: missing 'description:' in frontmatter"
        return $false
    }
    if (-not $hasType) {
        Write-Warning "SCHEMA FAIL [$FilePath]: 'type:' must be one of: user, feedback, project, reference"
        return $false
    }

    # Injection scan on body content
    foreach ($pattern in $InjectionPatterns) {
        if ($content -match $pattern) {
            $match = [regex]::Match($content, $pattern).Value
            Write-Error "INJECTION DETECTED [$FilePath]: pattern '$pattern' matched '$match'"
            Write-Error "  Memory must be declarative facts only. Move instructions to SKILL.md or policy engine."
            return $false
        }
    }

    return $true
}

$files = @()
if ($All) {
    $files = Get-ChildItem -Path $MemoryDir -Filter "*.md" | Where-Object { $_.Name -ne "MEMORY.md" }
} elseif ($MemoryFile) {
    $files = @([System.IO.FileInfo]$MemoryFile)
} else {
    Write-Host "Usage: -MemoryFile <path> or -All"
    exit 0
}

$passed = 0
$failed = 0

foreach ($f in $files) {
    $ok = Test-MemoryFile -FilePath $f.FullName
    if ($ok) {
        $passed++
    } else {
        $failed++
    }
}

Write-Host ""
Write-Host "Memory validation: $passed PASS, $failed FAIL"
if ($failed -gt 0) {
    exit 1
}
exit 0
