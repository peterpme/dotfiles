---
name: continuity
description: Learn, record, audit, and apply codebase patterns consistently across a repository by comparing current code to canonical local examples and a repo-local pattern registry. Use when asked to preserve continuity, learn a pattern, check drift, fix inconsistent implementations, migrate code to a local convention, or produce a CI-friendly continuity report.
argument-hint: "[learn|check|fix|ci] [pattern-name-or-paths]"
---

# Continuity

Use this skill to preserve codebase continuity: identify canonical local patterns, record their source of truth, audit similar code for drift, and apply the pattern consistently elsewhere.

Patterns include structural conventions such as:

- Navigation, screen, and component boundaries.
- Correct folder placement for functions, hooks, libraries, state, queries, helpers, and UI pieces.
- File, folder, component, hook, and helper naming conventions.
- Import style and dependency ownership.
- Reusable React, React Native, backend, or CLI module shapes.

## Pattern Registry

Use a repo-local registry for durable decisions. Prefer:

```text
.agents/continuity/patterns.md
```

If that file is absent and a legacy registry exists at `.devin/continuity/patterns.md`, read the legacy file before auditing. When updating or migrating decisions, write the canonical registry to `.agents/continuity/patterns.md` unless the user or repo rules require another path.

Always read the registry before auditing or changing code. If it does not exist, create it from this shape:

```markdown
# Continuity Patterns

This file records source-of-truth examples and continuity rules for this repo.

## Active Patterns

### Pattern: <kebab-case-name>

- **Status:** active | draft | deprecated
- **Scope:** <paths/globs where this applies>
- **Enforcement:** changed-files | full-repo | advisory
- **Default check:** changed-files | provided-paths | full-repo
- **Source of truth:**
  - `<path>` - <why this file is canonical>
- **Applies to:**
  - `<path/glob>`
- **Do not apply to:**
  - `<path/glob>` - <reason>
- **Rule summary:** <one-paragraph description>
- **Required shape:**
  - <observable rule>
- **Allowed variations:**
  - <intentional exception>
- **Severity:**
  - high: <rule that should block changed files or CI>
  - medium: <rule that should be fixed when touching the area>
  - low: <advisory cleanup>
- **Baseline exceptions:**
  - `<path/glob>` - <known legacy drift or reason it is excluded from CI>
- **Violation signals:**
  - <searchable symptom or AST-ish shape>
- **CI behavior:** <what should fail in automation>
- **Fix strategy:** <safe mechanical fix or refactor sequence>
- **Open questions:**
  - <question to ask before enforcing>
```

When you learn a pattern or resolve uncertainty, update the registry immediately so future runs inherit the decision.

## Invocation Modes

Infer the mode from the request:

- `learn <pattern-name> <paths...>`: inspect examples, infer the pattern, ask focused questions when needed, then record it.
- `check [pattern-name] [paths...]`: report violations only. Do not edit files.
- `fix [pattern-name] [paths...]`: audit and apply safe fixes. Ask before broad, risky, or ambiguous refactors.
- `ci [pattern-name] [paths...]`: deterministic report-only audit suitable for automation. Do not edit files. Follow each pattern's `CI behavior`; default to changed-file enforcement when a full-repo baseline has known legacy drift.
- No explicit mode: default to `check` unless the user asks to apply, fix, migrate, enforce, or record a pattern.

## Operating Principles

1. **Code wins over docs.** Start from the nearest implementation in the package being edited, then shared imports, then generated schema/client/model code.
2. **The registry wins over inference.** If the registry names source-of-truth files, read the relevant files and treat them as canonical unless current code contradicts them. If contradicted, report the conflict and ask before updating the registry.
3. **Do not invent canonical patterns.** If unsure which component, screen, hook, query wrapper, module layout, or folder structure should be canonical, ask the user to point to source-of-truth files.
4. **Record decisions.** After the user identifies canonical examples or resolves an open question, save that in the registry.
5. **Prefer narrow scope first.** Audit changed files or provided paths before scanning the whole repo.
6. **Separate detection from fixing.** First state the pattern and violations. Then apply only fixes clearly implied by the registry or source-of-truth examples.
7. **Avoid shallow text matching.** Use textual searches to find candidates, but verify structure by reading relevant files.
8. **Open questions limit enforcement.** If a pattern has unresolved open questions, enforce only the unambiguous rules and report unresolved decisions before broad fixes.
9. **Respect baselines.** If a pattern is marked `changed-files` or has baseline exceptions, do not present legacy drift as a CI blocker unless it overlaps changed/provided files.
10. **Respect repo rules.** Follow `AGENTS.md`, package-level `AGENTS.md`, and any relevant local skills or rules discovered near the files.

## React Navigation Screen Fixes

When applying a React or React Native navigation pattern, do not interpret "thin screen" as "extract the entire screen body into a new `*Content` component." Prefer the smallest change that makes the screen match the local pattern:

- A `*Screen.tsx` file should usually keep the screen implementation and export exactly one default screen component.
- Do not create `DustContent`, `<ScreenName>Content`, or similar one-off wrappers only to reduce line count or move all JSX elsewhere.
- Collapse unnecessary one-off renderable helpers into the default screen when they do not improve clarity; keep local private helpers only when they reduce real complexity.
- Move feature components, providers, query wrappers, atoms, and reusable UI outside the screen only when the local source-of-truth pattern clearly requires that boundary.
- Prefer navigator-level `screenLayout` or route-level `layout` for shared screen wrappers such as `ExchangeScreenContainer`; avoid repeating wrapper components inside every screen when React Navigation can own the layout.
- If deciding between extracting a component and keeping logic in the screen is ambiguous, ask for a canonical source file before editing.

## Learning Workflow

When invoked as `learn` or when asked to identify a new pattern:

1. Read the registry and nearby `AGENTS.md` files.
2. Inspect user-provided paths first. Treat explicit files as candidate source-of-truth examples.
3. Search for related implementations using names, imports, component usage, folder names, and similar APIs.
4. Compare examples and classify:
   - **Canonical:** clean, recent, repeated, or explicitly identified by the user.
   - **Candidate:** likely representative but not confirmed.
   - **Outlier:** old, local exception, deprecated, or structurally inconsistent.
5. If multiple plausible canonical shapes exist, ask focused questions. Ask for file paths, not abstract preferences.
6. Once canonical files are known, write or update a `Pattern:` section in the registry.
7. Record enforcement level, severity, known baseline exceptions, and CI behavior so future audits know whether to fail changed files, the full repo, or only report advisory drift.

Good questions are concrete:

```text
I found two bottom sheet shapes:
1. packages/app-mobile/src/app/exchange/components/.../ExampleA.tsx
2. packages/app-mobile/src/app/wallet/components/.../ExampleB.tsx

Which one should continuity treat as canonical, and should it apply to both exchange and wallet?
```

## Audit Workflow

When invoked as `check` or `ci`:

1. Read the registry.
2. Select the requested pattern. If no pattern is specified, audit active patterns whose scope overlaps provided paths or changed files.
3. Determine scope:
   - If paths were provided, audit those paths.
   - If the pattern says `Default check: changed-files`, audit files from `git diff --name-only origin/master...HEAD` or the user's stated base branch.
   - If the pattern says `Default check: full-repo`, audit the full pattern scope.
   - If there are no changed files and no paths, a full-repo audit is allowed but must be labeled advisory when `Enforcement` is not `full-repo`.
4. Find candidates with `rg`, `fd`, or glob searches based on:
   - Imports of canonical components/libraries.
   - File suffixes and folder names.
   - Component, hook, function, and type names.
   - Violation signals recorded in the registry.
5. Read candidate files and compare them against required shape, allowed variations, severity, and baseline exceptions.
6. Report each violation with:
   - **Pattern:** pattern name.
   - **File:** path.
   - **Severity:** high | medium | low.
   - **Issue:** exact continuity rule violated.
   - **Expected:** source-of-truth shape or rule.
   - **Evidence:** concise code reference or observed structure.
   - **Fix:** specific change to make.
   - **Confidence:** high | medium | low.
   - **Enforcement:** blocks changed files | advisory legacy drift | open question.
7. For `ci`, end with a stable summary:

```text
CONTINUITY_RESULT: pass|fail
PATTERNS_CHECKED: <n>
VIOLATIONS: <n>
BLOCKING_VIOLATIONS: <n>
```

Do not edit files in `check` or `ci` mode.

## Fix Workflow

When invoked as `fix` or when the user asks to apply a pattern:

1. Complete the Audit Workflow first.
2. Apply high-confidence mechanical fixes directly.
3. Ask before fixes that change public APIs, move files across package boundaries, rename exported symbols used widely, or require selecting between multiple canonical examples.
4. Keep diffs minimal and local to the pattern.
5. Re-run the audit search for the changed pattern.
6. Run relevant tests, lint, typecheck, or package-specific verification if available.
7. Summarize changed files and remaining open questions.

## Suggested Search Tactics

Use targeted commands, adapting paths and terms to the repo:

```bash
rg -n '<canonical-name>|<import>|<violation-signal>' <scope> --glob '*.{ts,tsx,js,jsx}'
fd '<file-or-folder-pattern>' <scope>
```

Prefer narrower searches based on the requested pattern and scope.

## Output Style

Be direct and actionable. Do not dump raw search results. Always distinguish:

- Confirmed source-of-truth.
- Inferred but unconfirmed pattern.
- Violations that should be fixed.
- Intentional exceptions or open questions.

If no violations are found, say:

```text
Continuity check passed for <pattern/scope>.
```
