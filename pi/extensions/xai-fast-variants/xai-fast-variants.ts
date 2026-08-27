import type { Api, Model } from "@earendil-works/pi-ai";

export const XAI_FAST_VARIANT_SUFFIX = "-fast";
export const XAI_HOST_RE = /(?:^|[./])(?:api\.x\.ai|cli-chat-proxy\.grok\.com)(?:$|[/:])/i;

export type XaiModel = Model<"openai-completions"> | Model<"openai-responses">;

/** True when a built-in model is an xAI Grok endpoint that accepts Priority Processing. */
export function isXaiFastEligibleModel(model: Model<Api>): model is XaiModel {
	if (model.provider !== "xai") return false;
	if (model.api !== "openai-completions" && model.api !== "openai-responses") return false;
	if (!model.id.toLowerCase().startsWith("grok-")) return false;
	return XAI_HOST_RE.test(model.baseUrl);
}

/** Create selectable `-fast` variants for built-in xAI models that support Priority Processing. */
export function createXaiFastVariantModels(
	baseModels: readonly XaiModel[],
	fastCapableModelIds: ReadonlySet<string>,
): readonly XaiModel[] {
	const baseModelIds = new Set(baseModels.map((model) => model.id));
	return baseModels.flatMap((model) => {
		if (!fastCapableModelIds.has(model.id)) return [];
		const variantId = `${model.id}${XAI_FAST_VARIANT_SUFFIX}`;
		if (baseModelIds.has(variantId)) return [];
		return [{ ...model, id: variantId, name: `${model.name} (Fast)` }];
	});
}

/** Resolve a visible Fast Mode variant to an exact model in the built-in xAI catalog. */
export function resolveXaiFastUpstreamModelId(
	visibleModelId: string,
	baseModels: readonly Model<Api>[],
): string | undefined {
	if (!visibleModelId.endsWith(XAI_FAST_VARIANT_SUFFIX)) return undefined;
	const upstreamModelId = visibleModelId.slice(0, -XAI_FAST_VARIANT_SUFFIX.length);
	return baseModels.some(
		(model) =>
			model.id === upstreamModelId &&
			`${model.id}${XAI_FAST_VARIANT_SUFFIX}` === visibleModelId,
	)
		? upstreamModelId
		: undefined;
}

/** Rebuild cached Fast Mode variants with metadata from the current built-in xAI catalog. */
export function restoreXaiFastVariantModels(
	baseModels: readonly XaiModel[],
	storedModels: readonly Model<Api>[],
): readonly XaiModel[] {
	const storedUpstreamModelIds = new Set(
		storedModels.flatMap((model) => {
			if (model.provider !== "xai") return [];
			const upstreamModelId = resolveXaiFastUpstreamModelId(model.id, baseModels);
			return upstreamModelId ? [upstreamModelId] : [];
		}),
	);
	return createXaiFastVariantModels(baseModels, storedUpstreamModelIds);
}
