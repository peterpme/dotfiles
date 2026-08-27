import type {
	Api,
	AssistantMessageEventStream,
	Context,
	Model,
	SimpleStreamOptions,
} from "@earendil-works/pi-ai";
import { streamSimple as streamSimpleByApi } from "@earendil-works/pi-ai/compat";

import { rewriteXaiFastRequestPayload } from "./xai-fast-request.ts";
import { resolveXaiFastUpstreamModelId } from "./xai-fast-variants.ts";

/** Create the xAI stream wrapper that applies Fast routing to every request path, including compaction. */
export function createXaiFastStream(
	baseModels: readonly Model<Api>[],
): (
	model: Model<Api>,
	context: Context,
	options?: SimpleStreamOptions,
) => AssistantMessageEventStream {
	return (visibleModel, context, options = {}) => {
		const upstreamModelId = resolveXaiFastUpstreamModelId(visibleModel.id, baseModels);
		if (!upstreamModelId) {
			return streamSimpleByApi(visibleModel, context, options);
		}

		const callerOnPayload = options.onPayload;
		return streamSimpleByApi(visibleModel, context, {
			...options,
			onPayload: async (payload, requestModel) => {
				const callerPayload = (await callerOnPayload?.(payload, requestModel)) ?? payload;
				return rewriteXaiFastRequestPayload(callerPayload, visibleModel.id, baseModels);
			},
		});
	};
}
