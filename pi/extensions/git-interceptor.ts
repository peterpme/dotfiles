/**
 * Git Interceptor
 *
 * Guards agent-driven git/gh commands so unattended coding work cannot hang on
 * an editor, bypass repository hooks, or accidentally land changes directly on
 * protected branches. This keeps automation safe while preserving the normal
 * feature-branch and pull-request workflow.
 *
 * Guards for agent-driven git/gh commands:
 *
 * 1. Editor hang prevention — Sets GIT_EDITOR, GIT_SEQUENCE_EDITOR to `true`
 *    (no-op) and GIT_MERGE_AUTOEDIT to `no` so git never spawns an interactive
 *    editor (nvim, vim, etc.) that would hang the bash process.
 *
 * 2. Hook bypass prevention — Blocks any command containing `--no-verify` so
 *    the agent cannot circumvent git hooks (pre-commit, commit-msg, etc.).
 *
 * 3. Protected-branch protection — Blocks direct pushes to main/master and
 *    merges into main/master (git merge/pull while on those branches, plus
 *    `gh pr merge`). Agents should push a feature branch and open a PR;
 *    a human lands it on the default branch.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

const GIT_ENV_PREFIX =
	"export GIT_EDITOR=true GIT_SEQUENCE_EDITOR=true GIT_MERGE_AUTOEDIT=no\n";

const PROTECTED_BRANCHES = new Set(["main", "master"]);

const NO_VERIFY_RE = /--no-verify\b/;

const NO_VERIFY_REASON =
	"BLOCKED: --no-verify is not allowed. Git hooks exist for a reason. " +
	"Do not attempt to bypass them. Instead: fix the underlying issue that " +
	"is causing the hook to fail, or ask the user for help.";

const PUSH_REASON =
	"BLOCKED: direct pushes to main/master are not allowed. " +
	"Push a feature branch and open a pull request instead. " +
	"A human should review and merge into the default branch.";

const MERGE_REASON =
	"BLOCKED: merging into main/master is not allowed. " +
	"Stay on a feature branch, open or update a pull request, and let a " +
	"human merge it. Do not git merge/pull into main/master or land PRs.";

const PR_MERGE_REASON =
	"BLOCKED: automatically merging pull requests is not allowed. " +
	"Leave the PR open for human review and merge.";

const SHELL_TOOLS = new Set(["bash", "hypa_shell"]);

/** Options that consume the following CLI argument for `git push`. */
const PUSH_OPTIONS_WITH_VALUE = new Set([
	"-o",
	"--push-option",
	"--receive-pack",
	"--exec",
	"--repo",
	"-c",
	"--signed",
]);

/** Options that consume the following CLI argument for `git merge` / `git pull`. */
const MERGE_PULL_OPTIONS_WITH_VALUE = new Set([
	"-m",
	"-s",
	"--strategy",
	"-X",
	"--strategy-option",
	"--into-name",
	"--cleanup",
	"--log",
	"--rebase",
	"--depth",
	"--shallow-since",
	"--shallow-exclude",
	"-j",
	"--jobs",
	"--negotiation-tip",
	"-c",
	"--server-option",
	"--upload-pack",
	"-o",
	"--push-option",
	"--recurse-submodules",
]);

type BlockResult = { block: true; reason: string };

function normalizeCommand(command: string): string {
	return command.replace(/\\\r?\n/g, " ");
}

function stripQuotes(token: string): string {
	if (
		(token.startsWith("'") && token.endsWith("'")) ||
		(token.startsWith('"') && token.endsWith('"'))
	) {
		return token.slice(1, -1);
	}
	return token;
}

/** Lightweight shell tokenizer. Good enough for agent-issued git/gh commands. */
function tokenize(segment: string): string[] {
	const tokens: string[] = [];
	const re = /'[^']*'|"[^"]*"|\S+/g;
	let match: RegExpExecArray | null;
	while ((match = re.exec(segment)) !== null) {
		tokens.push(stripQuotes(match[0]));
	}
	return tokens;
}

function splitShellSegments(command: string): string[] {
	return normalizeCommand(command)
		.split(/(?:&&|\|\||[;|\n]|(?<!&)&(?!&))/)
		.map((s) => s.trim())
		.filter(Boolean);
}

function isProtectedBranchName(name: string | null | undefined): boolean {
	if (!name) return false;
	return PROTECTED_BRANCHES.has(name.trim().toLowerCase());
}

/**
 * Resolve the destination branch from a git push refspec.
 * Examples:
 *   main              -> main
 *   +main             -> main
 *   HEAD:main         -> main
 *   feature:main      -> main
 *   refs/heads/main   -> main
 *   +refs/heads/foo:refs/heads/main -> main
 */
function pushRefspecDestination(refspec: string): string {
	let spec = refspec.trim();
	if (spec.startsWith("+")) spec = spec.slice(1);

	const colon = spec.lastIndexOf(":");
	const dest = colon === -1 ? spec : spec.slice(colon + 1);

	return dest
		.replace(/^refs\/heads\//i, "")
		.replace(/^refs\/remotes\/[^/]+\//i, "")
		.trim();
}

function isProtectedRefName(ref: string): boolean {
	const cleaned = ref
		.replace(/^refs\/heads\//i, "")
		.replace(/^refs\/remotes\/[^/]+\//i, "")
		.replace(/^\.\//, "")
		.trim()
		.toLowerCase();

	// origin/main, upstream/master, etc.
	const short = cleaned.includes("/") ? cleaned.split("/").pop()! : cleaned;
	return isProtectedBranchName(short) || isProtectedBranchName(cleaned);
}

async function getCurrentBranch(
	pi: ExtensionAPI,
	ctx: ExtensionContext,
): Promise<string | null> {
	try {
		const result = await pi.exec("git", ["rev-parse", "--abbrev-ref", "HEAD"], {
			cwd: ctx.cwd,
			timeout: 3000,
			signal: ctx.signal,
		});
		if (result.code !== 0) return null;
		const branch = result.stdout.trim();
		if (!branch || branch === "HEAD") return null;
		return branch;
	} catch {
		return null;
	}
}

/**
 * Skip leading env assignments / wrappers:
 *   FOO=bar git push
 *   env FOO=bar git push
 *   command git push
 *   sudo git push
 */
function findBinIndex(tokens: string[], bin: string): number {
	for (let i = 0; i < tokens.length; i++) {
		const t = tokens[i];
		if (t === bin) return i;
		if (t === "sudo" || t === "command" || t === "exec") continue;
		if (t === "env") {
			// skip env VAR=val pairs
			let j = i + 1;
			while (j < tokens.length && (tokens[j].includes("=") || tokens[j].startsWith("-"))) {
				j++;
			}
			i = j - 1;
			continue;
		}
		if (t.includes("=") && !t.startsWith("-")) continue; // VAR=value
		// once we hit a real command that isn't bin, stop looking in this segment
		if (!t.startsWith("-")) return -1;
	}
	return -1;
}

function collectPositionalArgs(
	tokens: string[],
	startIdx: number,
	optionsWithValue: Set<string>,
): { flags: Set<string>; positionals: string[] } {
	const flags = new Set<string>();
	const positionals: string[] = [];

	for (let i = startIdx; i < tokens.length; i++) {
		const t = tokens[i];
		if (t === "--") {
			positionals.push(...tokens.slice(i + 1));
			break;
		}
		if (t.startsWith("-")) {
			const eq = t.indexOf("=");
			const flag = eq === -1 ? t : t.slice(0, eq);
			flags.add(flag);
			// bundled short flags like -fu don't take values as a unit beyond known long/short
			if (eq === -1 && optionsWithValue.has(flag) && i + 1 < tokens.length) {
				i++;
			}
			continue;
		}
		positionals.push(t);
	}

	return { flags, positionals };
}

async function checkGitPush(
	tokens: string[],
	binIndex: number,
	pi: ExtensionAPI,
	ctx: ExtensionContext,
): Promise<BlockResult | undefined> {
	const { flags, positionals } = collectPositionalArgs(
		tokens,
		binIndex + 2, // after `git push`
		PUSH_OPTIONS_WITH_VALUE,
	);

	// --all / --mirror can update protected branches; refuse outright.
	if (flags.has("--all") || flags.has("--mirror")) {
		return { block: true, reason: PUSH_REASON };
	}

	const branch = await getCurrentBranch(pi, ctx);

	// git push [remote] [refspec...]
	// If any explicit refspec targets a protected branch, block.
	const refspecs = positionals.slice(1);
	if (refspecs.length > 0) {
		for (const spec of refspecs) {
			const dest = pushRefspecDestination(spec);
			// HEAD / @ resolves to the current branch
			const resolvesToCurrent = /^(HEAD|@)$/i.test(dest);
			if (
				isProtectedRefName(dest) ||
				(resolvesToCurrent && isProtectedBranchName(branch))
			) {
				return { block: true, reason: PUSH_REASON };
			}
		}
		return; // explicit non-protected refspecs are fine
	}

	// No refspec: pushes the current upstream / current branch.
	// Also covers: git push, git push origin, git push -u origin
	if (isProtectedBranchName(branch)) {
		return { block: true, reason: PUSH_REASON };
	}

	return;
}

async function checkGitMergeOrPull(
	tokens: string[],
	binIndex: number,
	subcommand: "merge" | "pull",
	pi: ExtensionAPI,
	ctx: ExtensionContext,
): Promise<BlockResult | undefined> {
	const { flags, positionals } = collectPositionalArgs(
		tokens,
		binIndex + 2,
		MERGE_PULL_OPTIONS_WITH_VALUE,
	);

	// Abort/continue/help paths are fine even on protected branches.
	if (
		flags.has("--abort") ||
		flags.has("--continue") ||
		flags.has("--quit") ||
		flags.has("--version") ||
		flags.has("--help") ||
		flags.has("-h")
	) {
		return;
	}

	const branch = await getCurrentBranch(pi, ctx);
	if (!isProtectedBranchName(branch)) return;

	if (subcommand === "merge") {
		// Any merge while checked out on main/master lands commits onto it.
		return { block: true, reason: MERGE_REASON };
	}

	// git pull [repository] [refspec...]
	// Allow plain upstream sync on main/master (no explicit foreign refspecs).
	// Block pulls that merge another branch into the protected branch.
	const refspecs = positionals.slice(1);
	if (refspecs.length === 0) return;

	for (const spec of refspecs) {
		const dest = pushRefspecDestination(spec);
		// pulling main into main is sync; pulling feature into main is a land
		if (!isProtectedRefName(dest) && dest.toLowerCase() !== "head") {
			return {
				block: true,
				reason: `${MERGE_REASON} (blocked git pull of '${spec}' into ${branch})`,
			};
		}
	}

	return;
}

function checkGhPrMerge(tokens: string[], binIndex: number): BlockResult | undefined {
	// gh pr merge [number] [flags]
	// Always block: PR bases are almost always main/master, and auto-merge is
	// exactly what this guard is meant to stop.
	void tokens;
	void binIndex;
	return { block: true, reason: PR_MERGE_REASON };
}

async function findProtectedBranchViolation(
	command: string,
	pi: ExtensionAPI,
	ctx: ExtensionContext,
): Promise<BlockResult | undefined> {
	// Fast path: skip if neither git nor gh appears.
	if (!/\b(?:git|gh)\b/.test(command)) return;

	for (const segment of splitShellSegments(command)) {
		const tokens = tokenize(segment);
		if (tokens.length === 0) continue;

		const gitIdx = findBinIndex(tokens, "git");
		if (gitIdx !== -1 && gitIdx + 1 < tokens.length) {
			const sub = tokens[gitIdx + 1];
			if (sub === "push") {
				const blocked = await checkGitPush(tokens, gitIdx, pi, ctx);
				if (blocked) return blocked;
			} else if (sub === "merge" || sub === "pull") {
				const blocked = await checkGitMergeOrPull(tokens, gitIdx, sub, pi, ctx);
				if (blocked) return blocked;
			} else if (sub === "rebase") {
				// Rebase while on main/master rewrites the protected branch.
				const branch = await getCurrentBranch(pi, ctx);
				if (isProtectedBranchName(branch)) {
					const { flags } = collectPositionalArgs(
						tokens,
						gitIdx + 2,
						MERGE_PULL_OPTIONS_WITH_VALUE,
					);
					const allow =
						flags.has("--abort") ||
						flags.has("--continue") ||
						flags.has("--quit") ||
						flags.has("--skip");
					if (!allow) {
						return { block: true, reason: MERGE_REASON };
					}
				}
			}
		}

		const ghIdx = findBinIndex(tokens, "gh");
		if (ghIdx !== -1 && ghIdx + 2 < tokens.length) {
			if (tokens[ghIdx + 1] === "pr" && tokens[ghIdx + 2] === "merge") {
				const blocked = checkGhPrMerge(tokens, ghIdx);
				if (blocked) return blocked;
			}
		}
	}

	return;
}

function getShellCommand(event: { toolName: string; input: Record<string, unknown> }): string | null {
	if (!SHELL_TOOLS.has(event.toolName)) return null;
	const command = event.input.command;
	return typeof command === "string" ? command : null;
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		// Built-in bash (typed) + hypa_shell (custom)
		let command: string | null = null;

		if (isToolCallEventType("bash", event)) {
			command = event.input.command;
		} else {
			command = getShellCommand(event as { toolName: string; input: Record<string, unknown> });
		}

		if (!command) return;

		// 1) Hook bypass
		if (NO_VERIFY_RE.test(command)) {
			if (ctx.hasUI) {
				ctx.ui.notify("Blocked --no-verify", "warning");
			}
			return { block: true, reason: NO_VERIFY_REASON };
		}

		// 2) Protected branch push/merge
		if (/\b(?:git|gh)\b/.test(command)) {
			const blocked = await findProtectedBranchViolation(command, pi, ctx);
			if (blocked) {
				if (ctx.hasUI) {
					ctx.ui.notify("Blocked protected-branch push/merge", "warning");
				}
				return blocked;
			}
		}

		// 3) Editor hang prevention for any git-touching shell command
		if (command.includes("git")) {
			if (isToolCallEventType("bash", event)) {
				event.input.command = GIT_ENV_PREFIX + event.input.command;
			} else if (event.toolName === "hypa_shell" && event.input && typeof event.input === "object") {
				const input = event.input as { command?: string };
				if (typeof input.command === "string") {
					input.command = GIT_ENV_PREFIX + input.command;
				}
			}
		}
	});
}
