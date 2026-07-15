#!/usr/bin/env bash
# Adds or refreshes the refresh-repos alias in ~/.zshrc.

set -euo pipefail

ZSHRC="$HOME/.zshrc"
START_MARKER="# >>> tools/git/refresh-repos refresh-repos alias >>>"
END_MARKER="# <<< tools/git/refresh-repos refresh-repos alias <<<"

ALIAS_BLOCK=$(cat <<'EOF'
# >>> tools/git/refresh-repos refresh-repos alias >>>
alias refresh-repos='$HOME/code/tools/git/refresh-repos/update_master.sh && $HOME/code/tools/git/refresh-repos/prune_all_repos.sh && $HOME/code/tools/git/refresh-repos/delete_gone_branches.sh'
# <<< tools/git/refresh-repos refresh-repos alias <<<
EOF
)

touch "$ZSHRC"

tmp_file=$(mktemp)
awk -v start="$START_MARKER" -v end="$END_MARKER" '
  $0 == start { skipping = 1; next }
  $0 == end { skipping = 0; next }
  !skipping { print }
' "$ZSHRC" > "$tmp_file"

{
  cat "$tmp_file"
  printf "\n%s\n" "$ALIAS_BLOCK"
} > "$ZSHRC"

rm -f "$tmp_file"

echo "Added refresh-repos alias to $ZSHRC"
