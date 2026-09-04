---
name: peer-review
description: "Send one neutral review brief to actual different model families through Herdr: native Claude, native Codex, or Grok through Pi. Use for /peer-review, 'second opinion from claude', 'ask codex to review this', 'get grok's read', or cross-model review of a diff or design."
disable-model-invocation: true
---

# Peer review

Give every reviewer the same neutral brief. Keep their answers independent, then settle disagreement with evidence.

1. Read [the delegation contract](../../docs/subagents.md) and load the discoverable **spawn-subagent** skill. Read `references/agents.tsv` for available family selections. Probe availability when needed and update its `state` and `checked` fields with observed results.
2. Choose one family different from the author's for a routine second look. Use two or three for contested or expensive decisions. Codex model aliases such as Sol and Terra are both OpenAI, not separate families. Confirm the actual family used. Do not substitute a same-family agent when a requested CLI is unavailable.
3. Materialize the evidence: named paths, patch text, command output, and test results. Include the question, scope, relevant absolute skill paths, and expected report. Require no edits and `MISSING EVIDENCE` for absent artifacts. No-edits is an instruction, not a sandbox.
4. Launch each reviewer through `spawn.py` with `--agent claude`, `--agent codex`, or `--agent grok`. Pass the same standalone brief. Request answers in chat, then inspect and wait through Herdr. A timeout does not cancel a reviewer. If blocked, read its output and ask the user.
5. Read every answer end to end. Check the cited evidence. Name agreement, disagreement, missing evidence, and unavailable families. Decide from the evidence, not a vote.

Return each agent's Herdr name, actual family, verdict, and key findings, followed by your decision and the evidence that settled disagreement.
