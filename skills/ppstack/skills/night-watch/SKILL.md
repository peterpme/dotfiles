---
name: night-watch
description: "Pre-flight for leaving agents running unattended: pin the done predicate, the wake mechanism, the verifier, the budgets, the trail, and the escalation gates, then hand off to the matching long-run playbook. Use for /night-watch, 'set up an overnight run', 'I'm going to bed, set this up', 'run this while I'm away', or before any autonomous run, autopilot, or orchestrate program."
disable-model-invocation: true
---

# Night watch

An unattended run fails in the morning for reasons that were visible the night before. This skill is the pre-flight. It does not do the work. It hands a checked contract to `petey/playbooks/autonomous-run.md`, `autopilot-full.md`, `autopilot-stack.md`, or `orchestrate.md`.

Open a todolist with the ten items below copied verbatim. A skipped item stays listed with `skip: <reason>`.

1. **Done predicate.** Countable or falsifiable, in words a script could check. A duration is not a predicate. "Work on this for four hours" buys four hours of motion. No brief yet, or a predicate you would be guessing at, means a **grill** session in strong mode first. It keeps going until the frontier is empty, and its brief is the run's contract.
2. **Route.** One task driven to a predicate is Autonomous run. A queue of independent PRs with merge authority is Autopilot-full. The same queue delivered as one reviewed stack is Autopilot-stack. A program that outlives one agent is Orchestrate, and only when one agent could not finish inside the session's budget.
3. **Proof.** Run **proof-plan** if no `## Proof` exists for the work. Then run the verifier's doctor command and one real drive on the current checkout, now. A verifier that fails at 3am produces a night of `UNAVAILABLE`.
4. **Isolation.** A fresh worktree off the named base. One writer per worktree or branch (**principle-separate-before-serializing-shared-state**). Name the path.
5. **Wake mechanism.** An event to watch (CI, a merge, a ref advancing) gets an async watcher run with a long scheduled heartbeat as fallback. No event gets a fixed schedule sized to when a re-check is worth it. Cross-turn programs arm a Pi mission. Never a polling loop in the parent. Name the cadence.
6. **Budgets.** Children run until they finish; only **peer-review** lanes carry a fixed 15-minute cap. Name the whole-run budget and stop spawning at roughly 70 percent of it to land what is verified. Two retries per unit, then abandon and replan.
7. **Standing orders.** What the run may do without asking (commit, push its own branch, open PRs) and the lines it never crosses (force-push to shared branches, deploys, deletions, customer messages). Numbered lines. Pasted into every spawn and every resume.
8. **Trail.** The `decisions.tsv` path per **show-me-your-work**, committed or local. Snags go to **debugger**.
9. **Escalation.** What ends the run early: a dead end after N attempts, a predicate the code contradicts, a gate only the human can answer. Where the stop note goes, per `petey/playbooks/pause-safely.md`.
10. **Morning report.** The shape the user reads first: predicate state, what landed, the trail review's Attention section, what needs them. Nothing else above the fold.

Then state the contract back in at most ten lines and start the playbook. The session override is in effect. Keep going.

```text
Goal: <one sentence>
Done: <predicate>
Playbook: <name>
Worktree: <path off base>
Verifier: <skill and doctor result>
Wake: <watcher or schedule, heartbeat cadence>
Budget: <per child, whole run, retries>
May: <actions>   Never: <lines>
Trail: <path>
Stop when: <escalation>, note at <path>
```

**Reply:** the contract, the doctor output, and the run id or schedule armed.
