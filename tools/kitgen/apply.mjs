// Turns the in-memory output map into controlled filesystem changes, using the
// ownership manifest so the generator only ever deletes/overwrites files it owns.
//
// Two phases, deliberately split:
//   planBuild()  — READ-ONLY. Decides deletes/writes/skips. Never mutates.
//   applyBuild() — executes the plan and saves the manifest.
// P0.3 wraps the mutating part of applyBuild in a backup/rollback transaction.
import { existsSync, readFileSync, writeFileSync, mkdirSync, rmSync } from "node:fs";
import { join, dirname } from "node:path";
import { sha256, loadManifest, saveManifest } from "./manifest.mjs";

// Compute the change plan. Pure/read-only.
//   force: overwrite locally-modified / untracked files even when a manifest exists.
export function planBuild({ outDir, outputs, projectDir, force = false }) {
  const pp = (...s) => join(projectDir, ...s);
  const manifest = loadManifest(projectDir);
  // Trust the previous file list only when it describes THIS outDir. A different
  // outDir (or no manifest) means "migration": adopt existing generated paths,
  // never delete anything we can't prove we wrote.
  const sameManifest = manifest.outDir === outDir;
  const prev = sameManifest ? manifest.files : {};

  const deletes = [];
  const writes = [];
  const warnings = [];
  const skipped = [];
  const newFiles = {};

  // 1. Stale cleanup: files we generated before but no longer emit. Delete ONLY if
  //    still byte-identical to what we wrote (hash match) — a user edit means keep.
  for (const rel of Object.keys(prev)) {
    if (outputs.has(rel)) continue;
    const abs = pp(outDir, rel);
    if (!existsSync(abs)) continue;
    if (sha256(readFileSync(abs, "utf8")) === prev[rel]) deletes.push({ rel, abs });
    else warnings.push(`kept stale file (modified since generated): ${outDir}/${rel}`);
  }

  // 2. Writes. Overwrite our own files freely; protect anything else.
  for (const [rel, content] of outputs) {
    const abs = pp(outDir, rel);
    const want = sha256(content);
    if (existsSync(abs)) {
      const cur = readFileSync(abs, "utf8");
      if (cur === content) { newFiles[rel] = want; continue; } // already correct, still ours
      const tracked = prev[rel] !== undefined;
      const owned = tracked && sha256(cur) === prev[rel];
      if (!owned) {
        const kind = tracked ? "locally-modified generated" : "untracked";
        // Steady state (manifest for this outDir exists) protects the file unless
        // --force. Migration (no manifest yet) adopts it with a warning.
        if (sameManifest && !force) {
          warnings.push(`skipped (would overwrite ${kind} file): ${outDir}/${rel} — rerun with --force to replace`);
          skipped.push(rel);
          continue;
        }
        warnings.push(`overwriting ${kind} file: ${outDir}/${rel}`);
      }
    }
    writes.push({ rel, abs, content });
    newFiles[rel] = want;
  }

  return { outDir, deletes, writes, skipped, warnings, newFiles, manifest };
}

// Execute a plan: delete stale, write outputs, persist the manifest.
// `mutate` is injected so P0.3 can wrap it in a transaction; default applies directly.
export function applyBuild(opts, mutate = applyPlanDirect) {
  const plan = planBuild(opts);
  mutate(plan);
  saveManifest(opts.projectDir, { outDir: plan.outDir, files: plan.newFiles });
  return {
    written: plan.writes.length,
    deleted: plan.deletes.length,
    skipped: plan.skipped.length,
    warnings: plan.warnings,
  };
}

// Direct (non-transactional) application of a plan's mutations.
export function applyPlanDirect(plan) {
  for (const d of plan.deletes) rmSync(d.abs, { force: true });
  for (const w of plan.writes) {
    mkdirSync(dirname(w.abs), { recursive: true });
    writeFileSync(w.abs, w.content);
  }
}
