# skills

House skills live here. Third-party skills do not.

Canonical path: `~/dotfiles/skills/`. Each folder with a `SKILL.md` is one skill. The linker uses the folder basename (`cloudflare-setup`).

```bash
bash ~/dotfiles/skills/scripts/link-skills.sh
# or
~/dotfiles/install.sh skills
```

That writes per-skill symlinks into `~/.pi/agent/skills`, links `ppstack/agents/*.md` into `~/.pi/agent/agents`, links the tracked Pi extensions plus `pi/settings.json` and `pi/models.json` into `~/.pi/agent/`, and prunes dangling links it finds in those directories.

Do not symlink this whole tree onto `~/.agents/skills`. `ppstack/` is a capsule, not a skill, and `link-skills.sh` refuses that.

## Agent homes

Pi is the only runtime this repo installs into. `~/.pi/agent` is Pi itself: settings, sessions, models, extensions, auth. `skills/` and `agents/` are the two subdirectories the linker writes.

`~/.agents/skills` is the shared store `npx skills` installs into. Pi reads it alongside `~/.pi/agent/skills`.

`~/.claude/skills` and `~/.cursor/skills` still hold links from before the Pi-only migration on 2026-08-27. Nothing here maintains them. Claude Code reads only `~/.claude/skills`, so a house skill added after that date is not visible there unless you link it by hand.

## Two installers

**House.** Written here, linked by the script above. Edits in this repo are live in every linked agent. `npx skills` does not know about these. They will not show a source in `npx skills ls -g`.

**Third-party.** Installed with the [skills CLI](https://github.com/vercel-labs/skills):

```bash
npx skills add cloudflare/skills -g -a pi
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

- **[cloudflare-setup](./cloudflare-setup/SKILL.md)** — House Worker setup: `wrangler.json`, never `wrangler.toml`.
- **[rewrite-this](./rewrite-this/SKILL.md)** — Rewrite in Peter's voice for Slack.
- **[setup-petey](./setup-petey/SKILL.md)** — Install or verify Petey's tracked Pi model routing.
- **[effect-v4-best-practices](./effect-v4-best-practices/SKILL.md)** — Effect v4 write and review rules.
- **[herdr](./herdr/SKILL.md)** — Spaces, worktrees, Peter's Herdr config and workflow. Manual invoke only.
- **[unifi-network-diagnostics](./unifi-network-diagnostics/SKILL.md)** — Home UniFi investigation and `LOG.md` updates. Manual invoke only.

### ppstack

Capsule at [`ppstack/`](./ppstack). Pi skill tree and agent set. `petey` is the mode. Each `SKILL.md` under `ppstack/skills/` still links as its own skill name. Agent markdown under `ppstack/agents/` links into `~/.pi/agent/agents`.

- **[petey](./ppstack/skills/petey/SKILL.md)** — Router for concise, verified work.
- Sibling skills (`how`, `why`, `grill`, `proof-plan`, `night-watch`, `peer-review`, `no-stupid-tests`, `tdd`, principles, `unslop`, ...) live next to it in `ppstack/skills/`.
- Agents (`petey-agent`, `comment-sicko`, `test-butcher`, `council-sol`) live in `ppstack/agents/`.
