---
name: why
description: "Use for why does X work this way, design rationale, regressions, postmortems, or data-backed thresholds. Searches available evidence categories and returns cited decisions, tradeoffs, contradictions, and gaps. Use how for runtime behavior."
---

# Why

Investigate motivation without inferring intent from code shape.

1. Identify the target paths, symbols, line ranges, recent commits, PRs, and linked issues.
2. Inventory available evidence for source control, issue tracking, long-form docs, team chat, infrastructure observability, error tracking, and product analytics. A missing tool is a reported gap.
3. Keep source-control-only work in the parent when small. For broader evidence, launch fresh read-only `researcher` runs through one `workflowScript`, one distinct evidence category per lane. Use the matching playbook under `references/sources/`, `references/investigator-prompt.md`, and the same code anchor. Do not select models per run.
4. Require direct citations, null results, contradictions, and explicit uncertainty. Defensive code also gets `references/sources/incident-postmortem.md`.
5. The parent synthesizes using `references/epistemics.md` and `references/synthesizer-prompt.md`. Separate direct evidence, inference, competing hypotheses, and unknowns.
6. List every source category, query scope, and result. When the investigation informs a change, finish with Preserve, Change, Avoid, and Risk constraints.

Never turn a plausible story into a fact. Preserve confidence language from the evidence.
