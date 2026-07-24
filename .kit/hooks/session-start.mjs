#!/usr/bin/env node
// SessionStart hook. Injects Constitution + Decision Log + Domain brief + ACTIVE WORK
// (current task + latest handoff) so each new session continues the recorded direction
// instead of inventing a new one from chat memory.
import { readFileSync, rmSync, readdirSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";
import { projectDir, currentTaskId } from "./_lib.mjs";

// Reset the pre-build critique gate each session: the first code write of a new session
// must go through a fresh critique (trụ cột #2). Best-effort — never throw at startup.
try { rmSync(join(projectDir, ".kit", "state", "gate.json"), { force: true }); } catch { /* best-effort */ }

function read(p, max) {
  try {
    const t = readFileSync(join(projectDir, p), "utf8");
    return max && t.length > max ? t.slice(0, max) + "\n…(truncated)" : t;
  } catch { return null; }
}

function listTaskFiles() {
  try {
    return readdirSync(join(projectDir, ".kit", "tasks"))
      .filter((f) => f.endsWith(".md") && !f.endsWith("-handoff.md"));
  } catch { return []; }
}

/** Prefer .kit/state/current-task; else newest task file marked in-progress. */
function resolveActiveTaskId() {
  const pinned = currentTaskId(projectDir);
  if (pinned) {
    const rel = `.kit/tasks/${pinned}.md`;
    if (existsSync(join(projectDir, rel))) return pinned;
  }
  let best = null;
  let bestMtime = 0;
  for (const f of listTaskFiles()) {
    const rel = `.kit/tasks/${f}`;
    const body = read(rel, 2000) || "";
    if (!/\*\*Status:\*\*[^\n]*in-progress/i.test(body) && !/Status:\s*in-progress/i.test(body)) continue;
    try {
      const m = statSync(join(projectDir, rel)).mtimeMs;
      if (m >= bestMtime) { bestMtime = m; best = f.replace(/\.md$/, ""); }
    } catch { /* skip */ }
  }
  return best;
}

function resolveHandoffRel(taskId) {
  if (taskId) {
    const preferred = `.kit/tasks/${taskId}-handoff.md`;
    if (existsSync(join(projectDir, preferred))) return preferred;
  }
  try {
    const hands = readdirSync(join(projectDir, ".kit", "tasks"))
      .filter((f) => f.endsWith("-handoff.md"));
    let best = null;
    let bestMtime = 0;
    for (const f of hands) {
      const m = statSync(join(projectDir, ".kit", "tasks", f)).mtimeMs;
      if (m >= bestMtime) { bestMtime = m; best = `.kit/tasks/${f}`; }
    }
    return best;
  } catch { return null; }
}

const parts = [];

parts.push(
  "=== SESSION CONTINUITY (do not invent a new product direction) ===\n" +
  "Source of truth is FILES under .kit/, not prior chat. Obey Constitution + Decision Log + " +
  "Domain brief + ACTIVE TASK scope (In/Out). If the user's ask conflicts with recorded " +
  "direction or task Out-of-scope, STOP and confirm before coding. Mid-feature pickup → /resume. " +
  "Do not re-litigate decided choices; do not expand scope silently."
);

const constitution = read(".kit/constitution.md", 4000);
if (constitution) parts.push("=== PROJECT CONSTITUTION (obey this) ===\n" + constitution);
const decisions = read(".kit/decisions.md", 8000);
if (decisions) parts.push("=== DECISION LOG (stay consistent with this) ===\n" + decisions);

// Team option: one file per decision under .kit/decisions/ (ADR-per-file) avoids the
// merge conflicts a shared append-only decisions.md causes. Inject the most recent ones
// (bounded, so context stays lean). Absent dir → nothing to do.
try {
  const files = readdirSync(join(projectDir, ".kit", "decisions")).filter((f) => f.endsWith(".md")).sort();
  const recent = files.slice(-30); // ADR files sort chronologically (NNNN-slug.md)
  const adrs = recent.map((f) => read(join(".kit", "decisions", f), 1500)).filter(Boolean);
  if (adrs.length) {
    const more = files.length > recent.length ? `\n…(${files.length - recent.length} older records not shown)` : "";
    parts.push("=== DECISION RECORDS (.kit/decisions/) ===\n" + adrs.join("\n\n") + more);
  }
} catch { /* no per-file decisions dir → fine */ }

// Domain brief = cached smart research for this app type. Reuse it; do not re-crawl
// unless the domain-research skill's refresh triggers fire.
const domainBrief = read(".kit/domain-brief.md", 4000);
if (domainBrief && !/<!--\s*what we are building/i.test(domainBrief)) {
  parts.push("=== DOMAIN BRIEF (reuse — do not re-research every reply) ===\n" + domainBrief);
} else if (domainBrief) {
  parts.push("=== DOMAIN BRIEF (template only — run domain-research when app direction is clear) ===\n" + domainBrief.slice(0, 800));
}

const activeId = resolveActiveTaskId();
if (activeId) {
  const taskBody = read(`.kit/tasks/${activeId}.md`, 6000);
  if (taskBody) {
    parts.push(
      `=== ACTIVE TASK (.kit/tasks/${activeId}.md — continue THIS; respect In/Out) ===\n` + taskBody
    );
  } else {
    parts.push(
      `=== ACTIVE TASK id=${activeId} ===\nFile missing — clear or fix .kit/state/current-task, or run /task.`
    );
  }
} else {
  parts.push(
    "=== ACTIVE TASK ===\nNone pinned. For non-trivial work open /task (writes .kit/state/current-task) " +
    "so the next session resumes the same scope. Casual Q&A needs no task."
  );
}

const handoffRel = resolveHandoffRel(activeId);
if (handoffRel) {
  const handoff = read(handoffRel, 4000);
  if (handoff) {
    parts.push(
      `=== LATEST HANDOFF (${handoffRel} — what was already delivered / pending approval) ===\n` + handoff
    );
  }
}

const additionalContext = parts.length
  ? parts.join("\n\n")
  : "No Constitution/Decision Log yet. If starting real work, create .kit/constitution.md from the template and record decisions in .kit/decisions.md. When the app direction is clear, run the domain-research skill to fill .kit/domain-brief.md. Use /task for resumable work.";

process.stdout.write(JSON.stringify({
  hookSpecificOutput: { hookEventName: "SessionStart", additionalContext },
}));
process.exit(0);
