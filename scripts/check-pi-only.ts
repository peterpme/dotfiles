#!/usr/bin/env bun

import { execFileSync } from "node:child_process";
import { existsSync, lstatSync, readFileSync, readlinkSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const ppstackRoot = join(root, "skills", "ppstack");
const settingsPath = join(root, "pi", "settings.json");
const liveSettingsPath = join(homedir(), ".pi", "agent", "settings.json");
const allowedHistory = new Set([
  "skills/ppstack/docs/cursor-history.md",
  "skills/ppstack/docs/pi-only-migration-plan.md",
]);

function workingTreeFiles() {
  return execFileSync(
    "git",
    ["ls-files", "--cached", "--others", "--exclude-standard", "-z"],
    { cwd: root },
  )
    .toString()
    .split("\0")
    .filter(Boolean);
}

function lines(text) {
  return text.split(/\r?\n/);
}

const violations = [];
function report(file, line, message) {
  violations.push({ file, line, message });
}

const activeFiles = workingTreeFiles().filter(
  (file) =>
    (file.startsWith("skills/ppstack/") || file.startsWith("skills/setup-petey/")) &&
    !allowedHistory.has(file),
);
const isActiveSkill = (file) =>
  file.startsWith("skills/ppstack/skills/") || file.startsWith("skills/setup-petey/");
const bannedTerms = [
  [/(?:^|\W)cursor(?:$|\W)/i, "legacy runtime term"],
  [/\bTask\b/, "legacy task tool"],
  [/subagent_type/, "legacy agent selector"],
  [/pstack-models\.mdc/, "deleted model selector"],
  [/\.agents\/skills|\.claude\/skills|\.cursor\/skills/, "non-Pi skill path"],
  [/cursor-team-kit|control-ui|control-cli/, "unavailable control dependency"],
  [/(?:^|\s)\/loop\b/, "legacy loop command"],
  [/references\/(?:spawn|models)\.md/, "deleted Petey reference"],
  [/sticky mode|^mode:\s*true\s*$/i, "unsupported sticky mode"],
  [/\bagent\s*:\s*["']?(?:explorer|search)["']?/, "retired duplicate agent call"],
];
const modelId = /(?:xai|openai(?:-codex)?|opencode|peter@backpack\.app|services\+openai@peterp\.me)\/[A-Za-z0-9._@+-]+/;
const perRunModel = /\bmodel\s*:/;

for (const file of activeFiles) {
  const fullPath = join(root, file);
  if (!existsSync(fullPath) || lstatSync(fullPath).isDirectory()) continue;
  const content = readFileSync(fullPath, "utf8");
  lines(content).forEach((lineText, index) => {
    for (const [pattern, message] of bannedTerms) {
      if (pattern.test(lineText)) report(file, index + 1, message);
    }
    if (isActiveSkill(file) && modelId.test(lineText)) report(file, index + 1, "model identifier in active skill");
    if (isActiveSkill(file) && perRunModel.test(lineText)) report(file, index + 1, "per-run model selector in active skill");
  });

  if (file.startsWith("skills/ppstack/agents/") && content.startsWith("---\n")) {
    const end = content.indexOf("\n---", 4);
    const frontmatter = content.slice(4, end < 0 ? content.length : end);
    lines(frontmatter).forEach((lineText, index) => {
      if (/^(?:model|thinking|defaultContext)\s*:/.test(lineText)) report(file, index + 2, "agent frontmatter duplicates a settings-owned routing field");
    });
  }
}

for (const deletedPath of [
  "skills/ppstack/.cursor-plugin",
  "skills/ppstack/agents/explorer.md",
  "skills/ppstack/agents/search.md",
  "skills/ppstack/skills/petey/references/spawn.md",
  "skills/ppstack/skills/petey/references/models.md",
  "skills/ppstack/skills/petey-debug",
  "skills/ppstack/PETEY-LOG.md",
  "skills/ppstack/traces",
]) {
  if (existsSync(join(root, deletedPath))) report(deletedPath, 1, "deleted path still exists");
}

for (const requiredPath of [
  "docs/typescript-automation.md",
  "pi/extensions/petey-debug.ts",
  "scripts/check-typescript-automation.ts",
  "skills/ppstack/debug/.gitignore",
  "skills/ppstack/debug/README.md",
]) {
  if (!existsSync(join(root, requiredPath))) report(requiredPath, 1, "required Pi-only file is missing");
}

try {
  execFileSync("bun", ["run", "scripts/check-typescript-automation.ts"], { cwd: root, stdio: "pipe" });
} catch {
  report("scripts/check-typescript-automation.ts", 1, "TypeScript automation check failed");
}

const trackedSettingsSelectors = workingTreeFiles().filter((file) => /(?:^|\/)pi\/settings\.json$/.test(file));
const settingsSelectors = new Set(trackedSettingsSelectors);
if (existsSync(settingsPath)) settingsSelectors.add("pi/settings.json");
if (settingsSelectors.size !== 1) report("pi/settings.json", 1, `expected one Pi settings selector, found ${settingsSelectors.size}`);

if (!existsSync(settingsPath)) report("pi/settings.json", 1, "canonical settings file is missing");
if (!existsSync(liveSettingsPath) && !lstatSafe(liveSettingsPath)) {
  report(relative(root, liveSettingsPath), 1, "live Pi settings symlink is missing");
} else if (!lstatSync(liveSettingsPath).isSymbolicLink()) {
  report(relative(root, liveSettingsPath), 1, "live Pi settings is not a symlink");
} else {
  const target = resolve(dirname(liveSettingsPath), readlinkSync(liveSettingsPath));
  if (target !== settingsPath) report(relative(root, liveSettingsPath), 1, `live Pi settings points to ${target}`);
}

function lstatSafe(path) {
  try {
    return lstatSync(path);
  } catch {
    return undefined;
  }
}

violations.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line || a.message.localeCompare(b.message));
for (const violation of violations) console.error(`${violation.file}:${violation.line}: ${violation.message}`);
if (violations.length) {
  console.error(`Pi-only check failed with ${violations.length} violation(s).`);
  process.exit(1);
}
console.log(`Pi-only check passed for ${activeFiles.length} active working-tree files.`);
