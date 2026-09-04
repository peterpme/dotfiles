### Autopilot-full

The Pi parent drives a queue of independent changes to verified, merged PRs when the user has granted landing authority. Items the user reserves for review stop at merge-ready.

1. Confirm the queue, dependencies, done condition, and existing authorization. A request to state a plan is not permission to execute it. Record any user-owned review gates.
2. Load **spawn-subagent** and follow [the delegation contract](../../../docs/subagents.md). Give one helper a scoped neutral implementation brief with portable skill paths, checks, cleanup requirements, and an in-chat commit report. Helpers do not load **petey-pi** or this playbook.
3. Keep one writer per checkout, including the parent. Parallel implementation requires explicitly requested or approved worktrees. Otherwise sequence writers. Independent changes branch from main. Dependent changes wait for integration or use the agreed stack order.
4. The parent inspects the diff and verifies the reported commit. For each PR, run the relevant gates, exercise the changed behavior through the available verifier, and inspect the resulting evidence. Use **swarm** for useful independent coverage. Missing live access is `UNAVAILABLE`, not a pass.
5. The parent integrates verified commits, prepares the PR, triages bot findings per [the rubric](../references/bugbot-triage.md), and runs [Babysit](babysit.md) when required. Resolve base drift before the final verdict. Recheck changed patches after a rebase per [Shipping](shipping.md).
6. Merge only with a passing verdict for the current change and user authority. The parent owns the merge. Reserved items wait for the user's review. A genuinely new increase to a pinned gate or budget needs explicit parent judgment backed by proof.
7. Inspect active helpers through Herdr and update the user from actual artifacts and PR state. Idle or done is not proof, and a timeout does not cancel work. Inspect a blocked helper and ask the user. A replacement writer waits until the old writer has stopped.
8. On the user's stop, start no new work and tell active helpers to stop writes. Confirm their state before resuming ownership. Keep a checkpoint of work and evidence without promising automatic continuation.

Return the queue with each PR's helper, head, verification, and merge state, plus user gates and unfinished work.
