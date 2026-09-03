/**
 * Debugger
 *
 * One TSV of session snags beside the Pi session file. Failed bash, read,
 * and subagent calls log themselves with no model involvement. The model
 * adds the rows only it can see through one small `log_problem` call.
 * `/debugger` prints the log without a model turn.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { existsSync } from "node:fs";
import { readFile } from "node:fs/promises";
import { Type } from "typebox";
import {
	KINDS,
	STATUSES,
	appendRow,
	classifyToolResult,
	dedupeKey,
	problemsPath,
	type Kind,
	type Row,
	type Status,
} from "./lib";

function logPath(ctx: ExtensionContext): string | undefined {
	const sessionFile = ctx.sessionManager.getSessionFile();
	return sessionFile ? problemsPath(sessionFile) : undefined;
}

export default function debuggerExtension(pi: ExtensionAPI): void {
	const seen = new Set<string>();

	pi.registerTool({
		name: "log_problem",
		label: "Log problem",
		description:
			"Append one row to this session's problems log, a TSV beside the session file. Call it when you assumed something wrong, the user corrected you, you dropped a path that failed, or you hit leftover work. Failed bash, read, and subagent calls are logged automatically, do not repeat them. One call, one line, keep working.",
		parameters: Type.Object({
			kind: Type.Union(KINDS.map((k) => Type.Literal(k))),
			problem: Type.String({ description: "One line. What broke or what you got wrong." }),
			fix: Type.Optional(Type.String({ description: "One line. What was true instead or what fixed it. Omit while open." })),
			status: Type.Optional(Type.Union(STATUSES.map((s) => Type.Literal(s)))),
			target: Type.Optional(
				Type.String({ description: "The ppstack skill, playbook, script, or pi config file that should change so this does not recur." }),
			),
		}),
		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const path = logPath(ctx);
			if (!path) {
				return {
					content: [{ type: "text", text: "No session file in this ephemeral session. Keep the snag in your reply." }],
					details: {},
				};
			}
			const row: Row = {
				ts: new Date().toISOString(),
				kind: params.kind as Kind,
				problem: params.problem,
				fix: params.fix ?? "-",
				status: (params.status as Status | undefined) ?? (params.fix ? "fixed" : "open"),
				target: params.target ?? "-",
				trace: ctx.sessionManager.getSessionId(),
			};
			await appendRow(path, row);
			return { content: [{ type: "text", text: `logged ${row.kind}` }], details: { path } };
		},
	});

	pi.on("tool_result", async (event, ctx) => {
		const finding = classifyToolResult(event);
		if (!finding) return;
		const key = dedupeKey(finding);
		if (seen.has(key)) return;
		seen.add(key);
		const path = logPath(ctx);
		if (!path) return;
		await appendRow(path, {
			ts: new Date().toISOString(),
			...finding,
			trace: `${ctx.sessionManager.getSessionId()} ${event.toolCallId}`,
		});
	});

	pi.registerCommand("debugger", {
		description: "Print this session's problems log",
		handler: async (_args, ctx) => {
			const path = logPath(ctx);
			if (!path || !existsSync(path)) {
				ctx.ui.notify("debugger: no snags logged this session", "info");
				return;
			}
			const text = await readFile(path, "utf8");
			const rows = Math.max(0, text.trimEnd().split("\n").length - 1);
			ctx.ui.notify(`debugger: ${rows} row(s) in ${path}\n\n${text}`, "info");
		},
	});
}
