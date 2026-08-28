---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, swarm this, parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

Use the installed `pi-subagents` multi-lane workflow. The parent owns framing and aggregation.

1. State the done predicate, required artifact, and report shape.
2. Choose coverage, race, or mixed. Declare the selection rule before a race.
3. Give each lane a standalone brief with goal, scope, source seam, authority, verification, and report contract.
4. Use `scout` for read-only retrieval, `reviewer` for judgment, `worker` for standard implementation, and `petey-agent` only for Petey-aware writing. Do not select models per run.
5. Launch coordinated lanes with one async `workflowScript`. Use stable keys. Keep one writer per checkout. Give concurrent writers separate worktrees.
6. Require `PASS`, `ISSUES`, or `BLOCKED` with evidence. Account for every lane and note dropouts.
7. Return one compact result table, evidenced issues, gaps, and the declared race rule. Do not paste raw reports.
