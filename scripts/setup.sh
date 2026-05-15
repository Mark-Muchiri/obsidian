#!/usr/bin/env bash
# =============================================================================
#  setup.sh — Fresh Fedora dotfiles installer
#  Repo: https://github.com/Mark-Muchiri/obsidian.git
#  Usage: bash setup.sh
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()   { echo -e "${GREEN}✔${RESET}  $*"; }
info() { echo -e "${CYAN}→${RESET}  $*"; }
warn() { echo -e "${YELLOW}⚠${RESET}  $*"; }
die()  { echo -e "${RED}✘${RESET}  $*" >&2; exit 1; }
h1()   { echo -e "\n${BOLD}${CYAN}══ $* ══${RESET}"; }

REPO_DIR="$HOME/repo/obsidian"

# ── Sanity check ─────────────────────────────────────────────────────────────
[[ "$EUID" -eq 0 ]] && die "Do not run this script as root. It will use sudo where needed."

# =============================================================================
#  STEP 0 — Collect user info upfront
# =============================================================================
h1 "Git + SSH Configuration"

read -rp "  Git name  : " GIT_NAME
read -rp "  Git email : " GIT_EMAIL
[[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]] && die "Name and email are required."

# =============================================================================
#  STEP 1 — Core system packages
# =============================================================================
h1 "Step 1 — Core System Packages"

info "Installing development tools group..."
sudo dnf group install development-tools -y

info "Installing core utilities..."
sudo dnf5 install -y \
  procps-ng curl file bat fd-find tree trash-cli btop \
  node dconf-editor gnome-tweaks zsh neovim fzf

ok "Core packages installed."

# =============================================================================
#  STEP 2 — ZSH + Oh My ZSH
# =============================================================================
h1 "Step 2 — ZSH + Oh My ZSH"

# Set ZSH as default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  info "Setting ZSH as default shell..."
  chsh -s "$(which zsh)"
  ok "Default shell changed to ZSH. Takes effect on next login."
else
  ok "ZSH is already the default shell."
fi

# Install Oh My ZSH (non-interactive, skip chsh)
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My ZSH..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My ZSH installed."
else
  ok "Oh My ZSH already present."
fi

# =============================================================================
#  STEP 3 — ZSH Plugins
# =============================================================================
h1 "Step 3 — ZSH Plugins"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
  local name="$1" url="$2" dest="$3"
  if [[ -d "$dest" ]]; then
    ok "$name already installed."
  else
    info "Cloning $name..."
    git clone --depth=1 "$url" "$dest"
    ok "$name installed."
  fi
}

clone_plugin "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

clone_plugin "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

clone_plugin "fast-syntax-highlighting" \
  "https://github.com/zdharma-continuum/fast-syntax-highlighting.git" \
  "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

clone_plugin "zsh-history-substring-search" \
  "https://github.com/zsh-users/zsh-history-substring-search.git" \
  "$ZSH_CUSTOM/plugins/zsh-history-substring-search"

# =============================================================================
#  STEP 4 — Starship prompt
# =============================================================================
h1 "Step 4 — Starship Prompt"

if command -v starship &>/dev/null; then
  ok "Starship already installed."
else
  info "Enabling starship COPR and installing..."
  sudo dnf copr enable atim/starship -y
  sudo dnf install starship -y
  ok "Starship installed."
fi

# =============================================================================
#  STEP 5 — Homebrew
# =============================================================================
h1 "Step 5 — Homebrew"

if command -v brew &>/dev/null; then
  ok "Homebrew already installed."
else
  info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Activate for this session
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ok "Homebrew installed."
fi

# Make sure brew is on PATH for this session
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

info "Installing gcc + glibc (required bootstrap)..."
brew install gcc 2>/dev/null || true

info "Installing CLI tools via Homebrew..."
brew install micro eza wget zoxide thefuck yazi fastfetch nerdfetch 2>/dev/null || true

info "Installing Nerd Fonts..."
brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
brew install --cask font-victor-mono-nerd-font 2>/dev/null || true

ok "Homebrew tools installed."

# =============================================================================
#  STEP 6 — Node / npm globals
# =============================================================================
h1 "Step 6 — Node Global Tools"

info "Installing prettier globally..."
sudo npm install --global prettier
ok "Prettier installed."

# =============================================================================
#  STEP 7 — Micro editor plugins
# =============================================================================
h1 "Step 7 — Micro Editor Plugins"

if command -v micro &>/dev/null; then
  info "Installing micro prettier plugin..."
  micro --plugin install prettier 2>/dev/null || warn "prettier plugin may already be installed."
  info "Installing micro lsp plugin..."
  micro --plugin install lsp 2>/dev/null || warn "lsp plugin may already be installed."
  ok "Micro plugins done."
else
  warn "micro not found — skipping plugin install."
fi

# =============================================================================
#  STEP 8 — SSH key + Git config
# =============================================================================
h1 "Step 8 — SSH Key & Git Configuration"

SSH_KEY="$HOME/.ssh/id_ed25519"

# Configure git identity
git config --global user.name  "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global core.sshCommand "ssh -i $SSH_KEY"
git config --global init.defaultBranch main
ok "Git identity configured."

# Generate SSH key if missing
if [[ -f "$SSH_KEY" ]]; then
  ok "SSH key already exists at $SSH_KEY."
else
  info "Generating new ed25519 SSH key..."
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
  ok "SSH key generated."
fi

# Ensure ssh-agent has the key
eval "$(ssh-agent -s)" &>/dev/null
ssh-add "$SSH_KEY" 2>/dev/null || true

echo ""
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD} Your public SSH key (add this to GitHub):${RESET}"
echo -e "${BOLD} https://github.com/settings/keys${RESET}"
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
cat "$SSH_KEY.pub"
echo ""
echo -e "${BOLD}${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

read -rp "  Press [Enter] once you've added the key to GitHub..." _

info "Testing GitHub SSH connection..."
if ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 | grep -q "successfully authenticated"; then
  ok "GitHub SSH connection verified!"
else
  warn "Could not verify GitHub connection. You may need to re-run or check manually with: ssh -T git@github.com"
fi

# =============================================================================
#  STEP 9 — Clone dotfiles repo
# =============================================================================
h1 "Step 9 — Clone Dotfiles Repo"

if [[ -d "$REPO_DIR/.git" ]]; then
  ok "Repo already exists at $REPO_DIR. Pulling latest..."
  git -C "$REPO_DIR" pull
else
  info "Cloning obsidian repo..."
  mkdir -p "$HOME/repo"
  git clone git@github.com:Mark-Muchiri/obsidian.git "$REPO_DIR"
  ok "Repo cloned to $REPO_DIR."
fi

# =============================================================================
#  STEP 10 — Wezterm
# =============================================================================
h1 "Step 10 — Wezterm Terminal"

if command -v wezterm &>/dev/null; then
  ok "Wezterm already installed."
else
  info "Enabling wezterm COPR and installing..."
  sudo dnf copr enable wezfurlong/wezterm-nightly -y
  sudo dnf install wezterm -y
  ok "Wezterm installed."
fi

info "Installing wezterm terminfo (needed for config.term = 'wezterm')..."
tempfile=$(mktemp)
curl -fsSo "$tempfile" \
  https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo
tic -x -o ~/.terminfo "$tempfile"
rm -f "$tempfile"
ok "Wezterm terminfo installed."

# =============================================================================
#  STEP 11 — GNOME Extensions
# =============================================================================
h1 "Step 11 — GNOME Extensions"

info "Installing gnome-browser-connector and xprop..."
sudo dnf5 install -y gnome-browser-connector xprop

info "Disabling extension version validation..."
sudo gsettings set org.gnome.shell disable-extension-version-validation true 2>/dev/null || \
  warn "gsettings failed — may need an active GNOME session."

info "Installing Unite shell extension..."
UNITE_ZIP="/tmp/unite-v85.zip"
wget -q -O "$UNITE_ZIP" \
  https://github.com/hardpixel/unite-shell/releases/download/v85/unite-v85.zip
gnome-extensions install --force "$UNITE_ZIP" 2>/dev/null || \
  warn "gnome-extensions install failed — may need active GNOME session. Run manually: gnome-extensions install --force $UNITE_ZIP"
rm -f "$UNITE_ZIP"

info "Installing Extension Manager flatpak..."
flatpak install -y flathub com.mattjakeman.ExtensionManager 2>/dev/null || \
  warn "Extension Manager install failed — try manually."

info "Installing Smile emoji picker..."
flatpak install -y it.mijorus.smile 2>/dev/null || \
  warn "Smile install failed — try manually."

ok "GNOME extensions step done."

# =============================================================================
#  STEP 12 — Restore all config files
# =============================================================================
h1 "Step 12 — Restore Config Files"

restore() {
  local src="$1" dst="$2" use_sudo="${3:-no}"
  local dst_dir
  dst_dir="$(dirname "$dst")"

  if [[ ! -f "$src" && ! -d "$src" ]]; then
    warn "Source not found, skipping: $src"
    return
  fi

  if [[ "$use_sudo" == "sudo" ]]; then
    sudo mkdir -p "$dst_dir"
    sudo cp -r "$src" "$dst"
  else
    mkdir -p "$dst_dir"
    cp -r "$src" "$dst"
  fi
  ok "Restored: $dst"
}

restore "$REPO_DIR/micro/micro/settings.json"  "$HOME/.config/micro/settings.json"
restore "$REPO_DIR/nano/nanorc"                "/etc/nanorc" sudo
restore "$REPO_DIR/starship/starship.toml"     "$HOME/.config/starship.toml"
restore "$REPO_DIR/wezterm/wezterm.lua"        "$HOME/.config/wezterm/wezterm.lua"
restore "$REPO_DIR/yazi/yazi.toml"             "$HOME/.config/yazi/yazi.toml"
restore "$REPO_DIR/zsh/.zshrc"                 "$HOME/.zshrc"

if [[ -f "$REPO_DIR/some-file/some-file.txt" ]]; then
  info "Restoring GNOME extensions via dconf..."
  dconf load /org/gnome/shell/extensions/ < "$REPO_DIR/some-file/some-file.txt" 2>/dev/null || \
    warn "dconf load failed — needs active GNOME session. Run manually after login."
  ok "GNOME extensions dconf restored."
fi

# =============================================================================
#  STEP 13 — Finalise: add sync alias to .zshrc
# =============================================================================
h1 "Step 13 — Sync Alias"

SYNC_ALIAS="alias sync-dots=\"bash $REPO_DIR/sync.sh\""
if ! grep -qF "sync-dots" "$HOME/.zshrc" 2>/dev/null; then
  echo "" >> "$HOME/.zshrc"
  echo "# Dotfiles sync" >> "$HOME/.zshrc"
  echo "$SYNC_ALIAS" >> "$HOME/.zshrc"
  ok "sync-dots alias added to .zshrc."
else
  ok "sync-dots alias already present."
fi

RESTORE_ALIAS="alias restore-dots=\"bash $REPO_DIR/restore.sh\""
if ! grep -qF "restore-dots" "$HOME/.zshrc" 2>/dev/null; then
  echo "$RESTORE_ALIAS" >> "$HOME/.zshrc"
  ok "restore-dots alias added to .zshrc."
fi

# =============================================================================
#  Done
# =============================================================================
h1 "Setup Complete"

echo ""
echo -e "${GREEN}${BOLD}Everything is installed and configured!${RESET}"
echo ""
echo -e "  ${CYAN}sync-dots${RESET}    — push your latest config changes to GitHub"
echo -e "  ${CYAN}restore-dots${RESET} — pull the latest configs from GitHub and apply them"
echo ""
echo -e "${YELLOW}⚠  Start a new ZSH session (or run: exec zsh) to load all changes.${RESET}"
echo ""

# ── Optional extras reminder ─────────────────────────────────────────────────
echo -e "${BOLD}Optional / not automated:${RESET}"
echo "  • Wine    → see README for repo instructions"
echo "  • ghostty → not yet in Fedora repos; grab from https://ghostty.org"
echo "  • pnpm    → curl -fsSL https://get.pnpm.io/install.sh | sh -"
echo "  • bun     → curl -fsSL https://bun.sh/install | bash"
echo ""
