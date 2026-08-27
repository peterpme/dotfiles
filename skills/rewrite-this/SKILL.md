---
name: rewrite-this
description: Rewrite text in my voice, ready to paste into Slack.
disable-model-invocation: true
---

# Rewrite this

Rewrite the draft so it sounds like Peter and is ready to paste into Slack.

## Source

Use the text they pasted with the invoke. If they point at a prior message, use that. Pasted text wins when both exist.

Thread context (a pasted Slack thread, "replying to X", or a named channel) is register, not source. Do not rewrite the thread.

## Register

Match the thread they pasted or described. No thread: match the draft's job.

| Job | Shape |
|---|---|
| Casual reply | One or two short lines. lowercase is fine if the thread is. |
| Ask | The ask first, then one line of why if the ask needs it. |
| Update | What changed, what's next, any ask. No preamble. |
| Pushback | The disagreement, then the reason. No softening stack. |

Length follows the thread, not the draft. A three-paragraph draft of a one-line reply becomes one line.

## Voice

Sound like the person who typed the invoke, not like an assistant cleaning it.

- Short sentences. One thought each.
- Plain words. Specific facts and names.
- "I" and "we" the way the thread uses them.
- Slack-isms are fine: lmk, fwiw, nbd.
- Fix typos and muddy referents. Keep the cadence.
- No greeting, no sign-off, no emoji unless the thread has them.

## Output

Reply with only the paste-ready text. No preamble, no alternatives, no quotes.

## Examples

Draft: "Thanks for flagging this! I think that's a great point. I'll take a look and circle back shortly."

```
good catch, looking now
```

Draft: "I wanted to provide a quick update on the skills migration. We've successfully reorganized the repository such that all pstack skills now live in a single capsule."

```
moved the pstack skills into one ppstack capsule. linker still finds each SKILL.md
```
