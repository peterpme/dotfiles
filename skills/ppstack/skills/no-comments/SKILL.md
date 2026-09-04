---
name: no-comments
description: "Delegate a scoped comment deletion pass, fix accepted structural findings, and offer encodings for valid constraints."
disable-model-invocation: true
---

# No comments

Delegate comment judgment to a fresh reader using [the deletion rules](references/deletion-rules.md). Act on accepted structural findings.

## Scope

Use the caller's named files or materialized diff. Otherwise use the current diff against the base branch, including the working tree. The parent resolves that scope before launch; the child never discovers the change set through Git.

## Steps

1. Follow [the delegation contract](../../docs/subagents.md) and load **spawn-subagent**. Launch one child as sole writer in the target checkout. The parent runs this skill. Give the child the absolute path to `references/deletion-rules.md` in its standalone brief, with no further delegation. Supply any grounding evidence from **how** and **why** yourself. Tell it to perform only the deletion pass and return its findings in chat. The parent stops editing until it finishes.
2. Inspect its report and diff only for the delegation boundary. Reject scope escapes and non-comment code changes. Prompt the same child once with the exact invalid hunk and require restoration. If it fails again, restore only that invalid hunk, report the failed pass, and stop.
3. Accept the child's keep and delete judgments. Treat every `MUST KILL` as a structural recommendation, not authority to change application code. When the caller accepts a recommendation, fix trivial flags directly. If a fix needs a shape, run `architect` once for the accepted set and surrounding code, then implement the smallest root-cause fix in scope with one writer.
4. Remove every accepted workaround. If the root cause is out of scope, land the smallest in-scope fix and report the rest open. The **principle-fix-root-causes** and **principle-redesign-from-first-principles** skills guide intent only. Neither authorizes widening the fence nor fixing instances outside it.
5. For a preserved constraint that says `do not remove`, `do not change wording`, or `talk to X before changing`, offer the cheapest in-scope type, runtime check, test, or CI lint. Apply it only within the caller's authority. Otherwise leave the proven external constraint comment in place.
6. Report the deletion count, preserved comments, restored hunks, reruns, architect sketch, fixes, encoding offers, encodings, and open recommendations.
