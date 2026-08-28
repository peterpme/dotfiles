---
name: recall
description: "Reconstruct recent working context from Pi sessions, live state, and shared records, then return a tight current-state brief. Use for recall my work, catch me up, or where did I leave off."
disable-model-invocation: true
---

# Recall

1. Route one known prior session to the session-pickup playbook. For broader recall, pin the topic, active workspace, and time window. Default to seven days.
2. Resolve only Pi session files for the active workspace. Use `PI_SESSION_FILE` as the anchor when available. Never scan another workspace.
3. For more than two sessions, use fresh `scout` lanes through one workflow. Split by time range. Each returns topic, goal, decisions, open work, corrections, artifacts, and session id. Keep raw session content out of the parent result.
4. For a named feature, file, subsystem, or bug, also run the `why` skill's evidence coverage for current shared state.
5. Verify surfaced branches, PRs, and tickets with live `git`, `gh`, and available source tools.
6. Return at most five capsule bullets, one status-tagged line per thread, at most five recurring problems, and one concrete next move. Cite session ids and shared records.
