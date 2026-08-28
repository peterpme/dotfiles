---
name: no-comments
description: "Run Comment Sicko, fix accepted findings, and offer structural encodings for claimed constraints."
disable-model-invocation: true
---

# No comments

1. Define the caller's files or current diff as scope. Supply named paths or a materialized patch. Do not ask Comment Sicko to discover the change set through Git.
2. Launch one `comment-sicko` child in the target checkout as the sole writer. Give it a standalone scope brief. Do not restate its rules or select a model. It owns comment deletions and may use its configured `how` and `why` skills before judging a claimed constraint.
3. Inspect the report and diff only for the delegation boundary. Reject scope escapes and any non-comment code change. Resume the same child once with the exact invalid hunk and require restoration; if it fails again, restore only that child's invalid hunk and report the failed pass.
4. Accept Comment Sicko's comment judgments. Treat every `MUST KILL` as a structural recommendation, not authority to change application code.
5. When the caller accepts a `MUST KILL`, use `architect` once, then give one writer the smallest in-scope root-cause fix. Apply any type, runtime check, test, or lint encoding only within the caller's authority.
6. Report deletions, preserved comments, restored hunks, reruns, accepted structural fixes, encodings, and open recommendations.
