#!/usr/bin/env bash
# Switches to master (or main) in each repo and pulls latest from origin.
# Skips a repo if checkout fails due to conflicting uncommitted changes.
# Aborts pull and reports if a merge conflict occurs.

set -uo pipefail

WORKSPACE_ROOTS=(
  "/home/roar/code"
  "/home/roar/misc"
)

while IFS= read -r git_dir; do
  repo="${git_dir%/.git}"
  echo "── $repo"

  # Determine default branch (master or main)
  if git -C "$repo" show-ref --verify --quiet refs/heads/master; then
    default_branch="master"
  elif git -C "$repo" show-ref --verify --quiet refs/heads/main; then
    default_branch="main"
  else
    echo "   SKIP: no master or main branch found"
    echo
    continue
  fi

  current_branch=$(git -C "$repo" symbolic-ref --short HEAD 2>/dev/null || echo "DETACHED")

  # Switch to master/main if not already on it
  if [[ "$current_branch" != "$default_branch" ]]; then
    checkout_output=$(git -C "$repo" checkout "$default_branch" 2>&1)
    checkout_exit=$?
    if [[ $checkout_exit -ne 0 ]]; then
      echo "   SKIP: could not switch to $default_branch (uncommitted changes conflict?)"
      echo "   $checkout_output" | sed 's/^/   /'
      echo
      continue
    fi
    echo "   switched: $current_branch → $default_branch"
  else
    echo "   already on $default_branch"
  fi

  # Pull latest from origin
  pull_output=$(git -C "$repo" pull origin "$default_branch" 2>&1)
  pull_exit=$?

  if [[ $pull_exit -ne 0 ]]; then
    # Check for merge conflict
    if echo "$pull_output" | grep -q "CONFLICT\|Automatic merge failed"; then
      echo "   ERROR: merge conflict during pull — aborting merge"
      git -C "$repo" merge --abort 2>/dev/null || true
      echo "$pull_output" | sed 's/^/   /'
    else
      echo "   ERROR: pull failed"
      echo "$pull_output" | sed 's/^/   /'
    fi
  else
    echo "$pull_output" | tail -1 | sed 's/^/   /'
  fi

  echo
done < <(find "${WORKSPACE_ROOTS[@]}" -mindepth 1 -name ".git" -type d 2>/dev/null | sort)
