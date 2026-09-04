# ppstack

Hi, I'm [Peter](https://x.com/peterpme). This is my take on pstack. AI writes too much slop. I want higher throughput without shipping it.

`ppstack` is the Pi skill collection, installed only under `~/.pi/agent/skills`. `/skill:petey-pi` is its coordinator. General root skills remain shared under `~/.agents/skills`.

- `skills/` contains **petey-pi**, task skills, and their references.
- `docs/subagents.md` describes [direct Herdr delegation](./docs/subagents.md).
- `debug/` holds local diagnostics.

The Pi coordinator loads **spawn-subagent**, also installed only under `~/.pi/agent/skills`. Pi is the default helper, with native Codex and Claude and Grok through Pi available. Helpers get standalone neutral briefs and explicitly selected portable skills by absolute path. Never load **petey-pi** in a native helper.

Run `bash install.sh skills` from the dotfiles checkout, restart Pi inside Herdr, and invoke `/skill:petey-pi`. Ask it to "spawn a subagent" or "ask Claude to review this diff". Pi loads [spawn-subagent](../spawn-subagent/SKILL.md), chooses the task's leaf instructions, and opens a helper pane without moving focus.

The installer links the checkout you run it from. Keep that checkout while its links are active. After merging this PR, rerun the installer from `~/dotfiles` before removing the development worktree.

These are my skills. Copy them and make them better.
