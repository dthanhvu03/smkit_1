// Shared config validator + filesystem boundary resolver.
// The ONE place that decides whether a config is safe to generate from. Both the
// generator (build/check) and doctor call this, so "is this config valid?" has a
// single answer. Pure/read-only: performs NO filesystem mutation — it only reads to
// resolve paths and check a profile exists. Callers MUST run this and stop on any
// error BEFORE creating, deleting, or writing anything.
import { existsSync, realpathSync } from "node:fs";
import { join, resolve, relative, isAbsolute, dirname, basename, sep } from "node:path";
import { collectInvariants, validateSkillGovernance, validateRoleGovernance, validateRuleGovernance } from "../../engine/emitter.mjs";

export const KNOWN_AGENTS = ["agentsmd", "claude", "cursor", "copilot", "windsurf"];
export const MODES = ["vibe", "standard", "strict"];

// realpathSync that degrades to the input when the path does not exist yet.
function realpathSafe(p) {
  try { return realpathSync(p); } catch { return p; }
}

// Resolve outDir against projectDir and decide whether it escapes the project
// boundary. Uses path.relative (NOT startsWith — "/project" must not match
// "/project-backup") and resolves the nearest existing ancestor through realpath so
// a symlink that points outside the project is caught even when outDir itself does
// not exist yet.
export function resolveOutDir(projectDir, outDir) {
  const proj = realpathSafe(resolve(projectDir));
  const abs = resolve(projectDir, String(outDir));
  // Walk up to the nearest existing ancestor, realpath it, then re-append the
  // not-yet-created tail — so `outDir` under a symlinked ancestor is judged by its
  // real location.
  let probe = abs;
  const tail = [];
  while (!existsSync(probe) && dirname(probe) !== probe) {
    tail.unshift(basename(probe));
    probe = dirname(probe);
  }
  const real = existsSync(probe) ? join(realpathSafe(probe), ...tail) : abs;
  const rel = relative(proj, real);
  const outside = rel === ".." || rel.startsWith(".." + sep) || isAbsolute(rel);
  return { abs: real, rel, outside };
}

// Validate a parsed config. Returns { errors:[], warnings:[] } of message strings.
// `kitDir` enables the profile-exists check; `projectDir` enables the outDir
// boundary check. Messages are the single source doctor prints and build fails on.
export function validateConfig(cfg, { kitDir, projectDir } = {}) {
  const errors = [];
  const warnings = [];
  cfg = cfg || {};

  if (!cfg.version) warnings.push("thiếu 'version'");
  if (!cfg.project?.name) warnings.push("thiếu 'project.name'");

  if (!MODES.includes(cfg.mode))
    errors.push(`mode "${cfg.mode}" không hợp lệ -> dùng: ${MODES.join(" | ")}`);

  const profile = cfg.stack?.profile;
  if (kitDir) {
    if (!profile || !existsSync(join(kitDir, "profiles", profile, "profile.yaml")))
      errors.push(`stack.profile "${profile}" không tồn tại -> xem profiles/`);
  }

  const agents = Array.isArray(cfg.agents) ? cfg.agents : [];
  if (!agents.length) errors.push("'agents' rỗng -> khai báo ít nhất một target");
  for (const a of agents)
    if (!KNOWN_AGENTS.includes(a))
      errors.push(`agent target lạ "${a}" -> dùng: ${KNOWN_AGENTS.join(", ")}`);

  if (cfg.outDir !== undefined && typeof cfg.outDir !== "string")
    warnings.push("'outDir' không phải string -> mặc định 'dist'");

  // Invariant merge (engine→profile→project): surface id conflicts and bad
  // enforcement values here, BEFORE any generation, so a conflict fails cleanly.
  if (kitDir && !errors.some((e) => e.includes("stack.profile"))) {
    try { collectInvariants(kitDir, cfg); }
    catch (e) { errors.push(e.message); }
  }

  // Skill governance: a skill must never self-escalate beyond its declared trust
  // tier (T3/T4 must be manual-only + content-hashed) or request a self-contradictory
  // permission (pre-approved yet denied, or pre-approved without being requested).
  if (kitDir) {
    const sg = validateSkillGovernance(kitDir);
    errors.push(...sg.errors);
    warnings.push(...sg.warnings);
  }

  // Role governance: a role can never declare a self-contradictory permission
  // boundary, an invalid enum value, or preload a skill that doesn't exist / can't be
  // preloaded (a disable-model-invocation skill).
  if (kitDir) {
    const rg = validateRoleGovernance(kitDir);
    errors.push(...rg.errors);
    warnings.push(...rg.warnings);
  }

  // Rule governance: a rule can never claim an enforcement type the kit cannot back
  // (hook with no hook file, static-check with no gate skill), and no two rules across
  // engine+profile may share an id.
  if (kitDir) {
    const ruleG = validateRuleGovernance(kitDir, cfg);
    errors.push(...ruleG.errors);
    warnings.push(...ruleG.warnings);
  }

  // Filesystem boundary: refuse to generate outside the project (write + the
  // recursive cleanup that follows would otherwise escape the project root).
  if (projectDir) {
    const outDir = typeof cfg.outDir === "string" ? cfg.outDir : "dist";
    const { outside, abs } = resolveOutDir(projectDir, outDir);
    if (outside)
      errors.push(`outDir "${outDir}" nằm ngoài project (${abs}) -> chọn một thư mục bên trong project`);
  }

  return { errors, warnings };
}
