# ppstack

Hi, I'm [Peter](https://x.com/peterpme). This is my take on pstack. AI writes too much slop. I want higher throughput without shipping it.

`ppstack` is the skill capsule. `petey` is the operating style. Pi is the only active runtime.

```text
ppstack/
  agents/
  debug/
  docs/
  skills/
```

Run `~/dotfiles/install.sh skills`. The installer links each skill into `~/.pi/agent/skills`, links ppstack agents into `~/.pi/agent/agents`, and links tracked Pi extensions, settings, and models into `~/.pi/agent/`.

The installed `pi-subagents` package owns execution. ppstack-specific guidance is in [`docs/pi-subagents.md`](./docs/pi-subagents.md). `pi/settings.json` owns model routing.

These are my skills. Copy them and make them better.
