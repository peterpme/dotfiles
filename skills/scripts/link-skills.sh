#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOTFILES_ROOT="$(cd "$REPO/.." && pwd)"
HOUSE_ROOTS=("$DOTFILES_ROOT")
while IFS= read -r record; do
  case "$record" in
    'worktree '*) HOUSE_ROOTS+=("${record#worktree }") ;;
  esac
done < <(git -C "$DOTFILES_ROOT" worktree list --porcelain 2>/dev/null || true)

is_house_skill() {
  local target="$1" root
  for root in "${HOUSE_ROOTS[@]}"; do
    case "$target" in "$root/skills/"*) return 0 ;; esac
  done
  return 1
}

is_pi_skill() {
  case "$1" in
    */skills/ppstack/*|*/skills/spawn-subagent|*/skills/spawn-subagent/*|\
    */skills/setup-petey|*/skills/setup-petey/*|*/skills/setup-petey-pi|*/skills/setup-petey-pi/*)
      return 0 ;;
  esac
  return 1
}

check_destination() {
  if [ -L "$1" ]; then
    echo "error: destination directory is a symlink: $1" >&2
    exit 1
  fi
}

remove_skill_links() {
  local directory="$1" scope="$2" link target
  [ -d "$directory" ] || return 0
  check_destination "$directory"
  for link in "$directory"/*; do
    [ -L "$link" ] || continue
    target="$(readlink "$link")"
    is_house_skill "$target" || continue
    if [ "$scope" = all ] || is_pi_skill "$target"; then
      rm "$link"
      echo "removed $link -> $target"
    fi
  done
}

link_resource() {
  local source="$1" target="$2"
  [ -e "$source" ] || { echo "error: missing $source" >&2; return 1; }
  check_destination "$(dirname "$target")"
  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$source" ]; then
      echo "ok      $target"
      return 0
    fi
    if [[ "$source" = "$REPO/"* ]] && ! is_house_skill "$(readlink "$target")"; then
      echo "skip    $target is a third-party skill link; review it manually" >&2
      return 0
    fi
    rm "$target"
  elif [ -e "$target" ]; then
    echo "skip    $target is a real file or directory; review it manually" >&2
    return 0
  fi
  ln -s "$source" "$target"
  echo "linked  $target -> $source"
}

for directory in "$HOME/.agents/skills" "$HOME/.pi/agent/skills" \
  "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.cursor/skills" \
  "$HOME/.pi/agent/agents"; do
  check_destination "$directory"
done

remove_skill_links "$HOME/.agents/skills" all
remove_skill_links "$HOME/.pi/agent/skills" all
for directory in "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.cursor/skills"; do
  remove_skill_links "$directory" pi-only
done

while IFS= read -r -d '' skill; do
  source="$(dirname "$skill")"
  name="$(basename "$source")"
  if is_pi_skill "$skill"; then
    destination="$HOME/.pi/agent/skills"
  else
    destination="$HOME/.agents/skills"
  fi
  link_resource "$source" "$destination/$name"
done < <(find "$REPO" -name SKILL.md -not -path '*/node_modules/*' \
  -not -path '*/deprecated/*' -not -path '*/.git/*' -print0)

for link in "$HOME/.pi/agent/agents"/*; do
  [ -L "$link" ] || continue
  target="$(readlink "$link")"
  if is_house_skill "$target"; then
    case "$target" in
      */skills/ppstack/agents/*) rm "$link"; echo "removed retired agent $link" ;;
    esac
  fi
done

for extension in herdr-tab-name debugger; do
  link_resource "$DOTFILES_ROOT/pi/extensions/$extension" "$HOME/.pi/agent/extensions/$extension"
done
for config in models.json settings.json; do
  link_resource "$DOTFILES_ROOT/pi/$config" "$HOME/.pi/agent/$config"
done

echo "Done. Restart Pi to load settings and Pi-only skills. Native helpers use standalone briefs."
