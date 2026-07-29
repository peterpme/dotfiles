#!/usr/bin/env bash
# cron-runner.sh — invoked by launchd/cron. Runs morning-recap, summarizes via `claude -p`,
# writes markdown to $OUT_DIR/YYYY-MM-DD.md, fires a macOS notification.
#
# This is a starting point — adjust paths and the schedule for your machine.
#
# Required env (set in the launchd plist or your shell):
#   MORNING_RECAP_REPO   target repo, e.g. "owner/repo"
#
# Optional env:
#   SKILL_DIR   directory containing run.sh (default: this script's dir)
#   OUT_DIR     where to write the daily markdown file (default: ~/Documents/Claude/morning-recap)
#   HOURS       lookback override; otherwise 72 on Monday, 24 other days
#
# Logs: redirect stderr in your launchd plist (e.g. ~/Library/Logs/morning-recap.log).

set -euo pipefail

# launchd hands us a minimal PATH; restore it so we can find gh/jq/claude.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:/usr/bin:/bin:${PATH:-}"

SKILL_DIR="${SKILL_DIR:-$(cd "$(dirname "$0")" && pwd)}"
OUT_DIR="${OUT_DIR:-$HOME/Documents/Claude/morning-recap}"
mkdir -p "$OUT_DIR"

if [[ -z "${MORNING_RECAP_REPO:-}" && -z "${REPO:-}" ]]; then
  echo "cron-runner: MORNING_RECAP_REPO is not set." >&2
  exit 2
fi

DATE=$(date +%Y-%m-%d)
OUT_FILE="$OUT_DIR/${DATE}.md"

# Monday → reach back through the weekend. Otherwise 24h.
if [[ -z "${HOURS:-}" ]]; then
  if [[ "$(date +%u)" == "1" ]]; then
    HOURS=72
  else
    HOURS=24
  fi
fi

echo "[$(date)] morning-recap starting (window=${HOURS}h repo=${MORNING_RECAP_REPO:-$REPO})" >&2

JSON=$(bash "$SKILL_DIR/run.sh" "$HOURS" 2>>/tmp/morning-recap-fetch.err) || {
  echo "fetch failed; see /tmp/morning-recap-fetch.err" >&2
  command -v osascript >/dev/null && \
    osascript -e 'display notification "Failed to fetch PRs — check logs" with title "Morning recap"' || true
  exit 1
}

COUNT=$(printf '%s' "$JSON" | jq 'length')

if [[ "$COUNT" == "0" ]]; then
  printf '# Morning recap — %s\n\nNo unreviewed PRs merged in the last %sh.\n' "$DATE" "$HOURS" > "$OUT_FILE"
  command -v osascript >/dev/null && \
    osascript -e "display notification \"Nothing to review (last ${HOURS}h)\" with title \"Morning recap\"" || true
  echo "[$(date)] no PRs; wrote $OUT_FILE" >&2
  exit 0
fi

PROMPT=$(cat <<'INSTRUCTIONS'
You will receive JSON of merged PRs, each with: number, title, author, mergedAt, url, additions, deletions, changedFiles, files[], body.

Produce a markdown morning-recap with two sections.

## Merged in the last <N>h (<count> PRs)

Chronological bulleted list (oldest → newest, the JSON is already sorted):
- [#NNNN](url) **Title** — @author — one-line summary derived from title + body. Be concrete (what changed). Don't invent details.

## Review priority

Group as ### High / ### Medium / ### Low using these heuristics:
- HIGH: shared state stores, navigators, secure storage / MMKV / react-query cache, list virtualization or animation primitives, hooks consumed app-wide, >500 LOC or >15 files, or title/body mentions refactor/perf/CPU/suspense/rendering cascade.
- MEDIUM: shared component used in >1 screen, animation/gesture/effect in hot path, inconsistent styling primitives in a styled area, 100–500 LOC.
- LOW: localized cosmetic/alignment/spacing fixes, single-file <100 LOC.

For each High/Medium item: 1-line concrete reason it's worth a look + Files: top 3 paths (+N more). For Low: collapse to one bullet listing the PR numbers.

End with: "Top N to actually open: #X, #Y, #Z."

Output ONLY the markdown — no preamble, no commentary.

JSON follows:
INSTRUCTIONS
)

{
  printf '# Morning recap — %s\n\n' "$DATE"
  printf '%s\n\n```json\n%s\n```\n' "$PROMPT" "$JSON" \
    | claude -p \
        --model claude-sonnet-4-6 \
        --tools "" \
        --max-budget-usd 0.25 \
        --no-session-persistence \
    || printf '_Claude summary failed; raw JSON below._\n\n```json\n%s\n```\n' "$JSON"
} > "$OUT_FILE"

command -v osascript >/dev/null && \
  osascript -e "display notification \"${COUNT} PRs to triage — open ${OUT_FILE/$HOME/~}\" with title \"Morning recap\"" || true

echo "[$(date)] wrote $OUT_FILE (${COUNT} PRs)" >&2
