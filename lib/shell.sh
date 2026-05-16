#!/usr/bin/env bash
# lib/shell.sh — Shell & terminal setup stage
# Sourced by scripts/setup.sh — do not run directly.
#
# Installs and configures:
#   zsh → Oh My Zsh → plugins → JetBrainsMono Nerd Font → starship
# Then copies .zshrc and starship.toml from configs/ into place.

# Guard against double-sourcing
[[ -n "${_SHELL_LOADED:-}" ]] && return 0
_SHELL_LOADED=1

# ── 1. Zsh ────────────────────────────────────────────────────────────────────

_install_zsh() {
  if command -v zsh &>/dev/null; then
    ok "zsh already installed ($(zsh --version | head -1))."
    return 0
  fi

  progress "Installing zsh via dnf5…"
  # sudo required: dnf5 writes to the system package database
  sudo dnf5 install -y zsh || die "Failed to install zsh."
  ok "zsh installed."
}

_set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)" || die "zsh not found in PATH after install."

  if [[ "${SHELL}" == "${zsh_path}" ]]; then
    ok "Default shell is already zsh."
    return 0
  fi

  # /etc/shells must list zsh before chsh will accept it
  if ! grep -qx "${zsh_path}" /etc/shells; then
    info "Adding ${zsh_path} to /etc/shells…"
    # sudo required: /etc/shells is root-owned
    printf '%s\n' "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
  fi

  info "Changing default shell to zsh (you will be prompted for your password)…"
  chsh -s "${zsh_path}" || die "chsh failed — could not set zsh as default shell."
  ok "Default shell set to zsh. Takes effect on next login."
}

# ── 2. Oh My Zsh ──────────────────────────────────────────────────────────────

_install_oh_my_zsh() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed."
    return 0
  fi

  progress "Installing Oh My Zsh…"
  check_battery  # download + setup takes ~30 seconds on slow connections

  # RUNZSH=no  — do not start a new zsh session after install (would halt script)
  # CHSH=no    — do not change the shell here; we handle that in _set_default_shell
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    || die "Oh My Zsh installation failed."

  ok "Oh My Zsh installed."
}

# ── 3. ZSH plugins ───────────────────────────────────────────────────────────
# All four plugins are cloned into ${ZSH_CUSTOM}/plugins/.
# ZSH_CUSTOM defaults to ~/.oh-my-zsh/custom if not already set.

_install_zsh_plugin() {
  local name="$1"
  local repo="$2"
  local plugin_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/${name}"

  if [[ -d "${plugin_dir}" ]]; then
    warn "  Plugin '${name}' already installed — skipping."
    return 0
  fi

  progress "  Installing plugin: ${name}…"
  git clone --depth=1 "${repo}" "${plugin_dir}" \
    || die "Failed to clone plugin '${name}' from ${repo}."
  ok "  Plugin '${name}' installed."
}

_install_zsh_plugins() {
  info "Installing ZSH plugins…"

  _install_zsh_plugin \
    "zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-autosuggestions"

  _install_zsh_plugin \
    "zsh-syntax-highlighting" \
    "https://github.com/zsh-users/zsh-syntax-highlighting"

  _install_zsh_plugin \
    "fast-syntax-highlighting" \
    "https://github.com/zdharma-continuum/fast-syntax-highlighting"

  _install_zsh_plugin \
    "zsh-history-substring-search" \
    "https://github.com/zsh-users/zsh-history-substring-search"

  ok "ZSH plugins installed."
}

# ── 4. JetBrainsMono Nerd Font ───────────────────────────────────────────────

_install_jetbrains_font() {
  # fc-list output for this font contains "JetBrainsMonoNL Nerd Font"
  if fc-list | grep -q "JetBrainsMono"; then
    ok "JetBrainsMono Nerd Font already installed."
    return 0
  fi

  progress "Downloading JetBrainsMono Nerd Font…"
  check_battery

  local font_dir="${HOME}/.local/share/fonts/JetBrainsMono"
  mkdir -p "${font_dir}"

  # Fetch the latest release tag from GitHub API
  local latest_tag
  latest_tag="$(curl -fsSL \
    "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
    | grep '"tag_name"' \
    | head -1 \
    | cut -d'"' -f4)" \
    || die "Could not fetch latest Nerd Fonts release tag."

  info "Latest Nerd Fonts release: ${latest_tag}"

  local zip_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${latest_tag}/JetBrainsMono.zip"
  local tmp_zip
  tmp_zip="$(mktemp --suffix='.zip')"

  curl -fsSL "${zip_url}" -o "${tmp_zip}" \
    || die "Failed to download JetBrainsMono.zip."

  unzip -q "${tmp_zip}" -d "${font_dir}" \
    || die "Failed to unzip JetBrainsMono.zip."

  rm -f "${tmp_zip}"

  # Refresh font cache for both user and system font directories
  fc-cache -f "${font_dir}"
  ok "JetBrainsMono Nerd Font installed and font cache refreshed."
}

# ── 5. Starship prompt ────────────────────────────────────────────────────────

_install_starship() {
  if command -v starship &>/dev/null; then
    ok "Starship already installed ($(starship --version | head -1))."
    return 0
  fi

  progress "Installing Starship prompt…"
  check_battery

  # Official install script — places binary in ~/.local/bin by default
  # BIN_DIR is set so it lands in a predictable, user-writable location
  curl -fsSL https://starship.rs/install.sh \
    | sh -s -- --yes --bin-dir "${HOME}/.local/bin" \
    || die "Starship installation failed."

  ok "Starship installed."
}

# ── 6. Deploy configs ─────────────────────────────────────────────────────────
# safe_symlink is defined in lib/utils.sh.
# Each config in configs/ gets linked to its canonical system location.

_deploy_shell_configs() {
  info "Linking shell configs…"

  safe_symlink \
    "${REPO_DIR}/configs/zsh/.zshrc" \
    "${HOME}/.zshrc"

  safe_symlink \
    "${REPO_DIR}/configs/starship/starship.toml" \
    "${HOME}/.config/starship.toml"

  ok "Shell configs linked."
}

# ── Stage entry point ─────────────────────────────────────────────────────────

setup_shell() {
  check_battery  # warn early — this stage does the most downloading

  _install_zsh
  _set_default_shell
  _install_oh_my_zsh
  _install_zsh_plugins
  _install_jetbrains_font
  _install_starship
  _deploy_shell_configs

  ok "Shell stage complete."
  info "Run 'exec zsh' or open a new terminal to start using zsh now."
}
