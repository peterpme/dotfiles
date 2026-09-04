---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

Fan out N parallel workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report. Read [the delegation contract](../../docs/subagents.md) and load **spawn-subagent** before launching children.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
3. Set N from the user or derive it from the shape. N is total workers, not the cloud concurrency limit.
4. For a race, give every arm the same brief and selected agent. Use **peer-review** if the task calls for actual different model families.
5. Keep one writer per checkout. Parallel writes require explicitly requested or approved worktrees. Otherwise sequence writers. Read-only findings return in chat, without a report-file requirement in the initial prompt.

## Phase B: Fan out

Launch each child through **spawn-subagent** from its assigned cwd. Pass explicit portable skill paths and no-edits instructions for searches and reviews. Keep the returned Herdr name and pane, then inspect and wait through Herdr. The parent stops editing while a child owns its checkout.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence.

If a child produces no result, inspect its state and scrollback. A timeout does not cancel it. Ask the user about a blocked state and confirm a writer has stopped before reusing its checkout. Record missing coverage explicitly.

## Phase C: Aggregate

Read the terminal results. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

Keep a compact result table, one-line evidenced issues, and explicit gaps or dropouts.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
