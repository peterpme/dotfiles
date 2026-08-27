# Models

pstack and pi-subagents mix. They do not share a file format. The link is the **job name**, not the slug.

## Two files, two parsers

The markdown in `ppstack/agents/` is one file on disk. Each harness reads a subset.

| Field | Cursor plugin agent | Pi `pi-subagents` |
|---|---|---|
| `name` | `subagent_type` | `agent:` |
| `description` | catalog blurb | catalog blurb |
| body | child system prompt | child system prompt |
| `is_background` | yes | ignored |
| `tools` | ignored. `Task` `readonly` is the sandbox | the sandbox |
| `model` | ignored. parent passes `Task` `model:` | pins the child |
| `inheritSkills`, `systemPromptMode`, `acceptanceRole` | ignored | Pi only |

Cursor model choice lives in `~/.cursor/rules/pstack-models.mdc` (`alwaysApply: true`). The parent reads it and puts `model:` on `Task`. The agent file does not pick.

Pi model choice, strongest first ([upstream](https://github.com/nicobailon/pi-subagents/blob/main/docs/models.md)):

1. This spawn’s `model` argument
2. Agent frontmatter `model` (`search.md` does this)
3. `~/.pi/agent/settings.json` `subagents.agentOverrides.<name>.model`
4. `subagents.defaultModel`
5. The parent session model

That last line is why a Grok parent makes unpinned children Grok. `worker`, `reviewer`, and `oracle` still inherit. `scout` is pinned to Luna low. Web search is `search` / `researcher`.

## What to call for search

`scout` is local recon. It has no web tools after our override. Do not send it looking.

Web and docs go to `search`. Frontmatter already pins `peter@backpack.app/gpt-5.6-luna`. If something still says `researcher`, settings pin that builtin to the same slug.

Inspect live mapping in Pi:

```text
/subagents-models
/subagents-models search
/subagents-models researcher
```

Reload Pi after editing settings. Disk and runtime can disagree until then.

## Job table

Role names match pstack. Slugs do not. Cursor uses Cursor ids. Pi uses Pi ids.

| Job | Pi `agent:` | Pi model | Cursor `Task` model |
|---|---|---|---|
| Web search | `search` (or `researcher`) | `peter@backpack.app/gpt-5.6-luna` | whatever you set for search in the mdc. Pass it on `Task`. The file `model:` is ignored. |
| Local codebase search | `explorer` | `peter@backpack.app/gpt-5.6-luna` thinking `low` | parent codebase search, or `Task` readonly |
| Writer | `petey-agent` | inherit | `feature, refactoring` |
| Reviewer | `reviewer` | inherit, or pass one slug per arm | `interrogate reviewers` list |
| Judgment | `oracle` | inherit, or a strong slug on the call | `how explainer` / `judgment and prose` |

List roles (how critics, arena, interrogate) cannot be one `agentOverrides.model`. The parent still passes a different `model:` per child. That is the same as Cursor.

## Where the pins live

- `ppstack/agents/search.md` `model:` is the Pi search pin.
- `~/.pi/agent/settings.json` `agentOverrides.researcher.model` is the mix-match pin.
- `~/.cursor/rules/pstack-models.mdc` is Cursor only. Do not copy those slugs into Pi settings. `cursor-grok-4.6-high-fast` is not a Pi id.

`setup-petey` should write both files from this table later. Until then, edit the two places by hand and keep the job names in sync.
