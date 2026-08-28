### Autonomous run

1. State a checkable exit predicate before the first iteration.
2. Create or attach one goal mission with a token budget. Store the exact next action in mission state. Use a schedule only for user-requested timed work.
3. Launch work asynchronously through `workflowScript`. Let result delivery wake the parent. Use `subagent_wait` only when the current turn must consume the result.
4. Keep one writer per checkout. Each iteration makes the smallest evidenced change, verifies the predicate, and records the result through `show-me-your-work`.
5. Resume from mission state and receipts after restart. Do not infer progress from chat memory or poll status merely to wait.
6. Stop when the predicate passes, a required owner decision blocks progress, the budget ends, or evidence proves a dead end. Close the mission with the real terminal state.

Reply with the predicate, iterations, landed work, discarded attempts, mission id, and final state.
