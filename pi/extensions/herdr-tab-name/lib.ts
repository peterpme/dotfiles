import { basename } from "node:path";

export const CUSTOM_TYPE = "herdr-tab-name";
export const MIN_USER_TURNS = 3;
export const MAX_WORDS = 2;
export const MAX_LABEL_CHARS = 18;

const PLACEHOLDER_LABELS = new Set(["bash", "fish", "pi", "shell", "zsh"]);
const WEAK_LABELS = new Set([
	"conversation",
	"hello",
	"hey",
	"hi",
	"ping",
	"session",
	"tab",
	"test",
	"testing",
]);
const WEAK_USER_TEXT = /^(hi|hello|hey|yo|sup|test|testing|ping|ok|okay|thanks|thx)(\s+[\w\d]+)*[!?.]*$/i;

export type TabNameState =
	| { kind: "idle" }
	| { kind: "named"; label: string }
	| { kind: "disabled" };

export type TabNameEntry = {
	type: string;
	customType?: string;
	data?: unknown;
	message?: {
		role?: string;
		content?: unknown;
	};
};

export type HerdrTab = {
	tabId: string;
	label: string;
	cwd: string;
};

export function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function isPlaceholderTabLabel(label: string, cwd: string): boolean {
	const trimmed = label.trim();
	if (trimmed.length === 0) return true;
	if (/^\d+$/.test(trimmed)) return true;
	const lower = trimmed.toLowerCase();
	if (PLACEHOLDER_LABELS.has(lower)) return true;
	const dir = basename(cwd).toLowerCase();
	return dir.length > 0 && lower === dir;
}

export function sanitizeTabLabel(raw: string): string | undefined {
	const firstLine = raw.split(/\r?\n/, 1)[0] ?? "";
	const stripped = firstLine
		.trim()
		.replace(/^["'`]+|["'`]+$/g, "")
		.replace(/[*_`#]/g, " ");
	const words = stripped
		.split(/[\s/_]+/)
		.flatMap((token) => token.split("-"))
		.map((token) => token.replace(/[^A-Za-z0-9]+/g, ""))
		.filter((token) => token.length > 0)
		.slice(0, MAX_WORDS);
	if (words.length === 0) return undefined;

	let label = words.join(" ");
	if (label.length > MAX_LABEL_CHARS) {
		label = words[0] ?? "";
	}
	if (label.length === 0 || label.length > MAX_LABEL_CHARS) return undefined;
	return label;
}

export function parseTabNameState(data: unknown): TabNameState | undefined {
	if (!isRecord(data) || typeof data.kind !== "string") return undefined;
	if (data.kind === "idle") return { kind: "idle" };
	if (data.kind === "disabled") return { kind: "disabled" };
	if (data.kind === "named" && typeof data.label === "string" && data.label.trim()) {
		return { kind: "named", label: data.label.trim() };
	}
	return undefined;
}

export function readTabNameState(entries: readonly TabNameEntry[]): TabNameState {
	let state: TabNameState = { kind: "idle" };
	for (const entry of entries) {
		if (entry.type !== "custom" || entry.customType !== CUSTOM_TYPE) continue;
		const parsed = parseTabNameState(entry.data);
		if (parsed) state = parsed;
	}
	return state;
}

export function extractUserTexts(entries: readonly TabNameEntry[]): string[] {
	const texts: string[] = [];
	for (const entry of entries) {
		if (entry.type !== "message") continue;
		if (entry.message?.role !== "user") continue;
		const text = contentText(entry.message.content).trim();
		if (text.length > 0) texts.push(text);
	}
	return texts;
}

export function shouldAutoName(input: {
	state: TabNameState;
	userTurns: number;
	minTurns?: number;
}): boolean {
	if (input.state.kind !== "idle") return false;
	return input.userTurns >= (input.minTurns ?? MIN_USER_TURNS);
}

export function labelsMatch(left: string, right: string): boolean {
	return left.trim().toLowerCase() === right.trim().toLowerCase();
}

export function isWeakUserText(text: string): boolean {
	const trimmed = text.trim();
	if (trimmed.length === 0) return true;
	if (trimmed.length < 8) return true;
	return WEAK_USER_TEXT.test(trimmed);
}

export function isUsableTabLabel(label: string, currentLabel: string): boolean {
	if (label.trim().length === 0) return false;
	if (labelsMatch(label, currentLabel)) return false;
	return !WEAK_LABELS.has(label.trim().toLowerCase());
}

export function herdrTabId(env: NodeJS.ProcessEnv): string | undefined {
	if (env.HERDR_ENV !== "1") return undefined;
	const tabId = env.HERDR_TAB_ID?.trim();
	return tabId && tabId.length > 0 ? tabId : undefined;
}

export function isSubagentSession(env: NodeJS.ProcessEnv): boolean {
	if (env.PPSTACK_SUBAGENT === "1") return true;
	const sessionId = env.PI_SESSION_ID;
	const parentId = env.PI_SUBAGENT_PARENT_SESSION;
	return Boolean(sessionId && parentId && sessionId !== parentId);
}

export function parseHerdrPaneCurrent(payload: unknown): HerdrTab | undefined {
	if (!isRecord(payload) || !isRecord(payload.result) || !isRecord(payload.result.pane)) {
		return undefined;
	}
	const pane = payload.result.pane;
	if (typeof pane.tab_id !== "string" || pane.tab_id.length === 0) return undefined;
	return {
		tabId: pane.tab_id,
		label: typeof pane.label === "string" ? pane.label : "",
		cwd: typeof pane.cwd === "string" ? pane.cwd : "",
	};
}

export function parseHerdrTabGet(payload: unknown): { tabId: string; label: string } | undefined {
	if (!isRecord(payload) || !isRecord(payload.result) || !isRecord(payload.result.tab)) {
		return undefined;
	}
	const tab = payload.result.tab;
	if (typeof tab.tab_id !== "string" || tab.tab_id.length === 0) return undefined;
	return {
		tabId: tab.tab_id,
		label: typeof tab.label === "string" ? tab.label : "",
	};
}

export function conversationExcerpt(userTexts: readonly string[]): string {
	const strong = userTexts.filter((text) => !isWeakUserText(text));
	const source = strong.length > 0 ? strong : userTexts;
	if (source.length === 0) return "";
	return source
		.slice(-4)
		.map((text) => text.slice(0, 400).trim())
		.filter((text) => text.length > 0)
		.map((text) => `<user>\n${text}\n</user>`)
		.join("\n\n");
}

export function contentText(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	const parts: string[] = [];
	for (const part of content) {
		if (!isRecord(part) || part.type !== "text" || typeof part.text !== "string") continue;
		parts.push(part.text);
	}
	return parts.join("\n");
}

export function assistantText(content: readonly { type: string; text?: string }[]): string {
	const parts: string[] = [];
	for (const block of content) {
		if (block.type !== "text" || typeof block.text !== "string") continue;
		parts.push(block.text);
	}
	return parts.join(" ");
}
