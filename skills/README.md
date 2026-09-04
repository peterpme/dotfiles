# skills

House skills live here. Third-party skills do not.

Canonical path: `~/dotfiles/skills/`. Each folder with a `SKILL.md` is one skill. The linker uses the folder basename (`cloudflare-setup`).

```bash
bash ~/dotfiles/skills/scripts/link-skills.sh
# or
~/dotfiles/install.sh skills
```

General root skills use per-skill links under `~/.agents/skills`. All ppstack skills, **spawn-subagent**, and **setup-petey-pi** install only under `~/.pi/agent/skills`. Verify the links after installation. Runtime settings and extensions remain separate from skill discovery.

Do not symlink this whole tree onto `~/.agents/skills`. `ppstack/` is a capsule, not a skill, and `link-skills.sh` refuses that.

## Agent homes

`~/.agents/skills` holds shared general skills. Pi's settings, sessions, models, extensions, and auth live under `~/.pi/agent`. Its `skills/` directory holds ppstack, **spawn-subagent**, and **setup-petey-pi**.

Only the Pi coordinator loads **petey-pi** and delegates through the discoverable **spawn-subagent** skill. Helpers run in sibling Herdr panes using Pi, native Codex, native Claude, or Grok through Pi. Give them neutral standalone briefs and explicitly selected portable skills by absolute path. Never load **petey-pi** in a native helper or rely on native auto-discovery of ppstack. See [the delegation contract](./ppstack/docs/subagents.md).

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
- **[setup-petey-pi](./setup-petey-pi/SKILL.md)** — Install or verify Petey Pi's Pi-only skills and Herdr delegation.
- **[effect-v4-best-practices](./effect-v4-best-practices/SKILL.md)** — Effect v4 write and review rules.
- **[herdr](./herdr/SKILL.md)** — Spaces, worktrees, Peter's Herdr config and workflow. Manual invoke only.
- **[unifi-network-diagnostics](./unifi-network-diagnostics/SKILL.md)** — Home UniFi investigation and `LOG.md` updates. Manual invoke only.

### ppstack

Collection at [`ppstack/`](./ppstack). `petey-pi` is the mode. Each `SKILL.md` under `ppstack/skills/` links as its own skill name only under `~/.pi/agent/skills`.

- **[petey-pi](./ppstack/skills/petey-pi/SKILL.md)** — Router for concise, verified work.
- Sibling skills (`how`, `why`, `grill`, `proof-plan`, `night-watch`, `peer-review`, `no-stupid-tests`, `tdd`, principles, `unslop`, ...) live next to it in `ppstack/skills/`.
- Specialist review and deletion rules live in each skill's references.
