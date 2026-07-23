#!/usr/bin/env bash
# Adds or refreshes the refresh-repos alias in the user's shell rc file.

set -euo pipefail

START_MARKER="# >>> tools/git/refresh-repos refresh-repos alias >>>"
END_MARKER="# <<< tools/git/refresh-repos refresh-repos alias <<<"

shell_name="$(basename "${SHELL:-}")"
case "$shell_name" in
  zsh)
    SHELL_RC="$HOME/.zshrc"
    ;;
  bash)
    SHELL_RC="$HOME/.bashrc"
    ;;
  *)
    if [[ "$(uname -s)" == "Darwin" ]]; then
      SHELL_RC="$HOME/.zshrc"
    else
      SHELL_RC="$HOME/.bashrc"
    fi
    ;;
esac

ALIAS_BLOCK=$(cat <<'EOF'
# >>> tools/git/refresh-repos refresh-repos alias >>>
alias refresh-repos='$HOME/code/tools/git/refresh-repos/update_master.sh && $HOME/code/tools/git/refresh-repos/prune_all_repos.sh && $HOME/code/tools/git/refresh-repos/delete_gone_branches.sh'
# <<< tools/git/refresh-repos refresh-repos alias <<<
EOF
)

touch "$SHELL_RC"

tmp_file=$(mktemp)
awk -v start="$START_MARKER" -v end="$END_MARKER" '
  $0 == start { skipping = 1; next }
  $0 == end { skipping = 0; next }
  !skipping { print }
' "$SHELL_RC" > "$tmp_file"

{
  cat "$tmp_file"
  printf "\n%s\n" "$ALIAS_BLOCK"
} > "$SHELL_RC"

rm -f "$tmp_file"

echo "Added refresh-repos alias to $SHELL_RC"
