// Minimal zero-dependency YAML subset parser.
// Supports: nested maps (2-space indent), block lists (scalars & maps),
// inline empty [], quoted/unquoted scalars, booleans, numbers, comments.
// Sufficient for kit.config.yaml, profile.yaml, i18n strings, and md frontmatter.

function stripComment(line) {
  // Remove a trailing "# ..." comment, but not a '#' inside a quoted scalar.
  // A comment '#' must be at line start or preceded by whitespace.
  if (line.trimStart().startsWith("#")) return "";
  let quote = null;
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (quote) { if (c === quote) quote = null; }
    else if (c === '"' || c === "'") quote = c;
    else if (c === "#" && (i === 0 || /\s/.test(line[i - 1]))) return line.slice(0, i);
  }
  return line;
}

function indentOf(l) { return l.length - l.trimStart().length; }

function scalar(v) {
  v = v.trim();
  if (v === "" ) return null;
  if (v === "[]") return [];
  if (v === "{}") return {};
  if (v.length >= 2 && v.startsWith('"') && v.endsWith('"'))
    return v.slice(1, -1).replace(/\\(["\\/])/g, "$1").replace(/\\n/g, "\n").replace(/\\t/g, "\t");
  if (v.length >= 2 && v.startsWith("'") && v.endsWith("'"))
    return v.slice(1, -1).replace(/''/g, "'"); // YAML single-quote: '' -> '
  if (v === "true") return true;
  if (v === "false") return false;
  if (v === "null" || v === "~") return null;
  if (/^-?\d+$/.test(v)) return parseInt(v, 10);
  if (/^-?\d*\.\d+$/.test(v)) return parseFloat(v);
  return v;
}

function isKV(s) { return /^[^:\s"'][^:]*:(\s|$)/.test(s) || /^"[^"]+":(\s|$)/.test(s); }

function assignInline(map, content) {
  const ci = content.indexOf(":");
  const key = content.slice(0, ci).trim().replace(/^["']|["']$/g, "");
  const rest = content.slice(ci + 1).trim();
  map[key] = rest === "" ? null : scalar(rest);
}

function parseNode(lines, idx, indent) {
  if (idx >= lines.length) return [null, idx];
  const firstIndent = indentOf(lines[idx]);
  if (firstIndent < indent) return [null, idx];

  if (lines[idx].trim().startsWith("- ")) {
    const arr = [];
    while (idx < lines.length) {
      const l = lines[idx];
      if (indentOf(l) !== firstIndent || !l.trim().startsWith("- ")) break;
      const content = l.trim().slice(2);
      if (content === "") {
        const [v, ni] = parseNode(lines, idx + 1, firstIndent + 1);
        arr.push(v); idx = ni;
      } else if (isKV(content)) {
        const map = {}; assignInline(map, content); idx++;
        const [more, ni] = parseNode(lines, idx, firstIndent + 2);
        if (more && typeof more === "object" && !Array.isArray(more)) { Object.assign(map, more); idx = ni; }
        arr.push(map);
      } else { arr.push(scalar(content)); idx++; }
    }
    return [arr, idx];
  }

  const map = {};
  while (idx < lines.length) {
    const l = lines[idx];
    const ind = indentOf(l);
    if (ind < firstIndent) break;
    if (ind > firstIndent) { idx++; continue; }
    if (l.trim().startsWith("- ")) break;
    const t = l.trim();
    const ci = t.indexOf(":");
    if (ci === -1) { idx++; continue; }
    const key = t.slice(0, ci).trim().replace(/^["']|["']$/g, "");
    const rest = t.slice(ci + 1).trim();
    idx++;
    if (rest === "") {
      const [v, ni] = parseNode(lines, idx, firstIndent + 1);
      map[key] = v; idx = ni;
    } else {
      map[key] = scalar(rest);
    }
  }
  return [map, idx];
}

export function parseYaml(text) {
  const lines = text.split(/\r?\n/).map(stripComment).filter((l) => l.trim() !== "");
  const [val] = parseNode(lines, 0, 0);
  return val || {};
}

export function parseFrontmatter(text) {
  const m = text.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?([\s\S]*)$/);
  if (!m) return { fm: {}, body: text };
  return { fm: parseYaml(m[1]), body: m[2] };
}
