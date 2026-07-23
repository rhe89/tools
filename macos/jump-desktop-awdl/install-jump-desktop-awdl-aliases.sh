#!/bin/sh
set -eu

ZSHRC="${ZSHRC:-"$HOME/.zshrc"}"
START_MARKER="# >>> Jump Desktop AWDL aliases >>>"
END_MARKER="# <<< Jump Desktop AWDL aliases <<<"

PREPARE_ALIAS="alias prepare-jump-desktop='sudo ifconfig awdl0 down'"
FINISHED_ALIAS="alias jump-desktop-finished='sudo ifconfig awdl0 up'"

mkdir -p "$(dirname "$ZSHRC")"
touch "$ZSHRC"

TMP_FILE="$(mktemp)"

awk -v start="$START_MARKER" -v end="$END_MARKER" '
  $0 == start { in_block = 1; next }
  $0 == end { in_block = 0; next }
  in_block { next }
  /^[[:space:]]*alias[[:space:]]+prepare-jump-desktop=/ { next }
  /^[[:space:]]*alias[[:space:]]+jump-desktop-finished=/ { next }
  { print }
' "$ZSHRC" > "$TMP_FILE"

{
  printf '\n%s\n' "$START_MARKER"
  printf '%s\n' "$PREPARE_ALIAS"
  printf '%s\n' "$FINISHED_ALIAS"
  printf '%s\n' "$END_MARKER"
} >> "$TMP_FILE"

mv "$TMP_FILE" "$ZSHRC"

printf 'Updated %s with Jump Desktop AWDL aliases.\n' "$ZSHRC"

printf 'Reload your shell with: source %s\n' "$ZSHRC"
