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
import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { createConnection } from "node:net";
import { dirname, join } from "node:path";
import { homedir } from "node:os";

const BUILTIN_CODEX_PROVIDER = "openai-codex";
const CODEX_API = "openai-codex-responses" as const;

/**
 * Each alias gets its own entry in Pi's auth.json while reusing Pi's native
 * Codex OAuth, model catalog, token refresh, and streaming implementation.
 *
 * Provider ids are the picker badges. Auth can be copied from a previous
 * provider id so existing logins keep working after a rename.
 */
const ALIASES = [
  {
    id: "peter@backpack.app",
    name: "peter@backpack.app",
    authSources: ["peter@backpack.app", "openai-codex"],
  },
  {
    id: "services+openai@peterp.me",
    name: "services+openai@peterp.me",
    authSources: ["services+openai@peterp.me"],
  },
  {
    id: "peter@backpack.exchange",
    name: "peter@backpack.exchange",
    // Deliberately do not copy another account's credentials.
    authSources: ["peter@backpack.exchange"],
  },
] as const;

type AuthStore = Record<string, unknown>;

export default function codexWorkspaces(pi: ExtensionAPI) {
  migrateCodexAuthAliases();
  const codexProvider = getBuiltinCodexProvider();

  for (const alias of ALIASES) {
    pi.registerProvider(
      createCodexAliasProvider(codexProvider, alias.id, alias.name),
    );
  }
}

function getAuthPath(): string {
  return join(homedir(), ".pi", "agent", "auth.json");
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function migrateCodexAuthAliases(): void {
  const authPath = getAuthPath();
  if (!existsSync(authPath)) return;

  let store: AuthStore;
  try {
    const parsed: unknown = JSON.parse(readFileSync(authPath, "utf8"));
    if (!isRecord(parsed)) return;
    store = parsed;
  } catch {
    return;
  }

  let changed = false;
  for (const alias of ALIASES) {
    if (isRecord(store[alias.id])) continue;
    const sourceId = alias.authSources.find((id) => id !== alias.id && isRecord(store[id]));
    if (!sourceId) continue;
    store[alias.id] = store[sourceId];
    changed = true;
  }

  if (!changed) return;

  mkdirSync(dirname(authPath), { recursive: true });
  copyFileSync(authPath, `${authPath}.bak`);
  writeFileSync(authPath, `${JSON.stringify(store, null, 2)}\n`);
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

async function isCodexCallbackPortBusy(): Promise<boolean> {
  return await new Promise((resolve) => {
    const socket = createConnection({ host: "127.0.0.1", port: 1455 });
    socket.once("connect", () => {
      socket.destroy();
      resolve(true);
    });
    socket.once("error", () => {
      socket.destroy();
      resolve(false);
    });
  });
}

function wrapCodexOAuth(oauth: OAuthAuth, displayName: string): OAuthAuth {
  return {
    ...oauth,
    name: displayName,
    async login(interaction) {
      if (await isCodexCallbackPortBusy()) {
        throw new Error(
          `Codex login for ${displayName} failed: port 1455 is already in use. Cancel the previous /login, then retry. A leftover callback there causes "Authentication failed, state mismatch".`,
        );
      }
      return oauth.login(interaction);
    },
  };
}

function createAliasAuth(auth: ProviderAuth, displayName: string): ProviderAuth {
  const oauth = auth.oauth;
  if (!oauth) {
    throw new Error("Pi's built-in OpenAI Codex provider does not expose OAuth.");
  }

  return {
    ...auth,
    oauth: wrapCodexOAuth(oauth, displayName),
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
