---
name: debugger
description: >-
  Append-only TSV log of what broke this session and how it was fixed: a model
  call or subagent failed, a file or skill was missing, a tool misbehaved, an
  assumption was wrong, the user corrected you, a path was abandoned, leftover
  work surfaced. Lives beside the Pi session file, never in the repo. Recapped
  at every wrap-up. Rows that should change ppstack are promoted so the loop
  closes. Use whenever something breaks or surprises you, when corrected, when
  finishing a task, or when the user says debugger.
---

# Debugger

Every snag this session hits becomes a row that can change ppstack later. Keep working. Recap at wrap-up. That is the whole job.

Not a decision trail. That is **show-me-your-work**. Not a skill editor. That is **reflect**, which reads these rows to propose skill edits.

## Where

Session log, next to the session JSONL:

```bash
printf '%s\n' "${PI_SESSION_FILE%.jsonl}.problems.tsv"
```

Durable log, for rows that should change ppstack: `~/dotfiles/skills/ppstack/debug/problems.tsv`. Ignored by git, local to this machine. `/petey-debug <label>` appends a `capture` row there with the saved trace path.

No `PI_SESSION_FILE` (ephemeral session): keep rows in memory and print them in the wrap-up recap. Leave the repo tree untouched.

## Row

Append with the helper. It stamps `ts`, writes the header on first use, strips tabs and newlines, and guards cells a spreadsheet would read as a formula.

```bash
scripts/log.sh <logfile> <kind> <problem> <fix> <status> <target> [trace]
```

Columns: `ts`, `kind`, `problem`, `fix`, `status`, `target`, `trace`.

- `kind`: `model-call`, `tool`, `missing-file`, `wrong-assumption`, `correction`, `wrong-path`, `drift`, `leftover`, `capture`.
- `problem`: one line. What broke or what you got wrong.
- `fix`: one line. What was true instead, or what fixed it. `-` while open.
- `status`: `open`, `fixed`, or `leftover`.
- `target`: the skill, playbook, script, or config file that should change so this does not recur, or `-`.
- `trace`: session id, run id, or trace path, or `-`.

## When

Append and continue. Do not discuss a row unless it blocks the work.

- A model call, subagent, or tool failed, timed out, or returned garbage.
- A file, skill, script, or command the instructions named was missing or different from described.
- You assumed something about the repo, API, or task that was wrong.
- The user corrected you.
- You dropped a path after it failed.
- You hit leftover work out of scope that you actually ran into. Do not grep the tree for TODOs to fill the log.

Skip routine progress and guesses that were right. Only the interactive parent writes. A child names the snag in its report and the parent appends.

## Wrap-up

Every reply that closes a task carries a **Session log** section. Open rows first, then fixed rows whose `target` names a ppstack or Pi file. Empty log: write `**Session log.** No snags.` The section is never omitted, so its absence means the wrap-up was skipped.

Promote every row whose `target` is under `skills/ppstack` or `pi/` to the durable log with the same columns and the session id in `trace`. Those rows are what **reflect** and the next `/petey` session read to improve ppstack.

Invoked with no current snag (`/skill:debugger`, "show the log"): print the session log, or say it is empty.

## Guardrails

Write only beside the session file or into the ignored durable log. Never `git add` either file. Never pause the task to discuss a snag unless it blocks the work.
