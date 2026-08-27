# skills

House skills live here. Third-party skills do not.

Canonical path: `~/dotfiles/skills/`. Each folder with a `SKILL.md` is one skill. The linker uses the folder basename (`cloudflare-setup`).

```bash
bash ~/dotfiles/skills/scripts/link-skills.sh
# or
~/dotfiles/install.sh skills
```

That writes per-skill symlinks into `~/.agents/skills`, `~/.pi/agent/skills`, and `~/.claude/skills`.

Do not symlink this whole tree onto `~/.agents/skills`. `ppstack/` is a capsule, not a skill, and `link-skills.sh` refuses that.

## Agent homes

`~/.agents`, `~/.pi`, `~/.claude`, and `~/.cursor` are not four skill folders. The last three are whole apps. Skills are one subdirectory.

| Path | What it is |
|------|------------|
| `~/.agents/skills` | Shared skill store. `npx skills` installs here. Pi and Cursor already read it. |
| `~/.pi/agent` | Pi itself: settings, sessions, models, extensions, auth. `skills/` is extra. |
| `~/.claude` | Claude Code itself: settings, hooks, MCP, `CLAUDE.md`, sessions. |
| `~/.cursor` | Cursor itself. `skills/` is yours. `skills-cursor/` is Cursor's built-in product skills. Leave that alone. |

Pi loads `~/.pi/agent/skills` and `~/.agents/skills`. Copies in `~/.pi/agent/skills` are redundant once `~/.agents/skills` is populated.

Cursor loads `~/.cursor/skills` and `~/.agents/skills`. Same story.

Claude Code loads `~/.claude/skills` only. It does not read `~/.agents`. That is why the linker still writes Claude copies.

You cannot point Pi or Claude at `~/.agents` for everything. Their settings and session files stay in their own homes.

## Two installers

**House.** Written here, linked by the script above. Edits in this repo are live in every linked agent. `npx skills` does not know about these. They will not show a source in `npx skills ls -g`.

**Third-party.** Installed with the [skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add cloudflare/skills -g -a pi -a claude-code
npx skills ls -g
npx skills update -g
npx skills remove wrangler -g
```

`-g` means user-level, not a project. The CLI copies each skill into `~/.agents/skills/<name>` as a real directory, records it in `~/.agents/.skill-lock.json`, then symlinks that copy into every agent you selected. That is the whole job. It is not a runtime. Agents just read `SKILL.md` from their skills folder.

Nothing auto-updates. `npx skills update -g` re-fetches the GitHub URL in the lockfile if the folder hash changed. Skip that and you keep the copy from the day you ran `add`. Cloudflare on this machine sat at the July install for a month.

Install only to agents you use. `--all` once linked Cloudflare into fifty agent homes.

`npx skills list` is project-only. It looks at `./.agents/skills` and `./skills-lock.json` in the current directory. From `$HOME` that path is the global install, so every skill shows up as a project skill with `Source: local`. Global inventory is `npx skills ls -g`, which reads `~/.agents/.skill-lock.json` and prints the real GitHub sources.

Do not vendor third-party skills into this repo. Then you own updates and `skills update` stops working.

## Layout

One folder per skill at the root. `ppstack/` stays a capsule. `scripts/` is the linker. `deprecated/` is skipped if it comes back.

```bash
find ~/dotfiles/skills -name SKILL.md \
  -not -path '*/deprecated/*' -not -path '*/node_modules/*' \
  | sed "s|$HOME/dotfiles/skills/||; s|/SKILL.md||" | sort
```

## House catalog

- **[engineering-manager](./engineering-manager/SKILL.md)** — Coordinate complex work with specialists, gates, PRs, audits.
- **[continuity](./continuity/SKILL.md)** — Learn, record, audit, and apply codebase patterns.
- **[component-data-refactor](./component-data-refactor/SKILL.md)** — Focused React/RN refactor with data-flow sketch first.
- **[source-parity](./source-parity/SKILL.md)** — Compare source-of-truth vs target, then narrow parity plan.
- **[repo-rule-mining](./repo-rule-mining/SKILL.md)** — Turn repeated review findings into durable guardrails.
- **[cloudflare-setup](./cloudflare-setup/SKILL.md)** — House Worker setup: `wrangler.json`, never `wrangler.toml`.
- **[morning-recap](./morning-recap/SKILL.md)** — Summarize recent PRs worth reviewing.
- **[study-repo](./study-repo/SKILL.md)** — Clone a repo and run an interactive study session.
- **[bro](./bro/SKILL.md)** — Restate the last message in plain human language.
- **[writing-great-skills](./writing-great-skills/SKILL.md)** — Vocabulary and principles for writing predictable skills.
- **[plain-book](./plain-book/SKILL.md)** — Programmer-plain explanatory book voice.
- **[rewrite-this](./rewrite-this/SKILL.md)** — Rewrite in Peter's voice for Slack.

### ppstack

Capsule at [`ppstack/`](./ppstack). Cursor plugin and Pi skill tree. `petey` is the mode. Each `SKILL.md` under `ppstack/skills/` still links as its own skill name. Agent markdown under `ppstack/agents/` links into `~/.pi/agent/agents`.

- **[petey](./ppstack/skills/petey/SKILL.md)** — Router for concise, verified work.
- Sibling skills (`how`, `why`, principles, `unslop`, ...) live next to it in `ppstack/skills/`.
