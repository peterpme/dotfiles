### Feature

**You own the design. Plan, review, verify.** Delegate implementation; stay in the lead.

1. Trace the affected code in this session with `grep`, `find`, and `read`. Name the invariant and the data shape. `how` only when that pass leaves the subsystem opaque. Skipping stays as `how skipped: parent traced <symbols>`. A **grill** brief's Invariants and Data shape count as this trace; then the item reads `trace: brief <path>`.
2. Run `architect` for persistence schema, queue contract, or public identity changes. For other features, run it only when the design remains contested after the trace. Skipping stays as `architect skipped: <reason>`. Do not fold a still-open design decision into implementation.
3. Write the throughput checkpoint as four todo items. A dimension that genuinely does not apply (single file, no fan-out) keeps its item with `n/a: <reason>` rather than being dropped:
   - **Blocking first steps.** Gates run before fan-out.
   - **Independent workstreams.** Disjoint files, services, or layers parallelize. Shared writes serialize.
   - **Shared mutable state.** Default to splitting the target (the **separate-before-serializing-shared-state** principle skill). Serialize only for real invariants.
   - **Smallest safe decomposition.** If one worker is best, name why.
4. Write the proof before the code via the **proof-plan** skill when the feature has no `## Proof` yet. Its boxes are what step 6 runs. Skipping stays as `proof-plan skipped: <existing proof path>`.
5. Delegate code-writing to the configured `worker` or `petey-agent` without per-run model selection. The packet must include `TRACE`, `FIRST UNIT`, `WRITE SEAM`, `FIRST CHECK`, and `EXPAND ONLY WHEN` as defined in **Subagents**. Name the data shape and its organizing structure per **principle-model-the-domain** before the delegate writes logic. Review its diff yourself. Use the **arena** skill only when two structurally distinct shapes remain open after the trace. Skip arena when the invariant and data shape are already named. You can spawn a subagent even though you are one. "The app is small" and "a subagent cannot spawn one" are both wrong. A subagent forbidden to spawn satisfies this by owning the diff directly with the same review separation. No "standing by" reply that waits on a nested agent. Comments per **Comments**. Surgical edits, re-ground against the source for upstream-derived files. Port shared-primitive improvements to all consumers and verify each. Commit liberally.
6. Work the `## Proof` boxes on the matching surface yourself. Record the command or surface and what it showed. "Inconclusive" or wrong-surface is not a pass; flag it. Until this step runs, the state is `implemented, unverified` (**Done**).
7. Rebase into small, ordered commits; stack follow-ups.
   Use the **sequence-verifiable-units** principle skill, building, verifying, and committing each small unit before the next.
8. If the design is contested, `interrogate` before shipping.
9. Run **Opening a PR**.

Code-coupled work (one feature, one migration) goes to a single owner with the checkpoint inline; that owner fans out internally after the blocking phase. Parent-level fan-out is for slices that produce independent artifacts (audits, cross-subsystem investigations, competing experiments). In a new worktree, the parent installs dependencies and proves `FIRST CHECK` starts before launch. Rewrite the checkpoint at phase boundaries; spawn a fresh owner rather than chaining interrupts.

**Reply:** what you built, what you chose and why, how you verified it and what it showed, open decisions. Tables for design alternatives.
