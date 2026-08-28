---
name: interrogate
description: "Use for interrogate, adversarial review, multi-model review, challenge this, stress test this code, find blind spots, or tear this apart. Independent reviewers challenge changes from distinct evidence angles."
disable-model-invocation: true
---

# Interrogate

Produce a parent-owned adversarial verdict. Do not auto-apply findings.

1. Identify the exact diff, files, base revision, and intended outcome. The parent materializes the changed-path list and patch when the review depends on them.
2. Build one standalone review brief. Include intent, scope, evidence paths, acceptance checks, `references/rubric.md`, and `references/code-quality-review.md`. Require `MISSING EVIDENCE` with the exact parent command when a required artifact is absent.
3. Use the installed `pi-subagents` packaged parallel-review pattern. Launch fresh builtin `reviewer` runs through one `workflowScript`. Give each a distinct angle such as correctness, tests, simplicity, security, or user flow. Do not select models per run.
4. Parse and deduplicate findings. Agreement raises confidence but does not replace source proof.
5. Apply `references/lead-judgment.md`. Classify every finding as Act on, Consider, Noted, or Dismissed. Cite the reviewers and the source evidence.

Return the intent, reviewer angles, classified findings, and agreement map.
