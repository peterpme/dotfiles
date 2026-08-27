import assert from "node:assert/strict";
import test from "node:test";

import { getModels } from "@earendil-works/pi-ai/compat";
import type {
	ExtensionAPI,
	ProviderConfig,
	ProviderModelConfig,
} from "@earendil-works/pi-coding-agent";

import { createXaiFastVariantsExtension } from "./index.ts";
import { isXaiFastEligibleModel } from "./xai-fast-variants.ts";

function requireFastModel(
	catalog: readonly ProviderModelConfig[],
	baseModelId: string,
): ProviderModelConfig {
	const fastModel = catalog.find((model) => model.id === `${baseModelId}-fast`);
	assert.ok(fastModel);
	return fastModel;
}

test("extension publishes Fast variants for built-in Grok models and persists them", async () => {
	let registeredProviderName: string | undefined;
	let registeredProviderConfig: ProviderConfig | undefined;
	const recordingApi = {
		registerProvider(providerName: string, providerConfig: ProviderConfig) {
			registeredProviderName = providerName;
			registeredProviderConfig = providerConfig;
		},
		on() {},
	};
	// SAFETY: createXaiFastVariantsExtension uses only registerProvider; recordingApi faithfully implements that ExtensionAPI operation for this integration test.
	const pi = recordingApi as unknown as ExtensionAPI;
	const builtInModels = getModels("xai").filter(isXaiFastEligibleModel);
	assert.ok(builtInModels[0]);

	createXaiFastVariantsExtension()(pi);

	assert.equal(registeredProviderName, "xai");
	assert.ok(registeredProviderConfig?.models);
	assert.ok(registeredProviderConfig.refreshModels);
	const initialFast = requireFastModel(registeredProviderConfig.models, builtInModels[0].id);
	assert.equal(initialFast.api, builtInModels[0].api);

	let persistedModels: ProviderModelConfig[] | undefined;
	const refreshedCatalog = await registeredProviderConfig.refreshModels({
		allowNetwork: false,
		signal: new AbortController().signal,
		async publish(publication) {
			persistedModels = publication.persist && publication.persist !== null
				? [...publication.persist.models]
				: undefined;
			publication.update?.();
			return true;
		},
	});

	assert.equal(requireFastModel(refreshedCatalog, builtInModels[0].id).id, initialFast.id);
	assert.ok(persistedModels && persistedModels.length > 0);
});
