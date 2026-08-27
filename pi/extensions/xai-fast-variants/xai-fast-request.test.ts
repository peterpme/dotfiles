import assert from "node:assert/strict";
import test from "node:test";

import type { Model } from "@earendil-works/pi-ai";

import { rewriteXaiFastRequestPayload } from "./xai-fast-request.ts";
import {
	createXaiFastVariantModels,
	isXaiFastEligibleModel,
	resolveXaiFastUpstreamModelId,
	restoreXaiFastVariantModels,
} from "./xai-fast-variants.ts";

function createTestXaiModel(id: string, baseUrl = "https://api.x.ai/v1"): Model<"openai-completions"> {
	return {
		id,
		name: "Test Grok Model",
		api: "openai-completions",
		provider: "xai",
		baseUrl,
		reasoning: true,
		input: ["text"],
		cost: { input: 1, output: 2, cacheRead: 0.1, cacheWrite: 0 },
		contextWindow: 128_000,
		maxTokens: 16_000,
	};
}

test("createXaiFastVariantModels clones only advertised built-in models", () => {
	const models = [createTestXaiModel("grok-a"), createTestXaiModel("grok-b")];
	const variants = createXaiFastVariantModels(models, new Set(["grok-b", "unknown-model"]));

	assert.deepEqual(
		variants.map(({ id, name }) => ({ id, name })),
		[{ id: "grok-b-fast", name: "Test Grok Model (Fast)" }],
	);
	assert.equal(resolveXaiFastUpstreamModelId("grok-b-fast", models), "grok-b");
	assert.equal(resolveXaiFastUpstreamModelId("unknown-model-fast", models), undefined);
});

test("isXaiFastEligibleModel requires grok ids on an xAI host", () => {
	assert.equal(isXaiFastEligibleModel(createTestXaiModel("grok-4.6")), true);
	assert.equal(
		isXaiFastEligibleModel(createTestXaiModel("grok-4.6", "https://cli-chat-proxy.grok.com/v1")),
		true,
	);
	assert.equal(isXaiFastEligibleModel(createTestXaiModel("not-grok")), false);
	assert.equal(
		isXaiFastEligibleModel(createTestXaiModel("grok-4.6", "https://example.com/v1")),
		false,
	);
});

test("restoreXaiFastVariantModels refreshes cached variants from current base metadata", () => {
	const current = createTestXaiModel("grok-a");
	const stale = { ...current, id: "grok-a-fast", name: "Stale Name" };
	const restored = restoreXaiFastVariantModels([current], [stale]);

	assert.equal(restored.length, 1);
	assert.equal(restored[0]?.name, "Test Grok Model (Fast)");
});

test("xAI Fast request helpers send the upstream model with priority service tier", () => {
	const models = [createTestXaiModel("grok-a")];
	const payload = rewriteXaiFastRequestPayload(
		{ model: "grok-a-fast", input: "hello" },
		"grok-a-fast",
		models,
	);

	assert.deepEqual(payload, {
		model: "grok-a",
		input: "hello",
		service_tier: "priority",
	});
});

test("rewriteXaiFastRequestPayload leaves standard requests unchanged", () => {
	const models = [createTestXaiModel("grok-a")];
	const payload = { model: "grok-a", input: "hello" };

	assert.equal(rewriteXaiFastRequestPayload(payload, "grok-a", models), payload);
});

test("rewriteXaiFastRequestPayload rejects an impossible non-object Fast request", () => {
	const models = [createTestXaiModel("grok-a")];
	assert.throws(
		() => rewriteXaiFastRequestPayload("invalid", "grok-a-fast", models),
		/xAI Fast request payload must be a JSON object/,
	);
});
