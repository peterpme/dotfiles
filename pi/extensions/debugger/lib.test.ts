import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { HEADER, appendRow, cell, classifyToolResult, dedupeKey, formatRow, problemsPath, type Row } from "./lib";

test("problems log sits beside the session jsonl", () => {
	expect(problemsPath("/s/2026-09-03T10-00-00Z_abc.jsonl")).toBe("/s/2026-09-03T10-00-00Z_abc.problems.tsv");
	expect(problemsPath("/s/no-extension")).toBe("/s/no-extension.problems.tsv");
});

test("cells stay on one line and cannot become spreadsheet formulas", () => {
	expect(cell("a\tb\nc")).toBe("a b c");
	expect(cell("=HYPERLINK()")).toBe("'=HYPERLINK()");
	expect(cell("-rf everything")).toBe("'-rf everything");
	expect(cell("-")).toBe("-");
	expect(cell("")).toBe("-");
});

test("a row has exactly seven columns", () => {
	const row: Row = { ts: "t", kind: "tool", problem: "p", fix: "-", status: "open", target: "-", trace: "s" };
	expect(formatRow(row).split("\t")).toHaveLength(7);
	expect(HEADER.split("\t")).toHaveLength(7);
});

test("a failed bash command is logged with its command and first error line", () => {
	const finding = classifyToolResult({
		toolName: "bash",
		input: { command: "bun test cart.test.ts" },
		content: [{ type: "text", text: "\n1 fail\nCommand exited with code 1" }],
		isError: true,
	});
	expect(finding?.kind).toBe("tool");
	expect(finding?.problem).toBe("bash failed: bun test cart.test.ts :: 1 fail");
	expect(finding?.status).toBe("open");
});

test("lookups that fail by design and successful commands are not logged", () => {
	expect(classifyToolResult({ toolName: "bash", input: { command: "rg -n foo src" }, content: "", isError: true })).toBeNull();
	expect(classifyToolResult({ toolName: "bash", input: { command: "git diff --quiet" }, content: "", isError: true })).toBeNull();
	expect(classifyToolResult({ toolName: "bash", input: { command: "bun test" }, content: "ok", isError: false })).toBeNull();
});

test("a failed read is a missing-file row and a failed subagent is a model-call row", () => {
	const read = classifyToolResult({ toolName: "read", input: { path: "/x/SKILL.md" }, content: "ENOENT: no such file", isError: true });
	expect(read).toEqual({ kind: "missing-file", problem: "read /x/SKILL.md: ENOENT: no such file", fix: "-", status: "open", target: "-" });
	const sub = classifyToolResult({ toolName: "subagent", input: {}, content: 'Return: {"key":"claude","ok":false,"error":"timed out"}', isError: false });
	expect(sub?.kind).toBe("model-call");
	expect(classifyToolResult({ toolName: "edit", input: {}, content: "nope", isError: true })).toBeNull();
});

test("identical findings share a dedupe key", () => {
	const a = classifyToolResult({ toolName: "bash", input: { command: "make" }, content: "boom", isError: true });
	const b = classifyToolResult({ toolName: "bash", input: { command: "make" }, content: "boom", isError: true });
	expect(dedupeKey(a!)).toBe(dedupeKey(b!));
});

test("appendRow writes the header once and never doubles it", async () => {
	const root = await mkdtemp(join(tmpdir(), "debugger-"));
	try {
		const path = join(root, "s.problems.tsv");
		const row: Row = { ts: "t1", kind: "correction", problem: "p", fix: "f", status: "fixed", target: "skills/x", trace: "sess" };
		await appendRow(path, row);
		await appendRow(path, { ...row, ts: "t2" });
		const lines = (await readFile(path, "utf8")).trimEnd().split("\n");
		expect(lines).toHaveLength(3);
		expect(lines[0]).toBe(HEADER);
		expect(lines.filter((l) => l === HEADER)).toHaveLength(1);
		expect(lines[2].startsWith("t2\tcorrection\tp\tf\tfixed\tskills/x\tsess")).toBe(true);
	} finally {
		await rm(root, { recursive: true, force: true });
	}
});
