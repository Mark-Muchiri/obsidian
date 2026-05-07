#!/usr/bin/env bash
# =============================================================================
#  sync.sh — Save live config changes to the obsidian repo and push to GitHub
#  Usage: bash sync.sh   OR   sync-dots  (alias added by setup.sh)
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
info() { echo -e "${CYAN}→${RESET}  $*"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
die()  { echo -e "${RED}✘${RESET}  $*" >&2; exit 1; }
h1()   { echo -e "\n${BOLD}${CYAN}══ $* ══${RESET}"; }

REPO_DIR="$HOME/repo/obsidian"

[[ -d "$REPO_DIR/.git" ]] || die "Repo not found at $REPO_DIR. Run setup.sh first."

# =============================================================================
#  Copy live configs → repo
# =============================================================================
h1 "Syncing configs to repo"

backup() {
  local src="$1" dst="$2" use_sudo="${3:-no}"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  if [[ ! -f "$src" && ! -d "$src" ]]; then
    warn "Not found, skipping: $src"
    return
  fi

  mkdir -p "$dst_dir"

  if [[ "$use_sudo" == "sudo" ]]; then
    sudo cp -r "$src" "$dst"
  else
    cp -r "$src" "$dst"
  fi
  ok "$src  →  $dst"
}

backup "$HOME/.zshrc"                    "$REPO_DIR/zsh/.zshrc"
backup "$HOME/.config/starship.toml"     "$REPO_DIR/starship/starship.toml"
backup "$HOME/.config/wezterm/wezterm.lua" "$REPO_DIR/wezterm/wezterm.lua"
backup "$HOME/.config/yazi/yazi.toml"   "$REPO_DIR/yazi/yazi.toml"
backup "$HOME/.config/micro/settings.json" "$REPO_DIR/micro/micro/settings.json"
backup "/etc/nanorc"                     "$REPO_DIR/nano/nanorc" sudo

# GNOME extensions dconf dump
if command -v dconf &>/dev/null; then
  info "Dumping GNOME extensions via dconf..."
  mkdir -p "$REPO_DIR/some-file"
  dconf dump /org/gnome/shell/extensions/ > "$REPO_DIR/some-file/some-file.txt" 2>/dev/null && \
    ok "GNOME extensions dumped." || warn "dconf dump failed — needs active GNOME session."
fi

# =============================================================================
#  Git: commit & push
# =============================================================================
h1 "Committing and pushing to GitHub"

cd "$REPO_DIR"

# Ensure SSH key is loaded
SSH_KEY="$HOME/.ssh/id_ed25519"
if [[ -f "$SSH_KEY" ]]; then
  eval "$(ssh-agent -s)" &>/dev/null
  ssh-add "$SSH_KEY" 2>/dev/null || true
fi

git add -A

# Only commit if there's something to commit
if git diff --cached --quiet; then
  ok "No changes detected — repo is already up to date."
  exit 0
fi

# Show what changed
echo ""
git diff --cached --stat
echo ""

# Commit with timestamp
COMMIT_MSG="chore: sync configs $(date '+%Y-%m-%d %H:%M')"
read -rp "  Commit message [${COMMIT_MSG}]: " USER_MSG
COMMIT_MSG="${USER_MSG:-$COMMIT_MSG}"

git commit -m "$COMMIT_MSG"
git push

ok "Changes pushed to GitHub."
echo ""
