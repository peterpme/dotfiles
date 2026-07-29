#!/usr/bin/env bash
# morning-recap: list PRs merged in last N hours, excluding ones the user authored or touched.
#
# Filtering is done server-side via GitHub search qualifiers:
#   -involves:USER  drops any PR the user has touched on GitHub
#                   (author, assignee, commenter, reviewer, or @-mentioned)
#
# Usage: run.sh [hours]
# Env:
#   MORNING_RECAP_REPO   target repo (e.g. "owner/repo"). Required unless REPO is set.
#   REPO                 legacy alias for MORNING_RECAP_REPO.
#   EXCLUDE_USER         default: $(gh api user --jq .login)
#
# Stdout: JSON array of PRs (sorted oldest -> newest), each:
#   { number, title, author, mergedAt, url, additions, deletions, changedFiles, files[], body }
# Stderr: one-line summary (window, returned count, filters applied).

set -euo pipefail

HOURS="${1:-12}"
REPO="${MORNING_RECAP_REPO:-${REPO:-}}"

if [[ -z "$REPO" ]]; then
  echo "morning-recap: target repo not set." >&2
  echo "  Set MORNING_RECAP_REPO=owner/repo in your shell, or pass it inline:" >&2
  echo "  MORNING_RECAP_REPO=owner/repo bash $0 [hours]" >&2
  exit 2
fi

EXCLUDE_USER="${EXCLUDE_USER:-$(gh api user --jq .login)}"

# macOS `date -u -v-NH` vs GNU `date -u -d "N hours ago"`.
if date -u -v-1H +%s >/dev/null 2>&1; then
  SINCE=$(date -u -v-"${HOURS}"H +%Y-%m-%dT%H:%M:%SZ)
else
  SINCE=$(date -u -d "${HOURS} hours ago" +%Y-%m-%dT%H:%M:%SZ)
fi

SEARCH="merged:>${SINCE} -involves:${EXCLUDE_USER}"

RAW=$(gh pr list \
  --repo "$REPO" \
  --state merged \
  --search "$SEARCH" \
  --limit 100 \
  --json number,title,author,mergedAt,url,body,additions,deletions,changedFiles,files)

RETURNED=$(printf '%s' "$RAW" | jq 'length')

printf 'window=%sh since=%s repo=%s excluded=involves:%s returned=%s\n' \
  "$HOURS" "$SINCE" "$REPO" "$EXCLUDE_USER" "$RETURNED" >&2

printf '%s' "$RAW" | jq '
  [
    .[]
    | {
        number,
        title,
        author: .author.login,
        mergedAt,
        url,
        additions,
        deletions,
        changedFiles,
        files: [.files[].path],
        body: (.body // ""
                | gsub("<!--[\\s\\S]*?-->"; "")
                | gsub("<sub>[\\s\\S]*?</sub>"; "")
                | gsub("<details>[\\s\\S]*?</details>"; "")
                | .[0:500])
      }
  ] | sort_by(.mergedAt)
'
