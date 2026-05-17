#!/usr/bin/env bash
# scripts/sync.sh — Sync dotfiles changes back to GitHub
# Usage: bash scripts/sync.sh
#
# Before committing, exports any config sources that cannot be symlinked:
#   - GNOME extension settings (dconf → configs/gnome-extensions/gnome-extensions.txt)
#
# Everything else (zsh, starship, nvim, wezterm, micro, btop, yazi, nano)
# is symlinked into the repo and is already up to date — no copy step needed.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"

# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"

_export_dconf() {
  local out_file="${REPO_DIR}/configs/gnome-extensions/gnome-extensions.txt"

  if ! command -v dconf &>/dev/null; then
    warn "dconf not found — skipping GNOME extension settings export."
    return 0
  fi

  progress "Exporting GNOME extension settings → configs/gnome-extensions/gnome-extensions.txt"
  mkdir -p "$(dirname "${out_file}")"
  dconf dump /org/gnome/shell/extensions/ > "${out_file}" \
    || warn "dconf dump failed — GNOME extension settings not updated."
  ok "GNOME extension settings exported."
}

main() {
  progress_header "Sync dotfiles → GitHub"
  cd "${REPO_DIR}"

  if ! git rev-parse --git-dir &>/dev/null; then
    die "Not a git repository: ${REPO_DIR}"
  fi

  if ! git remote get-url origin &>/dev/null; then
    die "No 'origin' remote configured. Add one with: git remote add origin git@github.com:Mark-Muchiri/obsidian.git"
  fi

  # Export non-symlinked configs before staging so they are always current.
  _export_dconf

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
  # -v shows the diff in the commit message editor — matches sync-config alias
  git commit -v

  info "Pushing to origin…"
  git push

  ok "Sync complete."
  printf '\n'
  info "Recent commits:"
  git log --oneline -5
}

main "$@"
