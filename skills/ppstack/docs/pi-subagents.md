# Pi subagents, for Petey

Source of truth for how Pi children work. Upstream is [nicobailon/pi-subagents](https://github.com/nicobailon/pi-subagents). We do not fork that package. Spawn calls live in `skills/petey/references/spawn.md`.

The parent session is Petey. A subagent is a child Pi process with its own tools and prompt. Cursor’s equivalent is `Task` plus `subagent_type`.

## Builtins

These six ship in the package `agents/` directory. None of them pin a model. They inherit the parent unless settings or the spawn call override it. All six set `inheritSkills: false`, so they will not load `petey` unless we say so.

| Name | Job | Tools (package default) | Writes? | Notes |
|---|---|---|---|---|
| `scout` | Local recon, compressed handoff | `read, grep, find, ls, bash, write` | yes | We override tools to `read, grep, find, ls`. Treat as readonly. |
| `worker` | Implement an approved plan | `read, grep, find, ls, bash, edit, write, contact_supervisor` | yes | Aliases `developer`, `coder`, `implementer`. `defaultContext: fork`. |
| `reviewer` | Evidence review of a diff or plan | `read, grep, find, ls` | no | Cannot run tests. Docs say “small fixes”; the allowlist cannot. |
| `oracle` | Second opinion, catch drift. Alias `advisor` | `read, grep, find, ls, bash` | bash only | Forked context. Prompt says do not edit. |
| `delegate` | Thin clone of the parent | same as worker | yes | Only builtin with `systemPromptMode: append`. |
| `researcher` | Web brief | `read, write, web_search, fetch_content, get_search_content` | notes only | No grep/find. Needs `pi-web-access`. Petey uses `luna` instead. |

There are also CLI adapter builtins (`claude-code`, `cursor-agent`, `codex-exec`, and their writer variants). Leave them. `disableBuiltins: true` would hide those too.

## Discovery

Lowest to highest.

1. Package builtins
2. Other installed packages
3. `~/.pi/agent/agents/**/*.md` (ppstack `agents/` is symlinked here)
4. Project `.pi/agents/**/*.md`

Same runtime `name:` shadows the lower one. `agentOverrides` in `~/.pi/agent/settings.json` patches fields on a builtin without copying the file. `tools` in that JSON must be an array, `"inherit"`, or `false`. A comma string throws and `subagent list` dies.

Do not `eject` a builtin unless the persona itself has to change. After eject, settings overrides skip fields the file already sets.

## House agents

These are ours. They do not replace the six names.

| Name | Job | Model | Tools |
|---|---|---|---|
| `petey-agent` | Playbook writer. Reads Petey first. | inherit | write |
| `comment-sicko` | Comment deletion pass. Alias `Comment Sicko`. | inherit | readonly |
| `search` | Web and docs search | pinned `peter@backpack.app/gpt-5.6-luna` | web search tools |
| `explorer` | Local codebase lookup | Luna low | `read, grep, find, ls`. No files. |

That is the pstack shape. pstack did not replace Cursor `generalPurpose`. It added `poteto-agent` and Comment Sicko on top. We do the same on Pi.

## What Petey should call

| Job | `agent:` | Do not call |
|---|---|---|
| Local codebase search | `explorer` | `scout` |
| Playbook writer | `petey-agent` | `worker` |
| Evidence review | `reviewer` | `comment-sicko` |
| Comment pass | `comment-sicko` | `reviewer` |
| Second opinion | `oracle` | `search` |
| Web search | `search` | `researcher` |
| Parent-shaped helper | `delegate` | only if you mean it |

Keep builtin names when the job matches. Local search is ours (`explorer`). Do not send that job to `scout`.

## Overrides we already have

`~/.pi/agent/settings.json`. Model pins are documented in [`models.md`](./models.md).

```json
"subagents": {
  "agentOverrides": {
    "scout": {
      "tools": ["read", "grep", "find", "ls"],
      "acceptanceRole": "read-only",
      "model": "peter@backpack.app/gpt-5.6-luna",
      "thinking": "low"
    },
    "researcher": {
      "model": "peter@backpack.app/gpt-5.6-luna"
    }
  }
}
```

Scout override is load-bearing. Builtin scout can write `context.md`. Researcher pin is the mix-match so a Grok parent does not send web search to Grok.

## Changes worth making later

Smallest first. None of these require a package fork.

1. Optional. `agentOverrides.worker.skills: ["petey"]` if a stock worker launch should see Petey. Do not set `inheritSkills: true` on scout or reviewer. That dumps the whole catalog into a narrow child.
2. `setup-petey` should write the Cursor mdc and these Pi pins from [`models.md`](./models.md). List roles (how critics, interrogate) still need the parent to pass `model:` on each spawn. Settings cannot express “four reviewers, four slugs."

Do not shadow `worker` with a file named `worker.md` that is actually `petey-agent`. You would steal the `developer` / `coder` aliases.

## How to check

New Pi session.

```text
List available subagents.
```

You want `petey-agent`, `comment-sicko`, and `search` as `user`, and the six builtins still present. Then:

```text
Use scout to map skills/petey/references/spawn.md. Do not edit.
Use search to look up pi-subagents model precedence. Cite docs.
```
