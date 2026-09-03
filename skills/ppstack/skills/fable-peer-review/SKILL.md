---
name: fable-peer-review
description: Peer-review via local `claude` on Fable 5.1. Use for fable peer review, spawn claude, or claude -p.
---

Spawn the `claude` binary through bash. Not the builtin `claude-code` subagent.

```bash
claude -p --model claude-fable-5-1 --effort max --permission-mode plan "$(cat <<'EOF'
<brief>
EOF
)"
```

The child has no parent chat. Run from the repo under review. Stay in plan mode. Return stdout.
