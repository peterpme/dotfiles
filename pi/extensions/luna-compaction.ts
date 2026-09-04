/**
 * Compaction model
 *
 * Always summarize with GPT-5.6 Luna at high thinking, regardless of the
 * session model. Uses pi's default compaction prompt and cut point.
 */

import { compact, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";

const LUNA_ID = "gpt-5.6-luna";
const THINKING_LEVEL = "high" as const;
const LUNA_PROVIDERS = ["openai-codex", "openai-codex-2", "openai"] as const;

function findLuna(ctx: ExtensionContext) {
	if (ctx.model?.id === LUNA_ID && ctx.modelRegistry.hasConfiguredAuth(ctx.model)) {
		return ctx.model;
	}

	for (const provider of LUNA_PROVIDERS) {
		const model = ctx.modelRegistry.find(provider, LUNA_ID);
		if (model && ctx.modelRegistry.hasConfiguredAuth(model)) return model;
	}

	return ctx.modelRegistry
		.getAvailable()
		.find((model) => model.id === LUNA_ID && ctx.modelRegistry.hasConfiguredAuth(model));
}

export default function lunaCompaction(pi: ExtensionAPI) {
	pi.on("session_before_compact", async (event, ctx) => {
		const { preparation, customInstructions, signal } = event;
		const model = findLuna(ctx);

		if (!model) {
			ctx.ui.notify("luna-compaction: gpt-5.6-luna not found, using session model", "warning");
			return;
		}

		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok) {
			ctx.ui.notify(`luna-compaction: ${auth.error}`, "warning");
			return;
		}

		const requestModel = auth.baseUrl ? { ...model, baseUrl: auth.baseUrl } : model;
		ctx.ui.notify(`Compacting with ${model.provider}/${model.id} (${THINKING_LEVEL})`, "info");

		try {
			const result = await compact(
				preparation,
				requestModel,
				auth.apiKey,
				auth.headers,
				customInstructions,
				signal,
				THINKING_LEVEL,
				undefined,
				auth.env,
			);

			if (!result.summary.trim()) {
				if (!signal.aborted) {
					ctx.ui.notify("luna-compaction: empty summary, using session model", "warning");
				}
				return;
			}

			return { compaction: result };
		} catch (error) {
			if (signal.aborted) return;
			const message = error instanceof Error ? error.message : String(error);
			ctx.ui.notify(`luna-compaction: ${message}`, "error");
		}
	});
}
