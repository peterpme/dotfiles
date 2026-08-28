import { expect, test } from "bun:test";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { saveSessionSnapshot } from "./petey-debug";

test("copies the session and records an untriaged Petey log entry", async () => {
	const root = await mkdtemp(join(tmpdir(), "petey-debug-"));
	try {
		const sessionFile = join(root, "source.jsonl");
		const contents = '{"type":"session","id":"session-1"}\n';
		await writeFile(sessionFile, contents);

		const result = await saveSessionSnapshot(sessionFile, "session-1", "Timeout Probe", root);

		expect(await readFile(result.path, "utf8")).toBe(contents);
		expect(result.bytes).toBe(Buffer.byteLength(contents));
		expect(result.path).toEndWith("_session-1_timeout-probe.jsonl");

		const log = await readFile(join(root, "PETEY-LOG.md"), "utf8");
		expect(log).toContain("# PETEY log");
		expect(log).toContain("Label: Timeout Probe");
		expect(log).toContain("Status: untriaged");
		expect(log).toContain(`Trace: traces/${basename(result.path)}`);
	} finally {
		await rm(root, { recursive: true, force: true });
	}
});
