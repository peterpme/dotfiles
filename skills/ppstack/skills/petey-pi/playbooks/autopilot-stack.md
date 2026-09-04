### Autopilot-stack

The Pi parent builds and verifies one linear Graphite stack for the user to review and land. Use this when changes are coupled, ordered, or lack merge authority. Use [Autopilot-full](autopilot-full.md) for independent PRs with landing authority.

1. State the queue, dependencies, stack order, and review gates. Begin execution only within the user's authorization.
2. Use the implementation and inspection steps in [Autopilot-full](autopilot-full.md), with [direct Herdr delegation](../../../docs/subagents.md). Helpers get neutral briefs and portable skill paths, never this playbook or **petey-pi**. One writer owns each checkout. Worktrees require explicit request or approval.
3. Read each helper's diff and verify its reported commit before integration. Exercise the changed behavior and inspect the evidence. A passing self-report or idle pane does not establish verification.
4. The parent integrates verified commits in dependency order and owns all Graphite parentage, registration, submission, and restacking. Helpers report their commit and intended base. They do not merge, arm auto-merge, close PRs, or mutate stack topology.
5. After trunk moves or a restack changes patches, rerun affected checks per [Shipping](shipping.md). Resolve conflicts with one writer at a time. A changed patch needs fresh evidence before delivery.
6. Deliver one linear stack, reviewable from bottom to top, with the current head and verification evidence for every PR. The user lands it. Stop at this boundary.

Return links to the stack root and tip, a verification summary per PR, and anything excluded or unfinished with its reason.
