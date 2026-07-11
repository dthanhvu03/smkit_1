#!/usr/bin/env node
// smkit — thin dispatcher: `smkit <init|build|check|doctor> [args]`.
// Delegates to init.mjs / kitgen.mjs (which resolve PROJECT_DIR from cwd/CLAUDE_PROJECT_DIR).
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const [cmd, ...rest] = process.argv.slice(2);
const run = (file, args) => spawnSync(process.execPath, [join(HERE, file), ...args], { stdio: "inherit" });

let r;
switch (cmd) {
  case "init": r = run("init.mjs", rest); break;
  case "build":
  case "check":
  case "doctor": r = run("kitgen.mjs", [cmd, ...rest]); break;
  default:
    console.log("Usage: smkit <init|build|check|doctor> [options]\n" +
      "  init    set up the kit in this project (interview or --flags)\n" +
      "  build   regenerate agent config from the source\n" +
      "  check   fail if generated files are out of sync (CI)\n" +
      "  doctor  health-check the kit + generated output");
    process.exit(cmd && cmd !== "help" && cmd !== "--help" ? 1 : 0);
}
process.exit(r.status ?? 1);
