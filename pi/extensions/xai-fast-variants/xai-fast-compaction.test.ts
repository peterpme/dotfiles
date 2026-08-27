import assert from "node:assert/strict";
import test from "node:test";

import {
	createAssistantMessageEventStream,
	getModels,
	registerApiProvider,
	resetApiProviders,
	streamSimple as streamSimpleByApi,
} from "@earendil-works/pi-ai/compat";
import {
	generateSummaryWithUsage,
	type ExtensionAPI,
	type ProviderConfig,
} from "@earendil-works/pi-coding-agent";

import { createXaiFastVariantsExtension } from "./index.ts";

test("compaction sends the upstream xAI model with priority service tier", async () => {
	let providerConfig: ProviderConfig | undefined;
	const recordingApi = {
		registerProvider(_providerName: string, config: ProviderConfig) {
			providerConfig = config;
		},
		on() {},
	};
	// SAFETY: The extension uses only registerProvider and on; recordingApi faithfully supplies both operations for this integration test.
	const pi = recordingApi as unknown as ExtensionAPI;
	createXaiFastVariantsExtension()(pi);

	const upstreamModel = getModels("xai")[0];
	assert.ok(upstreamModel);
	assert.ok(providerConfig);
	const fastModel = {
		...upstreamModel,
		id: `${upstreamModel.id}-fast`,
		name: `${upstreamModel.name} (Fast)`,
	};
	const streamFn = providerConfig.streamSimple ?? streamSimpleByApi;
	let observedPayload: Readonly<Record<string, unknown>> | undefined;
	let observedStreamModelId: string | undefined;
	const fakeXaiStream = (
		model: typeof fastModel,
		_context: unknown,
		options: {
			readonly onPayload?: (payload: unknown, model: typeof fastModel) => unknown;
		} = {},
	) => {
		const stream = createAssistantMessageEventStream();
		observedStreamModelId = model.id;
		void (async () => {
			const initialPayload = { model: model.id };
			const transformed = (await options.onPayload?.(initialPayload, model)) ?? initialPayload;
			assert.equal(typeof transformed, "object");
			assert.ok(transformed);
			observedPayload = transformed as Readonly<Record<string, unknown>>;
			const usage = {
				input: 1,
				output: 1,
				cacheRead: 0,
				cacheWrite: 0,
				totalTokens: 2,
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
			};
			stream.push({
				type: "done",
				reason: "stop",
				message: {
					role: "assistant",
					content: [{ type: "text", text: "summary" }],
					api: model.api,
					provider: model.provider,
					model: model.id,
					usage,
					stopReason: "stop",
					timestamp: 2,
				},
			});
			stream.end();
		})();
		return stream;
	};
	// SAFETY: The fake accepts the same model, context, and option capabilities exercised by compaction and returns a real Pi event stream.
	const streamXai = fakeXaiStream as Parameters<typeof registerApiProvider>[0]["streamSimple"];
	registerApiProvider(
		{
			api: upstreamModel.api,
			stream: streamXai,
			streamSimple: streamXai,
		},
		"xai-fast-compaction-test",
	);
	try {
		const result = await generateSummaryWithUsage(
			[{ role: "user", content: "Summarize this", timestamp: 1 }],
			fastModel,
			1_000,
			"test-key",
			undefined,
			new AbortController().signal,
			undefined,
			undefined,
			"off",
			streamFn,
		);

		assert.equal(result.text, "summary");
		assert.equal(observedPayload?.model, upstreamModel.id);
		assert.equal(observedPayload?.service_tier, "priority");
		assert.equal(observedStreamModelId, fastModel.id);

		observedPayload = undefined;
		observedStreamModelId = undefined;
		const standardResult = await generateSummaryWithUsage(
			[{ role: "user", content: "Summarize this", timestamp: 1 }],
			upstreamModel,
			1_000,
			"test-key",
			undefined,
			new AbortController().signal,
			undefined,
			undefined,
			"off",
			streamFn,
		);
		assert.equal(standardResult.text, "summary");
		assert.deepEqual(observedPayload, { model: upstreamModel.id });
		assert.equal(observedStreamModelId, upstreamModel.id);
	} finally {
		resetApiProviders();
	}
});
