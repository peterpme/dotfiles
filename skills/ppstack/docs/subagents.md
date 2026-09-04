# Delegate through Herdr

The Pi coordinator loads the discoverable **spawn-subagent** skill before delegating. Use its actual directory, not a guessed repository path. All ppstack skills and **spawn-subagent** install only under `~/.pi/agent/skills`. General root skills remain shared under `~/.agents/skills`.

**petey-pi** is a Pi-only coordinator skill. Never load it or its playbooks in native Codex, Claude, or other helpers. Helpers receive scoped neutral briefs with no further delegation and only explicitly selected portable task skills by absolute path. The parent runs coordinating skills such as **how**, **why**, **arena**, **swarm**, **interrogate**, **reflect**, **no-comments**, and **no-stupid-tests**. Give helpers their leaf references and concrete instructions, not the full coordinating skill. Do not rely on native CLIs auto-discovering ppstack.

## Launch

Run from the checkout the child should use. `HERDR_ENV=1` is required. The launcher opens a sibling pane in the same cwd with `--no-focus`.

```text
python3 <skill-directory>/scripts/spawn.py --task "..." [--agent pi|codex|claude|grok] [--skill <absolute SKILL.md>] [--direction right|down]
```

Pi is the default. `--agent pi` inherits the Pi parent's `PI_PROVIDER`, `PI_MODEL`, and `PI_REASONING_LEVEL` when available, otherwise uses native Pi startup settings; native Codex and Claude retain their own defaults, explicit Grok stays pinned to `xai/grok-4.6`, and provider failure never triggers a fallback. `codex` and `claude` launch their native CLIs. `grok` launches Pi with `--provider xai --model grok-4.6`. A launch returns the Herdr agent name and pane. Keep both for inspection. If the skill, Herdr environment, or selected CLI is unavailable, report the blocker and ask the user. There is no fallback launcher or model substitution.

For cross-model review, choose actual different families through **peer-review**. Two OpenAI model aliases do not provide cross-family review. Confirm the family used before counting a result.

## Write a standalone brief

Every child starts fresh. Include the goal, allowed reads and writes, relevant absolute skill and reference paths, settled decisions, evidence, verification steps, and the expected in-chat report. A child cannot see the parent's conversation or a sibling's output. Relay the findings it needs.

For implementation, include:

- `TRACE`: paths, symbols, runtime flow, and settled decisions.
- `FIRST UNIT`: the smallest behavior to implement.
- `WRITE SEAM`: the owned files or module boundary.
- `FIRST CHECK`: the exact command or surface that proves the unit.
- `EXPAND ONLY WHEN`: evidence that permits broader investigation. Edits still stay within the authorized scope.

Start at the first unit. Read adjacent code only when it serves that work. Do not repeat settled discovery or design.

Materialize review evidence before launch. Name files, the patch, command output, and test results. Instruct reviewers not to edit and to report `MISSING EVIDENCE` for absent artifacts. No-edits is an instruction, not a sandbox guarantee. Keep searches inside the repository and named configuration directories.

Request the report in the conversation. Do not put an output-file requirement in the initial prompt. Only if scrollback truncates the result, ask the child to save that result to a named file and read it there. Requested deliverables such as source files or a design document still belong in the task scope.

## Keep one writer per checkout

The parent stops editing while a child owns the checkout, even when their file scopes differ. Other children may inspect a stable snapshot with explicit no-edits instructions. A branch name alone does not isolate filesystem writes.

Create or use a separate worktree only when the user explicitly requests or approves it. Without that authorization, sequence writers in the current checkout. For an approved worktree, prepare dependencies and prove the first check starts before launching from its cwd.

The parent inspects the resulting diff and evidence, then integrates verified commits. A child does not merge or change stack topology on the parent's behalf.

## Inspect, wait, and follow up

Use the returned name or pane as the target:

```bash
herdr agent get <target>
herdr agent read <target> --source recent-unwrapped --lines 200
herdr agent wait <target> --timeout 60000
herdr agent prompt <target> "<specific follow-up>"
```

Read progress and artifacts between bounded waits. `idle` or `done` is a signal to inspect, not proof of completion. A wait timeout does not cancel the child. Do not start a replacement writer until the prior writer has stopped.

If an agent is `blocked`, inspect its state and output, then ask the user about the blocking decision. Do not submit prompts blindly through a blocked state. Use `prompt` for a concrete correction or follow-up, not to check liveness.

The parent owns result collection and verification. Herdr state does not promise completion delivery or automatic continuation after a session ends. On pickup, inspect the recorded name and pane, the current checkout, and the evidence before continuing. Report missing work honestly.
