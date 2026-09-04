# Working in this repository

Pi is the ppstack coordinator. In a parent Pi session, use `skills/ppstack/skills/petey-pi/SKILL.md` for the house workflow. A Pi process with `PPSTACK_SUBAGENT=1` is a helper, not a coordinator. For delegation, load `skills/spawn-subagent/SKILL.md` and launch helpers through Herdr. Do not add an orchestration package or per-role model profiles.

Helpers, including Pi children, Codex, and Claude, must not load `petey-pi`, its playbooks, or Pi coordinator workflows. Follow the parent's scoped brief. Read only the task-specific portable skills and reference files it names. Do not delegate further. Report changes, actual verification, and blockers to the parent. The Pi parent owns integration and PR operations.

All ppstack skills, `spawn-subagent`, and `setup-petey-pi` install only under `~/.pi/agent/skills`. General root skills remain shared under `~/.agents/skills`. `skills/scripts/link-skills.sh` owns this split and removes only this repository's old skill/profile links.

Keep one writer per checkout, including the parent. Use separate worktrees for concurrent writers only with explicit user approval. A review brief's no-edit rule is not a sandbox.

Checks for this migration:

```bash
python3 -m unittest discover -s skills/spawn-subagent/scripts -p 'test_*.py' -v
python3 -m unittest discover -s skills/scripts -p 'test_*.py' -v
bun test pi/extensions/herdr-tab-name/lib.test.ts
bash -n skills/scripts/link-skills.sh install.sh
git diff --check
```

Before claiming a route works, run a no-edit task through the actual launcher inside Herdr and read the answer. `submitted`, `idle`, and `done` do not prove success. Report provider quota and authentication failures without switching models silently.
