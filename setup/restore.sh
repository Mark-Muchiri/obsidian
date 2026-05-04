#!/usr/bin/env bash
# =============================================================================
#  restore.sh — Pull latest configs from GitHub and apply them to the system
#  Usage: bash restore.sh   OR   restore-dots  (alias added by setup.sh)
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
#  Pull latest from GitHub
# =============================================================================
h1 "Pulling latest from GitHub"

SSH_KEY="$HOME/.ssh/id_ed25519"
if [[ -f "$SSH_KEY" ]]; then
  eval "$(ssh-agent -s)" &>/dev/null
  ssh-add "$SSH_KEY" 2>/dev/null || true
fi

cd "$REPO_DIR"
git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master)

if [[ "$LOCAL" == "$REMOTE" ]]; then
  ok "Already up to date."
else
  git pull
  ok "Pulled latest changes."
fi

# Show what changed vs previous HEAD
if [[ "$LOCAL" != "$REMOTE" ]]; then
  echo ""
  info "Files changed:"
  git diff --name-only "$LOCAL" "$REMOTE" | sed 's/^/    /'
  echo ""
fi

# =============================================================================
#  Backup existing local configs before overwriting
# =============================================================================
h1 "Backing up current local configs"

BACKUP_DIR="$HOME/.config/dotfiles-backup/$(date '+%Y%m%d-%H%M%S')"
mkdir -p "$BACKUP_DIR"

safe_backup() {
  local src="$1"
  if [[ -f "$src" ]]; then
    cp "$src" "$BACKUP_DIR/$(basename "$src")"
    ok "Backed up: $src"
  fi
}

safe_backup "$HOME/.zshrc"
safe_backup "$HOME/.config/starship.toml"
safe_backup "$HOME/.config/wezterm/wezterm.lua"
safe_backup "$HOME/.config/yazi/yazi.toml"
safe_backup "$HOME/.config/micro/settings.json"

info "Backups saved to: $BACKUP_DIR"

# =============================================================================
#  Apply configs from repo → system
# =============================================================================
h1 "Applying configs to system"

restore() {
  local src="$1" dst="$2" use_sudo="${3:-no}"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  if [[ ! -f "$src" && ! -d "$src" ]]; then
    warn "Source not found in repo, skipping: $src"
    return
  fi

  if [[ "$use_sudo" == "sudo" ]]; then
    sudo mkdir -p "$dst_dir"
    sudo cp -r "$src" "$dst"
  else
    mkdir -p "$dst_dir"
    cp -r "$src" "$dst"
  fi
  ok "Applied: $dst"
}

restore "$REPO_DIR/zsh/.zshrc"                 "$HOME/.zshrc"
restore "$REPO_DIR/starship/starship.toml"     "$HOME/.config/starship.toml"
restore "$REPO_DIR/wezterm/wezterm.lua"        "$HOME/.config/wezterm/wezterm.lua"
restore "$REPO_DIR/yazi/yazi.toml"             "$HOME/.config/yazi/yazi.toml"
restore "$REPO_DIR/micro/micro/settings.json"  "$HOME/.config/micro/settings.json"
restore "$REPO_DIR/nano/nanorc"                "/etc/nanorc" sudo

# GNOME extensions dconf restore
if [[ -f "$REPO_DIR/some-file/some-file.txt" ]] && command -v dconf &>/dev/null; then
  info "Restoring GNOME extensions via dconf..."
  dconf load /org/gnome/shell/extensions/ < "$REPO_DIR/some-file/some-file.txt" 2>/dev/null && \
    ok "GNOME extensions restored." || \
    warn "dconf load failed — needs active GNOME session. Run manually if needed."
fi

# =============================================================================
#  Done
# =============================================================================
h1 "Restore Complete"

echo ""
ok "All configs applied from repo."
echo ""
echo -e "${YELLOW}⚠  Reload your shell to apply .zshrc changes:${RESET}"
echo -e "   ${CYAN}exec zsh${RESET}"
echo ""
echo -e "  If something looks wrong, restore your previous configs from:"
echo -e "  ${CYAN}$BACKUP_DIR${RESET}"
echo ""
