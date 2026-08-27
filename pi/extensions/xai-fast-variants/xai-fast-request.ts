import type { Api, Model } from "@earendil-works/pi-ai";

import { resolveXaiFastUpstreamModelId } from "./xai-fast-variants.ts";
import { isJsonRecord } from "./json-record.ts";

/** Rewrite a selected xAI Fast variant to the real model and priority service tier. */
export function rewriteXaiFastRequestPayload(
	payload: unknown,
	visibleModelId: string,
	baseModels: readonly Model<Api>[],
): unknown {
	const upstreamModelId = resolveXaiFastUpstreamModelId(visibleModelId, baseModels);
	if (!upstreamModelId) return payload;
	if (!isJsonRecord(payload)) {
		throw new Error("xAI Fast request payload must be a JSON object");
	}
	return { ...payload, model: upstreamModelId, service_tier: "priority" };
}
