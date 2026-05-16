#!/usr/bin/env bash
# scripts/sync.sh — Sync dotfiles changes back to GitHub
# Usage: bash scripts/sync.sh
#
# Equivalent to the sync-config alias:
#   git add -A && git commit -v && git push
#
# The repo is the source of truth. All configs are symlinked into place
# by restore.sh, so edits to live configs are already edits to the repo.
# This script just commits and pushes whatever has changed.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"

# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"

main() {
  progress_header "Sync dotfiles → GitHub"

  cd "${REPO_DIR}"

  # Verify we are inside a git repo — catches accidental moves
  if ! git rev-parse --git-dir &>/dev/null; then
    die "Not a git repository: ${REPO_DIR}"
  fi

  # Check there is a configured remote to push to
  if ! git remote get-url origin &>/dev/null; then
    die "No 'origin' remote configured. Add one with:\n  git remote add origin git@github.com:Mark-Muchiri/obsidian.git"
  fi

  # Bail early if there is nothing to commit — avoids an empty commit error
  if git diff --quiet && git diff --cached --quiet && \
     [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
    ok "Nothing to commit — repo is clean."
    info "Last commit:"
    git log --oneline -1
    exit 0
  fi

  info "Staging all changes…"
  git add -A

  info "Opening editor for commit message…"
  # -v shows the diff in the commit message editor — matches sync-config alias behaviour
  git commit -v

  info "Pushing to origin…"
  git push

  ok "Sync complete."
  printf '\n'
  info "Recent commits:"
  git log --oneline -5
}

main "$@"
