/**
 * Fast Mode
 *
 * Toggles paid priority scheduling. This is a speed/queue upgrade, not a
 * thinking-level change and not a different model slug.
 *
 * - xAI Grok: `service_tier: "priority"` (Grok 4.6 Fast, 2x price)
 * - OpenAI / Codex GPT-5.6: `service_tier: "fast"` (Sol Fast, 2x price)
 *
 * The toggle is session-scoped. Switching models does not turn it off.
 * Ineligible models keep the setting armed and show `fast: n/a`.
 *
 * Usage:
 * - `/fastmode`             toggle
 * - `/fastmode on|off`      set explicitly
 * - `/fastmode status`      show current state
 * - `Ctrl+Shift+F`          toggle
 * - `pi --fast`             start with fast mode on
 *
 * Docs:
 * - https://docs.x.ai/developers/advanced-api-usage/priority-processing
 * - https://developers.openai.com/api/docs/guides/fast-mode
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";

const STATUS_ID = "grok-fast";
const ENTRY_TYPE = "grok-fast-mode";
const COST_MULTIPLIER = 2;

const XAI_HOST_RE = /(?:^|[./])(?:api\.x\.ai|cli-chat-proxy\.grok\.com)(?:$|[/:])/i;
const OPENAI_FAST_PROVIDERS = new Set(["openai", "openai-codex"]);
const OPENAI_FAST_MODEL_RE = /gpt-5(?:\.5|\.6)|o3|o4/i;

type FastEntry = {
	enabled?: boolean;
};

type FastTarget = {
	tier: "priority" | "fast";
	label: string;
};

function parseEnabledArg(args: string | undefined): boolean | undefined {
	const value = args?.trim().toLowerCase();
	if (!value) return undefined;
	if (["on", "enable", "enabled", "true", "1"].includes(value)) return true;
	if (["off", "disable", "disabled", "false", "0"].includes(value)) return false;
	return undefined;
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function modelBaseUrl(model: { baseUrl?: unknown } | undefined): string {
	return typeof model?.baseUrl === "string" ? model.baseUrl : "";
}

function describeModel(model: ExtensionContext["model"] | undefined): string {
	if (!model) return "none";
	return `${model.provider}/${model.id}`;
}

function fastTarget(model: ExtensionContext["model"] | undefined): FastTarget | undefined {
	if (!model) return undefined;

	const id = model.id.toLowerCase();
	const url = modelBaseUrl(model);
	if (model.provider === "xai" || (id.startsWith("grok-") && XAI_HOST_RE.test(url))) {
		return { tier: "priority", label: "xAI Priority Processing" };
	}

	if (OPENAI_FAST_PROVIDERS.has(model.provider) && OPENAI_FAST_MODEL_RE.test(model.id)) {
		return { tier: "fast", label: "OpenAI Fast mode" };
	}

	return undefined;
}

export default function grokFastModeExtension(pi: ExtensionAPI) {
	let enabled = false;
	let injectedThisTurn = false;

	pi.registerFlag("fast", {
		description: "Start with Fast Mode (priority scheduling, 2x price)",
		type: "boolean",
		default: false,
	});

	function persist(): void {
		pi.appendEntry(ENTRY_TYPE, { enabled });
	}

	function updateStatus(ctx: ExtensionContext): void {
		if (!ctx.hasUI) return;

		if (!enabled) {
			ctx.ui.setStatus(STATUS_ID, undefined);
			return;
		}

		const theme = ctx.ui.theme;
		if (fastTarget(ctx.model)) {
			ctx.ui.setStatus(STATUS_ID, theme.fg("accent", theme.bold("FAST 2x")));
			return;
		}

		ctx.ui.setStatus(STATUS_ID, theme.fg("muted", "fast: n/a"));
	}

	function setEnabled(next: boolean, ctx: ExtensionContext, notify: boolean): void {
		enabled = next;
		persist();
		updateStatus(ctx);

		if (!notify || !ctx.hasUI) return;

		if (!enabled) {
			ctx.ui.notify("Fast Mode off (standard scheduling)", "info");
			return;
		}

		const target = fastTarget(ctx.model);
		if (target) {
			ctx.ui.notify(
				`Fast Mode on for ${describeModel(ctx.model)} — ${target.label} at 2x token price`,
				"info",
			);
			return;
		}

		ctx.ui.notify(
			`Fast Mode stays on, but ${describeModel(ctx.model)} has no speed tier. Status will show fast: n/a until you switch back to Grok or GPT-5.6.`,
			"warning",
		);
	}

	function toggle(ctx: ExtensionContext): void {
		setEnabled(!enabled, ctx, true);
	}

	function statusMessage(ctx: ExtensionContext): string {
		const model = describeModel(ctx.model);
		const target = fastTarget(ctx.model);
		if (!enabled) return `Fast Mode off (${model})`;
		if (target) {
			return `Fast Mode on for ${model} — service_tier=${target.tier} (2x)`;
		}
		return `Fast Mode on, but ${model} is not eligible (need xai/grok-* or openai-codex/gpt-5.6-*)`;
	}

	async function handleFastCommand(args: string | undefined, ctx: ExtensionContext): Promise<void> {
		const trimmed = args?.trim().toLowerCase() ?? "";
		if (trimmed === "status") {
			if (ctx.hasUI) ctx.ui.notify(statusMessage(ctx), "info");
			return;
		}

		const parsed = parseEnabledArg(trimmed);
		if (trimmed && parsed === undefined) {
			if (ctx.hasUI) {
				ctx.ui.notify("Usage: /fastmode [on|off|status]", "error");
			}
			return;
		}

		if (parsed === undefined) {
			toggle(ctx);
			return;
		}

		setEnabled(parsed, ctx, true);
	}

	const commandOptions = {
		description: "Toggle Fast Mode (priority scheduling, 2x price)",
		getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
			const items: AutocompleteItem[] = [
				{ value: "on", label: "on", description: "Enable priority / Fast scheduling" },
				{ value: "off", label: "off", description: "Use standard scheduling" },
				{ value: "status", label: "status", description: "Show current Fast Mode state" },
			];
			const filtered = items.filter((item) => item.value.startsWith(prefix.trim().toLowerCase()));
			return filtered.length > 0 ? filtered : null;
		},
		handler: handleFastCommand,
	};

	pi.registerCommand("fastmode", commandOptions);

	pi.on("input", async (event, ctx) => {
		const match = event.text.trim().match(/^\/fastmode(?:\s+(.*))?$/i);
		if (!match) return;
		await handleFastCommand(match[1], ctx);
		return { action: "handled" as const };
	});

	pi.registerShortcut("ctrl+shift+f", {
		description: "Toggle Fast Mode",
		handler: async (ctx) => {
			toggle(ctx);
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		enabled = false;
		injectedThisTurn = false;

		const entries = ctx.sessionManager.getEntries();
		const saved = entries
			.filter((entry) => entry.type === "custom" && entry.customType === ENTRY_TYPE)
			.at(-1) as { data?: FastEntry } | undefined;
		if (saved?.data?.enabled === true) {
			enabled = true;
		}

		if (pi.getFlag("fast") === true) {
			enabled = true;
			persist();
		}

		updateStatus(ctx);
	});

	pi.on("model_select", async (_event, ctx) => {
		updateStatus(ctx);
		if (!enabled || !ctx.hasUI) return;

		const target = fastTarget(ctx.model);
		if (target) {
			ctx.ui.notify(
				`Fast Mode still on — ${describeModel(ctx.model)} will use ${target.label}`,
				"info",
			);
			return;
		}

		ctx.ui.notify(
			`Fast Mode still on, but ${describeModel(ctx.model)} has no speed tier (fast: n/a)`,
			"warning",
		);
	});

	pi.on("before_provider_request", (event, ctx) => {
		injectedThisTurn = false;
		if (!enabled) return;

		const target = fastTarget(ctx.model);
		if (!target || !isRecord(event.payload)) return;

		injectedThisTurn = true;
		return {
			...event.payload,
			service_tier: target.tier,
		};
	});

	pi.on("after_provider_response", (event, ctx) => {
		if (!injectedThisTurn || !ctx.hasUI) return;
		if (event.status !== 429) return;
		ctx.ui.notify("Fast Mode request was rate limited; retry or turn Fast Mode off.", "warning");
	});

	pi.on("message_end", async (event) => {
		if (!injectedThisTurn) return;
		if (event.message.role !== "assistant") return;

		const usage = event.message.usage;
		const cost = usage?.cost;
		if (!usage || !cost) return;

		return {
			message: {
				...event.message,
				usage: {
					...usage,
					cost: {
						...cost,
						input: cost.input * COST_MULTIPLIER,
						output: cost.output * COST_MULTIPLIER,
						cacheRead: cost.cacheRead * COST_MULTIPLIER,
						cacheWrite: cost.cacheWrite * COST_MULTIPLIER,
						total: cost.total * COST_MULTIPLIER,
					},
				},
			},
		};
	});
}
