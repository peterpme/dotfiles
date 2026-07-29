---
name: source-parity
description: Compare a source-of-truth implementation, design, API, or product surface against a target implementation, then produce and execute a narrow parity plan. Use when asked to match web and mobile behavior, port behavior across repos, audit parity gaps, or plan implementation from a reference system.
argument-hint: "<source> <target>"
---

# Source Parity

Use this skill when the work depends on a reference system and the target must match it closely enough to avoid behavioral, data-contract, or UX regressions.

Typical sources include another repo, production web behavior, API route/schema, Figma, docs backed by code, or an existing platform implementation. Code and runtime behavior beat docs.

## Workflow

1. **Name the parity contract**
   - Source of truth: repo/path/URL/design/API.
   - Target: repo/path/surface being changed.
   - Required dimensions: data contract, routing, eligibility gates, loading/error states, mutation flow, layout, copy, analytics, or performance.
   - Explicit non-goals.

2. **Inspect source before target**
   - Read the source entry points first, then the helpers/hooks/state/API types they depend on.
   - Capture file references and observable behavior, not just inferred intent.
   - If the source is a live product or web page, confirm important details in code/API/schema before treating them as requirements.

3. **Inspect target implementation**
   - Read local rules first: `AGENTS.md`, repo-local skills, pattern registries, docs, and package conventions.
   - Identify existing target abstractions to reuse.
   - Separate missing behavior from intentionally different platform behavior.

4. **Produce a parity matrix**

   ```text
   Requirement | Source evidence | Target state | Gap | Fix | Validation
   ```

   Keep it short. Include only requirements that affect correctness, user-visible behavior, maintainability, or review risk.

5. **Plan the smallest implementation**
   - Prefer existing target architecture over copying source code.
   - Preserve target platform conventions for state, queries, navigation, styling, and validation.
   - Split work into reviewable slices when gaps span multiple layers.

6. **Implement only confirmed gaps**
   - Do not broaden scope to unrelated cleanup.
   - Keep source-specific terminology only when it is part of the target domain.
   - Add comments only for non-obvious parity decisions.

7. **Validate**
   - Run repo-native typecheck, lint, tests, or builds that cover changed files.
   - Manually verify the source-critical flows when automation does not cover them.
   - Re-run the parity matrix and mark each row: matched, intentionally different, or unresolved.

## Delegation Pattern

For complex work, use focused read-only agents before implementation:

- Source contract audit: source files, behavior, edge cases, API/schema.
- Target implementation audit: existing target files, gaps, local conventions.
- Architecture/risk audit: state ownership, mutation lifecycle, data model, validation.
- Final parity review: checks the finished diff against the matrix.

Each agent should report:

```text
Agent: <role>
Sources inspected:
- <path or URL>
Findings:
- <source-backed fact or gap>
Risks:
- <risk or none>
Validation:
- <command or manual check>
```

## Stop Conditions

Stop when:

- Every high-confidence parity row is matched, intentionally different with rationale, or explicitly deferred.
- Validation has run or the blocking reason is documented.
- Remaining questions identify the exact missing source evidence or product decision needed.

Do not continue if the source of truth is ambiguous and multiple target behaviors would be plausible. Ask for the canonical source path, design, API, or product decision.
