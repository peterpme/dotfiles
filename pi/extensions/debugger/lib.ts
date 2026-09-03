import { appendFile, readFile } from "node:fs/promises";

export const HEADER = "ts\tkind\tproblem\tfix\tstatus\ttarget\ttrace";

export const KINDS = [
	"model-call",
	"tool",
	"missing-file",
	"wrong-assumption",
	"correction",
	"wrong-path",
	"drift",
	"leftover",
] as const;
export type Kind = (typeof KINDS)[number];

export const STATUSES = ["open", "fixed", "leftover"] as const;
export type Status = (typeof STATUSES)[number];

export type Row = {
	ts: string;
	kind: Kind;
	problem: string;
	fix: string;
	status: Status;
	target: string;
	trace: string;
};

export type Finding = Pick<Row, "kind" | "problem" | "fix" | "status" | "target">;

export type ToolResultLike = {
	toolName: string;
	input: unknown;
	content: unknown;
	isError?: boolean;
};

const NOISY_COMMAND = /^\s*(rg|grep|fd|find|ls|test|\[|diff|cmp|which|command\s+-v|git\s+diff)\b/;
const MAX_PROBLEM_CHARS = 240;

export function problemsPath(sessionFile: string): string {
	const base = sessionFile.endsWith(".jsonl") ? sessionFile.slice(0, -".jsonl".length) : sessionFile;
	return `${base}.problems.tsv`;
}

export function cell(value: string): string {
	const flat = value.replace(/[\t\n\r]+/g, " ").trim();
	if (flat === "" || flat === "-") return "-";
	return /^[=+\-@]/.test(flat) ? `'${flat}` : flat;
}

export function formatRow(row: Row): string {
	return [row.ts, row.kind, cell(row.problem), cell(row.fix), row.status, cell(row.target), cell(row.trace)].join("\t");
}

export function textOf(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	return content
		.map((part) => (part && typeof part === "object" && "text" in part ? String((part as { text: unknown }).text) : ""))
		.join("\n");
}

function firstLine(text: string): string {
	const line = text.split("\n").find((l) => l.trim().length > 0) ?? "";
	return line.trim().slice(0, MAX_PROBLEM_CHARS);
}

function truncate(text: string, max: number): string {
	return text.length > max ? `${text.slice(0, max - 3)}...` : text;
}

export function classifyToolResult(event: ToolResultLike): Finding | null {
	const text = textOf(event.content);
	const input = (event.input ?? {}) as Record<string, unknown>;

	if (event.toolName === "bash") {
		if (!event.isError) return null;
		const command = String(input.command ?? "").trim();
		if (NOISY_COMMAND.test(command)) return null;
		return {
			kind: "tool",
			problem: `bash failed: ${truncate(command, 120)} :: ${firstLine(text)}`,
			fix: "-",
			status: "open",
			target: "-",
		};
	}

	if (event.toolName === "read") {
		if (!event.isError) return null;
		return {
			kind: "missing-file",
			problem: `read ${String(input.path ?? "?")}: ${firstLine(text)}`,
			fix: "-",
			status: "open",
			target: "-",
		};
	}

	if (event.toolName === "subagent") {
		if (!event.isError && !/"ok":\s*false/.test(text)) return null;
		return {
			kind: "model-call",
			problem: `subagent: ${firstLine(text)}`,
			fix: "-",
			status: "open",
			target: "-",
		};
	}

	return null;
}

export function dedupeKey(finding: Finding): string {
	return `${finding.kind} ${finding.problem}`;
}

export async function appendRow(path: string, row: Row): Promise<void> {
	let prefix = `${HEADER}\n`;
	try {
		const current = await readFile(path, "utf8");
		if (current.length > 0) prefix = current.endsWith("\n") ? "" : "\n";
	} catch {
		prefix = `${HEADER}\n`;
	}
	await appendFile(path, `${prefix}${formatRow(row)}\n`, { mode: 0o600 });
}
