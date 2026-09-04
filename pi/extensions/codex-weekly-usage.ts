/**
 * Codex Weekly Usage
 *
 * Shows the ChatGPT Codex usage pool from the official Codex harness API:
 *   GET https://chatgpt.com/backend-api/wham/usage
 *
 * The compact chip sits after the model picker, same color as the model:
 *   14% • Aug 23rd
 *   100% • 1 reset • Aug 23rd
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { isCodexProvider } from "./lib/codex-provider.ts";
import {
	registerUsageChip,
	requestUsageFooterRender,
	syncUsageFooter,
	uninstallUsageFooter,
} from "./lib/usage-footer.ts";

const USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";
const CODEX_ACCOUNT_CLAIM = "https://api.openai.com/auth";
const POLL_MS = 5 * 60 * 1000;
const FETCH_TIMEOUT_MS = 15_000;

type CodexUsage = {
	percent: number;
	resetsAt?: Date;
	resetsAvailable: number;
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

function isCodexModel(model: ExtensionContext["model"] | undefined): boolean {
	return isCodexProvider(model?.provider);
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

function compactLabel(usage: CodexUsage): string {
	const parts = [formatPercent(usage.percent)];
	if (usage.resetsAvailable > 0) {
		parts.push(usage.resetsAvailable === 1 ? "1 reset" : `${usage.resetsAvailable} resets`);
	}
	if (usage.resetsAt) parts.push(formatResetDay(usage.resetsAt));
	return parts.join(" • ");
}

function asFiniteNumber(value: unknown): number | undefined {
	return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function pickWindow(payload: Record<string, unknown>): Record<string, unknown> | undefined {
	const rateLimit = isRecord(payload.rate_limit) ? payload.rate_limit : undefined;
	const primary = isRecord(rateLimit?.primary_window) ? rateLimit.primary_window : undefined;
	const secondary = isRecord(rateLimit?.secondary_window) ? rateLimit.secondary_window : undefined;

	const weeklySeconds = 7 * 24 * 60 * 60;
	if (asFiniteNumber(secondary?.limit_window_seconds) === weeklySeconds) return secondary;
	if (asFiniteNumber(primary?.limit_window_seconds) === weeklySeconds) return primary;
	return secondary ?? primary;
}

function parseUnixDate(value: unknown): Date | undefined {
	const seconds = asFiniteNumber(value);
	if (seconds === undefined) return undefined;
	const date = new Date(seconds * 1000);
	return Number.isNaN(date.getTime()) ? undefined : date;
}

function parseResetsAvailable(payload: Record<string, unknown>): number {
	const credits = isRecord(payload.rate_limit_reset_credits)
		? payload.rate_limit_reset_credits
		: undefined;
	const applicable = asFiniteNumber(credits?.applicable_available_count);
	if (applicable !== undefined) return Math.max(0, applicable);
	const available = asFiniteNumber(credits?.available_count);
	return available === undefined ? 0 : Math.max(0, available);
}

function parseCodexUsage(payload: unknown, fetchedAt: Date): CodexUsage {
	if (!isRecord(payload)) {
		throw new Error("usage payload is not an object");
	}

	const window = pickWindow(payload);
	const percent = asFiniteNumber(window?.used_percent);
	if (percent === undefined) {
		throw new Error("usage payload missing used_percent");
	}

	const resetsAt = parseUnixDate(window?.reset_at);
	return {
		percent,
		...(resetsAt ? { resetsAt } : {}),
		resetsAvailable: parseResetsAvailable(payload),
		fetchedAt,
	};
}

function parseAccountId(token: string): string | undefined {
	try {
		const parts = token.split(".");
		if (parts.length !== 3 || !parts[1]) return undefined;
		const payload: unknown = JSON.parse(Buffer.from(parts[1], "base64url").toString("utf8"));
		if (!isRecord(payload) || !isRecord(payload[CODEX_ACCOUNT_CLAIM])) return undefined;
		const accountId = payload[CODEX_ACCOUNT_CLAIM].chatgpt_account_id;
		return typeof accountId === "string" && accountId.length > 0 ? accountId : undefined;
	} catch {
		return undefined;
	}
}

export default function codexWeeklyUsageExtension(pi: ExtensionAPI) {
	let latest: CodexUsage | undefined;
	let lastProvider: string | undefined;
	let inflight: Promise<CodexUsage> | undefined;
	let timer: ReturnType<typeof setInterval> | undefined;

	registerUsageChip("codex", {
		matches: isCodexModel,
		label: () => (latest ? compactLabel(latest) : undefined),
	});

	async function resolveAuth(
		ctx: ExtensionContext,
	): Promise<{ token: string; accountId: string; provider: string }> {
		const provider = ctx.model?.provider;
		if (!provider || !isCodexModel(ctx.model)) {
			throw new Error("current model is not a Codex account");
		}

		const auth = await ctx.modelRegistry.getProviderAuth(provider);
		const token = auth?.auth.apiKey;
		if (!token) {
			throw new Error(`not signed in to ${provider}. Run /login and choose that Codex account.`);
		}

		const headerAccountId =
			auth.auth.headers?.["chatgpt-account-id"] ?? auth.auth.headers?.["ChatGPT-Account-Id"];
		const accountId =
			(typeof headerAccountId === "string" && headerAccountId) || parseAccountId(token);
		if (!accountId) {
			throw new Error(`could not resolve ChatGPT account id for ${provider}`);
		}

		return { token, accountId, provider };
	}

	async function fetchCodexUsage(ctx: ExtensionContext): Promise<CodexUsage> {
		if (inflight) return inflight;

		inflight = (async () => {
			const { token, accountId } = await resolveAuth(ctx);
			const response = await fetch(USAGE_URL, {
				headers: {
					authorization: `Bearer ${token}`,
					"chatgpt-account-id": accountId,
					accept: "application/json",
					originator: "pi",
				},
				signal: AbortSignal.timeout(FETCH_TIMEOUT_MS),
			});
			if (!response.ok) {
				throw new Error(`usage endpoint returned ${response.status}`);
			}
			return parseCodexUsage(await response.json(), new Date());
		})();

		try {
			const usage = await inflight;
			latest = usage;
			lastProvider = ctx.model?.provider;
			requestUsageFooterRender();
			return usage;
		} finally {
			inflight = undefined;
		}
	}

	function startPolling(ctx: ExtensionContext): void {
		if (timer) return;
		timer = setInterval(() => {
			if (!isCodexModel(ctx.model)) return;
			void fetchCodexUsage(ctx).catch(() => {
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

	function refreshIfNeeded(ctx: ExtensionContext): void {
		if (!isCodexModel(ctx.model)) return;
		if (ctx.model?.provider !== lastProvider) latest = undefined;
		void fetchCodexUsage(ctx).catch(() => {
			// Stay quiet; omit the chip until Codex returns fields.
		});
	}

	pi.on("session_start", async (_event, ctx) => {
		syncUsageFooter(ctx);
		startPolling(ctx);
		refreshIfNeeded(ctx);
	});

	pi.on("model_select", async (_event, ctx) => {
		syncUsageFooter(ctx);
		refreshIfNeeded(ctx);
	});

	pi.on("agent_settled", async (_event, ctx) => {
		if (!isCodexModel(ctx.model)) return;
		void fetchCodexUsage(ctx).catch(() => {
			// Keep the last good snapshot.
		});
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		stopPolling();
		uninstallUsageFooter(ctx);
	});
}
