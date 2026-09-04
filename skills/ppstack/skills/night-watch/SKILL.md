---
name: night-watch
description: "Pre-flight for leaving agents running unattended: pin the done predicate, checkout ownership, the verifier, budgets, and blockers, then hand off to the matching long-run playbook. Use for /night-watch, 'set up an overnight run', 'I'm going to bed, set this up', 'run this while I'm away', or before any autonomous run, autopilot, or orchestrate program."
disable-model-invocation: true
---

# Night watch

An unattended run fails in the morning for reasons that were visible the night before. This skill is the pre-flight. It does not do the work. It hands a checked contract to `petey-pi/playbooks/autonomous-run.md`, `autopilot-full.md`, `autopilot-stack.md`, or `orchestrate.md`.

Check these before starting:

1. State a falsifiable done condition and the user's authorized actions. Use **grill** when product choices remain open.
2. Choose Autonomous run for one task, Autopilot-full for independent PRs with merge authority, Autopilot-stack for a reviewed stack, or Orchestrate for a larger project.
3. Run **proof-plan** if proof is not defined. Run the verifier's doctor and one real check in the current checkout before leaving work unattended.
4. Name the checkout and its writer. The parent reads while a child writes. Worktrees require explicit user request or approval. Sequence writers otherwise.
5. Load **spawn-subagent** and follow [the delegation contract](../../docs/subagents.md). Record returned Herdr names and panes. Inspect output between bounded waits. Idle or done is not proof. A timeout does not cancel work.
6. State any user-supplied budget and leave time for verification and integration. Do not replace an active writer because a wait timed out. If blocked, inspect its output and ask the user.
7. Give helpers fresh neutral briefs with scope, evidence, leaf reference paths, portable skills when selected, and no further delegation. Never pass **petey-pi** or a coordinator playbook to a helper.
8. Keep the decision trail through **show-me-your-work**. At a session boundary, record remaining work and helper targets. Do not promise automatic continuation or result delivery after the parent stops.
9. Report the done condition, verifier result, checkout ownership, active helpers, and unresolved user decisions, then continue under the selected playbook within existing authorization.

An unattended request does not remove blockers that require a user decision. Keep independent authorized work moving while that decision is pending.
