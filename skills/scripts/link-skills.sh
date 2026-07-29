#!/usr/bin/env bash
set -euo pipefail

# Link every SKILL.md-bearing directory under skills/ into the agent skill
# homes this machine uses. Canonical source stays in the dotfiles repo.
#
#   ~/dotfiles/skills/<bucket>/<name>/
#     -> ~/.agents/skills/<name>
#     -> ~/.pi/agent/skills/<name>
#     -> ~/.claude/skills/<name>
#
# Skips deprecated/. Third-party skills installed via the skills CLI into
# ~/.agents/skills are left alone (we only overwrite matching names).

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOTFILES_ROOT="$(cd "$REPO/.." && pwd)"

# Resolve to absolute paths so symlinks survive cwd changes.
REPO="$(cd "$REPO" && pwd)"

link_into() {
  local dest_root="$1"
  local label="$2"

  mkdir -p "$dest_root"

  # Guard: if dest_root itself is a symlink into the repo, bail.
  if [ -L "$dest_root" ]; then
    local resolved
    resolved="$(readlink -f "$dest_root" 2>/dev/null || readlink "$dest_root")"
    case "$resolved" in
      "$REPO"|"$REPO"/*|"$DOTFILES_ROOT"|"$DOTFILES_ROOT"/*)
        echo "error: $dest_root is a symlink into the repo ($resolved)." >&2
        echo "Remove it and re-run." >&2
        return 1
        ;;
    esac
  fi

  find "$REPO" -name SKILL.md \
    -not -path '*/node_modules/*' \
    -not -path '*/deprecated/*' \
    -not -path '*/.git/*' \
    -print0 |
  while IFS= read -r -d '' skill_md; do
    local src name target
    src="$(cd "$(dirname "$skill_md")" && pwd)"
    name="$(basename "$src")"
    target="$dest_root/$name"

    # Replace real dirs (e.g. earlier copies) with symlinks.
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ -L "$target" ]; then
        local current
        current="$(readlink "$target")"
        if [ "$current" = "$src" ]; then
          echo "ok      $label/$name"
          continue
        fi
      fi
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "linked  $label/$name -> $src"
  done
}

echo "Linking skills from $REPO"
link_into "$HOME/.agents/skills" "agents"
link_into "$HOME/.pi/agent/skills" "pi"
link_into "$HOME/.claude/skills" "claude"
echo "Done."
