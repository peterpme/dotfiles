---
name: spawn-subagent
description: "Pi-only delegation through Herdr. Use when asked to spawn a subagent, delegate work, run parallel helpers, ask Codex or Claude, or get Grok's review. Starts native CLIs in sibling panes without an orchestration package."
---

# Spawn a subagent

Use this skill from the Pi coordinator only. Native helpers receive standalone task briefs, not `petey-pi` or other coordinator workflows.

## Choose the work

Do narrow lookups yourself. Delegate a bounded task that benefits from separate context or another model family.

Honor a requested agent. Otherwise use Pi for ordinary work, Codex or Claude for an independent review. Grok runs through Pi with xAI. The exact launch arguments live in `scripts/spawn.py`; native CLI configuration owns all other model and permission choices. Do not silently substitute a provider after a failure.

Choose skills by their descriptions. Read the matching skill, then pass its absolute `SKILL.md` path with `--skill`. Pass only task-specific skills a helper can execute in its own CLI. Do not pass Pi-only orchestration skills to native helpers. If a skill delegates, keep that coordination in the parent and send its leaf task instead.

Write a self-contained brief with the question, allowed paths, edit or no-edit boundary, expected result, and verification command. Materialize named review evidence before launch. A missing artifact is `MISSING EVIDENCE`, not permission to search the home directory.

## Launch

Require `HERDR_ENV=1`. Outside Herdr, do the work in the parent or ask the user to attach to Herdr. Never control the focused session from outside it.

Resolve this script relative to the directory containing this skill:

```bash
python3 /absolute/path/to/spawn-subagent/scripts/spawn.py \
  --agent codex \
  --task 'Review the named patch and test output. Do not edit. Return actionable findings with file and line references.'
```

Options:

- `--agent pi|codex|claude|grok`. Defaults to Pi, inheriting the parent's `PI_PROVIDER`, `PI_MODEL`, and `PI_REASONING_LEVEL` when provider and model are present. Otherwise Pi uses its native startup settings. No conversation history is inherited.
- `--skill /absolute/path/to/SKILL.md`. Repeat for multiple portable skills.
- `--direction right|down`. Otherwise choose from the caller pane's dimensions.
- `--dry-run`. Print the route and brief without contacting Herdr.

The launcher checks executables and skill paths before creating a pane. It starts a fresh interactive agent in a sibling pane, preserves the caller's cwd, and uses `--no-focus`. It returns a unique `name`, a `pane` ID, and `status: submitted`. That means submission, not completion.

One writer per checkout, including the parent. Read-only helpers may share it. For parallel writers, get approval for separate worktrees, create them with Git or Herdr, and launch from each approved checkout. Never share an index between writers. Do not create another Herdr server or named session for each helper.

## Read and follow up

Use the returned name or pane ID, never the UI-focused pane:

```bash
herdr agent get <name>
herdr agent read <name> --source recent-unwrapped --lines 120
herdr agent wait <name> --timeout 60000
herdr agent prompt <name> 'Follow-up with the next bounded task.'
```

Inspect active work about once a minute while doing your own work. If a history read returns `agent_not_idle`, use `herdr agent read <name> --source visible` while it works, then read history after it settles. A wait timeout leaves the agent running. `idle` and `done` mean the terminal is ready, not that the task succeeded. `unknown` proves nothing. There is no automatic completion message back into Pi.

For a blocked agent, read its screen and ask the user before answering an approval, login, or question. Do not weaken CLI permissions to make startup pass. On startup or prompt errors, the launcher keeps the pane and reports its identity. Inspect it before retrying. A timed-out prompt may already have been delivered; never resend blindly. If a split times out before returning an ID, inspect `herdr pane list` in the caller workspace to find any newly created pane.

Read the full answer. If the alternate screen lost part of it, ask the helper to write its complete answer in a temporary Markdown file and return the path. Use that only after a truncated read, not in the initial brief.

Verify the actual diff and rerun the named checks before accepting a writer's work. A no-edit brief is an instruction, not a sandbox. Native CLI permissions still apply; this launcher adds no tool allowlist, write isolation, or approval automation.

When finished, close only panes you created, after collecting results and confirming no useful work remains:

```bash
herdr pane close <pane-id>
```

For cancellation, inspect the agent first and use its native interrupt through `herdr agent send-keys`. Verify it stopped. Keep the pane when the user needs to resolve a blocker.

## Verify changes to this skill

```bash
python3 -m unittest discover -s /absolute/path/to/spawn-subagent/scripts -p 'test_*.py' -v
```

Then run a no-edit smoke task through the real launcher for each configured route. Check both the terminal answer and the reported runtime/model. A missing binary, login prompt, quota error, or unavailable model is a failed route, not successful proof.
