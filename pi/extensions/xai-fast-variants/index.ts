import { getModels } from "@earendil-works/pi-ai/compat";
import type { ExtensionFactory, ProviderModelConfig } from "@earendil-works/pi-coding-agent";

import { rewriteXaiFastRequestPayload } from "./xai-fast-request.ts";
import { createXaiFastStream } from "./xai-fast-stream.ts";
import {
	createXaiFastVariantModels,
	isXaiFastEligibleModel,
	restoreXaiFastVariantModels,
	type XaiModel,
} from "./xai-fast-variants.ts";

function toProviderModelConfig(model: XaiModel): ProviderModelConfig {
	return {
		id: model.id,
		name: model.name,
		api: model.api,
		baseUrl: model.baseUrl,
		reasoning: model.reasoning,
		thinkingLevelMap: model.thinkingLevelMap,
		input: [...model.input],
		cost: model.cost,
		contextWindow: model.contextWindow,
		maxTokens: model.maxTokens,
		compat: model.compat,
	};
}

function buildProviderModelCatalog(
	baseModels: readonly XaiModel[],
	fastVariants: readonly XaiModel[],
): ProviderModelConfig[] {
	return [...baseModels, ...fastVariants].map(toProviderModelConfig);
}

function eligibleModelIds(baseModels: readonly XaiModel[]): ReadonlySet<string> {
	return new Set(baseModels.filter(isXaiFastEligibleModel).map((model) => model.id));
}

/** Create a Pi extension that publishes selectable xAI `-fast` model variants. */
export function createXaiFastVariantsExtension(): ExtensionFactory {
	return (pi) => {
		const baseModels = getModels("xai").filter((model): model is XaiModel => {
			return (
				model.provider === "xai" &&
				(model.api === "openai-completions" || model.api === "openai-responses")
			);
		});
		const baseUrl = baseModels[0]?.baseUrl;
		if (!baseUrl) {
			throw new Error("xAI Fast built-in provider has no base URL");
		}

		const fastCapableModelIds = eligibleModelIds(baseModels);

		// streamSimple is only applied when model.api === this provider api.
		// Completions covers grok-4.6 / 4.3 / build; responses (grok-4.5) is rewritten below.
		pi.registerProvider("xai", {
			name: "xAI",
			api: "openai-completions",
			baseUrl,
			models: buildProviderModelCatalog(
				baseModels,
				createXaiFastVariantModels(baseModels, fastCapableModelIds),
			),
			streamSimple: createXaiFastStream(baseModels),
			async refreshModels(context) {
				const storedVariants = restoreXaiFastVariantModels(
					baseModels,
					context.stored?.models ?? [],
				);
				const freshVariants = createXaiFastVariantModels(baseModels, fastCapableModelIds);
				const variants = freshVariants.length > 0 ? freshVariants : storedVariants;
				await context.publish({
					persist: { models: variants },
				});
				return buildProviderModelCatalog(baseModels, variants);
			},
		});

		pi.on("before_provider_request", (event, ctx) => {
			if (ctx.model?.provider !== "xai") return;
			return rewriteXaiFastRequestPayload(event.payload, ctx.model.id, baseModels);
		});
	};
}

/** Register xAI Fast Mode variants. */
export default function xaiFastVariantsExtension(
	pi: Parameters<ExtensionFactory>[0],
): void {
	createXaiFastVariantsExtension()(pi);
}

