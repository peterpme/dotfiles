/**
 * Shared session footer used by Grok and Codex usage chips.
 *
 * Both extensions replace the stock footer with the same renderer so switching
 * models cannot wipe the other provider's chip. The compact chip sits after the
 * model name, same color as the model:
 *   8% • Aug 15th
 */

import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

export type UsageChip = {
	matches: (model: ExtensionContext["model"]) => boolean;
	label: (model: ExtensionContext["model"]) => string | undefined;
};

type UsageFooterState = {
	chips: Map<string, UsageChip>;
	footerInstalled: boolean;
	requestRender?: () => void;
};

const STATE_KEY = Symbol.for("dotfiles.pi.usage-footer");

function getState(): UsageFooterState {
	const globalState = globalThis as typeof globalThis & {
		[STATE_KEY]?: UsageFooterState;
	};
	if (!globalState[STATE_KEY]) {
		globalState[STATE_KEY] = {
			chips: new Map<string, UsageChip>(),
			footerInstalled: false,
		};
	}
	return globalState[STATE_KEY];
}

export function registerUsageChip(id: string, chip: UsageChip): void {
	getState().chips.set(id, chip);
}

export function requestUsageFooterRender(): void {
	getState().requestRender?.();
}

export function uninstallUsageFooter(ctx: ExtensionContext): void {
	const state = getState();
	if (!ctx.hasUI || !state.footerInstalled) return;
	state.footerInstalled = false;
	state.requestRender = undefined;
	ctx.ui.setFooter(undefined);
}

export function syncUsageFooter(ctx: ExtensionContext): void {
	if (!ctx.hasUI) return;
	if (hasMatchingChip(ctx.model)) {
		installUsageFooter(ctx);
		return;
	}
	uninstallUsageFooter(ctx);
}

function hasMatchingChip(model: ExtensionContext["model"]): boolean {
	for (const chip of getState().chips.values()) {
		if (chip.matches(model)) return true;
	}
	return false;
}

function chipLabel(model: ExtensionContext["model"]): string | undefined {
	for (const chip of getState().chips.values()) {
		if (chip.matches(model)) return chip.label(model);
	}
	return undefined;
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

function installUsageFooter(ctx: ExtensionContext): void {
	const state = getState();
	if (!ctx.hasUI || state.footerInstalled) return;
	state.footerInstalled = true;

	ctx.ui.setFooter((tui, theme, footerData) => {
		state.requestRender = () => tui.requestRender();
		const unsub = footerData.onBranchChange(() => tui.requestRender());

		return {
			dispose() {
				unsub();
				state.requestRender = undefined;
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

				const chip = chipLabel(model);
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
