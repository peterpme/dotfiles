import { createAssistantMessageEventStream } from "@earendil-works/pi-ai";
import type {
  AssistantMessage,
  AssistantMessageEvent,
  AssistantMessageEventStream,
  Context,
  Model,
  OAuthAuth,
  Provider,
  ProviderAuth,
} from "@earendil-works/pi-ai";
import { builtinProviders } from "@earendil-works/pi-ai/providers/all";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const BUILTIN_CODEX_PROVIDER = "openai-codex";
const CODEX_API = "openai-codex-responses" as const;

/**
 * Each alias gets its own entry in Pi's auth.json while reusing Pi's native
 * Codex OAuth, model catalog, token refresh, and streaming implementation.
 */
const ALIASES = [
  {
    id: "codex-bp-work",
    name: "Codex — BP Work",
  },
  {
    id: "codex-peterpme-work",
    name: "Codex — peterpme Work",
  },
] as const;

export default function codexWorkspaces(pi: ExtensionAPI) {
  const codexProvider = getBuiltinCodexProvider();

  for (const alias of ALIASES) {
    pi.registerProvider(
      createCodexAliasProvider(codexProvider, alias.id, alias.name),
    );
  }
}

function getBuiltinCodexProvider(): Provider<typeof CODEX_API> {
  const provider = builtinProviders().find(
    (candidate) => candidate.id === BUILTIN_CODEX_PROVIDER,
  );

  if (!provider) {
    throw new Error("Pi's built-in OpenAI Codex provider is unavailable.");
  }
  if (!provider.auth.oauth) {
    throw new Error("Pi's built-in OpenAI Codex provider does not expose OAuth.");
  }

  return provider as Provider<typeof CODEX_API>;
}

function createCodexAliasProvider(
  codexProvider: Provider<typeof CODEX_API>,
  providerId: string,
  displayName: string,
): Provider<typeof CODEX_API> {
  const models = codexProvider.getModels().map((model) => ({
    ...model,
    provider: providerId,
    name: `${model.name ?? model.id} (${displayName})`,
  }));

  return {
    id: providerId,
    name: displayName,
    baseUrl: codexProvider.baseUrl,
    headers: codexProvider.headers,
    auth: createAliasAuth(codexProvider.auth, displayName),
    getModels: () => models,
    stream(model, context, options) {
      const inner = codexProvider.stream(
        toBuiltinCodexModel(model),
        normalizeCodexAliasContext(context, providerId),
        options,
      );
      return rewriteStreamProvider(inner, providerId);
    },
    streamSimple(model, context, options) {
      const inner = codexProvider.streamSimple(
        toBuiltinCodexModel(model),
        normalizeCodexAliasContext(context, providerId),
        options,
      );
      return rewriteStreamProvider(inner, providerId);
    },
  };
}

function createAliasAuth(auth: ProviderAuth, displayName: string): ProviderAuth {
  const oauth = auth.oauth;
  if (!oauth) {
    throw new Error("Pi's built-in OpenAI Codex provider does not expose OAuth.");
  }

  const aliasOAuth: OAuthAuth = {
    ...oauth,
    name: displayName,
  };

  return {
    ...auth,
    oauth: aliasOAuth,
  };
}

function toBuiltinCodexModel(
  model: Model<typeof CODEX_API>,
): Model<typeof CODEX_API> {
  return {
    ...model,
    provider: BUILTIN_CODEX_PROVIDER,
    api: CODEX_API,
  };
}

function normalizeCodexAliasContext(
  context: Context,
  providerId: string,
): Context {
  return {
    ...context,
    messages: context.messages.map((message) => {
      if (message.role !== "assistant" || message.provider !== providerId) {
        return message;
      }

      return {
        ...message,
        provider: BUILTIN_CODEX_PROVIDER,
      };
    }),
  };
}

function rewriteStreamProvider(
  inner: AssistantMessageEventStream,
  providerId: string,
): AssistantMessageEventStream {
  const outer = createAssistantMessageEventStream();

  void (async () => {
    for await (const event of inner) {
      outer.push(rewriteEventProvider(event, providerId));
    }
  })();

  return outer;
}

function rewriteEventProvider(
  event: AssistantMessageEvent,
  providerId: string,
): AssistantMessageEvent {
  const eventWithMessages = event as AssistantMessageEvent & {
    partial?: AssistantMessage;
    message?: AssistantMessage;
    error?: AssistantMessage;
  };

  if (eventWithMessages.partial) {
    eventWithMessages.partial.provider = providerId;
  }
  if (eventWithMessages.message) {
    eventWithMessages.message.provider = providerId;
  }
  if (eventWithMessages.error) {
    eventWithMessages.error.provider = providerId;
  }

  return event;
}
