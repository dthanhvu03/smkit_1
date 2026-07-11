#!/usr/bin/env bash
# Relocate the ERP .cursor/.claude dirs out of the repo root once the IDE lock is released.
# Run from the repo root: bash examples/sixmen-erp/finish-move.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
dest="examples/sixmen-erp"
for d in .cursor .claude; do
  if [ -e "$d" ]; then
    if [ -e "$dest/$d" ]; then
      echo "skip $d — already present in $dest (root copy left in place)"
    else
      mv "$d" "$dest/$d" && echo "moved $d -> $dest/$d"
    fi
  fi
done
echo "Done. The universal kit generates its own .claude/.cursor via: node tools/kitgen/kitgen.mjs build"
