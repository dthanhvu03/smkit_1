// Shared helpers for the kit hooks. Kept dependency-light so a hook never
// crashes (and thus silently disables itself) just because an import failed.
import { readFileSync, appendFileSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";

// The project the hooks act on. Claude Code passes CLAUDE_PROJECT_DIR; fall back
// to the repo that contains this hook (…/.kit/hooks/_lib.mjs → repo root).
export const projectDir = process.env.CLAUDE_PROJECT_DIR
  || join(dirname(fileURLToPath(import.meta.url)), "..", "..");

// Parse kit.config.yaml, returning {} on any failure. The YAML parser is loaded
// via dynamic import so a missing/moved parser degrades gracefully (the caller
// falls back to its own safe defaults) instead of throwing at module load.
export async function loadConfig() {
  try {
    // Vendored copy so .kit/ is self-contained (no reach into tools/); kept in
    // sync with tools/kitgen/yaml.mjs by the generator + checked by `doctor`.
    const { parseYaml } = await import("./yaml.mjs");
    return parseYaml(readFileSync(join(projectDir, "kit.config.yaml"), "utf8")) || {};
  } catch {
    return {};
  }
}

// Always-enforced destructive-command blocklist (fail-closed baseline).
export const DEFAULT_BLOCK = [
  "rm -rf /", "rm -rf ~", "rm -rf *",
  "git push --force", "git push -f", "git reset --hard",
  "DROP TABLE", "DROP DATABASE", "TRUNCATE", "DELETE FROM",
  "docker compose down -v", "docker volume rm", "docker volume prune",
  "docker system prune --volumes",
];

// Matcher for one blocklist entry: whitespace-flexible, case-insensitive, and
// bounded so "--force" does not match "--force-with-lease".
export function makeMatcher(pattern) {
  const esc = pattern.trim().replace(/[.*+?^${}()|[\]\\]/g, "\\$&").replace(/\s+/g, "\\s+");
  return new RegExp(`(?<![\\w-])${esc}(?![\\w-])`, "i");
}

// Returns the matched pattern (truthy) or undefined.
export function matchesBlock(cmd, list) {
  return list.find((p) => makeMatcher(p).test(cmd));
}

// Full blocklist = built-in defaults + config block + allow_extra (deduped).
export async function loadBlocklist() {
  const g = (await loadConfig()).guardrails || {};
  return [...new Set([...DEFAULT_BLOCK, ...(g.block || []), ...(g.allow_extra || [])])];
}

// ---- Guard v2: segment split, path-boundary, classification ---------------
// NOTE: this is operator-level tokenization, NOT a full shell parser. It closes
// chaining/path-escape/audit gaps for honest mistakes; it is NOT isolation.

// Split a command into top-level segments on ; | & && || and newlines,
// respecting single/double quotes. Returns trimmed non-empty segments.
export function splitSegments(cmd) {
  const segs = [];
  let cur = "", quote = null;
  for (let i = 0; i < cmd.length; i++) {
    const c = cmd[i];
    if (quote) { cur += c; if (c === quote) quote = null; continue; }
    if (c === '"' || c === "'") { quote = c; cur += c; continue; }
    if (c === ";" || c === "\n" || c === "|" || c === "&") {
      segs.push(cur); cur = "";
      if ((c === "|" || c === "&") && cmd[i + 1] === c) i++; // consume second of || &&
      continue;
    }
    cur += c;
  }
  segs.push(cur);
  return segs.map((s) => s.trim()).filter(Boolean);
}

function tokenize(seg) {
  const out = []; let cur = "", quote = null;
  for (const c of seg) {
    if (quote) { if (c === quote) quote = null; else cur += c; continue; }
    if (c === '"' || c === "'") { quote = c; continue; }
    if (/\s/.test(c)) { if (cur) { out.push(cur); cur = ""; } continue; }
    cur += c;
  }
  if (cur) out.push(cur);
  return out;
}

const EMBEDDED = /\$\(|`|<<|\b(?:bash|sh|zsh|node|python|python3|ruby|perl)\s+-\w*(?:c|e)\b/;
const NET = /\b(?:curl|wget|fetch)\b/;
const EXEC_SINK = /\|\s*(?:sudo\s+)?(?:bash|sh|zsh|node|python|python3|ruby|perl)\b/;
const WRITE_VERB = /^(?:rm|rmdir|mv|dd|shred|truncate|chmod|chown|cp|ln)$/;
const DB_CLIENTS = /^(?:psql|mysql|mysqldump|sqlite3|mongo|mongosh|redis-cli|cockroach|clickhouse-client)$/;

const ZERO_ACCESS = [/(^|\/)\.ssh(\/|$)/, /(^|\/)\.aws(\/|$)/, /(^|\/)\.gnupg(\/|$)/,
  /(^|\/)\.env(\.|$|\/)/, /(^|\/)\.git(\/|$)/, /(^|\/)\.kit(\/|$)/, /(^|\/)id_rsa(\b|$)/];

function expandTilde(p, home) { return p.startsWith("~") ? home + p.slice(1) : p; }

export function pathTier(raw, projDir, home = homedir()) {
  const abs = resolve(projDir, expandTilde(raw, home)).replace(/\\/g, "/");
  const proj = resolve(projDir).replace(/\\/g, "/");
  if (ZERO_ACCESS.some((re) => re.test(abs))) return "zeroAccess";
  if (abs !== proj && !abs.startsWith(proj + "/")) return "outsideWorkspace";
  return "workspace";
}

function pathArgs(tokens) {
  return tokens.slice(1).filter((t) =>
    !t.startsWith("-") && (/[~/]/.test(t) || /^\.?(env|ssh|aws|gnupg|git)\b/i.test(t)));
}

// Classify a full command → {decision: block|warn|allow, reason, segment}.
export function classifyCommand(cmd, { mode = "vibe", block = DEFAULT_BLOCK, projDir = projectDir } = {}) {
  const segs = splitSegments(cmd);

  // network → exec composition (curl … | sh)
  if (NET.test(cmd) && EXEC_SINK.test(cmd))
    return { decision: "block", reason: "pipes network download into a shell (curl|sh)", segment: cmd };

  let warn = null;
  for (const seg of segs) {
    const tokens = tokenize(seg);
    const verb = (tokens[0] || "").split("/").pop(); // strip path prefix e.g. /bin/rm
    const isDbExec = DB_CLIENTS.test(verb) || /(^|\s)-[ce]\s+['"]/.test(seg) || /--(?:command|execute|eval)\b/.test(seg);

    for (const pat of block) {
      if (!makeMatcher(pat).test(seg)) continue;
      const sqlish = /^[A-Z]/.test(pat.trim()); // e.g. "DROP TABLE", "DELETE FROM"
      if (!sqlish) return { decision: "block", reason: `matches blocked pattern "${pat}"`, segment: seg };
      if (isDbExec) return { decision: "block", reason: `executes destructive SQL "${pat}"`, segment: seg };
      warn = warn || { decision: "warn", reason: `mentions SQL keyword "${pat}" (not clearly executed)`, segment: seg };
    }

    for (const p of pathArgs(tokens)) {
      const tier = pathTier(p, projDir);
      if (tier === "zeroAccess")
        return { decision: "block", reason: `touches protected path "${p}"`, segment: seg };
      if (tier === "outsideWorkspace" && (WRITE_VERB.test(verb) || seg.startsWith(">")))
        return { decision: "block", reason: `writes/deletes outside the workspace ("${p}")`, segment: seg };
    }

    if (EMBEDDED.test(seg)) {
      if (mode === "strict") return { decision: "block", reason: "contains embedded/obfuscated code (strict)", segment: seg };
      warn = warn || { decision: "warn", reason: "contains embedded code — review before trusting", segment: seg };
    }
  }
  return warn || { decision: "allow", reason: "", segment: "" };
}

// Append one JSONL decision line to .kit/audit.log (best-effort; not tamper-evident).
export function auditLog(entry, projDir = projectDir) {
  try { appendFileSync(join(projDir, ".kit", "audit.log"), JSON.stringify(entry) + "\n"); }
  catch { /* best-effort */ }
}
