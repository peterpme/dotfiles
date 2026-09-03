---
name: herdr
description: "Peter's Herdr conventions. Spaces vs tabs vs panes, worktrees, keybindings, config paths, and how to move work between spaces. Use only when explicitly invoked (/herdr) or the user asks to load the herdr skill."
disable-model-invocation: true
---

# Herdr

House conventions for Herdr 0.8.2 on this machine. Do not fetch herdr.dev unless this file does not cover the question. For live CLI syntax, the installed binary is the authority. Run `herdr --help`, then `herdr <group>` with no nested mutating args. Commands such as `herdr workspace create` execute with defaults.

If `HERDR_ENV=1` and you need to drive panes, run `herdr --skill`. Skip that when this file already answers the question.

## Spaces

Docs say workspace. The sidebar says space. Same object.

A space is one attention unit. One live project, one investigation, or one catch-all such as ENGINE. It is not a window and not a tmux session.

Tmux words on this machine: window = tab (`prefix+c` new, `prefix+1..9` jump). Session picker ≈ space picker (`prefix+w`). Pane = pane.

```
session          one background Herdr server. Keep one.
  workspace      the space. Top-level. Cannot nest.
    tab          a layout inside the space (agents, logs, review)
      pane       a real terminal. This is what you move.
        agent    the process Herdr recognized in that pane
```

**You cannot put a space inside another space.** There is no parent/child for ordinary spaces. The only grouping is git worktree spaces hanging off a parent repo space.

Named Herdr sessions (`herdr --session work`) are a different runtime. Separate sockets, separate persisted state. Do not use them to organize projects. Workspaces first.

### Move panes, keep the process

To fold `cursor-plugins` into ENGINE, move the panes. Do not look for a merge-space command. There isn't one.

The running process stays alive. The agent conversation stays because the process never stopped. That is what "retain its session" means here. The Herdr space identity does not move. `w1G` is not a child of ENGINE after the move. The pane just lives in ENGINE now.

The pane ID changes (`w1G:p1` becomes `w1C:p3`). Herdr keeps the old ID as an alias for that process, so `--current` still works from inside it. A live agent name follows the pane.

```bash
# New tab in ENGINE, leave focus where it is
herdr pane move w1G:p1 --new-tab --workspace w1C --label cursor-plugins --no-focus

# Or split into an existing ENGINE tab
herdr pane move w1G:p1 --tab w1C:t1 --split right --no-focus
```

Parse the new pane ID from `.result.move_result.pane.pane_id`. After the last pane leaves a space, close the leftover if it is still there:

```bash
herdr workspace close w1G
```

Closing a space's last tab also closes the space. `workspace close` drops Herdr state only. It does not kill a process you already moved.

Do not `herdr server stop` unless the user wants every pane in the session dead.

### Worktrees

`herdr worktree create` makes a git checkout under `~/.herdr/worktrees/<repo>/<branch-slug>` and opens it as a space grouped with the parent repo. That grouping is the exception, not a general nest.

`workspace close` does not delete the checkout. `herdr worktree remove --workspace <id>` runs `git worktree remove`. It never deletes the branch. Dirty checkouts need `--force`.

## Workflow

One default session, always running. Sidebar is the inbox. Attach when something is `blocked` or `done`, not to babysit `working`.

| Job | Do this |
| --- | --- |
| New project | New space. `prefix+shift+n` or `herdr workspace create --cwd ~/Projects/foo --label foo` |
| Same repo, isolated branch | Worktree space from the parent. `prefix+shift+g` |
| Same concern, extra view | Tab, not a space |
| Helper agent | Sibling pane in the current tab, same `$PWD`, `--no-focus` |
| Catch-all investigation (ENGINE) | One space. Related repos are tabs or panes inside it |
| Switch | `prefix+w` |
| Leave | `prefix+d` or `prefix+q`. Come back with `herdr` |

A second space named after a repo that already belongs to ENGINE is the wrong shape. Move the pane into ENGINE as a tab.

Inside a space, a typical layout is tab `agents` and tab `dev` (tests, servers, logs).

### Rename panes and tabs

The row at the top is tabs, not panes. Pane names show in the sidebar and pane UI. Tab names are what you switch between with `prefix+1..9`.

Spaces are the project (`ENGINE`, `wallet-api`). Tabs are the topic, 1-2 words. Do not name a tab after the repo unless that is the topic.

Pi auto-names the current Herdr tab after 3 user turns, once per session, even if the tab already has a lazy name. Model is `opencode/deepseek-v4-flash` (Luna fallback). It also sets the Pi session name. It uses `$HERDR_TAB_ID`, not the focused pane.

```text
/tabname           # name now from the conversation
/tabname Auth Fix  # set an explicit label
/tabname off       # stop auto-renaming this session
/tabname on        # re-enable and name now
```

After it names a session, it stops. `/tabname off` keeps the current label. Subagent sessions are skipped.

```bash
herdr pane rename w1C:p1 dotfiles
herdr pane rename w1C:p1 --clear
herdr tab rename w1C:t1 Auth Fix
```

Keyboard: `prefix+shift+p` renames the pane, `prefix+shift+t` renames the tab. Rename the pane after the repo if you want both. The extension only touches the tab.

### Switch tabs

| Action | Binding |
| --- | --- |
| Tab 1..9 | `prefix+1` through `prefix+9` |
| Next tab | `prefix+space` or `prefix+n` |
| Previous tab | `prefix+backspace` or `prefix+p` |
| Jump UI | `prefix+g` |

Click the tab. `prefix+3` is tab number 3, which is whatever Herdr currently numbers `cursor-plugins`, not a stable name.

### Switch spaces

There is no one-shot cycle bound on this machine. `previous_workspace` and `next_workspace` are unset. `switch_workspace` (indexed `prefix+shift+1..9`) is also unset.

Without clicking:

1. `prefix+w` opens workspace navigation. `up` / `down` move between spaces.
2. `prefix+g` is the goto picker (spaces, tabs, panes, agents).

To cycle like tmux sessions, bind `previous_workspace` / `next_workspace`. Tmux muscle memory is `prefix+(` / `prefix+)`:

```toml
previous_workspace = "prefix+("
next_workspace = "prefix+)"
```

Reload with `prefix+shift+r`.

## This machine

| What | Where |
| --- | --- |
| Canonical config | `~/dotfiles/config/herdr/config.toml` |
| Live config | `~/.config/herdr/config.toml` (symlink to canonical) |
| Logs, sockets, `session.json` | `~/.config/herdr/` |
| Worktree checkouts | `~/.herdr/worktrees/<repo>/<branch-slug>` |
| Binary | Homebrew, currently `herdr 0.8.2` |

Reload after config edits: `herdr server reload-config` or `prefix+shift+r`. Show live bindings with `prefix+?`.

Prefix is `ctrl+a`, not the upstream default `ctrl+b`.

### Keys that differ from stock

| Action | Binding |
| --- | --- |
| Prefix | `ctrl+a` |
| Split right | `prefix+v`, `prefix+\|`, `prefix+%` |
| Split down | `prefix+s`, `prefix+minus`, `prefix+_` |
| Next / prev tab | `prefix+space` / `prefix+backspace` (also `n` / `p`) |
| Detach | `prefix+d` and `prefix+q` |
| Settings | `prefix+comma` (stock `prefix+s` is split down) |
| New space | `prefix+shift+n` |
| Rename space | `prefix+shift+w` |
| Close space | `prefix+shift+d` |
| New worktree | `prefix+shift+g` |
| Open worktree | `prefix+shift+o` (stock unset) |
| Remove worktree | `prefix+shift+backspace` (stock unset) |
| Workspace picker | `prefix+w` |
| Sidebar | `prefix+b` |
| Help | `prefix+?` |
| Rename tab | `prefix+shift+t` |
| Rename pane | `prefix+shift+p` (stock, now also in config) |
| Switch tab 1..9 | `prefix+1..9` |

Stock pane movement still applies: `prefix+h/j/k/l`, resize mode `prefix+r`, zoom `prefix+z`, new tab `prefix+c`, close pane `prefix+x`.

### Config that is on purpose

- `terminal.new_cwd = "follow"` so new panes inherit the source pane or workspace cwd
- `[worktrees] directory = "~/.herdr/worktrees"`
- `theme.name = "catppuccin"`
- `ui.prompt_new_tab_name = false` (stock true)
- `ui.toast.delivery = "herdr"` with `delay_seconds = 1` (stock off)
- `ui.mouse_capture = true`, `copy_on_select = true`
- `ui.sidebar_collapsed_mode = "compact"`, `sidebar_start_collapsed = false`
- `onboarding = false`

Left at stock: `session.resume_agents_on_restore = true`, `experimental.pane_history = false`, `ui.confirm_close = true`. Pane history stays off because scrollback can hold secrets.

`herdr integration install pi` is what makes Pi panes resume after a Herdr server restart. Detach is still the strong persistence path. Restart reconstructs layout. Processes are gone unless an integration can resume them.

## Agent rules

Only drive Herdr when `HERDR_ENV=1`. If it is unset, say you are not inside Herdr and stop.

Do not create a space, tab, worktree, or different cwd unless the user asked. Default helper work is a sibling pane in the current tab.

```bash
herdr pane split --current --direction right --cwd "$PWD" --no-focus
```

Split a wide pane right and a tall pane down. Keep user focus on the calling pane.

Use `--current`, an explicit pane ID, or a unique agent name. Do not target the UI-focused pane. Parse IDs from JSON. Do not close spaces, tabs, or panes you did not create unless asked. Never kill the main Herdr process.

`idle` means ready for input and the tab has been seen. `done` is the same idle state after unseen background work. CLI reads do not mark a tab seen. `blocked` means Herdr saw an approval or question UI. Inspect it and ask the user before answering.

## If this file is silent

1. `herdr --help` or `herdr <group>` with no nested command
2. `herdr --default-config` for every config key
3. `herdr --skill` only when inside Herdr and you need to control panes
4. Upstream concepts: https://herdr.dev/docs/concepts/
