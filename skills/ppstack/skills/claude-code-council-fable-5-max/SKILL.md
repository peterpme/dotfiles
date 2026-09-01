---
name: claude-code-council-fable-5-max
description: Spawn the local bash `claude` CLI on Fable 5 max effort as a read-only council. Use for spawn claude, claude -p, fable 5 council, or claude-code-council-fable-5-max.
---

# Fable 5 max-effort council

Spawn the `claude` binary through the parent bash tool. That is the spawn path. The builtin `claude-code` subagent is a different runner and does not take these flags.

## Flags

Pin these on every call:

- `-p`
- `--model claude-fable-5`
- `--effort max`
- `--permission-mode plan`

Council turns use `--output-format json`. The answer is `.result`. Confirm `is_error` is false and `modelUsage` contains `claude-fable-5`. Use `--output-format text` only when the user wants raw prose and no extraction.

## Steps

1. Write a standalone brief: question, scope, cwd, and what to return. The child has no parent chat.
2. Run from the repo under review. Heredoc the brief so quotes survive:

```bash
claude -p --model claude-fable-5 --effort max --permission-mode plan --output-format json "$(cat <<'EOF'
<brief>
EOF
)"
```

3. Timeout is the bash tool's `timeout` in seconds. Use 30s for a login probe. Use minutes for a real council turn.
4. If the process prints `Failed to authenticate` or exits non-zero on auth, stop. The user runs `claude auth` in a real terminal. Then retry once.
5. Return `.result` from json. Return stdout as-is from text. Include cost or session id only when asked.

Stay in plan mode and report. Native Pi subagent options (`model`, `thinking`, `outputSchema`, `context`) do not apply to this CLI.
