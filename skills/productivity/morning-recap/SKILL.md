---
name: morning-recap
description: Summarize PRs merged in a GitHub repo over the last N hours (default 12), excluding ones you authored or have already touched, and rank what's worth reviewing. Use when user says "morning recap", "what did I miss", "what shipped overnight", or "what went on while I was sleeping".
argument-hint: [hours]
user_invocable: true
---

# morning-recap

Recap merged PRs in a GitHub repo over the last N hours, skip ones the user authored or has already touched (any review state / comment / @-mention), and rank the rest by review priority.

The script filters server-side using GitHub's `-involves:USER` search qualifier — covers author, assignee, commenter, reviewer, and @-mentioned. Excluded PRs never come back over the wire.

## Setup (one-time)

This skill is repo-agnostic but needs to know **which repo** to recap. Pick one:

**Option A — set a default in your shell** (recommended if you only watch one repo):

```bash
# ~/.zshrc or ~/.bashrc
export MORNING_RECAP_REPO="owner/repo"
```

**Option B — pass it inline each time**:

```bash
MORNING_RECAP_REPO=owner/repo /morning-recap 12
```

**Option C — edit the default** in `run.sh` (change the `REPO` default near the top).

You also need:
- `gh` CLI installed and authenticated (`gh auth status`)
- `jq` installed

The exclude-user defaults to your authenticated `gh` user; override with `EXCLUDE_USER=someoneelse` if needed.

## Inputs

- Optional positional argument: lookback in hours (integer). Default `12`.

## Steps

1. Run the helper script. It does the GitHub queries, filters PRs you've touched, trims bodies, and returns compact JSON. **Do not call `gh` directly** — the script consolidates everything in one call.

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills}/morning-recap/run.sh" "${HOURS:-12}" 2>&1
   ```

   If the skill is installed under `~/.claude/skills/morning-recap/`, the absolute path works too. When loaded as a plugin, `$CLAUDE_PLUGIN_ROOT` points at the plugin's skill dir.

   Stderr (one line) reports the window, the filters applied, and how many PRs came back. Stdout is a JSON array of the remaining PRs:

   ```json
   [
     {
       "number": 11652,
       "title": "...",
       "author": "yhpark",
       "mergedAt": "...",
       "url": "...",
       "additions": 19,
       "deletions": 4,
       "changedFiles": 4,
       "files": ["..."],
       "body": "trimmed, comments stripped, capped at 500 chars"
     }
   ]
   ```

   Env overrides: `MORNING_RECAP_REPO=...` (or legacy `REPO=...`) and `EXCLUDE_USER=...`.

2. **Recap section** — print a chronological markdown list:

   ```
   ## Merged in the last <N>h (<count> PRs — excludes ones you authored or already touched)

   - [#1234](url) **Title** — @author — one-line summary
   - …
   ```

   - One-line summary derived from title + body. Be concrete (what changed), don't just rephrase the title.
   - If body is empty/boilerplate after trimming, fall back to title alone.
   - Never invent details that aren't in the title or body.
   - If the JSON array is empty: print `No unreviewed PRs merged in the last <N>h.` and stop.
   - If the API returned exactly 100, mention the window may be truncated.

3. **Review priority section** — classify each PR **High / Medium / Low** using these heuristics. Lean on judgment; rules are signals, not a checklist.

   **High signals** (any one is usually enough):
   - Touches shared state stores (atoms, providers, query client config)
   - Touches navigation root or tab navigators (`*Navigator.tsx`, `*ScreenStack*`)
   - Touches secure storage, MMKV/persistence, or react-query cache layer
   - Performance-critical primitives: list virtualization, animation hooks, suspense boundaries, hooks consumed app-wide
   - Large diff (>500 LOC) or >15 files changed
   - Title/body mentions "refactor", "rendering cascade", "perf", "CPU", "stringify", "suspense", or removes a widely-used hook

   **Medium signals**:
   - Feature-area UI changes that touch a shared component used in >1 screen
   - New animation logic, gesture handlers, or `useEffect` with non-trivial deps in a hot path
   - Inconsistent styling primitives (raw `View`/`Text`/`StyleSheet` in a Tamagui/NativeWind-styled area)
   - Diff 100–500 LOC

   **Low signals**:
   - Localized cosmetic / alignment / spacing fixes
   - Single-file change under 100 LOC with no shared-state or list/animation files
   - Title is `fix(...): center align …`, `fix padding`, etc.

   Adapt the heuristics to the target repo — these defaults assume a React Native app. For a backend or library repo, substitute the relevant hotspots (migrations, public API surface, auth, schema, etc.).

4. Print priorities sorted High → Medium → Low (drop the Low list if it's long, summarize):

   ```
   ## Review priority

   ### High
   - [#NNNN] **Title** — concrete reason it's worth a look (1 line). Files: `path/a.ts`, `path/b.tsx` (+N more)

   ### Medium
   - [#NNNN] **Title** — reason

   ### Low (skim)
   - [#NNNN], [#NNNN] — single-file cosmetic fixes
   ```

   The "why" line should name a concrete risk rather than restate the title. Cap file list at 3 paths + "(+N more)".

5. End with a one-line recommendation: "Top N to actually open: #X, #Y, #Z."

## Notes

- The script consolidates all `gh` calls into one — don't loop `gh pr view` per PR. If you need extra detail on a single PR, fetch only that one.
- Don't fetch full diffs — file paths + diff size + (trimmed) body is enough for a triage call.
- This is triage, not review — don't try to render verdicts on correctness.
- If the script errors with `gh` auth issues, surface verbatim and stop.
- Heuristics are guidance: a small diff that swaps the root provider is High; a 600-line copy edit is Low. Use judgment.

## Optional: scheduled daily recap

`cron-runner.sh` is a launchd-friendly wrapper that runs the recap headlessly, summarizes via `claude -p`, writes markdown to `~/Documents/Claude/morning-recap/YYYY-MM-DD.md`, and fires a macOS notification.

It's **personal-setup-flavored** (hardcoded paths, macOS-only `osascript`, assumes the `claude` CLI is installed). Treat it as a starting point — copy it somewhere editable and adjust `SKILL_DIR`, `OUT_DIR`, `MORNING_RECAP_REPO`, and the schedule for your machine.

Example launchd plist snippet:

```xml
<key>ProgramArguments</key>
<array>
  <string>/bin/bash</string>
  <string>/path/to/morning-recap/cron-runner.sh</string>
</array>
<key>StartCalendarInterval</key>
<dict>
  <key>Hour</key><integer>7</integer>
  <key>Minute</key><integer>30</integer>
</dict>
<key>EnvironmentVariables</key>
<dict>
  <key>MORNING_RECAP_REPO</key><string>owner/repo</string>
</dict>
```
