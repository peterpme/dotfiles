### Orchestrate

The Pi coordinator owns the plan, verification, and integration for a project that spans several tasks or PRs. If one agent can finish within the session budget, use Autonomous run instead.

1. State the outcome, scope, dependencies, allowed actions, and available budget. Split work into units with concrete artifacts and checks. Resolve contested design before implementation.
2. Prove one unit end to end before expanding. Use its actual results to improve later briefs and verification steps. Keep the plan and a decision trail through **show-me-your-work** small enough to read.
3. Load **spawn-subagent** and follow [the delegation contract](../../../docs/subagents.md). Give each helper a fresh neutral brief with its scope, upstream findings, absolute portable skill paths, verification commands, and expected in-chat report. Do not pass the Pi coordinator skill or this playbook to helpers.
4. Keep one writer per checkout. The parent reads while a child writes. Parallel writers require worktrees explicitly requested or approved by the user. Launch from each approved cwd after checking dependencies and the first verification command. Otherwise sequence writers. Parallel read-only investigation can use the same stable checkout.
5. Inspect returned Herdr names and panes with `agent get`, `read`, and bounded `wait`. Prompt specific corrections. Idle or done is not proof. A timeout is not cancellation. If blocked, inspect the output and ask the user. Do not replace a writer until it has stopped.
6. Read each artifact and diff. Verify the behavior at the reported commit. Use an independent reviewer for judgment-heavy work and **peer-review** when another family adds value. Missing evidence stays unverified. Fix failed work before advancing dependent units.
7. Integrate verified commits in the Pi parent. Keep stack operations under one owner. Helpers do not rebase the shared stack, merge PRs, or change parentage. Work from the lowest unmerged PR upward. After a restack, check which patches changed and rerun affected verification per [Shipping](shipping.md).
8. Report progress from artifacts, commits, checks, and current PR state. Keep named user gates intact. At a pause or session end, record the remaining work and Herdr targets. Do not promise automatic continuation or completion delivery.
9. Finish only when the outcome is verified and authorized integration is complete. Account for missing or unfinished helpers and report any unresolved decisions.

Return the outcome, verified commits and PRs, remaining work, blocking decisions, and the decision-trail path.
