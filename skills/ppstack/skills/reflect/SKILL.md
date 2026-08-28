---
name: reflect
description: Review the active Pi session for durable lessons, then route approved lessons to concrete skill or structural edits. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

1. Use `PI_SESSION_FILE` when present. Otherwise identify the active Pi session from the current session directory. Never scan unrelated project session directories. If no session file resolves, write a tight digest.
2. Launch three fresh read-only `reviewer` lanes through one `workflowScript`. Use the judgment, tooling, and divergent templates under `references/`. Do not select models per run. Pass the session path or digest and require evidence citations.
3. The parent synthesizes with `references/synthesizer.md` into Accepted, Rejected, and Backlog.
4. Move enforceable recurring rules to Backlog for a lint, metadata flag, runtime check, or script.
5. Present the synthesis and wait for explicit approval before editing skills.
6. Apply approved skill edits with the `writing-for-agents` skill and its mechanics reference. Validate frontmatter, links, references, and structural test cases.
7. Report edits, new skills, backlog entries, and rejected findings.
