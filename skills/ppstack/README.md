# ppstack

Hi I'm [Peter](https://x.com/peterpme). This is my take on pstack. I just wanted to build it myself. I agree that ai writes too much slop. I don't want to ship slop. I want to increase throughouput and keep quality high.

`ppstack` is the capsule. `petey` is the mode.

This is a Cursor plugin and a Pi skill capsule. Same tree.

```
ppstack/
  .cursor-plugin/plugin.json
  skills/     # every SKILL.md, including petey
  agents/     # petey-agent, comment-sicko, search, explorer
```

**Cursor.** Install the folder as a local plugin. `plugin.json` mounts `skills/` and `agents/`. Turn off the public pstack plugin so you do not run poteto-mode next to petey.

**Pi.** `~/dotfiles/install.sh skills` runs `link-skills.sh`. Every `SKILL.md` under this repo is linked by folder basename into `~/.pi/agent/skills`. Agent markdown under `agents/` is linked into `~/.pi/agent/agents`. How those children relate to pi-subagents builtins is in [`docs/pi-subagents.md`](./docs/pi-subagents.md). Model pins and the Cursor/Pi split are in [`docs/models.md`](./docs/models.md).

These are my skills. They're similar to other skills you've seen online. You can do the same and copy me. I think you should copy and make it better.

I primarily use Pi, but mess around with Cursor as well.
