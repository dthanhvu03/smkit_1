<#
.SYNOPSIS
    Scan markdown docs for references to files/paths that do not exist in the repo.
.DESCRIPTION
    Detects two classes of problems in local file references inside markdown:

      FAIL  - ref not found anywhere in the repo (true dead link)
      WARN  - ref found but only via fuzzy search (bare filename, no full path)
              This means the doc omits the qualified path - confusing for agents.

    Default scan targets:
      AGENTS.md, CLAUDE.md, .cursor/skills/*/SKILL.md,
      docs/ai-agent/reference/*.md

    Exit 0 = PASS (no fails, no warns)
    Exit 1 = FAIL (at least one true dead link)
    Exit 2 = PASS with warnings (fuzzy-only refs; only when -Strict)
.PARAMETER RepoRoot
    Repo root. Defaults to two levels above this script.
.PARAMETER Extra
    Additional glob patterns (relative to RepoRoot) to scan.
.PARAMETER Strict
    Treat fuzzy-only refs (WARN) as failures.
.EXAMPLE
    .\.cursor\bootstrap\validate-doc-refs.ps1
    .\.cursor\bootstrap\validate-doc-refs.ps1 -Strict
    .\.cursor\bootstrap\validate-doc-refs.ps1 -Extra "docs/erp/core/*.md"
#>
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [string[]]$Extra  = @(),
    [switch]$Strict
)

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Known sub-trees where bare filenames are valid targets
# (searched in order; first hit wins)
# ---------------------------------------------------------------------------
$searchPrefixes = @(
    "docs\ai-agent\reference",
    "docs\erp\core",
    "docs\erp\phases",
    "docs\erp\sheets\data",
    ".cursor\rules",
    ".cursor\bootstrap",
    ".cursor\templates\sixmen",
    ".cursor\skills",
    "artifacts"
)

# For bare filenames that live in phase sub-folders (docs\erp\phases\GDx_*\)
# we do a one-level wildcard search
function Find-InPhases {
    param([string]$FileName)
    $phasesRoot = Join-Path $RepoRoot "docs\erp\phases"
    $hit = Get-ChildItem -Path $phasesRoot -Filter $FileName -Recurse -ErrorAction SilentlyContinue |
           Select-Object -First 1
    if ($hit) { return $hit.FullName }
    return $null
}

# ---------------------------------------------------------------------------
# Resolve a ref string to an existing absolute path
# Returns hashtable: @{ Found=$bool; Exact=$bool; FullPath='' }
# Exact=$true  -> direct join with repo root resolved the path
# Exact=$false -> found only via fuzzy (bare name) search in known prefixes
# ---------------------------------------------------------------------------
function Resolve-Ref {
    param([string]$Ref)

    $ref = $Ref -replace '/', '\'

    # 1. Direct under repo root
    $candidate = Join-Path $RepoRoot $ref
    if (Test-Path $candidate) {
        return @{ Found=$true; Exact=$true; FullPath=$candidate }
    }

    # 2. .mdc files always live in .cursor\rules\
    if ($ref -match '\.mdc$' -and $ref -notmatch '\\') {
        $candidate = Join-Path $RepoRoot ".cursor\rules\$ref"
        if (Test-Path $candidate) {
            return @{ Found=$true; Exact=$true; FullPath=$candidate }
        }
    }

    # 3. Bare filename (no path separator) - fuzzy search in known prefixes
    if ($ref -notmatch '\\') {
        foreach ($prefix in $searchPrefixes) {
            $candidate = Join-Path $RepoRoot "$prefix\$ref"
            if (Test-Path $candidate) {
                return @{ Found=$true; Exact=$false; FullPath=$candidate }
            }
        }
        # Also search recursively under docs\erp\phases (phase sub-folders)
        $phaseHit = Find-InPhases -FileName $ref
        if ($phaseHit) {
            return @{ Found=$true; Exact=$false; FullPath=$phaseHit }
        }
    }

    # 4. Partial path (e.g. GD1_Kho_SX/ERD.md) - try under docs\erp\phases
    if ($ref -match '\\') {
        $candidate = Join-Path $RepoRoot "docs\erp\phases\$ref"
        if (Test-Path $candidate) {
            return @{ Found=$true; Exact=$false; FullPath=$candidate }
        }
    }

    return @{ Found=$false; Exact=$false; FullPath='' }
}

# ---------------------------------------------------------------------------
# Regex patterns - each must capture the ref in group 1
# ---------------------------------------------------------------------------
$patterns = @(
    # Markdown link [text](path) - local only
    '(?<!\!)\[(?:[^\]]*)\]\((?!https?://|mailto:|#)([^)#\s]+)',
    # Backtick path with known doc/code extension
    '`([A-Za-z0-9_.][A-Za-z0-9_./\\-]+\.(?:md|ps1|php|json|yaml|yml|env|mdc|neon|csv|log|sh|ts|js))`'
)

# Ref strings that are definitely not local file paths
$skipPatterns = @(
    '^https?://',
    '^mailto:',
    '^#',
    '^\{',
    '^\$',
    '^\*',
    '^@',
    '^\s*$',
    '^[a-z][a-z0-9_-]*/[a-z][a-z0-9_-]*$',   # Composer vendor/package (all lowercase, hyphens)
    '^[A-Z]:\\',
    '^/'
)

# Bare artifact filenames are template-context examples, not resolvable paths
# e.g. 00-gate-status.md, 01-task-brief.md mentioned as examples in skill docs
function Test-IsBareArtifactExample {
    param([string]$Ref)
    # Bare NN-name.md with no path prefix = artifact slot name used as example
    return ($Ref -match '^\d{2}-[a-z][a-z0-9-]*\.md$' -and $Ref -notmatch '[/\\]')
}

$skipExtensions = @('.png','.jpg','.jpeg','.gif','.svg','.ico','.woff','.woff2','.ttf','.eot')

# ---------------------------------------------------------------------------
# Build scan file list
# ---------------------------------------------------------------------------
$defaultTargets = @(
    "AGENTS.md",
    "CLAUDE.md",
    ".cursor\skills\sixmen-*\SKILL.md",
    "docs\ai-agent\reference\*.md"
)

$scanFiles = [System.Collections.Generic.List[string]]::new()
foreach ($glob in ($defaultTargets + $Extra)) {
    $resolved = Join-Path $RepoRoot $glob
    @(Get-ChildItem -Path $resolved -ErrorAction SilentlyContinue) |
        Where-Object { -not $_.PSIsContainer } |
        ForEach-Object { $scanFiles.Add($_.FullName) | Out-Null }
}
$scanFiles = @($scanFiles | Sort-Object -Unique)

if ($scanFiles.Count -eq 0) {
    Write-Host "No files matched. Check RepoRoot and targets." -ForegroundColor Yellow
    exit 0
}

# ---------------------------------------------------------------------------
# Scan
# ---------------------------------------------------------------------------
$failures = [System.Collections.Generic.List[string]]::new()
$fuzzyHits = [System.Collections.Generic.List[string]]::new()
$cache    = @{}   # ref string -> resolve result

foreach ($srcFile in $scanFiles) {
    $relSrc  = $srcFile.Replace($RepoRoot, '').TrimStart('\/')
    $lines   = Get-Content -Path $srcFile -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $lines) { continue }

    $lineNum = 0
    $inFence = $false

    foreach ($line in $lines) {
        $lineNum++

        if ($line -match '^```') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        if ($line -match '^\s*<!--') { continue }

        foreach ($pat in $patterns) {
            foreach ($m in [regex]::Matches($line, $pat)) {
                $ref = $m.Groups[1].Value.Trim() -replace '[)\.,]+$', ''
                $ref = ($ref -split '#')[0].Trim()
                if ([string]::IsNullOrWhiteSpace($ref)) { continue }

                $skip = $false
                foreach ($sp in $skipPatterns) {
                    if ($ref -match $sp) { $skip = $true; break }
                }
                if ($skip) { continue }

                $ext = [System.IO.Path]::GetExtension($ref).ToLower()
                if ($skipExtensions -contains $ext) { continue }

                if (Test-IsBareArtifactExample $ref) { continue }

                if (-not $cache.ContainsKey($ref)) {
                    $cache[$ref] = Resolve-Ref -Ref $ref
                }

                $result = $cache[$ref]
                $loc    = "$relSrc :$lineNum"

                if (-not $result.Found) {
                    $failures.Add("$ref  |  $loc") | Out-Null
                } elseif (-not $result.Exact) {
                    $fuzzyHits.Add("$ref  |  $loc  |  found at: $($result.FullPath.Replace($RepoRoot,'').TrimStart('\\/'))") | Out-Null
                }
            }
        }
    }
}

# Group by ref for cleaner output
function Group-ByRef ([System.Collections.Generic.List[string]]$list) {
    $list | Group-Object { ($_ -split '  \|  ')[0] } | Sort-Object Name
}

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=== SIXMEN Doc-Ref Validation ===" -ForegroundColor Cyan
Write-Host "Repo:    $RepoRoot"
Write-Host "Scanned: $($scanFiles.Count) file(s)"
Write-Host ""
$scanFiles | ForEach-Object {
    Write-Host "  $($_.Replace($RepoRoot,'').TrimStart('\/'))" -ForegroundColor DarkGray
}
Write-Host ""

$failGroups  = Group-ByRef $failures
$fuzzyGroups = Group-ByRef $fuzzyHits

if ($fuzzyGroups.Count -gt 0) {
    Write-Host "WARN - bare-name refs (file exists but path unqualified, $($fuzzyGroups.Count) unique):" -ForegroundColor Yellow
    foreach ($g in $fuzzyGroups) {
        Write-Host "  $($g.Name)" -ForegroundColor Yellow
        $g.Group | ForEach-Object {
            $parts = $_ -split '  \|  '
            Write-Host "    <- $($parts[1])   [found: $($parts[2] -replace 'found at: ','')]" -ForegroundColor DarkYellow
        }
    }
    Write-Host ""
}

if ($failGroups.Count -gt 0) {
    Write-Host "FAIL - true dead links (not found anywhere, $($failGroups.Count) unique):" -ForegroundColor Red
    foreach ($g in $failGroups) {
        Write-Host "  $($g.Name)" -ForegroundColor Red
        $g.Group | ForEach-Object {
            $parts = $_ -split '  \|  '
            Write-Host "    <- $($parts[1])" -ForegroundColor DarkRed
        }
    }
    Write-Host ""
    Write-Host "Action: create the missing file/path OR correct the reference." -ForegroundColor Yellow
    exit 1
}

if ($fuzzyGroups.Count -gt 0 -and $Strict) {
    Write-Host "FAIL (Strict) - fuzzy refs should use full paths." -ForegroundColor Red
    exit 1
}

if ($fuzzyGroups.Count -gt 0) {
    Write-Host "PASS (with warnings) - no dead links, but some refs use bare filenames." -ForegroundColor Green
    exit 2
}

Write-Host "PASS - no broken local references found." -ForegroundColor Green
exit 0
