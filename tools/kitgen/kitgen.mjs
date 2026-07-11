#!/usr/bin/env node
// kitgen — orchestrator: reads kit.config.yaml, delegates ALL file generation to
// engine/emitter.mjs (the single transformer layer), and owns writing to disk,
// drift-checking, and the health `doctor`.
//   node tools/kitgen/kitgen.mjs build     write generated files into outDir
//   node tools/kitgen/kitgen.mjs check     fail (exit 1) if outDir is out of sync
//   node tools/kitgen/kitgen.mjs doctor    health-check the kit + generated output
import { readFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { parseYaml } from "./yaml.mjs";
import { validateConfig } from "./validate.mjs";
import { applyBuild } from "./apply.mjs";
import { buildOutputs, collectRules, collectRoles, collectSkills } from "../../engine/emitter.mjs";

// KIT_DIR = where the kit's sources live (engine/, profiles/) — relative to this file,
// so it works whether the kit is the project root or an installed dep.
// PROJECT_DIR = the project being configured — where kit.config.yaml is read and
// generated files are written. Defaults to the cwd (or CLAUDE_PROJECT_DIR).
const KIT_DIR = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
const PROJECT_DIR = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const kp = (...s) => join(KIT_DIR, ...s);
const pp = (...s) => join(PROJECT_DIR, ...s);

// ---- doctor ---------------------------------------------------------------
const HOOK_MAP = { "consistency-guard": "consistency-guard.mjs" }; // enforce:hook rule.id -> hook file
const OUTPUT_SECTION = /output format|required output|final output/i;

// Read-only health check of the kit + generated output. Returns an exit code.
function runDoctor() {
  const R = [];
  const ok = (g, m) => R.push({ g, level: "ok", m });
  const warn = (g, m) => R.push({ g, level: "warn", m });
  const err = (g, m) => R.push({ g, level: "error", m });
  const clean = (g) => R.filter((r) => r.g === g && r.level !== "ok").length === 0;

  // 1. Node
  const nodeMajor = parseInt(process.versions.node, 10);
  if (nodeMajor >= 18) ok("Node", `node v${process.versions.node} (>= 18)`);
  else err("Node", `node v${process.versions.node} < 18 -> nâng cấp Node lên >= 18`);

  // 2. Config
  let cfg = null;
  const cfgPath = pp("kit.config.yaml");
  if (!existsSync(cfgPath)) err("Config", "thiếu kit.config.yaml -> chạy: npm run init");
  else {
    try { cfg = parseYaml(readFileSync(cfgPath, "utf8")); }
    catch (e) { err("Config", `kit.config.yaml không parse được (${e.message}) -> ${e.hint || "sửa YAML"}`); }
  }
  if (cfg) {
    const { errors, warnings } = validateConfig(cfg, { kitDir: KIT_DIR, projectDir: PROJECT_DIR });
    for (const m of warnings) warn("Config", m);
    for (const m of errors) err("Config", m);
    if (clean("Config")) ok("Config", "kit.config.yaml hợp lệ");
  }

  // 3. Paths
  const reqDirs = ["engine/rules", "engine/roles", "engine/commands", "engine/skills", "profiles", ".kit/hooks"];
  const missDirs = reqDirs.filter((d) => !existsSync(kp(d)));
  if (missDirs.length) for (const d of missDirs) err("Paths", `thiếu thư mục ${d}/`);
  else ok("Paths", reqDirs.join(", "));

  // 5. Hooks
  const reqHooks = ["guard-shell.mjs", "session-start.mjs", "consistency-guard.mjs", "_lib.mjs", "yaml.mjs"];
  const missHooks = reqHooks.filter((h) => !existsSync(kp(".kit/hooks", h)));
  if (missHooks.length) for (const h of missHooks) err("Hooks", `thiếu .kit/hooks/${h}`);
  // vendored yaml must stay byte-identical to the source parser
  const vend = kp(".kit/hooks/yaml.mjs"), src = kp("tools/kitgen/yaml.mjs");
  if (existsSync(vend) && existsSync(src) && readFileSync(vend, "utf8") !== readFileSync(src, "utf8"))
    err("Hooks", "hook yaml lệch nguồn -> chạy: cp tools/kitgen/yaml.mjs .kit/hooks/yaml.mjs");
  if (clean("Hooks")) ok("Hooks", reqHooks.map((h) => h.replace(".mjs", "")).join(", "));

  // Build once, reused by drift + settings cross-check.
  let outputs = null;
  const outDir = cfg?.outDir || "dist";
  if (cfg) {
    try { outputs = buildOutputs(cfg, { kitDir: KIT_DIR }); }
    catch (e) { err("Generated output", `không dựng được output để so drift (${e.message})`); }
  }

  // 4. Drift
  if (outputs) {
    let drift = 0;
    for (const [rel, content] of outputs) {
      const abs = pp(outDir, rel);
      if ((existsSync(abs) ? readFileSync(abs, "utf8") : null) !== content) drift++;
    }
    if (drift) err("Generated output", `${outDir}/ lệch nguồn (${drift} file) -> chạy: npm run build`);
    else ok("Generated output", `${outputs.size} file khớp (${outDir}/)`);
  }

  // Hooks: settings cross-check (WARN)
  if (outputs) {
    const refs = (outputs.get(".claude/settings.json") || "").match(/\.kit\/hooks\/([\w.-]+\.mjs)/g) || [];
    for (const ref of new Set(refs)) {
      const f = ref.split("/").pop();
      if (!existsSync(kp(".kit/hooks", f))) warn("Hooks", `settings tham chiếu hook không tồn tại: ${f}`);
    }
  }

  // 6. Rules enforce
  let rules = [];
  try { rules = collectRules(KIT_DIR, cfg || {}); } catch { /* ignore */ }
  const gateSkillExists = () => { try { return collectSkills(KIT_DIR).some((s) => OUTPUT_SECTION.test(s.body)); } catch { return false; } };
  for (const r of rules) {
    if (!r.enforce) { warn("Rules (enforce)", `rule "${r.id}" thiếu nhãn enforce`); continue; }
    for (const tok of String(r.enforce).split("+").map((t) => t.trim())) {
      if (tok === "agent-read") continue;
      else if (tok === "generator") { if (!existsSync(kp("tools/kitgen/kitgen.mjs"))) err("Rules (enforce)", `rule "${r.id}" enforce=generator nhưng thiếu tools/kitgen/kitgen.mjs`); }
      else if (tok === "gate") { if (!gateSkillExists()) err("Rules (enforce)", `rule "${r.id}" enforce=gate nhưng không skill nào có mục output format`); }
      else if (tok === "hook") {
        const mapped = HOOK_MAP[r.id];
        if (!mapped) warn("Rules (enforce)", `rule "${r.id}" enforce=hook nhưng chưa có mapping hook (bổ sung HOOK_MAP)`);
        else if (!existsSync(kp(".kit/hooks", mapped))) err("Rules (enforce)", `rule "${r.id}" enforce=hook nhưng thiếu .kit/hooks/${mapped}`);
      } else warn("Rules (enforce)", `rule "${r.id}" enforce="${tok}" không nhận diện`);
    }
  }
  if (rules.length && clean("Rules (enforce)")) ok("Rules (enforce)", `${rules.length} rule enforce hợp lệ`);

  // 7. Skills P0
  let skills = [];
  try { skills = collectSkills(KIT_DIR); } catch { /* ignore */ }
  const byId = new Map(skills.map((s) => [s.id, s]));
  for (const id of ["code-review", "refactor", "test-design"]) {
    const s = byId.get(id);
    if (!s) { err("Skills", `thiếu skill ${id}`); continue; }
    if (!s.description) warn("Skills", `skill ${id} thiếu description`);
    if (!Array.isArray(s.paths) || !s.paths.length) warn("Skills", `skill ${id} thiếu paths`);
    if (!OUTPUT_SECTION.test(s.body)) warn("Skills", `skill ${id} thiếu mục output format`);
  }
  if (clean("Skills")) ok("Skills", "code-review, refactor, test-design");

  // 8. Roles
  let roles = [];
  try { roles = collectRoles(KIT_DIR); } catch { /* ignore */ }
  for (const role of roles) {
    const fm = role.fm || {};
    const n = fm.name || "?";
    if (!fm.description || !/use when|invoke for/i.test(fm.description)) warn("Roles", `role "${n}" description thiếu "Use when/Invoke for"`);
    if (!fm.model) warn("Roles", `role "${n}" thiếu model`);
    if (!fm.tools) warn("Roles", `role "${n}" thiếu tools`);
  }
  if (roles.length && clean("Roles")) ok("Roles", `${roles.length} role có description trigger + model + tools`);

  // ---- print ----
  console.log(`SM Kit doctor — ${cfg?.project?.name || "?"} (mode=${cfg?.mode || "?"}, profile=${cfg?.stack?.profile || "?"})\n`);
  const sym = { ok: "  ✔", warn: "  ⚠ [WARN]", error: "  ✖ [ERROR]" };
  for (const g of ["Node", "Config", "Paths", "Generated output", "Hooks", "Rules (enforce)", "Skills", "Roles"]) {
    const items = R.filter((r) => r.g === g);
    if (!items.length) continue;
    console.log(g);
    for (const it of items) console.log(`${sym[it.level]} ${it.m}`);
  }
  const errs = R.filter((r) => r.level === "error").length;
  const warns = R.filter((r) => r.level === "warn").length;
  console.log(`\nSummary: ${errs} error(s), ${warns} warning(s).`);
  return errs > 0 ? 1 : 0;
}

// ---- run ------------------------------------------------------------------

function main() {
  const mode = process.argv[2] || "build";
  if (mode === "doctor") { process.exit(runDoctor()); }
  const cfgPath = pp("kit.config.yaml");
  if (!existsSync(cfgPath)) {
    console.error(`No kit.config.yaml in ${PROJECT_DIR}. Run \`smkit init\` there first (or cd into the project).`);
    process.exit(1);
  }
  let cfg;
  try {
    cfg = parseYaml(readFileSync(cfgPath, "utf8"));
  } catch (e) {
    console.error(`Invalid kit.config.yaml — ${e.message}${e.hint ? ` -> ${e.hint}` : ""}. Nothing was generated.`);
    process.exit(1);
  }

  // Validate BEFORE touching the filesystem. A bad config must never produce a
  // partial or out-of-bounds generation, so we stop here — no mkdir/rm/write ran yet.
  const { errors, warnings } = validateConfig(cfg, { kitDir: KIT_DIR, projectDir: PROJECT_DIR });
  for (const w of warnings) console.error(`WARN: ${w}`);
  if (errors.length) {
    console.error(`Invalid kit.config.yaml — nothing was generated (${mode}):`);
    for (const e of errors) console.error(`  ✖ ${e}`);
    process.exit(1);
  }

  const outDir = cfg.outDir || "dist";
  const outputs = buildOutputs(cfg, { kitDir: KIT_DIR });

  if (mode === "check") {
    let drift = 0;
    for (const [rel, content] of outputs) {
      const abs = pp(outDir, rel);
      const cur = existsSync(abs) ? readFileSync(abs, "utf8") : null;
      if (cur !== content) { console.error(`DRIFT: ${outDir}/${rel}`); drift++; }
    }
    if (drift) { console.error(`\n${drift} file(s) out of sync. Run: node tools/kitgen/kitgen.mjs build`); process.exit(1); }
    console.log(`OK — ${outputs.size} generated file(s) in sync (${outDir}/).`);
    return;
  }

  // build — apply via the ownership manifest: delete only files THIS kit generated
  // before (and only if unmodified), never blanket-delete a directory. User-authored
  // files that the kit doesn't generate are always left untouched.
  const force = process.argv.includes("--force");
  let res;
  try {
    res = applyBuild({ outDir, outputs, projectDir: PROJECT_DIR, force });
  } catch (e) {
    console.error(`Build failed while writing — rolled back, previous output left intact: ${e.message}`);
    process.exit(1);
  }
  for (const w of res.warnings) console.error(`WARN: ${w}`);
  console.log(`Built ${outputs.size} file(s) → ${outDir}/  (mode=${cfg.mode}, profile=${cfg.stack?.profile}, lang=${cfg.project?.language})`);
  if (res.deleted) console.log(`  removed ${res.deleted} stale generated file(s)`);
  if (res.skipped) console.log(`  skipped ${res.skipped} protected file(s) — rerun with --force to replace`);
  for (const rel of [...outputs.keys()].sort()) console.log(`  ${outDir}/${rel}`);
}

main();
