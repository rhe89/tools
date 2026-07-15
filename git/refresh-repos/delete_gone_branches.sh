#!/usr/bin/env bash
# Deletes local branches whose upstream tracking branch no longer exists in origin.
# Runs 'git fetch --prune' first to update remote refs, then removes gone branches.
#
# Usage: delete_gone_branches.sh [-D]
#   -D  Force-delete unmerged gone branches (git branch -D)

set -euo pipefail

FORCE_DELETE=false
while getopts ":D" opt; do
  case $opt in
    D) FORCE_DELETE=true ;;
    *) echo "Usage: $0 [-D]"; exit 1 ;;
  esac
done

WORKSPACE_ROOTS=(
  "$HOME/code"
)

while IFS= read -r git_dir; do
  repo="${git_dir%/.git}"
  echo "── $repo"

  git -C "$repo" fetch --prune 2>&1 | sed 's/^/   fetch: /' || echo "   fetch failed (skipping gone-branch detection)"

  gone_branches=$(git -C "$repo" branch -vv \
    | grep ': gone]' \
    | grep -v '^\*' \
    | awk '{print $1}' || true)

  if [[ -z "$gone_branches" ]]; then
    echo "   no gone branches"
  else
    while IFS= read -r branch; do
      if $FORCE_DELETE; then
        if git -C "$repo" branch -D "$branch" 2>/dev/null; then
          echo "   force-deleted: $branch"
        else
          echo "   failed to delete: $branch"
        fi
      else
        if git -C "$repo" branch -d "$branch" 2>/dev/null; then
          echo "   deleted: $branch"
        else
          echo "   unmerged (re-run with -D to force-delete): $branch"
        fi
      fi
    done <<< "$gone_branches"
  fi

  echo
done < <(find "${WORKSPACE_ROOTS[@]}" -mindepth 1 -name ".git" -type d 2>/dev/null | sort)
