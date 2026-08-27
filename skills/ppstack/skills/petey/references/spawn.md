# Spawn

Petey runs in Cursor and in Pi. Leaf skills name the job. This file names the call.

If the current tools list has `subagent`, this is Pi. If it has `Task`, this is Cursor.

## Jobs

| Job | Cursor | Pi |
|---|---|---|
| local codebase search | `Task` readonly. Cursor already has codebase search, so the parent can search itself. | `agent: "explorer"`. Not `scout`. Scout writes a recon dump. |
| writer / playbook helper | `Task` with `subagent_type: "petey-agent"` | `agent: "petey-agent"` |
| comment pass | `Task` with `subagent_type: "comment-sicko"` or `"Comment Sicko"` | `agent: "comment-sicko"` |
| web search | `Task` with an explicit search model. Do not inherit the parent. | `agent: "search"`. Never `scout`. `researcher` is pinned to the same Luna model. |
| N parallel reviewers | N `Task` calls, `readonly: true`, one model each | one `workflowScript` with `await runs.all` of `reviewer`, model per arm |
| isolated worker | `environment: "cloud"` when the user wants Cursor cloud | `worktree: true` |
| background | `run_in_background: true` | `async: true` |

Fan-out on Pi is one `workflowScript` with `runs.all`. Do not fire N separate `subagent` calls.

Never pass top-level `agent` or `task` together with `workflowScript`. That throws `Structured single-child execution cannot be combined with workflowScript`. One child is `await runs.run` inside the script. N children is `await runs.all`.

The script must `return` a value. `await runs.all([...])` with no return yields `Return: null`. Children still wrote `*_output.md`. The parent got nothing. Return `results.map(r => r.output)` or a keyed object.

Do not set `async: false` to wait for explorers. Launch async. Read outputs. Then synthesize. Per-run `model` on a `runs.all` item beats agent frontmatter. `explorer` pinned to Luna still accepts `model: "xai/grok-4.6-fast"` for how-explorer. Do not switch to `delegate` to dodge the pin.

A one-shot lookup ("find ast-grep rules") stays in the parent with `grep`. Spawn `explorer` when the parent should not eat the hits, or when the user says to use a search child.
