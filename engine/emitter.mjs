// engine/emitter.mjs
// The kit's ONE transformer layer: reads engine/ + profiles/ sources and turns
// kit.config.yaml into per-IDE config, organized as a class per target behind a
// registry. Pure — every emitter returns [path, content] pairs; writing to disk,
// drift-checking and orchestration live in tools/kitgen (the orchestrator).
//
// Single source of truth: kitgen delegates all file generation here. Add an IDE by
// writing an Emitter subclass and registering it in EMITTERS.
//
// Zero new deps: reuses the kit's own YAML parser.
import { parseYaml, parseFrontmatter } from "../tools/kitgen/yaml.mjs";
import { readFileSync, readdirSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

// KIT_DIR = where the kit's sources live (engine/, profiles/). Default = repo root
// relative to this file; overridable so a copied/installed kit resolves correctly.
export const DEFAULT_KIT_DIR = join(dirname(fileURLToPath(import.meta.url)), "..");

const readAt = (kitDir, rel) => readFileSync(join(kitDir, rel), "utf8");
const listMdAt = (kitDir, rel) =>
  existsSync(join(kitDir, rel)) ? readdirSync(join(kitDir, rel)).filter((f) => f.endsWith(".md")).sort() : [];

// ---- source collectors (exported so `doctor` can reuse them) --------------
export function loadStrings(kitDir, lang) {
  const f = join(kitDir, "engine", "i18n", lang, "strings.yaml");
  const fb = join(kitDir, "engine", "i18n", "en", "strings.yaml");
  return parseYaml(readFileSync(existsSync(f) ? f : fb, "utf8"));
}

export function collectRules(kitDir, cfg) {
  const rules = [];
  for (const f of listMdAt(kitDir, "engine/rules")) {
    const { fm, body } = parseFrontmatter(readAt(kitDir, join("engine/rules", f)));
    rules.push({ ...fm, body: body.trim() });
  }
  const profDir = join("profiles", cfg.stack?.profile || "generic");
  const profFile = join(kitDir, profDir, "profile.yaml");
  if (existsSync(profFile)) {
    const prof = parseYaml(readFileSync(profFile, "utf8"));
    for (const r of prof.rules || []) {
      const { fm, body } = parseFrontmatter(readAt(kitDir, join(profDir, r)));
      rules.push({ ...fm, body: body.trim() });
    }
  }
  return rules;
}

export function collectRoles(kitDir) {
  return listMdAt(kitDir, "engine/roles").map((f) => {
    const { fm, body } = parseFrontmatter(readAt(kitDir, join("engine/roles", f)));
    return { fm, body: body.trim() };
  });
}

export function collectCommands(kitDir) {
  return listMdAt(kitDir, "engine/commands").map((f) => {
    const { fm, body } = parseFrontmatter(readAt(kitDir, join("engine/commands", f)));
    return { ...fm, body: body.trim() };
  });
}

const SKILLS_DIR = "engine/skills";
const SUPPORT_SUBDIRS = ["scripts", "references", "assets"]; // NOT tests/ (never emitted)

function listFilesRec(base, prefix = "") {
  const out = [];
  for (const e of readdirSync(base, { withFileTypes: true })) {
    if (e.isDirectory()) out.push(...listFilesRec(join(base, e.name), `${prefix}${e.name}/`));
    else out.push(prefix + e.name);
  }
  return out;
}

// Load one skill as the normalized two-layer model: a portable SKILL.md (Agent Skills
// open standard — metadata is string→string only) plus an optional kit governance
// sidecar (skill.kit.yaml). Old single-file skills (id/paths/related_*) are migrated
// in-memory for one release, each divergence recorded as a warning (never silent).
function normalizeSkill(kitDir, d, warn) {
  const { fm, body } = parseFrontmatter(readAt(kitDir, join(SKILLS_DIR, d, "SKILL.md")));
  const src = `${SKILLS_DIR}/${d}/SKILL.md`;

  // name MUST equal the directory (Agent Skills identity + command name).
  if (fm.name && fm.name !== d)
    warn({ target: "skill", field: "name", source: src, message: `name "${fm.name}" != directory "${d}"; using the directory name`, remediation: "set SKILL.md name to the folder name" });

  // paths is not an Agent Skills field — skills activate by description, not globs.
  if (fm.paths)
    warn({ target: "skill", field: "paths", source: src, message: `"paths" is not an Agent Skills field and is dropped from SKILL.md`, remediation: "model path-gating as a Rule that recommends this skill" });

  // metadata must be a string→string map.
  const metadata = {};
  if (fm.metadata && typeof fm.metadata === "object" && !Array.isArray(fm.metadata)) {
    for (const [k, v] of Object.entries(fm.metadata)) {
      if (v !== null && typeof v === "object")
        warn({ target: "skill", field: `metadata.${k}`, source: src, message: "metadata must be string→string; complex value ignored", remediation: "move it to skill.kit.yaml" });
      else metadata[String(k)] = String(v);
    }
  }

  // governance sidecar, or a backward-compat shim derived from old fields.
  const sidecar = join(kitDir, SKILLS_DIR, d, "skill.kit.yaml");
  let gov;
  if (existsSync(sidecar)) {
    gov = parseYaml(readFileSync(sidecar, "utf8")) || {};
  } else {
    gov = {
      invocation: { implicit: true, manual: true },
      permissions: { requestedTools: [], deniedTools: [], preApprovedTools: [] },
      relatedRoles: fm.related_roles || [],
      relatedRules: fm.related_rules || [],
    };
    if (fm.related_roles || fm.related_rules)
      warn({ target: "skill", field: "related_*", source: src, message: "related_roles/related_rules are non-standard and are dropped from SKILL.md", remediation: "declare them in skill.kit.yaml" });
  }

  // supporting resources (scripts/references/assets), emitted alongside SKILL.md.
  const supporting = [];
  for (const sub of SUPPORT_SUBDIRS) {
    const abs = join(kitDir, SKILLS_DIR, d, sub);
    if (existsSync(abs)) for (const f of listFilesRec(abs)) supporting.push({ rel: `${sub}/${f}`, abs: join(abs, f) });
  }

  return {
    id: d, name: d, description: fm.description || "",
    license: fm.license, compatibility: fm.compatibility, metadata,
    body: body.trim(), gov, supporting, user_invocable: fm.user_invocable,
  };
}

// Collect all skills. `warn` is an optional sink for migration/validation warnings.
export function collectSkills(kitDir, warn = () => {}) {
  if (!existsSync(join(kitDir, SKILLS_DIR))) return [];
  return readdirSync(join(kitDir, SKILLS_DIR))
    .filter((d) => existsSync(join(kitDir, SKILLS_DIR, d, "SKILL.md")))
    .sort()
    .map((d) => normalizeSkill(kitDir, d, warn));
}

// Re-run skill collection purely to gather warnings (used by build + doctor to surface
// capability drops / migration notices without changing buildOutputs' Map contract).
export function collectBuildWarnings(kitDir) {
  const warnings = [];
  collectSkills(kitDir, (w) => warnings.push(w));
  return warnings;
}

// Merge invariants across layers: engine → profile → project (F-07). Each invariant
// gets a stable id (explicit `id` or slug of its path); a duplicate id is a conflict
// unless the PROJECT layer explicitly sets `override: true` over a lower layer.
// `enforcement` (guidance|static-check|hook|ci|unsupported) defaults to guidance.
const INV_ENFORCEMENT = new Set(["guidance", "static-check", "hook", "ci", "unsupported"]);

export function collectInvariants(kitDir, cfg) {
  const out = [];
  const byId = new Map();
  const add = (inv, layer) => {
    if (!inv || typeof inv !== "object" || !inv.rule) return;
    const id = inv.id || `invariant-${slug(inv.path || inv.rule)}`;
    const enforcement = inv.enforcement || "guidance";
    if (!INV_ENFORCEMENT.has(enforcement))
      throw new Error(`invariant "${id}": enforcement "${enforcement}" invalid -> ${[...INV_ENFORCEMENT].join(" | ")}`);
    const rec = { ...inv, id, enforcement, layer };
    const prev = byId.get(id);
    if (prev) {
      const canOverride = layer === "project" && inv.override === true && prev.layer !== "project";
      if (!canOverride)
        throw new Error(`invariant id conflict: "${id}" (${prev.layer} vs ${layer}) -> set 'override: true' on the project invariant to replace, or rename its id`);
      out.splice(out.indexOf(prev), 1);
    }
    byId.set(id, rec);
    out.push(rec);
  };

  const profDir = join("profiles", cfg.stack?.profile || "generic");
  const profFile = join(kitDir, profDir, "profile.yaml");
  if (existsSync(profFile)) {
    const prof = parseYaml(readFileSync(profFile, "utf8"));
    for (const inv of prof.invariants || []) add(inv, "profile");
  }
  for (const inv of Array.isArray(cfg.invariants) ? cfg.invariants : []) add(inv, "project");
  return out;
}

// ---- render helpers (verbatim behavior — golden depends on exact bytes) ----
const y = (v) => JSON.stringify(String(v));
const slug = (s) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "") || "rule";
const invName = (inv, i) => `invariant-${i + 1}-${slug(inv.path || i + 1)}`;

const SECRET_DENY = ["Read(./.env)", "Read(./.env.*)", "Read(./**/*.pem)", "Read(./**/*.key)", "Read(./**/id_rsa)"];

export function denyFromGuardrails(cfg) {
  const block = [...(cfg.guardrails?.block || []), ...(cfg.guardrails?.allow_extra || [])];
  const bases = new Set();
  for (const b of block) {
    if (!/^[a-z][\w.-]*(\s|$)/.test(b)) continue;
    const base = b.replace(/\s+([~/.][^\s]*)\s*$/, "").trim();
    bases.add(`Bash(${base}:*)`);
  }
  return [...bases, ...SECRET_DENY];
}

function emitClaudeMd(cfg, S) {
  const note = { vibe: S.mode_note_vibe, standard: S.mode_note_standard, strict: S.mode_note_strict }[cfg.mode] || S.mode_note_vibe;
  return `<!-- ${S.generated_banner} -->

# ${cfg.project?.name || "Project"} — agent instructions

${S.claude_intro}

${note}

${S.session_memory_note}

Roles live in \`.claude/agents/\`. Auto-loaded rules live in \`.claude/rules/\`. Single source: \`kit.config.yaml\` + \`engine/\`.
`;
}

function emitClaudeRule(rule, S) {
  const fmLines = [`# ${S.generated_banner}`];
  if (rule.scope === "paths" && Array.isArray(rule.paths) && rule.paths.length) {
    fmLines.push("paths:");
    for (const g of rule.paths) fmLines.push(`  - "${g}"`);
  }
  if (rule.title) fmLines.push(`description: ${y(rule.title)}`);
  return `---\n${fmLines.join("\n")}\n---\n\n${rule.body}\n`;
}

function emitCursorRule(rule, S) {
  const always = rule.scope !== "paths";
  const fmLines = [`# ${S.generated_banner}`];
  if (rule.title) fmLines.push(`description: ${y(rule.title)}`);
  if (!always && Array.isArray(rule.paths)) fmLines.push(`globs: ${rule.paths.join(",")}`);
  fmLines.push(`alwaysApply: ${always}`);
  return `---\n${fmLines.join("\n")}\n---\n\n${rule.body}\n`;
}

function emitAgent(role, S) {
  const fm = role.fm;
  const lines = [`# ${S.generated_banner}`];
  for (const k of ["name", "description", "tools", "model"]) {
    if (fm[k] === undefined || fm[k] === null) continue;
    lines.push(`${k}: ${k === "description" ? y(fm[k]) : fm[k]}`);
  }
  return `---\n${lines.join("\n")}\n---\n\n${role.body}\n`;
}

function emitAgentsMd(cfg, S, alwaysRules, roles, skills, commands) {
  const note = { vibe: S.mode_note_vibe, standard: S.mode_note_standard, strict: S.mode_note_strict }[cfg.mode] || S.mode_note_vibe;
  const idx = (title, items) => items.length ? `\n## ${title}\n${items.map((i) => `- ${i}`).join("\n")}\n` : "";
  return `<!-- ${S.generated_banner} -->

# ${cfg.project?.name || "Project"} — agent instructions (AGENTS.md)

${note}

${S.session_memory_note}

${alwaysRules.map((r) => r.body).join("\n\n")}
${idx("Roles", roles.map((r) => `**${r.fm.name}** — ${r.fm.description || ""}`))}${idx("Skills", skills.map((s) => `**${s.id}** — ${s.description || ""}`))}${idx("Commands", commands.map((c) => `\`/${c.id}\` — ${c.description || ""}`))}`;
}

function emitClaudeSkill(skill, S) {
  // Agent Skills open standard + Claude extensions. No `paths` (not a skill field).
  const fm = [`# ${S.generated_banner}`, `name: ${y(skill.name)}`];
  if (skill.description) fm.push(`description: ${y(skill.description)}`);
  // allowed-tools ONLY from pre-approved tools — never auto-promote requestedTools.
  const preApproved = skill.gov?.permissions?.preApprovedTools || [];
  if (preApproved.length) fm.push(`allowed-tools: ${preApproved.join(", ")}`);
  if (skill.gov?.invocation?.implicit === false) fm.push("disable-model-invocation: true");
  if (skill.user_invocable === false) fm.push("user-invocable: false");
  return `---\n${fm.join("\n")}\n---\n\n${skill.body}\n`;
}

function emitSettings(cfg, S) {
  const hookCmd = (f) => `node "\${CLAUDE_PROJECT_DIR}/.kit/hooks/${f}"`;
  const settings = {
    $schema: "https://json.schemastore.org/claude-code-settings.json",
    _generated: S.generated_banner,
    permissions: { deny: denyFromGuardrails(cfg) },
    hooks: {
      SessionStart: [{ hooks: [{ type: "command", command: hookCmd("session-start.mjs") }] }],
      PreToolUse: [
        { matcher: "Bash", hooks: [{ type: "command", command: hookCmd("guard-shell.mjs") }] },
        { matcher: "Write|Edit", hooks: [{ type: "command", command: hookCmd("consistency-guard.mjs") }] },
      ],
    },
  };
  return JSON.stringify(settings, null, 2) + "\n";
}

function emitCopilotRepo(cfg, S, alwaysRules) {
  const body = alwaysRules.map((r) => r.body).join("\n\n");
  return `<!-- ${S.generated_banner} -->\n\n# ${cfg.project?.name || "Project"} — Copilot instructions\n\n${S.claude_intro}\n\n${body}\n`;
}
function emitCopilotInstruction(rule, S) {
  return `---\n# ${S.generated_banner}\napplyTo: "${(rule.paths || []).join(",")}"\n---\n\n${rule.body}\n`;
}

function emitClaudeCommand(cmd, S) {
  const fm = [`# ${S.generated_banner}`];
  if (cmd.description) fm.push(`description: ${y(cmd.description)}`);
  if (cmd["argument-hint"]) fm.push(`argument-hint: ${y(cmd["argument-hint"])}`);
  return `---\n${fm.join("\n")}\n---\n\n${cmd.body}\n`;
}
function emitCursorCommand(cmd, S) {
  return `<!-- ${S.generated_banner} -->\n\n${cmd.body}\n`;
}

// Enforcement note so a human reading the artifact knows whether it is advisory.
const invNote = (inv) =>
  (inv.enforcement && inv.enforcement !== "guidance")
    ? `\n\n_(enforcement: ${inv.enforcement})_`
    : "\n\n_SOFT RULE — advisory guidance, not enforced by the kit._";

function emitCursorInvariant(inv, S) {
  const fm = [`# ${S.generated_banner}`, `description: ${y(inv.rule || "")}`, `globs: ${inv.path || "**/*"}`, "alwaysApply: false"];
  return `---\n${fm.join("\n")}\n---\n\n${inv.rule || ""}${invNote(inv)}\n`;
}
function emitWindsurfInvariant(inv, S) {
  // Modern .windsurf/rules format: trigger frontmatter (NOT the legacy XML .windsurfrules).
  const fm = [`# ${S.generated_banner}`, "trigger: glob", `globs: ${inv.path || "**/*"}`];
  return `---\n${fm.join("\n")}\n---\n\n${inv.rule || ""}${invNote(inv)}\n`;
}
function emitWindsurfRule(rule, S) {
  const fmLines = [`# ${S.generated_banner}`];
  if (rule.scope === "paths" && Array.isArray(rule.paths)) {
    fmLines.push("trigger: glob");
    fmLines.push(`globs: ${rule.paths.join(",")}`);
  } else {
    fmLines.push("trigger: always_on");
  }
  return `---\n${fmLines.join("\n")}\n---\n\n${rule.body}\n`;
}

// ---- transformers (one class per IDE target) ------------------------------
// Each emit() returns an array of [relativePath, content] pairs.
class Emitter {
  constructor(ctx) { this.ctx = ctx; }
  emit() { return []; }
}

class AgentsMdEmitter extends Emitter {
  emit() {
    const { cfg, S, alwaysRules, roles, skills, commands } = this.ctx;
    return [["AGENTS.md", emitAgentsMd(cfg, S, alwaysRules, roles, skills, commands)]];
  }
}

class ClaudeEmitter extends Emitter {
  emit() {
    const { cfg, S, rules, roles, commands, skills } = this.ctx;
    const out = [["CLAUDE.md", emitClaudeMd(cfg, S)]];
    for (const r of rules) out.push([`.claude/rules/${r.id}.md`, emitClaudeRule(r, S)]);
    for (const role of roles) out.push([`.claude/agents/${role.fm.name}.md`, emitAgent(role, S)]);
    for (const c of commands) out.push([`.claude/commands/${c.id}.md`, emitClaudeCommand(c, S)]);
    for (const s of skills) {
      out.push([`.claude/skills/${s.id}/SKILL.md`, emitClaudeSkill(s, S)]);
      // Bundle supporting resources (scripts/references/assets); tests/ is never emitted.
      for (const sup of s.supporting) out.push([`.claude/skills/${s.id}/${sup.rel}`, readFileSync(sup.abs, "utf8")]);
    }
    out.push([".claude/settings.json", emitSettings(cfg, S)]);
    return out;
  }
}

class CursorEmitter extends Emitter {
  emit() {
    const { S, rules, commands, skills, invariants } = this.ctx;
    const out = [];
    for (const r of rules) out.push([`.cursor/rules/${r.id}.mdc`, emitCursorRule(r, S)]);
    for (const c of commands) out.push([`.cursor/commands/${c.id}.md`, emitCursorCommand(c, S)]);
    // Cursor has no model-invoked skills → expose each skill as a command too.
    for (const s of skills) out.push([`.cursor/commands/${s.id}.md`, emitCursorCommand({ body: s.body }, S)]);
    invariants.forEach((inv, i) => out.push([`.cursor/rules/${invName(inv, i)}.mdc`, emitCursorInvariant(inv, S)]));
    return out;
  }
}

class CopilotEmitter extends Emitter {
  emit() {
    const { cfg, S, rules } = this.ctx;
    const always = rules.filter((r) => r.scope !== "paths");
    const scoped = rules.filter((r) => r.scope === "paths");
    const out = [[".github/copilot-instructions.md", emitCopilotRepo(cfg, S, always)]];
    for (const r of scoped) out.push([`.github/instructions/${r.id}.instructions.md`, emitCopilotInstruction(r, S)]);
    return out;
  }
}

class WindsurfEmitter extends Emitter {
  emit() {
    const { S, rules, invariants } = this.ctx;
    const out = [];
    for (const r of rules) out.push([`.windsurf/rules/${r.id}.md`, emitWindsurfRule(r, S)]);
    invariants.forEach((inv, i) => out.push([`.windsurf/rules/${invName(inv, i)}.md`, emitWindsurfInvariant(inv, S)]));
    return out;
  }
}

// Registry — key order defines emit order (matches the original fixed order).
export const EMITTERS = {
  agentsmd: AgentsMdEmitter,
  claude: ClaudeEmitter,
  cursor: CursorEmitter,
  copilot: CopilotEmitter,
  windsurf: WindsurfEmitter,
};

// Build the full output map for a config. Pure: returns Map<relPath, content>.
export function buildOutputs(cfg, { kitDir = DEFAULT_KIT_DIR } = {}) {
  const S = loadStrings(kitDir, cfg.project?.language || "en");
  const rules = collectRules(kitDir, cfg);
  const roles = collectRoles(kitDir);
  const commands = collectCommands(kitDir);
  const skills = collectSkills(kitDir);
  const alwaysRules = rules.filter((r) => r.scope !== "paths");
  const invariants = collectInvariants(kitDir, cfg);
  const ctx = { cfg, S, rules, roles, commands, skills, alwaysRules, invariants };

  const targets = new Set(cfg.agents || ["claude"]);
  const out = new Map();
  for (const agent of Object.keys(EMITTERS)) {
    if (!targets.has(agent)) continue;
    for (const [rel, content] of new EMITTERS[agent](ctx).emit()) out.set(rel, content);
  }
  return out;
}
