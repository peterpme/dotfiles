/**
 * Grok Weekly Usage
 *
 * Shows the SuperGrok weekly usage pool from the official CLI billing API
 * that backs grok.com Settings → Usage:
 *   GET https://cli-chat-proxy.grok.com/v1/billing?format=credits
 *
 * The compact chip sits after the model picker, same color as the model:
 *   8% • Aug 15th
 *
 * Usage:
 * - `/grok-usage`          fetch now and show details
 * - `/grok-usage refresh`  same as above
 * - `/grok-usage status`   show the last fetched snapshot
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const BILLING_URL = "https://cli-chat-proxy.grok.com/v1/billing?format=credits";
const TOKEN_AUTH = "xai-grok-cli";
const PROVIDERS = ["xai", "grok-cli"] as const;
const POLL_MS = 5 * 60 * 1000;
const FETCH_TIMEOUT_MS = 15_000;
const WEEKLY_PERIOD = "USAGE_PERIOD_TYPE_WEEKLY";

type WeeklyUsage = {
	percent: number;
	resetsAt?: Date;
	products: Array<{ product: string; percent?: number }>;
	fetchedAt: Date;
};

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null && !Array.isArray(value);
}

function ordinal(day: number): string {
	const remainder = day % 100;
	if (remainder >= 11 && remainder <= 13) return `${day}th`;
	switch (day % 10) {
		case 1:
			return `${day}st`;
		case 2:
			return `${day}nd`;
		case 3:
			return `${day}rd`;
		default:
			return `${day}th`;
	}
}

function isGrokModel(model: ExtensionContext["model"] | undefined): boolean {
	return model?.provider === "xai" || model?.provider === "grok-cli";
}

function formatResetDay(date: Date): string {
	const month = date.toLocaleString("en-US", { month: "short", timeZone: "UTC" });
	const day = Number(
		date.toLocaleString("en-US", { day: "numeric", timeZone: "UTC" }),
	);
	return `${month} ${ordinal(day)}`;
}

function formatPercent(percent: number): string {
	if (!Number.isFinite(percent)) return "?%";
	const rounded = Math.round(percent);
	if (Math.abs(percent - rounded) < 0.05) return `${rounded}%`;
	return `${percent.toFixed(1)}%`;
}

function compactLabel(usage: WeeklyUsage): string {
	const parts = [formatPercent(usage.percent)];
	if (usage.resetsAt) parts.push(formatResetDay(usage.resetsAt));
	return parts.join(" • ");
}

function parseWeeklyUsage(payload: unknown, fetchedAt: Date): WeeklyUsage {
	if (!isRecord(payload) || !isRecord(payload.config)) {
		throw new Error("billing payload missing config");
	}

	const config = payload.config;
	const period = isRecord(config.currentPeriod) ? config.currentPeriod : undefined;
	if (period?.type !== WEEKLY_PERIOD) {
		throw new Error("billing payload is not a weekly usage period");
	}

	// grok.com omits proto3 creditUsagePercent when usage is 0.
	const rawPercent = config.creditUsagePercent;
	const percent =
		rawPercent === undefined || rawPercent === null
			? 0
			: rawPercent;
	if (typeof percent !== "number" || !Number.isFinite(percent)) {
		throw new Error("billing payload has invalid creditUsagePercent");
	}

	const endRaw =
		(typeof config.billingPeriodEnd === "string" && config.billingPeriodEnd) ||
		(typeof period.end === "string" && period.end) ||
		undefined;
	const parsedEnd = endRaw ? new Date(endRaw) : undefined;
	const resetsAt = parsedEnd && !Number.isNaN(parsedEnd.getTime()) ? parsedEnd : undefined;

	const products: WeeklyUsage["products"] = [];
	if (Array.isArray(config.productUsage)) {
		for (const item of config.productUsage) {
			if (!isRecord(item) || typeof item.product !== "string") continue;
			const usagePercent =
				typeof item.usagePercent === "number" && Number.isFinite(item.usagePercent)
					? item.usagePercent
					: undefined;
			products.push({ product: item.product, percent: usagePercent });
		}
	}

	return {
		percent,
		...(resetsAt ? { resetsAt } : {}),
		products,
		fetchedAt,
	};
}

function formatDetail(usage: WeeklyUsage): string {
	const lines = [`Weekly usage  ${formatPercent(usage.percent)} used`];
	if (usage.resetsAt) {
		lines.push(`Resets        ${usage.resetsAt.toISOString()} (${formatResetDay(usage.resetsAt)})`);
	}
	lines.push(`Fetched       ${usage.fetchedAt.toLocaleTimeString()}`);

	if (usage.products.length > 0) {
		const breakdown = usage.products
			.map((product) =>
				product.percent === undefined
					? product.product
					: `${product.product} ${formatPercent(product.percent)}`,
			)
			.join(", ");
		lines.push(`Products      ${breakdown}`);
	}

	return lines.join("\n");
}

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10_000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1000)}k`;
	if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
	return `${Math.round(count / 1_000_000)}M`;
}

function formatCwd(cwd: string, home: string | undefined): string {
	if (!home) return cwd;
	if (cwd === home) return "~";
	if (cwd.startsWith(`${home}/`) || cwd.startsWith(`${home}\\`)) {
		return `~${cwd.slice(home.length)}`;
	}
	return cwd;
}

export default function grokWeeklyUsageExtension(pi: ExtensionAPI) {
	let latest: WeeklyUsage | undefined;
	let lastError: string | undefined;
	let inflight: Promise<WeeklyUsage> | undefined;
	let timer: ReturnType<typeof setInterval> | undefined;
	let footerInstalled = false;
	let requestRender: (() => void) | undefined;

	function uninstallFooter(ctx: ExtensionContext): void {
		if (!ctx.hasUI || !footerInstalled) return;
		footerInstalled = false;
		requestRender = undefined;
		ctx.ui.setFooter(undefined);
	}

	function syncFooter(ctx: ExtensionContext): void {
		if (!ctx.hasUI) return;
		if (isGrokModel(ctx.model)) {
			installFooter(ctx);
			return;
		}
		uninstallFooter(ctx);
	}

	function installFooter(ctx: ExtensionContext): void {
		if (!ctx.hasUI || footerInstalled) return;
		footerInstalled = true;

		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = () => tui.requestRender();
			const unsub = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose() {
					unsub();
					requestRender = undefined;
				},
				invalidate() {},
				render(width: number): string[] {
					const model = ctx.model;
					let pwd = formatCwd(ctx.sessionManager.getCwd(), process.env.HOME || process.env.USERPROFILE);
					const branch = footerData.getGitBranch();
					if (branch) pwd = `${pwd} (${branch})`;
					const sessionName = ctx.sessionManager.getSessionName();
					if (sessionName) pwd = `${pwd} • ${sessionName}`;

					let input = 0;
					let output = 0;
					let cacheRead = 0;
					let cacheWrite = 0;
					let cost = 0;
					let latestCacheHitRate: number | undefined;
					for (const entry of ctx.sessionManager.getEntries()) {
						if (entry.type === "message" && entry.message.role === "assistant") {
							const usage = entry.message.usage;
							input += usage.input;
							output += usage.output;
							cacheRead += usage.cacheRead;
							cacheWrite += usage.cacheWrite;
							cost += usage.cost.total;
							const promptTokens = usage.input + usage.cacheRead + usage.cacheWrite;
							latestCacheHitRate = promptTokens > 0 ? (usage.cacheRead / promptTokens) * 100 : undefined;
						} else if (entry.type === "message" && entry.message.role === "toolResult" && entry.message.usage) {
							const usage = entry.message.usage;
							input += usage.input;
							output += usage.output;
							cacheRead += usage.cacheRead;
							cacheWrite += usage.cacheWrite;
							cost += usage.cost.total;
						} else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
							const usage = entry.usage;
							input += usage.input;
							output += usage.output;
							cacheRead += usage.cacheRead;
							cacheWrite += usage.cacheWrite;
							cost += usage.cost.total;
						}
					}

					const stats: string[] = [];
					if (input) stats.push(`↑${formatTokens(input)}`);
					if (output) stats.push(`↓${formatTokens(output)}`);
					if (cacheRead) stats.push(`R${formatTokens(cacheRead)}`);
					if (cacheWrite) stats.push(`W${formatTokens(cacheWrite)}`);
					if ((cacheRead > 0 || cacheWrite > 0) && latestCacheHitRate !== undefined) {
						stats.push(`CH${latestCacheHitRate.toFixed(1)}%`);
					}

					const usingSubscription = Boolean(model && ctx.modelRegistry.isUsingOAuth(model));
					if (cost || usingSubscription) {
						stats.push(`$${cost.toFixed(3)}${usingSubscription ? " (sub)" : ""}`);
					}

					const contextUsage = ctx.getContextUsage();
					const contextWindow = contextUsage?.contextWindow ?? model?.contextWindow ?? 0;
					const contextPercentValue = contextUsage?.percent ?? 0;
					const contextDisplay =
						contextUsage?.percent == null
							? `?/${formatTokens(contextWindow)}`
							: `${contextPercentValue.toFixed(1)}%/${formatTokens(contextWindow)}`;
					let contextStr = contextDisplay;
					if (contextUsage?.percent != null && contextPercentValue > 90) {
						contextStr = theme.fg("error", contextDisplay);
					} else if (contextUsage?.percent != null && contextPercentValue > 70) {
						contextStr = theme.fg("warning", contextDisplay);
					}
					stats.push(contextStr);

					let statsLeft = stats.join(" ");
					if (visibleWidth(statsLeft) > width) {
						statsLeft = truncateToWidth(statsLeft, width, "...");
					}

					let modelLabel = model?.id || "no-model";
					if (model?.reasoning) {
						const thinking = ctx.thinkingLevel || "off";
						modelLabel = thinking === "off" ? `${modelLabel} • thinking off` : `${modelLabel} • ${thinking}`;
					}
					if (footerData.getAvailableProviderCount() > 1 && model) {
						const withProvider = `(${model.provider}) ${modelLabel}`;
						if (visibleWidth(statsLeft) + 2 + visibleWidth(withProvider) <= width) {
							modelLabel = withProvider;
						}
					}

					const chip = isGrokModel(model) ? (latest ? compactLabel(latest) : undefined) : undefined;
					const rightPlain = chip ? `${modelLabel} • ${chip}` : modelLabel;
					const minPad = 2;
					const leftWidth = visibleWidth(statsLeft);
					let right = rightPlain;
					if (leftWidth + minPad + visibleWidth(right) > width) {
						right = truncateToWidth(right, Math.max(0, width - leftWidth - minPad), "");
					}
					const rightStyled = theme.fg("dim", right);
					const pad = " ".repeat(Math.max(0, width - leftWidth - visibleWidth(rightStyled)));

					const statuses = Array.from(footerData.getExtensionStatuses().entries())
						.sort(([a], [b]) => a.localeCompare(b))
						.map(([, text]) => text.replace(/[\r\n\t]+/g, " ").replace(/ +/g, " ").trim())
						.filter(Boolean);

					const lines = [
						truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
						theme.fg("dim", statsLeft) + pad + rightStyled,
					];
					if (statuses.length > 0) {
						lines.push(truncateToWidth(statuses.join(" "), width, theme.fg("dim", "...")));
					}
					return lines;
				},
			};
		});
	}

	async function resolveToken(ctx: ExtensionContext): Promise<string> {
		let lastErrorMessage = "no xAI or Grok CLI login";
		for (const provider of PROVIDERS) {
			try {
				const auth = await ctx.modelRegistry.getProviderAuth(provider);
				const token = auth?.auth.apiKey;
				if (token) return token;
			} catch (error) {
				lastErrorMessage = error instanceof Error ? error.message : String(error);
			}
		}
		throw new Error(`not signed in to Grok (${lastErrorMessage}). Run /login and choose xAI.`);
	}

	async function fetchWeeklyUsage(ctx: ExtensionContext): Promise<WeeklyUsage> {
		if (inflight) return inflight;

		inflight = (async () => {
			const token = await resolveToken(ctx);
			const response = await fetch(BILLING_URL, {
				headers: {
					authorization: `Bearer ${token}`,
					"x-xai-token-auth": TOKEN_AUTH,
					accept: "application/json",
				},
				signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
			});
			if (!response.ok) {
				throw new Error(`billing endpoint returned ${response.status}`);
			}
			return parseWeeklyUsage(await response.json(), new Date());
		})();

		try {
			const usage = await inflight;
			latest = usage;
			lastError = undefined;
			requestRender?.();
			return usage;
		} catch (error) {
			lastError = error instanceof Error ? error.message : String(error);
			throw error;
		} finally {
			inflight = undefined;
		}
	}

	function startPolling(ctx: ExtensionContext): void {
		if (timer) return;
		timer = setInterval(() => {
			void fetchWeeklyUsage(ctx).catch(() => {
				// Keep the last good snapshot in the footer.
			});
		}, POLL_MS);
		timer.unref?.();
	}

	function stopPolling(): void {
		if (!timer) return;
		clearInterval(timer);
		timer = undefined;
	}

	async function handleCommand(args: string | undefined, ctx: ExtensionContext): Promise<void> {
		const trimmed = args?.trim().toLowerCase() ?? "";
		if (trimmed && trimmed !== "refresh" && trimmed !== "status") {
			ctx.ui.notify("Usage: /grok-usage [refresh|status]", "error");
			return;
		}

		if (trimmed === "status") {
			if (latest) {
				ctx.ui.notify(formatDetail(latest), "info");
				return;
			}
			ctx.ui.notify(
				lastError ? `Weekly usage unavailable: ${lastError}` : "Weekly usage not fetched yet",
				"warning",
			);
			return;
		}

		try {
			const usage = await fetchWeeklyUsage(ctx);
			ctx.ui.notify(formatDetail(usage), "info");
		} catch (error) {
			const message = error instanceof Error ? error.message : String(error);
			ctx.ui.notify(`Weekly usage refresh failed: ${message}`, "error");
		}
	}

	pi.registerCommand("grok-usage", {
		description: "Show SuperGrok weekly usage and reset day",
		getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
			const items: AutocompleteItem[] = [
				{ value: "refresh", label: "refresh", description: "Fetch weekly usage now" },
				{ value: "status", label: "status", description: "Show the last fetched snapshot" },
			];
			const filtered = items.filter((item) => item.value.startsWith(prefix.trim().toLowerCase()));
			return filtered.length > 0 ? filtered : null;
		},
		handler: handleCommand,
	});

	pi.on("session_start", async (_event, ctx) => {
		syncFooter(ctx);
		startPolling(ctx);
		void fetchWeeklyUsage(ctx).catch(() => {
			// Stay quiet until /grok-usage; omit the chip until Grok returns fields.
		});
	});

	pi.on("model_select", async (_event, ctx) => {
		syncFooter(ctx);
	});

	pi.on("agent_settled", async (_event, ctx) => {
		const provider = ctx.model?.provider;
		if (provider !== "xai" && provider !== "grok-cli") return;
		void fetchWeeklyUsage(ctx).catch(() => {
			// Keep the last good snapshot.
		});
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		stopPolling();
		uninstallFooter(ctx);
	});
}
