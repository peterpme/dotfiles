---
name: component-data-refactor
description: Component and data architecture workflow for focused React and React Native refactors. Use when the user asks to refactor a specific screen, component, feature, or PR and wants the agent to review first, ask architecture questions, sketch data flow and component tree separately, reason about render triggers, and wait for approval before editing code.
argument-hint: "<target code, PR, screen, component, or feature>"
---

# Component + Data Refactor

Use this skill for focused React or React Native refactors where component boundaries, data ownership, subscriptions, or list performance matter. Stay anchored to the specific code, PR, screen, component, or feature named by the user.

Do not edit files until the user approves the architecture sketch.

## Workflow

Follow this loop:

1. review
2. ask questions
3. sketch data architecture
4. sketch React component tree
5. get approval
6. implement
7. final review

## Scope

- Stay anchored to the named code, PR, screen, component, or feature.
- Use nearby code to understand constraints, not as proof that a pattern is good.
- Do not turn the task into a repo-wide rewrite unless the user explicitly asks.
- If discovery invalidates the sketch, stop and revise the sketch before continuing.

## Review First

Inspect the nearest implementation, then the hooks/state/components it imports, then generated client/model/schema code if needed.

Summarize:

- current component tree
- current data flow
- current state ownership
- current subscription/render triggers
- likely performance or composition risks

## Questions

Ask only questions that materially affect the architecture. If the answer is discoverable from code, inspect first.

## Pattern Judgment

Do not blindly preserve existing local patterns. Classify relevant existing patterns:

- **Preserve:** required by APIs, navigation, generated clients, design system constraints, tests, cache behavior, localization, permissions, or platform compatibility.
- **Challenge:** broad subscriptions, global state for screen-local behavior, derived atoms/selectors rebuilding large row arrays, prop chains through components that do not use the state, mixed screen/data/leaf responsibilities, or expensive search/sort/filter on frequent updates.
- **Improve:** propose a better local pattern with the smallest useful scope.

When existing examples are poor, preserve compatibility constraints, explain the better local pattern, and name what old pattern should not be copied forward.

## Data Architecture Sketch

Describe:

- source of truth for server/global data
- source of truth for screen-local state
- query/context/store boundaries
- subscription strategy
- search/sort/filter strategy
- row identity strategy, if lists are involved
- what must not subscribe at the parent level

## React Component Tree Sketch

Describe:

- screens
- providers/containers
- list components
- rows
- leaf controls
- what each component owns
- what props cross boundaries
- where composition replaces prop drilling

## Approval Gate

Before coding, answer:

- What renders when important state changes?
- What renders when one row or item changes?
- What renders when search, sort, or filter changes?
- Which state is local, shared, or server-backed?
- Which existing patterns are preserved or challenged?
- What better local pattern is being introduced?
- What files will change?
- What checks will verify the refactor?

Wait for user approval. The first sketch does not need to be perfect; revise it through back-and-forth.

## Implementation

After approval, implement only the approved architecture.

Keep these guardrails:

- Stable row identity: list items use durable IDs.
- Fast row data uses per-row subscriptions or selectors.
- Parent list components do not broadly subscribe to data that invalidates every row.
- Screen-local explore/search/sort state does not become global state.
- Do not create derived global or Jotai atoms that rebuild full row arrays from snapshots.
- Do not rebuild full row arrays on high-frequency query updates.
- Do not drill state through intermediate components that do not use it.
- Colocate state, compose components, or use a scoped context/store where appropriate.
- Keep search/sort/filter updates narrow and predictable.
- Avoid `memo`, `useMemo`, and `useCallback` by default unless the codebase pattern or measured risk justifies it.

## Final Review

Before finishing, verify:

- component boundaries match the approved sketch
- parent subscriptions are narrow
- row or item subscriptions are scoped
- list row keys and identities are stable
- search/sort/filter do not invalidate more than needed
- screen-local state stayed local
- props are minimal and intentional
- poor local patterns were not copied forward
- no broad unrelated churn was introduced
- tests, typecheck, lint, or manual checks were run, or explain why not
