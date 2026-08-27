# Role models

Lookup table for Petey spawns on Pi. Same role names as Cursor’s `pstack-models.mdc`. Different slugs. Cursor still reads the mdc. This file is Pi.

`inherit-parent` means omit `model` on the spawn.

A list is one child per entry.

| Role | Model |
|---|---|
| feature, refactoring | `xai/grok-4.6-fast` |
| bug-fix | `peter@backpack.app/gpt-5.6-sol` |
| perf-issue | `peter@backpack.app/gpt-5.6-sol` |
| hillclimb | `peter@backpack.app/gpt-5.6-sol` |
| judgment and prose | inherit-parent |
| hardest tasks | inherit-parent |
| how explorer | `xai/grok-4.6-fast` |
| how explainer | `peter@backpack.app/gpt-5.6-sol` |
| how critics | `peter@backpack.app/gpt-5.6-sol`, `xai/grok-4.6-fast`, `peter@backpack.app/gpt-5.6-luna`, `peter@backpack.app/gpt-5.6-terra` |
| why investigators | `xai/grok-4.6-fast` |
| why synthesizer | `peter@backpack.app/gpt-5.6-sol` |
| reflect tooling | `peter@backpack.app/gpt-5.6-sol` |
| reflect judgment, divergent, synthesizer | inherit-parent |
| arena runners | `peter@backpack.app/gpt-5.6-sol`, `xai/grok-4.6-fast`, `peter@backpack.app/gpt-5.6-luna`, `peter@backpack.app/gpt-5.6-terra` |
| arena cross-judge pool | `peter@backpack.app/gpt-5.6-sol`, `xai/grok-4.6-fast`, `peter@backpack.app/gpt-5.6-luna`, `peter@backpack.app/gpt-5.6-terra` |
| swarm workers | `xai/grok-4.6-fast` |
| architect runners | `peter@backpack.app/gpt-5.6-sol`, `xai/grok-4.6-fast`, `peter@backpack.app/gpt-5.6-luna`, `peter@backpack.app/gpt-5.6-terra` |
| interrogate reviewers | `peter@backpack.app/gpt-5.6-sol`, `xai/grok-4.6-fast`, `peter@backpack.app/gpt-5.6-luna`, `peter@backpack.app/gpt-5.6-terra` |

Named agents pin themselves. Do not look them up here.

| Agent | Pin |
|---|---|
| `search` | frontmatter `peter@backpack.app/gpt-5.6-luna` |
| `explorer` | frontmatter Luna low |
| `researcher` | settings override, same Luna slug |
| `scout` | settings override, Luna low. Petey should not spawn scout. |
