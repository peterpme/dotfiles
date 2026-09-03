---
name: debugger
description: >-
  Session problem log for improving ppstack. The debugger extension logs failed
  bash, read, and subagent calls on its own; the model calls the log_problem
  tool when it was wrong, was corrected, dropped a path, or hit leftover work.
  /debugger prints the log. Use when something breaks or surprises you, when
  corrected, or when the user says debugger.
disable-model-invocation: true
---

# Debugger

One TSV beside the Pi session file, `<session>.problems.tsv`, with columns `ts`, `kind`, `problem`, `fix`, `status`, `target`, `trace`. Never in a repo. Never committed.

Two writers.

- **The extension** (`pi/extensions/debugger`) appends a row for every failed `bash`, `read`, or `subagent` call, skipping lookups that fail by design (`rg`, `grep`, `fd`, `find`, `ls`, `git diff`) and repeating an identical failure once per session. No model tokens.
- **The model** appends the rows only it can see with one `log_problem` call: `kind` is `wrong-assumption`, `correction`, `wrong-path`, `leftover`, or `drift`; `problem` is one line; `fix` is one line or omitted while open; `target` is the ppstack skill, playbook, script, or Pi config file that should change so it does not recur. One call, keep working. Do not discuss the row unless it blocks the work.

Skip routine progress and guesses that were right. Do not grep the tree for TODOs to fill the log. Only the parent logs; a child names its snag in its report.

`/debugger` prints the log with no model turn. `scripts/log.sh <file> <kind> <problem> <fix> <status> <target> [trace]` writes a row by hand with the same columns.

Nothing here is promoted anywhere. The human reads the log and decides what changes. **reflect** is separate and mines the transcript on its own.
