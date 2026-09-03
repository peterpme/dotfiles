---
name: log-problems
description: >-
  Log session-local problems: agent misunderstandings, wrong assumptions,
  abandoned paths, and out-of-scope leftovers. Write LOG.md next to the Pi
  session file, never in the repo, never commit it. Surface it when wrapping
  up. Use when confused, corrected, a wrong path is dropped, leftover work is
  noticed, a feature or PR is finishing, or the user says log-problems.
---

# Log problems

Scratch log of snags in this session. Keep working. Recap only at wrap-up.

This is not a decision trail. That is **show-me-your-work**.
This is not a project file. Other repos already use `LOG.md` for real records.

## Where

Next to the session jsonl:

```bash
printf '%s\n' "${PI_SESSION_FILE%.jsonl}.LOG.md"
```

Create it on the first snag. Header:

```markdown
# Session log

Session: $PI_SESSION_ID
```

No `PI_SESSION_FILE` (ephemeral session): keep snags in memory and print them only in the wrap-up recap. Leave the repo tree untouched.

Only the interactive parent writes. A child names the snag in its returned output. The parent appends.

## When to append

Append and continue. Do not mention the log in chat until wrap-up.

- You assumed something about the repo, API, or task that was wrong
- The user corrected you
- You dropped a path after it failed
- You hit leftover work that is out of scope (a TODO, bug, or broken link you actually ran into). Do not grep the tree for TODOs to fill the log.

Skip routine progress, plans, and guesses that were right.

## Entry

Append-only. One heading per snag.

```markdown
## 2026-09-01T18:22Z misunderstanding
Assumed skills live only in ~/.pi/agent/skills. They are linked from ~/dotfiles/skills.
Status: corrected
```

Kinds: `misunderstanding`, `wrong-path`, `correction`, `leftover`, `confusion`.

Status: `open`, `corrected`, or `leftover`.

One or two sentences. What you got wrong, what was true instead.

## Wrap-up

When the feature, PR, or task is finishing, or the user asks for the log (`/skill:log-problems`, "show the log"):

1. Read the session `.LOG.md`.
2. Put a **Session log** section in that reply. Open items first. Then corrected items that should change a skill or the repo later.
3. Empty or missing file: omit the section.

Invoked with no current snag: print the log, or say it is empty.

## Guardrails

Write only beside the session file, or recap from memory if there is no session file.
Keep the log out of `git add`, commits, and the project tree.
Do not pause the task to discuss a snag unless it blocks the work.
