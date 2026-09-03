---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

## When to invoke

- The user said "reflect" or "/reflect".
- A complex task (5+ tool calls) just landed cleanly and the recipe is worth keeping.
- The agent hit dead ends, found the working path, and the path generalizes.
- The user corrected the agent's approach mid-task.
- A non-trivial workflow emerged that isn't captured anywhere.

Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## Process

### 1. Locate the active transcript

The parent finds its own Pi session file before fanning out. Use `PI_SESSION_FILE` when available or `/session` in interactive mode. Stay inside the active workspace's directory under `~/.pi/agent/sessions/`; do not scan other projects. If no path resolves, write a tight digest of the session and pass that instead.

Also pass the session's `problems.tsv` from the **debugger** skill and every row in `skills/ppstack/debug/problems.tsv` whose `status` is not `fixed`. Those rows are pre-triaged findings that already name a `target`; reviewers start from them and confirm or reject each against the transcript.

### 2. Spawn three reviewers in parallel

Use one async `workflowScript` with `runs.all` of three fresh `reviewer` children. Do not select models per run. The prompt forbids file writes; the parent applies edits.

| Lens | Prompt template |
|---|---|
| Judgment | `references/judgment-reviewer.md` |
| Tooling | `references/tooling-reviewer.md` |
| Divergent | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in their child outputs.

### 3. Synthesize

The parent synthesizes. Use `references/synthesizer.md` with each reviewer's output inlined. Produce Accepted / Rejected / Backlog. Do not spawn a fourth child unless the dumps cannot fit.

### 4. Structural enforcement check

Sanity-check the synthesizer's Accepted list. For any item that would be enforced more reliably by a lint rule, script, metadata flag, or runtime check, move it from Accepted to Backlog. The synthesizer already applies this criterion; this is a final pass before edits land. See the **encode-lessons-in-structure** principle skill.

### 5. Apply

Before applying any Accepted edit, present the synthesizer's full Accepted/Rejected/Backlog output to the user and wait for explicit approval. The user picks which subset to apply and may redirect routings. Skill changes affect every future agent in the org; do not auto-apply.

Backlog items file to whatever devex / backlog tracker your team uses automatically. Those are tracker submissions, not skill edits. Only the Accepted list waits for approval.

For each approved Accepted item, follow the Routing field exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): parent does directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): follow the Authoring a skill playbook (`petey/playbooks/authoring-a-skill.md`) and run a draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): rewrite the description per that playbook and test the triggering phrases.
- `new skill: <kebab-name>`: follow that playbook. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done. Skip this step if it doesn't.

### 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
