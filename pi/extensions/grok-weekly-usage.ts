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
import {
	registerUsageChip,
	requestUsageFooterRender,
	syncUsageFooter,
	uninstallUsageFooter,
} from "./lib/usage-footer.ts";

const BILLING_URL = "https://cli-chat-proxy.grok.com/v1/billing?format=credits";
const TOKEN_AUTH = "xai-grok-cli";
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
	return model?.provider === "xai";
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

export default function grokWeeklyUsageExtension(pi: ExtensionAPI) {
	let latest: WeeklyUsage | undefined;
	let lastError: string | undefined;
	let inflight: Promise<WeeklyUsage> | undefined;
	let timer: ReturnType<typeof setInterval> | undefined;

	registerUsageChip("grok", {
		matches: isGrokModel,
		label: () => (latest ? compactLabel(latest) : undefined),
	});

	async function resolveToken(ctx: ExtensionContext): Promise<string> {
		let lastErrorMessage = "no xAI login";
		try {
			const auth = await ctx.modelRegistry.getProviderAuth("xai");
			const token = auth?.auth.apiKey;
			if (token) return token;
		} catch (error) {
			lastErrorMessage = error instanceof Error ? error.message : String(error);
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
			requestUsageFooterRender();
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
		syncUsageFooter(ctx);
		startPolling(ctx);
		void fetchWeeklyUsage(ctx).catch(() => {
			// Stay quiet until /grok-usage; omit the chip until Grok returns fields.
		});
	});

	pi.on("model_select", async (_event, ctx) => {
		syncUsageFooter(ctx);
	});

	pi.on("agent_settled", async (_event, ctx) => {
		const provider = ctx.model?.provider;
		if (provider !== "xai") return;
		void fetchWeeklyUsage(ctx).catch(() => {
			// Keep the last good snapshot.
		});
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		stopPolling();
		uninstallUsageFooter(ctx);
	});
}
