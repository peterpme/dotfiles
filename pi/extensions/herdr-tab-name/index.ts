/**
 * Auto-name the Herdr tab after a few turns.
 *
 * Tabs are 1-2 words. Spaces are ENGINE / wallet-api. After three user
 * messages, a cheap model names the tab if it still looks like a default
 * (a number or the cwd basename). `/tabname` forces it. `/tabname off`
 * leaves the label alone.
 */

import { uuidv7 } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	CUSTOM_TYPE,
	MAX_LABEL_CHARS,
	assistantText,
	conversationExcerpt,
	extractUserTexts,
	herdrTabId,
	isSubagentSession,
	isUsableTabLabel,
	parseHerdrTabGet,
	readTabNameState,
	sanitizeTabLabel,
	shouldAutoName,
	type HerdrTab,
	type TabNameState,
} from "./lib";

const HERDR_TIMEOUT_MS = 5_000;
const MODEL_MAX_TOKENS = 32;

const MODEL_CANDIDATES = [
	{ provider: "opencode", id: "deepseek-v4-flash" },
	{ provider: "peter@backpack.app", id: "gpt-5.6-luna" },
	{ provider: "services+openai@peterp.me", id: "gpt-5.6-luna" },
	{ provider: "openai-codex", id: "gpt-5.6-luna" },
] as const;

function herdrBin(env: NodeJS.ProcessEnv): string {
	return env.HERDR_BIN_PATH?.trim() || "herdr";
}

async function readJsonCommand(
	pi: ExtensionAPI,
	command: string,
	args: string[],
): Promise<unknown> {
	const result = await pi.exec(command, args, { timeout: HERDR_TIMEOUT_MS });
	if (result.code !== 0) {
		const details = result.stderr.trim() || `exited ${result.code}`;
		throw new Error(details);
	}
	return JSON.parse(result.stdout) as unknown;
}

async function currentHerdrTab(
	pi: ExtensionAPI,
	ctx: ExtensionContext,
	env: NodeJS.ProcessEnv,
): Promise<HerdrTab | undefined> {
	const tabId = herdrTabId(env);
	if (!tabId) return undefined;
	const tab = parseHerdrTabGet(
		await readJsonCommand(pi, herdrBin(env), ["tab", "get", tabId]),
	);
	return {
		tabId: tab?.tabId ?? tabId,
		label: tab?.label ?? "",
		cwd: ctx.cwd,
	};
}

async function renameHerdrTab(
	pi: ExtensionAPI,
	env: NodeJS.ProcessEnv,
	tabId: string,
	label: string,
): Promise<void> {
	const words = label.split(/\s+/).filter((word) => word.length > 0);
	const result = await pi.exec(herdrBin(env), ["tab", "rename", tabId, ...words], {
		timeout: HERDR_TIMEOUT_MS,
	});
	if (result.code !== 0) {
		const details = result.stderr.trim() || `exited ${result.code}`;
		throw new Error(details);
	}
}

function findNamer(ctx: ExtensionContext) {
	for (const candidate of MODEL_CANDIDATES) {
		const model = ctx.modelRegistry.find(candidate.provider, candidate.id);
		if (model && ctx.modelRegistry.hasConfiguredAuth(model)) return model;
	}
	if (ctx.model && ctx.modelRegistry.hasConfiguredAuth(ctx.model)) return ctx.model;
	return undefined;
}

function namePrompt(excerpt: string, currentLabel: string, banned: string): string {
	return [
		"Name the topic of this conversation as a terminal tab.",
		"Reply with 1 or 2 words only. No quotes, no punctuation, no repo names.",
		"Do not use greetings, test, testing, hello, or the current tab name.",
		currentLabel ? `Current tab: ${currentLabel}` : "",
		banned ? `Do not answer with: ${banned}` : "",
		"The words should be what a human would look for in a tab bar.",
		"",
		excerpt,
	]
		.filter((line) => line.length > 0)
		.join("\n");
}

async function completeLabel(
	ctx: ExtensionContext,
	model: NonNullable<ReturnType<typeof findNamer>>,
	prompt: string,
): Promise<string | undefined> {
	const response = await ctx.modelRegistry.complete(
		model,
		{
			messages: [
				{
					role: "user",
					content: [{ type: "text", text: prompt }],
					timestamp: Date.now(),
				},
			],
		},
		{
			maxTokens: MODEL_MAX_TOKENS,
			cacheRetention: "none",
			sessionId: uuidv7(),
			signal: ctx.signal,
		},
	);
	return sanitizeTabLabel(assistantText(response.content));
}

async function generateLabel(
	ctx: ExtensionContext,
	userTexts: readonly string[],
	currentLabel: string,
): Promise<string | undefined> {
	const model = findNamer(ctx);
	if (!model) return undefined;
	const excerpt = conversationExcerpt(userTexts);
	if (!excerpt) return undefined;

	const first = await completeLabel(ctx, model, namePrompt(excerpt, currentLabel, ""));
	if (first && isUsableTabLabel(first, currentLabel)) return first;
	const banned = first || currentLabel || "testing";
	const second = await completeLabel(ctx, model, namePrompt(excerpt, currentLabel, banned));
	if (second && isUsableTabLabel(second, currentLabel)) return second;
	return undefined;
}

export default function herdrTabNameExtension(pi: ExtensionAPI): void {
	let state: TabNameState = { kind: "idle" };
	let naming = false;
	let lastAttemptTurns = 0;

	const persist = (next: TabNameState) => {
		state = next;
		pi.appendEntry(CUSTOM_TYPE, next);
	};

	const applyLabel = async (
		ctx: ExtensionContext,
		label: string,
		opts: { notify: boolean },
	) => {
		pi.setSessionName(label);
		persist({ kind: "named", label });
		if (isSubagentSession(process.env)) {
			if (opts.notify) ctx.ui.notify(`session: ${label}`, "info");
			return;
		}
		try {
			const tab = await currentHerdrTab(pi, ctx, process.env);
			if (tab) await renameHerdrTab(pi, process.env, tab.tabId, label);
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			if (opts.notify) ctx.ui.notify(`tab name saved, herdr rename failed: ${message}`, "warning");
			return;
		}
		if (opts.notify) ctx.ui.notify(`tab: ${label}`, "info");
	};

	const nameFromConversation = async (
		ctx: ExtensionContext,
		opts: { force: boolean; notify: boolean },
	) => {
		if (naming) return;
		if (isSubagentSession(process.env)) return;
		const userTexts = extractUserTexts(ctx.sessionManager.getBranch());
		if (userTexts.length === 0) {
			if (opts.notify) ctx.ui.notify("tabname: no user messages yet", "warning");
			return;
		}
		if (!opts.force && lastAttemptTurns === userTexts.length) return;

		let tabLabel = pi.getSessionName() ?? "";
		if (process.env.HERDR_ENV === "1") {
			try {
				const tab = await currentHerdrTab(pi, ctx, process.env);
				if (tab) tabLabel = tab.label;
			} catch {
				// Session naming still works outside a reachable Herdr socket.
			}
		}

		if (!opts.force && !shouldAutoName({ state, userTurns: userTexts.length })) {
			return;
		}

		naming = true;
		lastAttemptTurns = userTexts.length;
		try {
			const label = await generateLabel(ctx, userTexts, tabLabel);
			if (!label) {
				if (opts.notify) ctx.ui.notify("tabname: model returned nothing usable", "warning");
				return;
			}
			await applyLabel(ctx, label, { notify: true });
		} catch (error) {
			if (ctx.signal?.aborted) return;
			const message = error instanceof Error ? error.message : String(error);
			if (opts.notify) ctx.ui.notify(`tabname: ${message}`, "error");
		} finally {
			naming = false;
		}
	};

	pi.on("session_start", async (_event, ctx) => {
		state = readTabNameState(ctx.sessionManager.getEntries());
		lastAttemptTurns = 0;
		naming = false;
	});

	pi.on("agent_settled", async (_event, ctx) => {
		if (state.kind !== "idle") return;
		await nameFromConversation(ctx, { force: false, notify: false });
	});

	pi.registerCommand("tabname", {
		description: "Name the Herdr tab in 1-2 words. Usage: /tabname [name|off|on]",
		handler: async (args, ctx) => {
			const trimmed = args.trim();
			if (trimmed === "off") {
				persist({ kind: "disabled" });
				ctx.ui.notify("tabname: auto-rename off", "info");
				return;
			}
			if (trimmed === "on") {
				persist({ kind: "idle" });
				lastAttemptTurns = 0;
				await nameFromConversation(ctx, { force: true, notify: true });
				return;
			}
			if (trimmed.length > 0) {
				const label = sanitizeTabLabel(trimmed) ?? trimmed.slice(0, MAX_LABEL_CHARS).trim();
				if (!label) {
					ctx.ui.notify("tabname: need a usable 1-2 word label", "warning");
					return;
				}
				await applyLabel(ctx, label, { notify: true });
				return;
			}
			await nameFromConversation(ctx, { force: true, notify: true });
		},
	});
}
