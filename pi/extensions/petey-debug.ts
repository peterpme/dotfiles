import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { appendFile, mkdir, readFile, writeFile } from "node:fs/promises";
import { homedir } from "node:os";
import { basename, join } from "node:path";

const DEBUG_DIRECTORY = join(homedir(), "dotfiles", "skills", "ppstack", "debug");

type SnapshotResult = {
	path: string;
	bytes: number;
	createdAt: string;
};

function timestamp(date: Date): string {
	return date.toISOString().replaceAll(":", "-").replace(".", "-");
}

function labelSuffix(value: string): string {
	const label = value.trim().toLowerCase().replace(/[^a-z0-9_-]+/g, "-").replace(/^-+|-+$/g, "");
	return label ? `_${label}` : "";
}

async function recordSnapshot(
	result: SnapshotResult,
	sessionId: string,
	label: string,
	debugDirectory: string,
): Promise<void> {
	const peteyLog = join(debugDirectory, "PETEY-LOG.md");
	await appendFile(peteyLog, "", { mode: 0o600 });
	const current = await readFile(peteyLog, "utf8");
	if (current.length === 0) {
		await writeFile(peteyLog, "# PETEY log\n\n", { mode: 0o600 });
	}
	const separator = current.length === 0 || current.endsWith("\n\n") ? "" : current.endsWith("\n") ? "\n" : "\n\n";
	const displayLabel = label.trim() || "unlabeled";
	await appendFile(
		peteyLog,
		`${separator}## ${result.createdAt} Debug capture\n\n- Label: ${displayLabel}\n- Session: ${sessionId}\n- Trace: traces/${basename(result.path)}\n- Status: untriaged\n\n`,
	);
}

export async function saveSessionSnapshot(
	sessionFile: string,
	sessionId: string,
	label: string,
	debugDirectory = DEBUG_DIRECTORY,
): Promise<SnapshotResult> {
	const contents = await readFile(sessionFile);
	const createdAt = new Date();
	const traceDirectory = join(debugDirectory, "traces");
	await mkdir(traceDirectory, { recursive: true, mode: 0o700 });
	const outputPath = join(traceDirectory, `${timestamp(createdAt)}_${sessionId}${labelSuffix(label)}.jsonl`);
	await writeFile(outputPath, contents, { flag: "wx", mode: 0o600 });
	const result = { path: outputPath, bytes: contents.byteLength, createdAt: createdAt.toISOString() };
	await recordSnapshot(result, sessionId, label, debugDirectory);
	return result;
}

export default function peteyDebugExtension(pi: ExtensionAPI): void {
	pi.registerCommand("petey-debug", {
		description: "Save the current Pi session JSONL under ppstack/debug/traces",
		handler: async (args, ctx) => {
			await ctx.waitForIdle();
			const sessionFile = ctx.sessionManager.getSessionFile();
			if (!sessionFile) {
				ctx.ui.notify("petey-debug: this session is not persisted", "error");
				return;
			}

			try {
				const result = await saveSessionSnapshot(sessionFile, ctx.sessionManager.getSessionId(), args);
				ctx.ui.notify(`Saved ${result.bytes} bytes to ${result.path}`, "info");
			} catch (error) {
				const message = error instanceof Error ? error.message : String(error);
				ctx.ui.notify(`petey-debug: ${message}`, "error");
			}
		},
	});
}
