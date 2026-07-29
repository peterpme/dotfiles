---
name: engineering-manager
description: reusable engineering manager workflow for complex agentic or human-led engineering tasks that require coordinating specialists, auditing repositories, implementing changes, validating with project-native commands, opening pull requests, resolving review comments, and running an independent final audit. Use when the user asks an agent or engineering lead to coordinate multi-agent or multi-reviewer implementation, create a PR, install project rules or skills, perform large refactors, enforce validation gates, or manage a complex engineering issue from intake through merge readiness.
---

# Engineering Manager

Use this skill to turn a complex engineering request into a managed workflow with specialist agents or human reviewers, evidence gates, implementation, validation, PR handling, review resolution, and final independent audit.

It is tool-agnostic. Adapt it for any environment that supports local agent rules, skills, prompts, or reviewer playbooks, including `.agents`, `.devin`, `.cursor`, `.claude`, `.codex`, `.github`, or project docs.

## Core rule

Act as a manager first. Do not let implementation begin until the relevant discovery agents have produced written findings.

For every complex task:
1. Restate the objective and constraints.
2. Split the work into focused agents.
3. Require each agent to report files inspected, findings, risks, and proposed changes.
4. Merge findings into a concrete checklist.
5. Assign implementation work in small, reviewable slices.
6. Run the repo-native validation loop.
7. Open or update a pull request.
8. Resolve or explicitly dismiss review comments.
9. Run a fresh final audit by an agent that did not write the implementation.

## Default agent set

Use up to 10 agents or reviewers. Prefer fewer when the issue is small, but do not under-split ambiguous or high-risk work.

Suggested roles:
- Manager agent: coordinates, maintains checklist, decides sequencing, owns final response.
- Product/reference audit agent: inspects source-of-truth behavior, docs, designs, APIs, or web implementation.
- Current implementation audit agent: inspects the target app/repo and identifies gaps.
- Architecture agent: proposes state, data, routing, component, or system design changes.
- Performance agent: profiles or reasons about render cost, data flow, recomputation, subscriptions, and latency.
- Design agent: inspects Figma or design references and extracts implementable requirements.
- Implementation agent: makes focused code changes.
- Validation agent: runs typecheck, lint, format, tests, builds, or other project-native checks.
- Review agent: handles PR comments and CI failures.
- Final independent audit agent: re-checks the finished work against requirements and source-of-truth inputs.

## Required findings format

Every non-manager audit agent must report:

```text
Agent: <role>
Files or sources inspected:
- <path or source>

Findings:
- <specific finding>

Proposed changes:
- <specific change>

Risks:
- <risk or none>

Validation needed:
- <command, manual check, CI check, or review>
```

The manager must convert findings into a checklist before implementation.

## Implementation rules

- Prefer small, reviewable commits or batches.
- Keep behavior correctness ahead of visual polish unless the task is primarily visual.
- Do not copy source-of-truth code blindly when adapting across platforms or architectures.
- Preserve project conventions unless a refactor is required for correctness, performance, or maintainability.
- Centralize reusable logic where the project convention expects it.
- Avoid global state for temporary form/session state unless required.
- Break large providers and screens into smaller components that subscribe only to required state.
- Name temporary/scoped state clearly so lifecycle and ownership are obvious.
- Add comments only for non-obvious decisions.

## Validation loop

Inspect the repo before choosing commands. Use package.json, README, Makefile, justfile, CI config, or existing scripts.

Run all applicable repo-native checks requested by the user, usually:
- TypeScript or equivalent typecheck
- lint
- formatting
- tests if present or requested
- build if present or requested

Do not invent commands when existing scripts are available. If a command fails, fix the issue and rerun the relevant checks.

## Pull request loop

When the user requests a PR:
1. Create or update a branch with a descriptive name.
2. Commit coherent changes.
3. Push the branch.
4. Open or update a PR.
5. Include a PR description with:
   - summary
   - sources inspected
   - files changed
   - validation commands run
   - screenshots or manual verification notes when relevant
   - risks or known limitations
6. Read PR comments and CI failures.
7. Fix actionable comments.
8. Treat low-signal automated comments with judgment; dismiss with rationale when appropriate.
9. Repeat validation after fixes.

## Final independent audit

Before claiming completion, spawn a fresh review agent that did not write the implementation. It must compare the final code against the original requirements and source-of-truth references.

The audit must report:
- requirements satisfied
- discrepancies found
- validation evidence
- remaining risks

Fix material discrepancies before finalizing.

## Reusable prompt template

Use `references/manager-prompt-template.md` when the user wants a copyable engineering manager prompt.

Use `references/install-skill-pr-prompt.md` when the user wants a prompt that adds this skill to a repository and opens a separate PR.
