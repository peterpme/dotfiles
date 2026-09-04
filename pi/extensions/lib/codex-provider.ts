const CODEX_PROVIDER_RE = /^openai-codex(-\d+)?$/;

/** Pi's built-in Codex provider plus the numbered seats pi-codex-multi registers. */
export function isCodexProvider(provider: string | undefined): boolean {
	return provider !== undefined && CODEX_PROVIDER_RE.test(provider);
}
