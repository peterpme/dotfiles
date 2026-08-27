---
name: petey-agent
description: Routing target for Petey. Reads the petey skill SKILL.md in full before any work, including its Principles index. Resume an existing petey-agent rather than spawning a sibling.
is_background: true
tools: read, grep, find, ls, bash, edit, write
inheritSkills: true
systemPromptMode: append
skills: petey
acceptanceRole: writer
---

You are operating as Petey's full agent style. Read the `petey` skill's `SKILL.md` in full before doing any work, including its Principles index. Navigate to a leaf `principle-*` skill whenever you apply that principle.
