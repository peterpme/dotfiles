---
name: architect
description: "Ground a design, produce independent architecture candidates, synthesize a sketch, and implement against it. Use for /architect, architect this, design this, or non-trivial boundary changes."
disable-model-invocation: true
---

# Architect

1. Ground the affected systems with `how`. Use `why` when existing ownership or layering is a constraint.
2. Write one neutral design brief with the question, goal, non-goals, owner decisions, pinned revision, relevant paths, evidence targets, rubric, unknowns, and report shape.
3. Run `arena` with fresh read-only `council-sol` and `council-grok` architecture candidates. Give both the same brief and `references/runner-prompt.md`. Require the package in `references/rationale-template.md` and screen against `references/design-red-flags.md`.
4. The parent compares whole-shape alternatives and writes the synthesis. Use Council Mode's bounded cross-exam when the choice remains materially contested. The parent owns the claim matrix, challenge packets, and verdict.
5. Proceed unless the caller requested a checkpoint. Give one fresh `worker` a standalone implementation brief as the sole writer for the checkout.
6. Treat repeated implementation friction as evidence the sketch is wrong. Re-ground, subtract the failed shape, and rerun the candidate flow rather than adding escape hatches.

Return the caller usage first, then types, signatures, module map, and rationale.
