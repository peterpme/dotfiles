import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { saveSessionSnapshot } from "./petey-debug";

test("copies the session and appends an untriaged capture row", async () => {
	const root = await mkdtemp(join(tmpdir(), "petey-debug-"));
	try {
		const sessionFile = join(root, "source.jsonl");
		const contents = '{"type":"session","id":"session-1"}\n';
		await writeFile(sessionFile, contents);

		const result = await saveSessionSnapshot(sessionFile, "session-1", "Timeout Probe", root);

		expect(await readFile(result.path, "utf8")).toBe(contents);
		expect(result.bytes).toBe(Buffer.byteLength(contents));
		expect(result.path).toEndWith("_session-1_timeout-probe.jsonl");

		const rows = (await readFile(join(root, "problems.tsv"), "utf8")).trimEnd().split("\n");
		expect(rows[0]).toBe("ts\tkind\tproblem\tfix\tstatus\ttarget\ttrace");
		const cells = rows[1].split("\t");
		expect(cells).toHaveLength(7);
		expect(cells.slice(1, 6)).toEqual(["capture", "Timeout Probe", "-", "untriaged", "-"]);
		expect(cells[6]).toBe(`traces/${basename(result.path)} session session-1`);
	} finally {
		await rm(root, { recursive: true, force: true });
	}
});

test("appends to an existing log without a second header and flattens hostile labels", async () => {
	const root = await mkdtemp(join(tmpdir(), "petey-debug-"));
	try {
		const sessionFile = join(root, "source.jsonl");
		await writeFile(sessionFile, "{}\n");
		await writeFile(join(root, "problems.tsv"), "ts\tkind\tproblem\tfix\tstatus\ttarget\ttrace\n2026-08-28T00:00:00Z\ttool\tearlier row\t-\topen\t-\t-");

		await saveSessionSnapshot(sessionFile, "session-2", "=HYPERLINK()\ttabbed\nlabel", root);

		const rows = (await readFile(join(root, "problems.tsv"), "utf8")).trimEnd().split("\n");
		expect(rows).toHaveLength(3);
		expect(rows.filter((r) => r.startsWith("ts\t"))).toHaveLength(1);
		expect(rows[2].split("\t")[2]).toBe("'=HYPERLINK() tabbed label");
	} finally {
		await rm(root, { recursive: true, force: true });
	}
});
