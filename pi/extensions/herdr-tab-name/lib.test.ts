import { expect, test } from "bun:test";
import {
	CUSTOM_TYPE,
	conversationExcerpt,
	extractUserTexts,
	herdrTabId,
	isPlaceholderTabLabel,
	isSubagentSession,
	isUsableTabLabel,
	isWeakUserText,
	parseHerdrPaneCurrent,
	parseHerdrTabGet,
	parseTabNameState,
	readTabNameState,
	sanitizeTabLabel,
	shouldAutoName,
} from "./lib";

test("placeholder labels are numbers, empty, shells, and the cwd basename", () => {
	expect(isPlaceholderTabLabel("", "/tmp/cursor-plugins")).toBe(true);
	expect(isPlaceholderTabLabel("3", "/tmp/cursor-plugins")).toBe(true);
	expect(isPlaceholderTabLabel("pi", "/tmp/cursor-plugins")).toBe(true);
	expect(isPlaceholderTabLabel("cursor-plugins", "/tmp/cursor-plugins")).toBe(true);
	expect(isPlaceholderTabLabel("ROBUST", "/tmp/cursor-plugins")).toBe(false);
});

test("sanitizeTabLabel keeps 1-2 words and drops junk", () => {
	expect(sanitizeTabLabel('"Tab Names"')).toBe("Tab Names");
	expect(sanitizeTabLabel("tab-names")).toBe("tab names");
	expect(sanitizeTabLabel("Authentication Flow Extra")).toBe("Authentication");
	expect(sanitizeTabLabel("***")).toBeUndefined();
	expect(sanitizeTabLabel("OAuth")).toBe("OAuth");
});

test("shouldAutoName waits for turns and ignores the current label", () => {
	expect(shouldAutoName({ state: { kind: "idle" }, userTurns: 3 })).toBe(true);
	expect(shouldAutoName({ state: { kind: "idle" }, userTurns: 2 })).toBe(false);
	expect(
		shouldAutoName({
			state: { kind: "named", label: "Auth Fix" },
			userTurns: 8,
		}),
	).toBe(false);
	expect(shouldAutoName({ state: { kind: "idle" }, userTurns: 4 })).toBe(true);
});

test("isUsableTabLabel rejects the current name and greetings", () => {
	expect(isUsableTabLabel("Who Am", "testing")).toBe(true);
	expect(isUsableTabLabel("testing", "testing")).toBe(false);
	expect(isUsableTabLabel("Testing", "testing")).toBe(false);
	expect(isUsableTabLabel("hello", "1")).toBe(false);
	expect(isUsableTabLabel("Identity", "")).toBe(true);
});

test("isWeakUserText drops pings", () => {
	expect(isWeakUserText("testing hello 123")).toBe(true);
	expect(isWeakUserText("hello 456")).toBe(true);
	expect(isWeakUserText("who do you think i am")).toBe(false);
});

test("herdrTabId requires HERDR_ENV and a tab id", () => {
	expect(herdrTabId({})).toBeUndefined();
	expect(herdrTabId({ HERDR_ENV: "1" })).toBeUndefined();
	expect(herdrTabId({ HERDR_ENV: "1", HERDR_TAB_ID: "w1C:t5" })).toBe("w1C:t5");
});

test("readTabNameState uses the latest custom entry", () => {
	expect(
		readTabNameState([
			{
				type: "custom",
				customType: CUSTOM_TYPE,
				data: { kind: "named", label: "Old" },
			},
			{
				type: "custom",
				customType: CUSTOM_TYPE,
				data: { kind: "disabled" },
			},
		]),
	).toEqual({ kind: "disabled" });
	expect(parseTabNameState({ kind: "named" })).toBeUndefined();
});

test("extractUserTexts ignores non-user entries", () => {
	expect(
		extractUserTexts([
			{
				type: "message",
				message: { role: "user", content: "rename herdr tabs" },
			},
			{
				type: "message",
				message: { role: "assistant", content: [{ type: "text", text: "ok" }] },
			},
			{
				type: "custom",
				customType: CUSTOM_TYPE,
				data: { kind: "idle" },
			},
		]),
	).toEqual(["rename herdr tabs"]);
});

test("conversationExcerpt prefers later non-ping prompts", () => {
	const excerpt = conversationExcerpt([
		"testing hello 123",
		"hello 456",
		"hello 789",
		"who do you think i am",
		"how do you know its peter",
	]);
	expect(excerpt).toContain("who do you think i am");
	expect(excerpt).toContain("how do you know its peter");
	expect(excerpt).not.toContain("testing hello 123");
});

test("helpers never rename their parent's tab, including before Pi assigns a session id", () => {
	expect(isSubagentSession({ PPSTACK_SUBAGENT: "1" })).toBe(true);
	expect(isSubagentSession({ PPSTACK_SUBAGENT: "0" })).toBe(false);
	expect(isSubagentSession({})).toBe(false);
	expect(
		isSubagentSession({
			PI_SESSION_ID: "abc",
			PI_SUBAGENT_PARENT_SESSION: "abc",
		}),
	).toBe(false);
	expect(
		isSubagentSession({
			PI_SESSION_ID: "child",
			PI_SUBAGENT_PARENT_SESSION: "parent",
		}),
	).toBe(true);
});

test("herdr JSON parsers read tab id and labels", () => {
	expect(
		parseHerdrPaneCurrent({
			id: "cli:pane:current",
			result: {
				pane: { tab_id: "w1C:t1", label: "dotfiles", cwd: "/tmp/cursor-plugins" },
				type: "pane_current",
			},
		}),
	).toEqual({
		tabId: "w1C:t1",
		label: "dotfiles",
		cwd: "/tmp/cursor-plugins",
	});
	expect(
		parseHerdrTabGet({
			id: "cli:tab:get",
			result: { tab: { tab_id: "w1C:t1", label: "3" }, type: "tab_info" },
		}),
	).toEqual({ tabId: "w1C:t1", label: "3" });
	expect(parseHerdrTabGet({ nope: true })).toBeUndefined();
});
