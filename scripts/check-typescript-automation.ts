#!/usr/bin/env bun

import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, extname, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const automationRoots = [join(root, "scripts"), join(root, "pi", "extensions")];
const forbiddenExtensions = new Set([".js", ".mjs", ".cjs"]);
const violations: string[] = [];

function filesUnder(path: string): string[] {
	if (!existsSync(path)) return [];
	const files: string[] = [];
	for (const entry of readdirSync(path, { withFileTypes: true })) {
		if (entry.name === "node_modules" || entry.name === ".git") continue;
		const child = join(path, entry.name);
		if (entry.isDirectory()) files.push(...filesUnder(child));
		else if (entry.isFile()) files.push(child);
	}
	return files;
}

for (const path of automationRoots.flatMap(filesUnder)) {
	if (forbiddenExtensions.has(extname(path))) {
		violations.push(`${relative(root, path)}: automation must be TypeScript`);
	}
}

for (const path of filesUnder(join(root, "scripts"))) {
	if (extname(path) !== ".ts" || statSync(path).size === 0) continue;
	const firstLine = readFileSync(path, "utf8").split(/\r?\n/, 1)[0];
	if (firstLine !== "#!/usr/bin/env bun") {
		violations.push(`${relative(root, path)}: executable TypeScript script must use the Bun shebang`);
	}
}

for (const violation of violations.sort()) console.error(violation);
if (violations.length) process.exit(1);
console.log("TypeScript automation check passed.");
