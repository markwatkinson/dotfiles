#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
GOOD="$HOME/.config/plasma-appletsrc.good"
BACKUP="$HOME/.config/plasma-appletsrc.bak.$(date +%Y%m%d-%H%M%S)"

# Pick the right tools for Plasma 5 vs 6
if command -v kquitapp6 >/dev/null; then
    QUIT=kquitapp6; START=(kstart plasmashell)
else
    QUIT=kquitapp5; START=(kstart5 plasmashell)
fi

stop_shell()  { $QUIT plasmashell 2>/dev/null || true; sleep 2; }
start_shell() { nohup "${START[@]}" >/dev/null 2>&1 & }

case "${1:-}" in
  save)
    cp "$CFG" "$GOOD"
    echo "Saved current layout to $GOOD"
    ;;

  restore)
    [[ -f $GOOD ]] || { echo "No saved layout. Run '$0 save' first."; exit 1; }
    stop_shell
    cp "$CFG" "$BACKUP"
    cp "$GOOD" "$CFG"
    start_shell
    echo "Restored saved layout (previous one backed up to $BACKUP)"
    ;;

  swap)
    # Usage: plasma-layout.sh swap 1 2   (swaps lastScreen=1 and lastScreen=2)
    A="${2:?first screen number}"; B="${3:?second screen number}"
    stop_shell
    cp "$CFG" "$BACKUP"
    awk -v a="$A" -v b="$B" '
      /^lastScreen=/ {
        split($0, p, "=")
        if (p[2] == a) { print "lastScreen=" b; next }
        if (p[2] == b) { print "lastScreen=" a; next }
      }
      { print }
    ' "$BACKUP" > "$CFG"
    start_shell
    echo "Swapped screens $A and $B (backup at $BACKUP)"
    ;;

  wipe)
    # Nuclear option: back up and delete, Plasma rebuilds the default layout
    stop_shell
    mv "$CFG" "$BACKUP"
    start_shell
    echo "Config removed (backup at $BACKUP). You'll need to re-add widgets."
    ;;

  *)
    echo "Swap Plasma screens without restart"
    echo "Usage: $0 {save|restore|swap A B|wipe}"
    exit 1
    ;;
esac
