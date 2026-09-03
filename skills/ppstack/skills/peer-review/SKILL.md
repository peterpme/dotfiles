---
name: peer-review
description: "Send one neutral review brief to reviewers outside Pi's model roster (Claude Code, Cursor agent, Codex, Gemini) and compare their answers. Use for /peer-review, 'second opinion from claude', 'spawn claude -p', 'ask codex or gemini to review this', or any cross-vendor review of a diff or design."
disable-model-invocation: true
---

# Peer review

Fresh eyes from another vendor. Every reviewer gets the same brief. None sees the others. Agreement is the signal.

## Reviewers on this machine

| Reviewer | How to spawn | Pins model | State on 2026-09-02 |
|---|---|---|---|
| Claude, Fable 5.1 | **fable-peer-review** (bash `claude -p --model claude-fable-5-1 --effort max`) | yes | works |
| Claude, account default | pi-subagents builtin `claude-code` | no, uses the `model` key in `~/.claude/settings.json` | installed, that key is `sonnet` today |
| Cursor agent | pi-subagents builtin `cursor-agent` | no | installed, not probed |
| Codex | pi-subagents builtin `codex-exec` | no | `codex` not installed |
| Gemini | bash `gemini -p "<brief>" -m <model>` | yes | installed, no auth configured |

The builtin adapters run one shot, read-only, plan mode, no tools, prompt on stdin. They cannot read files or ask questions, so the brief must inline the patch. Do not pass Pi child options (model, thinking, tools) to them.

## Steps

1. Materialize the evidence. Named paths, the patch as text, command output, test results. A reviewer with no tools reviews only what the brief carries.
2. Write one neutral brief. The question, the scope, what to return, and the rule that a missing artifact yields `MISSING EVIDENCE` rather than a guess. No hint of your own view.
3. Fan out in one async `workflowScript`, capped at 10 minutes. Adapter lanes are `runs.run("claude", { agent: "claude-code", task })` and `runs.run("cursor", { agent: "cursor-agent", task })`. CLIs without an adapter run as bash lanes from the repo under review. The pinned Fable lane is **fable-peer-review**.
4. Read every answer end to end. Do not pass summaries through. Where reviewers agree, treat it as high signal. Where they disagree, name the question and settle it with evidence, not by vote.
5. Reply with one verdict per reviewer, the agreement map, and your decision.

## Adding a CLI

A new vendor is one agent file in `ppstack/agents/`, linked by the installer. Test it with a one-line brief before relying on it.

```yaml
---
name: gemini-cli
description: Read-only one-shot review through the installed Gemini CLI
runner:
  type: external-cli
  command: gemini
  args: "-p"
  promptDelivery: stdin
async: true
systemPromptMode: replace
inheritSkills: false
---
Review only the supplied brief. Return findings with evidence. Do not edit files.
```

**Reply:** per reviewer, verdict and key findings; the agreement map; your decision and the evidence that settled any disagreement.
