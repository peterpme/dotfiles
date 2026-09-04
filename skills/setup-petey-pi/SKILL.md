---
name: setup-petey-pi
description: Install or verify Petey Pi's Pi-only skills and direct Herdr delegation. Use when setting up Petey Pi or checking its available agent CLIs.
disable-model-invocation: true
---

# Set up Petey Pi

Run this setup skill in Pi. Native helpers do not load the coordinator skill.

1. Find **petey-pi** and **spawn-subagent** in the available skill catalog. Read their actual `SKILL.md` files. Both skills and all ppstack skills install only under `~/.pi/agent/skills`. General root skills stay shared under `~/.agents/skills`. Report a missing skill instead of guessing its path.
2. Read the [delegation contract](../ppstack/docs/subagents.md). Confirm that the shell is inside Herdr with `HERDR_ENV=1` and that the selected CLI is installed. Pi is the default. Codex and Claude use native CLIs. Grok uses Pi with `--provider xai --model grok-4.6`. No fallback is allowed.
3. If installation was requested, use the repository's skills installer and verify ppstack, **spawn-subagent**, and **setup-petey-pi** links under `~/.pi/agent/skills`. The installer removes only house-owned links from shared and old native homes. Preserve unrelated skills and runtime settings. Do not add agent profiles or routing overrides.
4. Probe the requested agent through the loaded spawn skill with a small no-edits task in the current cwd. Pass one explicitly selected portable task skill by absolute path. Never pass **petey-pi** or its coordinator playbooks to a native helper. Do not rely on native auto-discovery of ppstack. Ask it to read one named file and return a cited finding in chat.
5. Inspect the returned Herdr name and pane with `agent get`, `agent read`, and a bounded `agent wait`. Confirm the selected CLI, cwd, loaded skill, and finding. Check the checkout diff to verify the no-edits instruction held. An idle or done state alone is not proof.
6. Report what was checked and what failed. On a blocked agent, inspect its output and ask the user. Do not claim automatic result delivery or continuation, and do not substitute another launcher.
