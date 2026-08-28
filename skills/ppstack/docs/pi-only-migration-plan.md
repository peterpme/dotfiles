# Pi-only migration record

## Decision

ppstack and Petey support Pi as their only active runtime. Pi owns the parent session and global configuration. The installed `pi-subagents` package owns child execution, contexts, workflows, worktrees, councils, missions, waiting, status, and recovery. Petey owns principles, playbooks, role selection, and task contracts.

`pi/settings.json` is the runtime source for model, thinking, context, fallback, tool, and output overrides. The generated `docs/model-routing.md` explains those settings without configuring them.

## Final role policy

- `scout`, `researcher`, `worker`, `petey-agent`, `reviewer`, `comment-sicko`, and `council-sol` use fresh context.
- `oracle` uses forked context for inherited decision consistency.
- Fresh writers receive standalone implementation briefs.
- Fresh reviewers receive named paths, materialized patches, command output, and test results.
- The parent chooses each council roster from fresh `council-sol`, fresh `reviewer`, and forked `oracle`; `oracle` joins only when inherited context matters.
- Council advisors receive the same neutral brief without peer opinions during the first pass.
- The parent owns evidence collection, claim synthesis, cross-exam packets, and final decisions.
- Read-only agents return `MISSING EVIDENCE` instead of reconstructing missing change state from `.git` internals.

The current model mapping and verification state are generated in `docs/model-routing.md`.

## Removed compatibility paths

The migration removed:

- `.cursor-plugin/` packaging.
- Cursor installation and model-rule instructions.
- Duplicate `explorer` and `search` agents.
- `skills/petey/references/spawn.md`.
- `skills/petey/references/models.md`.
- Per-run model selection in active skills.
- Model and thinking fields from custom agent frontmatter.
- Obsolete `autopilot-full` and `autopilot-stack` playbooks.
- Copied orchestration mechanics now owned by `pi-subagents`.

`docs/cursor-history.md` and Git history retain the historical record.

## Added enforcement

- `skills/setup-petey/SKILL.md` configures and verifies tracked Pi routing.
- `scripts/check-pi-only.ts` rejects active legacy runtime terms and duplicate selectors.
- `scripts/render-model-routing.ts` generates the routing explanation.
- `scripts/check-typescript-automation.ts` rejects JavaScript automation under `scripts/` and `pi/extensions/`.
- `pi/extensions/petey-debug.ts` implements `/petey-debug` without an LLM turn.
- `skills/ppstack/debug/` defines the ignored local incident layout.

## Local diagnostics

Raw session captures and runtime receipts stay under ignored `debug/traces/`. `debug/PETEY-LOG.md` indexes symptoms, traces, root causes, fixes, and verification. These files do not enter commits.

## Verification evidence

The migration audit is `.audit/pi-only-migration.tsv`. Static verification covers the Pi-only rules, generated routing document, TypeScript automation policy, JSON parsing, shell syntax, installer behavior, model registry entries, Markdown links, and the `petey-debug` extension test.

A nested runtime probe exceeded its outer tool timeout while its council phase was still running. The complete local forensic capture is indexed in `debug/PETEY-LOG.md`. The failure led to the materialized-evidence rule and bounded review seams.
