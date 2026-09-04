### Feature

**You own the design. Plan, review, verify.** Delegate implementation; stay in the lead.

1. Trace the affected code in this session with `grep`, `find`, and `read`. Name the invariant and the data shape. `how` only when that pass leaves the subsystem opaque. Skipping stays as `how skipped: parent traced <symbols>`. A **grill** brief's Invariants and Data shape count as this trace; then the item reads `trace: brief <path>`.
2. Run `architect` for persistence schema, queue contract, or public identity changes. For other features, run it only when the design remains contested after the trace. Skipping stays as `architect skipped: <reason>`. Do not fold a still-open design decision into implementation.
3. Write the throughput checkpoint as four todo items. A dimension that genuinely does not apply (single file, no fan-out) keeps its item with `n/a: <reason>` rather than being dropped:
   - **Blocking first steps.** Gates run before fan-out.
   - **Independent workstreams.** Independent investigations can run together. Writes in one checkout stay sequential, even across disjoint files.
   - **Shared mutable state.** Default to splitting the target (the **separate-before-serializing-shared-state** principle skill). Serialize only for real invariants.
   - **Smallest safe decomposition.** If one worker is best, name why.
4. Write the proof before the code via the **proof-plan** skill when the feature has no `## Proof` yet. Its boxes are what step 6 runs. Skipping stays as `proof-plan skipped: <existing proof path>`.
5. Delegate code-writing through **spawn-subagent** under [the delegation contract](../../../docs/subagents.md). Give the helper a neutral brief and selected portable skill paths, never **petey-pi** or this playbook. The packet must include `TRACE`, `FIRST UNIT`, `WRITE SEAM`, `FIRST CHECK`, and `EXPAND ONLY WHEN` as defined in **Subagents**. Name the data shape and its organizing structure per **principle-model-the-domain** before the delegate writes logic. Review its diff yourself. Use the **arena** skill only when two structurally distinct shapes remain open after the trace. Skip arena when the invariant and data shape are already named. The Pi parent owns delegation and stops editing while the helper writes. A helper assigned implementation owns that scope directly and returns to the parent. Comments per **Comments**. Surgical edits, re-ground against the source for upstream-derived files. Port shared-primitive improvements to all consumers and verify each. Commit liberally.
6. Work the `## Proof` boxes on the matching surface yourself. Record the command or surface and what it showed. "Inconclusive" or wrong-surface is not a pass; flag it. Until this step runs, the state is `implemented, unverified` (**Done**).
7. Rebase into small, ordered commits; stack follow-ups.
   Use the **sequence-verifiable-units** principle skill, building, verifying, and committing each small unit before the next.
8. If the design is contested, `interrogate` before shipping.
9. Run **Opening a PR**.

Code-coupled work goes to one writer with the checkpoint in its brief. The Pi parent coordinates independent investigations. One writer owns each checkout, and worktrees require explicit user request or approval. In an approved worktree, prepare dependencies and prove `FIRST CHECK` starts before launch. Update the brief when new evidence changes the next unit.

**Reply:** what you built, what you chose and why, how you verified it and what it showed, open decisions. Tables for design alternatives.
