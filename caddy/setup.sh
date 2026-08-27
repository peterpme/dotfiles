#!/usr/bin/env bash
# Point Homebrew Caddy at this Caddyfile.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
CADDY_DST="/opt/homebrew/etc/Caddyfile"

ln -sfn "$HERE/Caddyfile" "$CADDY_DST"
echo "Caddyfile → $CADDY_DST"

echo
echo "Add names to /etc/hosts (once per model):"
echo "  sudo sh -c 'grep -q qwen38-27b.ai.peterp.local /etc/hosts || cat $HERE/hosts >> /etc/hosts'"
echo
echo "Start Caddy if it isn't running (needs :80):"
echo "  sudo brew services start caddy"
echo
echo "Check:"
echo "  ping -c 1 qwen38-27b.ai.peterp.local"
