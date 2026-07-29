---
name: repo-rule-mining
description: Turn repeated code review findings into durable repository guardrails such as docs, local skills, ESLint rules, ast-grep rules, tests, or CI checks. Use when asked to mine review comments, codify recurring patterns, author repo rules, review lint-rule PRs, or reduce repeat manual PR feedback.
argument-hint: "<repo-or-findings>"
---

# Repo Rule Mining

Use this skill to package repeated review feedback into enforceable, low-noise guardrails. The goal is fewer repeated comments, not more rules.

## Candidate Bar

Codify a rule only when all are true:

- The issue has appeared at least twice, or is clearly likely to recur in a costly area.
- The bad and good shapes can be described with concrete code examples.
- The rule has stable scope and clear exceptions.
- Enforcement would catch real regressions with acceptable false positives.
- Existing docs, skills, lint rules, or CI do not already cover it adequately.

Prefer documentation or a repo-local skill when judgment is required. Prefer ESLint, ast-grep, tests, or CI only when detection is mechanical.

## Workflow

1. **Collect evidence**
   - Review PR comments, session notes, docs, rule mining reports, existing lint failures, and representative code.
   - Record dates, PRs, files, and the exact repeated symptom.
   - Confirm important claims in the repo source rather than relying only on summaries.

2. **Check existing coverage**
   - Read repo rules: `AGENTS.md`, `.agents/skills`, docs, existing ESLint plugins/config, ast-grep rules/tests, CI scripts, and pattern registries.
   - If covered, extend the existing rule or docs instead of adding another guardrail.

3. **Choose the smallest guardrail**
   - **Docs or skill rule:** nuanced architecture or review guidance.
   - **ESLint rule:** AST-aware JavaScript/TypeScript semantics, imports, hooks, or type-aware patterns.
   - **ast-grep rule:** simple structural matches with examples and low false-positive risk.
   - **Test:** behavior, generated output, fixtures, schema, or CLI behavior.
   - **CI check:** deterministic repository-wide invariant.
   - **Skip:** one-off, style-only, ambiguous, or context-heavy judgment.

4. **Define scope and exceptions**

   ```text
   Problem:
   Evidence:
   Bad shape:
   Good shape:
   Scope:
   Exceptions:
   Enforcement:
   Fix strategy:
   Validation:
   ```

5. **Implement narrowly**
   - Add or update the existing rule/docs in the repo’s established location.
   - Include passing and failing fixtures for mechanical rules.
   - Keep autofixes conservative. Do not autofix changes that require domain judgment.
   - Avoid broad baseline churn unless the user explicitly asks for a full cleanup.

6. **Validate signal**
   - Run the rule against changed files first, then a broader baseline if needed.
   - Inspect matches manually and classify true positives, acceptable warnings, and false positives.
   - If false positives are material, narrow the rule or downgrade to docs/skill guidance.
   - Run repo-native lint/test/typecheck commands that cover the new guardrail.

7. **Report**
   - What pattern was codified.
   - Evidence and examples used.
   - Files changed.
   - Validation results.
   - Known exceptions or remaining manual review areas.

## Review Checklist For Rule PRs

When reviewing a rule PR, look for:

- The rule name matches what it actually detects.
- Scope excludes generated files, tests, examples, or legacy areas when needed.
- Fixtures cover true positives and common near-misses.
- Autofix does not change behavior.
- CI invokes the rule in the intended package.
- Docs explain when to ignore or avoid enforcing the pattern.
- The rule does not duplicate another linter, skill, or repo convention.

If a finding is valid but hard to detect mechanically, prefer adding a concise repo skill rule and examples over forcing a brittle lint rule.
