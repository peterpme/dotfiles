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

Run `/petey-debug [label]` to copy the current Pi session JSONL into ignored `debug/traces/` and add an untriaged entry to `debug/PETEY-LOG.md`. The extension command bypasses the model.

The installed `pi-subagents` package owns execution. ppstack-specific overrides are in [`docs/pi-subagents.md`](./docs/pi-subagents.md). The generated routing table is at [`../../docs/model-routing.md`](../../docs/model-routing.md). Repository automation follows [`docs/typescript-automation.md`](../../docs/typescript-automation.md).

These are my skills. Copy them and make them better.
