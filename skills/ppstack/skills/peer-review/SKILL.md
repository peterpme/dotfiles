---
name: peer-review
description: "Send one neutral review brief to configured Sol, Grok, and Claude Fable review roles and compare their answers. Use for /peer-review, 'second opinion from claude', 'spawn claude -p', 'ask codex to review this', 'get grok's read', or any cross-model review of a diff or design. One lane is fine for a routine second look."
disable-model-invocation: true
---

# Peer review

Fresh eyes from another model family. Every reviewer gets the same brief. None sees the others. Agreement is the signal.

The reviewers on this machine, their configured roles, and whether each works today live in `references/agents.tsv`. Open it before spawning. Update its `state` and `checked` columns when a lane is probed. Model and effort routing lives in `pi/settings.json`; do not select models per run or substitute external CLI adapters.

## Steps

1. Pick lanes. One for a routine second look. Two or three when the decision is contested or expensive to reverse.
2. Materialize the evidence. Named paths, the patch as text, command output, and test results. The brief carries everything each reviewer needs.
3. Write one neutral brief. The question, the scope, what to return, and the rule that a missing artifact yields `MISSING EVIDENCE` rather than a guess. No hint of your own view. The same text goes to every lane.
4. Fan out the selected `reviewer-*` roles in one async `workflowScript` capped at 15 minutes (`timeoutMs: 900000`). This is the only fixed deadline any child gets in ppstack; a reviewer that has not answered in 15 minutes is not going to. Use `runs.run("<lane>", { agent: "<role>", task })` and run all lanes in parallel.
5. Read every answer end to end. Do not pass summaries through. Where lanes agree, treat it as high signal. Where they disagree, name the question and settle it with evidence, not by vote.

**Reply:** per lane, verdict and key findings; the agreement map; your decision and the evidence that settled any disagreement.
