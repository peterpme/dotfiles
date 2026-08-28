---
name: how
description: "Use for how does X work, code walkthroughs before changing something, and placement, ownership, or layering questions. Explains subsystem architecture and runtime flow. Can critique architecture. Use why for motivation."
---

# How

Explain a subsystem at the level a senior engineer needs to start working in it.

## Explain

1. Bound the question. State the best interpretation instead of asking about a minor ambiguity.
2. For one module or symbol, inspect it in the parent with `grep`, `find`, and `read`.
3. For a cross-cutting subsystem, use builtin `scout` in fresh context. Split only genuinely distinct source seams. Launch the coordinated fanout through the installed `pi-subagents` workflow path. Each task names its seam, entry points, evidence requirement, and bounded report shape. Use `references/explorer-prompt.md` as the report contract.
4. Read the load-bearing files yourself. Reconcile child findings against source.
5. Write the explanation using `references/explainer-prompt.md`.

Use these sections when they help. Overview, key concepts, runtime flow, file map, and gotchas. Cite paths and symbols. Do not dump files.

## Critique

Explain first. Then use fresh builtin `reviewer` runs with distinct architecture angles and the same grounded explanation, paths, `references/critic-prompt.md`, and `references/critique-rubric.md`. Use the packaged parallel-review pattern. The parent classifies findings as Act on, Consider, Noted, or Dismissed and writes the verdict.
