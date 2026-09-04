import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptsDirectory = path.dirname(fileURLToPath(import.meta.url));
const repositoryDirectory = path.resolve(scriptsDirectory, "../..");
const settingsPath = path.join(repositoryDirectory, "pi/settings.json");
const settings = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
const overrides = settings.subagents?.agentOverrides ?? {};
const enabledModels = new Set(settings.enabledModels ?? []);
const reviewerRoles = ["reviewer-sol", "reviewer-grok", "reviewer-fable", "reviewer-terra"];
const candidateRoles = ["candidate-sol", "candidate-grok", "candidate-fable", "candidate-terra"];

function requireCondition(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function requireConfiguredRole(role) {
  const config = overrides[role];
  requireCondition(config !== undefined, `Missing settings override for ${role}`);
  requireCondition(typeof config.model === "string", `Missing model for ${role}`);
  requireCondition(enabledModels.has(config.model), `${role} model is not enabled: ${config.model}`);
  requireCondition(config.defaultContext === "fresh", `${role} must use fresh context`);
  requireCondition(
    Array.isArray(config.fallbackModels) && config.fallbackModels.length === 0,
    `${role} must disable fallback models`,
  );
  const agentPath = path.join(repositoryDirectory, `skills/ppstack/agents/${role}.md`);
  requireCondition(fs.existsSync(agentPath), `Missing agent profile: ${agentPath}`);
}

function requireRoleMentions(relativePath, roles) {
  const filePath = path.join(repositoryDirectory, relativePath);
  const content = fs.readFileSync(filePath, "utf8");
  for (const role of roles) {
    requireCondition(content.includes(`\`${role}\``), `${relativePath} does not route ${role}`);
  }
}

function requireReadOnlyReviewer(role) {
  const agentPath = path.join(repositoryDirectory, `skills/ppstack/agents/${role}.md`);
  const content = fs.readFileSync(agentPath, "utf8");
  const tools = content.match(/^tools: (.+)$/m)?.[1] ?? "";
  for (const mutationTool of ["bash", "edit", "write"]) {
    requireCondition(!tools.split(", ").includes(mutationTool), `${role} exposes ${mutationTool}`);
  }
}

for (const role of [...reviewerRoles, ...candidateRoles]) {
  requireConfiguredRole(role);
}

requireCondition(
  new Set(reviewerRoles.map((role) => overrides[role].model)).size === reviewerRoles.length,
  "Reviewer roles must resolve to distinct model selectors",
);

for (const role of reviewerRoles) {
  requireReadOnlyReviewer(role);
}

for (const suffix of ["sol", "grok", "fable", "terra"]) {
  requireCondition(
    overrides[`reviewer-${suffix}`].model === overrides[`candidate-${suffix}`].model,
    `Reviewer and candidate ${suffix} roles must use the same model selector`,
  );
}

requireRoleMentions("skills/ppstack/skills/reflect/SKILL.md", [
  "reviewer-sol",
  "reviewer-grok",
  "reviewer-fable",
]);
requireRoleMentions("skills/ppstack/skills/how/SKILL.md", [
  "reviewer-sol",
  "reviewer-grok",
  "reviewer-fable",
]);
requireRoleMentions("skills/ppstack/skills/interrogate/SKILL.md", [
  "reviewer-sol",
  "reviewer-grok",
  "reviewer-fable",
]);
requireRoleMentions("skills/ppstack/skills/peer-review/SKILL.md", ["reviewer-*"]);
requireRoleMentions("skills/ppstack/skills/arena/SKILL.md", ["candidate-sol", "candidate-grok", "candidate-fable", "candidate-terra"]);

console.log("Model-diverse reviewer and candidate routing is consistent.");
