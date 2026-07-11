#!/bin/bash
# Scan markdown docs for references to files/paths that do not exist in the repo.
# Exit 0 = PASS, Exit 1 = FAIL (dead links), Exit 2 = PASS with warnings (fuzzy refs + -s)
#
# Usage:
#   .cursor/bootstrap/validate-doc-refs.sh
#   .cursor/bootstrap/validate-doc-refs.sh -s          # strict: fuzzy refs = FAIL
#   .cursor/bootstrap/validate-doc-refs.sh -e "docs/erp/core/*.md"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STRICT=false
EXTRA_GLOBS=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--strict|-Strict) STRICT=true; shift ;;
        -e|--extra|-Extra) EXTRA_GLOBS+=("$2"); shift 2 ;;
        *) shift ;;
    esac
done

python3 - "$REPO_ROOT" "$STRICT" "${EXTRA_GLOBS[@]}" << 'PYEOF'
import sys, os, re, glob

repo_root = sys.argv[1]
strict = sys.argv[2].lower() == 'true'
extra_globs = sys.argv[3:]

SEARCH_PREFIXES = [
    "docs/ai-agent/reference",
    "docs/erp/core",
    "docs/erp/phases",
    "docs/erp/sheets/data",
    ".cursor/rules",
    ".cursor/bootstrap",
    ".cursor/templates/sixmen",
    ".cursor/skills",
    "artifacts",
]

SKIP_EXTENSIONS = {'.png','.jpg','.jpeg','.gif','.svg','.ico','.woff','.woff2','.ttf','.eot'}

SKIP_PATTERNS = [
    re.compile(r'^https?://'),
    re.compile(r'^mailto:'),
    re.compile(r'^#'),
    re.compile(r'^\{'),
    re.compile(r'^\$'),
    re.compile(r'^\*'),
    re.compile(r'^@'),
    re.compile(r'^\s*$'),
    re.compile(r'^[a-z][a-z0-9_-]*/[a-z][a-z0-9_-]*$'),  # composer package
    re.compile(r'^[A-Z]:\\'),                               # Windows absolute
    re.compile(r'^/'),                                      # Linux absolute
]

BARE_ARTIFACT = re.compile(r'^\d{2}-[a-z][a-z0-9-]*\.md$')

LINK_PATTERNS = [
    re.compile(r'(?<!\!)\[(?:[^\]]*)\]\((?!https?://|mailto:|#)([^)#\s]+)'),
    re.compile(r'`([A-Za-z0-9_.][A-Za-z0-9_./\\-]+\.(?:md|ps1|php|json|yaml|yml|env|mdc|neon|csv|log|sh|ts|js))`'),
]

# Roots searched recursively for bare filenames (code/test/CI files live outside SEARCH_PREFIXES).
# TASK-GD0-047 P1-10: prevents false dead-links for refs like AdminPanelProvider.php / deploy-staging.yml.
RECURSIVE_ROOTS = ["docs/erp/phases", "app", "tests", ".github", "modules", "database", "resources"]
_PRUNE_DIRS = {"vendor", "node_modules", ".git"}

def find_recursive(filename):
    for root in RECURSIVE_ROOTS:
        base = os.path.join(repo_root, root)
        if not os.path.isdir(base):
            continue
        for dirpath, dirs, filenames in os.walk(base):
            dirs[:] = [d for d in dirs if d not in _PRUNE_DIRS]
            if filename in filenames:
                return os.path.join(dirpath, filename)
    return None

resolve_cache = {}

def resolve_ref(ref):
    ref = ref.replace('\\', '/')
    if ref in resolve_cache:
        return resolve_cache[ref]

    # 1. Direct under repo root
    candidate = os.path.join(repo_root, ref)
    if os.path.exists(candidate):
        resolve_cache[ref] = (True, True, candidate)
        return resolve_cache[ref]

    # 2. .mdc files in .cursor/rules/
    if ref.endswith('.mdc') and '/' not in ref:
        candidate = os.path.join(repo_root, ".cursor/rules", ref)
        if os.path.exists(candidate):
            resolve_cache[ref] = (True, True, candidate)
            return resolve_cache[ref]

    # 3. Bare filename — fuzzy search
    if '/' not in ref and '\\' not in ref:
        for prefix in SEARCH_PREFIXES:
            candidate = os.path.join(repo_root, prefix, ref)
            if os.path.exists(candidate):
                resolve_cache[ref] = (True, False, candidate)
                return resolve_cache[ref]
        rec_hit = find_recursive(ref)
        if rec_hit:
            resolve_cache[ref] = (True, False, rec_hit)
            return resolve_cache[ref]

    # 4. Partial path — try phase prefix then any known search prefix
    #    (e.g. sixmen-backend/SKILL.md → .cursor/skills/sixmen-backend/SKILL.md). TASK-GD0-047 P1-10.
    if '/' in ref:
        candidate = os.path.join(repo_root, "docs/erp/phases", ref)
        if os.path.exists(candidate):
            resolve_cache[ref] = (True, False, candidate)
            return resolve_cache[ref]
        for prefix in SEARCH_PREFIXES:
            candidate = os.path.join(repo_root, prefix, ref)
            if os.path.exists(candidate):
                resolve_cache[ref] = (True, False, candidate)
                return resolve_cache[ref]

    resolve_cache[ref] = (False, False, '')
    return resolve_cache[ref]

def should_skip(ref):
    ext = os.path.splitext(ref)[1].lower()
    if ext in SKIP_EXTENSIONS:
        return True
    if BARE_ARTIFACT.match(ref):
        return True
    for p in SKIP_PATTERNS:
        if p.search(ref):
            return True
    return False

# Build scan list
default_targets = [
    "AGENTS.md", "CLAUDE.md",
    ".cursor/skills/sixmen-*/SKILL.md",
    "docs/ai-agent/reference/*.md",
]
scan_files = set()
for pattern in default_targets + extra_globs:
    matched = glob.glob(os.path.join(repo_root, pattern), recursive=True)
    for f in matched:
        if os.path.isfile(f):
            scan_files.add(f)
scan_files = sorted(scan_files)

if not scan_files:
    print("No files matched. Check RepoRoot and targets.")
    sys.exit(0)

failures = []  # (ref, src_file, line_num)
fuzzy_hits = []

for src_file in scan_files:
    rel_src = os.path.relpath(src_file, repo_root)
    try:
        lines = open(src_file, encoding='utf-8').readlines()
    except:
        continue

    in_fence = False
    for line_num, line in enumerate(lines, 1):
        stripped = line.rstrip('\n')
        if stripped.strip().startswith('```'):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if stripped.strip().startswith('<!--'):
            continue

        for pat in LINK_PATTERNS:
            for m in pat.finditer(stripped):
                ref = m.group(1).strip().rstrip(').,')
                ref = ref.split('#')[0].strip()
                if not ref or should_skip(ref):
                    continue

                found, exact, full_path = resolve_ref(ref)
                if not found:
                    failures.append((ref, rel_src, line_num))
                elif not exact:
                    rel_found = os.path.relpath(full_path, repo_root)
                    fuzzy_hits.append((ref, rel_src, line_num, rel_found))

print()
print("=== SIXMEN Doc-Ref Validation ===")
print(f"Repo:    {repo_root}")
print(f"Scanned: {len(scan_files)} file(s)")
print()
for f in scan_files:
    print(f"  {os.path.relpath(f, repo_root)}")
print()

if fuzzy_hits:
    unique_fuzzy = {}
    for ref, src, ln, found in fuzzy_hits:
        unique_fuzzy.setdefault(ref, []).append((src, ln, found))
    print(f"WARN - bare-name refs (file exists but path unqualified, {len(unique_fuzzy)} unique):")
    for ref, locs in sorted(unique_fuzzy.items()):
        print(f"  {ref}")
        for src, ln, found in locs:
            print(f"    <- {src}:{ln}   [found: {found}]")
    print()

if failures:
    unique_fail = {}
    for ref, src, ln in failures:
        unique_fail.setdefault(ref, []).append((src, ln))
    print(f"FAIL - true dead links (not found anywhere, {len(unique_fail)} unique):")
    for ref, locs in sorted(unique_fail.items()):
        print(f"  {ref}")
        for src, ln in locs:
            print(f"    <- {src}:{ln}")
    print()
    print("Action: create the missing file/path OR correct the reference.")
    sys.exit(1)

if fuzzy_hits and strict:
    print("FAIL (Strict) - fuzzy refs should use full paths.")
    sys.exit(1)

if fuzzy_hits:
    print("PASS (with warnings) - no dead links, but some refs use bare filenames.")
    sys.exit(2)

print("PASS - no broken local references found.")
sys.exit(0)
PYEOF
