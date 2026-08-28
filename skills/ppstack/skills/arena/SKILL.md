---
name: arena
description: "Run parallel candidates on the same task, pick a base, graft the strongest parts, and verify the result. Use for /arena, arena this, or when one attempt would lock in the wrong shape."
disable-model-invocation: true
---

# Arena

1. Name the artifact and derive three to six gradeable criteria.
2. Write one standalone candidate brief. Include grounding paths, authority, output contract, rationale requirement, and verification.
3. Launch at least two candidates through one async `workflowScript`. For read-only design or prose artifacts, use `council-sol` and `council-grok`. For writable code artifacts, use fresh `worker` or `petey-agent` roles and give every writer a separate worktree. Do not select models per run.
4. After all candidates finish, launch a fresh read-only `reviewer` as cross-judge while the parent reads every candidate end to end.
5. Score each candidate against the rubric. Pick the base with the clearest invariants and smallest useful interface.
6. Graft only ideas that fit the base's design. Record the source, accepted grafts, and rejected alternatives.
7. Verify the synthesized artifact on its real path. Reframe and rerun if candidates diverged because the brief was underspecified.

Return one artifact and one short synthesis note with the base, grafts, rejections, dropouts, and verification result.
