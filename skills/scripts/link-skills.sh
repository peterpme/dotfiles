#!/usr/bin/env bash
set -euo pipefail

# Link every SKILL.md-bearing directory under skills/ into ~/.agents/skills,
# the shared store every harness reads (Pi, Cursor, npx skills). Canonical
# source stays in the dotfiles repo. Third-party installs are never touched:
# a real directory with a house skill's name is reported, not replaced.
# Pi-only pieces (agents, extensions, settings, models) still go to ~/.pi/agent.

prune_dangling() {
  local dir="$1"
  local label="$2"
  local link target

  [ -d "$dir" ] || return 0
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    [ -e "$link" ] && continue
    target="$(readlink "$link")"
    rm -f "$link"
    echo "pruned  $label/$(basename "$link") -> $target (dangling)"
  done
}

link_pi_config() {
  local name="$1"
  local source="$DOTFILES_ROOT/pi/$name"
  local target="$HOME/.pi/agent/$name"

  [ -f "$source" ] || { echo "error: missing $source" >&2; return 1; }
  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "ok      pi-config/$name"
    return 0
  fi
  rm -f "$target"
  ln -s "$source" "$target"
  echo "linked  pi-config/$name -> $source"
}

# Skips deprecated/.

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

    if [ -L "$target" ]; then
      local current
      current="$(readlink "$target")"
      if [ "$current" = "$src" ]; then
        echo "ok      $label/$name"
        continue
      fi
      rm -f "$target"
    elif [ -e "$target" ]; then
      echo "skip    $label/$name is a real directory (third-party install?), not replacing" >&2
      continue
    fi

    ln -sfn "$src" "$target"
    echo "linked  $label/$name -> $src"
  done
}

link_pi_agents() {
  local src_root="$REPO/ppstack/agents"
  local dest_root="$HOME/.pi/agent/agents"

  if [ ! -d "$src_root" ]; then
    return 0
  fi

  mkdir -p "$dest_root"

  local src name target
  for src in "$src_root"/*.md; do
    [ -e "$src" ] || continue
    name="$(basename "$src")"
    target="$dest_root/$name"
    if [ -L "$target" ]; then
      local current
      current="$(readlink "$target")"
      if [ "$current" = "$src" ]; then
        echo "ok      pi-agent/$name"
        continue
      fi
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
      rm -rf "$target"
    fi
    ln -sfn "$src" "$target"
    echo "linked  pi-agent/$name -> $src"
  done
}

# Remove house links from a directory this script no longer targets.
unlink_house_links() {
  local dir="$1"
  local label="$2"
  local link target

  [ -d "$dir" ] || return 0
  for link in "$dir"/*; do
    [ -L "$link" ] || continue
    target="$(readlink "$link")"
    case "$target" in
      "$REPO"/*)
        rm -f "$link"
        echo "removed $label/$(basename "$link") -> $target (now linked under ~/.agents/skills)"
        ;;
    esac
  done
}

link_pi_extension() {
  local name="$1"
  local source="$DOTFILES_ROOT/pi/extensions/$name"
  local target="$HOME/.pi/agent/extensions/$name"

  [ -e "$source" ] || { echo "error: missing $source" >&2; return 1; }
  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "ok      pi-extension/$name"
    return 0
  fi
  rm -rf "$target"
  ln -s "$source" "$target"
  echo "linked  pi-extension/$name -> $source"
}

echo "Linking skills from $REPO"
link_into "$HOME/.agents/skills" "agents"
prune_dangling "$HOME/.agents/skills" agents
unlink_house_links "$HOME/.pi/agent/skills" pi
prune_dangling "$HOME/.pi/agent/skills" pi
link_pi_agents
rm -f "$HOME/.pi/agent/agents/explorer.md" "$HOME/.pi/agent/agents/search.md"
prune_dangling "$HOME/.pi/agent/agents" pi-agent
link_pi_extension petey-debug.ts
link_pi_extension herdr-tab-name
link_pi_config models.json
link_pi_config settings.json
echo "Done. Restart Pi to load settings changes."
