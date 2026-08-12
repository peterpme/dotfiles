import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const TIMEOUT_MS = 10_000;

export default function prUrlExtension(pi: ExtensionAPI): void {
	pi.registerCommand("pr-url", {
		description: "Show the open GitHub pull request URL for the current branch",
		handler: async (_args, ctx) => {
			try {
				const result = await pi.exec("gh", ["pr", "view", "--json", "state,url"], {
					cwd: ctx.cwd,
					timeout: TIMEOUT_MS,
				});

				if (result.code !== 0) {
					const details = result.stderr.trim() || `gh exited with code ${result.code}`;
					ctx.ui.notify(`pr-url: ${details}`, "error");
					return;
				}

				const pullRequest = JSON.parse(result.stdout) as { state?: string; url?: string };
				if (pullRequest.state !== "OPEN" || !pullRequest.url) {
					ctx.ui.notify("pr-url: no open pull request for the current branch", "error");
					return;
				}

				ctx.ui.notify(pullRequest.url, "info");
			} catch (error) {
				const details = error instanceof Error ? error.message : String(error);
				ctx.ui.notify(`pr-url: ${details}`, "error");
			}
		},
	});
}
