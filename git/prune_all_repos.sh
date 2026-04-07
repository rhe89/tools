#!/usr/bin/env bash
# Prunes stale remote-tracking branches for 'origin' in all git repositories
# found under the VS Code workspace folders.

set -euo pipefail

WORKSPACE_ROOTS=(
  "$HOME/code"
)

while IFS= read -r git_dir; do
  repo="${git_dir%/.git}"
  echo "── $repo"
  git -C "$repo" remote prune origin && echo "   OK" || echo "   FAILED (or no origin)"
done < <(find "${WORKSPACE_ROOTS[@]}" -mindepth 1 -name ".git" -type d 2>/dev/null | sort)
