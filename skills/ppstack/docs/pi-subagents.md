# Pi subagents for ppstack

The installed `pi-subagents` package owns agent discovery, child execution, workflows, worktrees, missions, councils, waiting, recovery, and result delivery. Read its installed guide with `/subagents-guide` or `subagent({ action: "guide", topic: "workflows" })`.

ppstack adds two personas. `petey-agent` writes with Petey policy. `comment-sicko` performs read-only comment review. It also adds two read-only council profiles. Builtin `scout`, `researcher`, `worker`, `reviewer`, and `oracle` keep their package jobs.

Model, thinking, context, fallback, and output overrides live only in `pi/settings.json`. The repository-level `docs/model-routing.md` is the generated explanation of those settings.

Fresh children need standalone briefs. A writer brief names the goal, scope, repository paths, authority, acceptance checks, verification commands, and report shape. A council gives both advisors the same neutral brief. The parent builds the claim matrix, curates any cross-exam, and writes the verdict.

The parent also materializes review evidence. Read-only agents receive named paths, patches, command output, and test results instead of instructions to discover change state through Git. Missing evidence produces `MISSING EVIDENCE` with the exact artifact or parent command required.

Fresh context does not isolate filesystem writes. Keep one writer per checkout or give each writer a separate worktree.
