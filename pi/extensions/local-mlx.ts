/**
 * Local MLX picker labels.
 *
 * models.json exposes `local / qwen3.8-27b-uncensored-mlx-8bit`.
 * The alias proxy on :18766 also rewrites that id to the folder path.
 * This rewrite is a fallback if a client hits mlx-vlm (:18765) directly.
 */

import type {
  Api,
  AssistantMessageEventStream,
  Context,
  Model,
  SimpleStreamOptions,
} from "@earendil-works/pi-ai";
import { streamSimple as streamSimpleByApi } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DISPLAY_PROVIDER = "local";
const DISPLAY_IDS = new Set([
  "qwen3.8-27b-uncensored-mlx-8bit",
  "qwen3.8-27b",
]);
const UPSTREAM_MODEL_ID = "/Users/peter/models/Qwen3.8-27B-Uncensored-MLX/8-bit";

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function rewriteLocalRequestPayload(payload: unknown): unknown {
  if (!isRecord(payload) || !DISPLAY_IDS.has(String(payload.model))) return payload;
  return { ...payload, model: UPSTREAM_MODEL_ID };
}

function createLocalStream(): (
  model: Model<Api>,
  context: Context,
  options?: SimpleStreamOptions,
) => AssistantMessageEventStream {
  return (visibleModel, context, options = {}) => {
    const callerOnPayload = options.onPayload;
    return streamSimpleByApi(visibleModel, context, {
      ...options,
      onPayload: async (payload, requestModel) => {
        const callerPayload = (await callerOnPayload?.(payload, requestModel)) ?? payload;
        return rewriteLocalRequestPayload(callerPayload);
      },
    });
  };
}

export default function localMlxExtension(pi: ExtensionAPI) {
  pi.registerProvider(DISPLAY_PROVIDER, {
    api: "openai-completions",
    streamSimple: createLocalStream(),
  });
}
