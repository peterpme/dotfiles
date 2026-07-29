# skills

Personal agent skills, lived in this dotfiles repo.

Canonical path: `~/dotfiles/skills/`. Linked into agent homes with:

```bash
bash ~/dotfiles/skills/scripts/link-skills.sh
# or
~/dotfiles/install.sh skills
```

That creates per-skill symlinks:

| Target | Purpose |
|--------|---------|
| `~/.agents/skills/<name>` | shared multi-agent home |
| `~/.pi/agent/skills/<name>` | pi |
| `~/.claude/skills/<name>` | Claude Code |

Third-party skills (Cloudflare, Firecrawl, etc.) stay managed by the skills CLI under `~/.agents/skills` and are not stored here.

## Layout

```
skills/
├── engineering/    # daily code work
├── productivity/   # daily non-code
├── personal/       # tied to my own setup (bro, writing-great-skills, …)
├── misc/           # rare-use
├── in-progress/    # drafts
└── deprecated/     # not linked
```

## Skills

### Engineering

- **[engineering-manager](./engineering/engineering-manager/SKILL.md)** — Coordinate complex work with specialists, gates, PRs, audits.
- **[continuity](./engineering/continuity/SKILL.md)** — Learn, record, audit, and apply codebase patterns.
- **[component-data-refactor](./engineering/component-data-refactor/SKILL.md)** — Focused React/RN refactor with data-flow sketch first.
- **[source-parity](./engineering/source-parity/SKILL.md)** — Compare source-of-truth vs target, then narrow parity plan.
- **[repo-rule-mining](./engineering/repo-rule-mining/SKILL.md)** — Turn repeated review findings into durable guardrails.

### Productivity

- **[morning-recap](./productivity/morning-recap/SKILL.md)** — Summarize recent PRs worth reviewing.
- **[study-repo](./productivity/study-repo/SKILL.md)** — Clone a repo and run an interactive study session.

### Personal

- **[bro](./personal/bro/SKILL.md)** — Restate the last message in plain human language.
- **[writing-great-skills](./personal/writing-great-skills/SKILL.md)** — Vocabulary and principles for writing predictable skills.
