#!/usr/bin/env bash
# lib/editors.sh — Editor & desktop tool configuration
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_EDITORS_LOADED:-}" ]] && return 0
_EDITORS_LOADED=1

_install_prettier() {
  if npm list -g --depth=0 2>/dev/null | grep -q 'prettier'; then
    ok "prettier already installed globally."
    return 0
  fi
  progress "Installing prettier globally via npm…"
  # sudo required: npm -g writes to the system node_modules directory
  sudo npm install -g prettier || die "Failed to install prettier."
  ok "prettier installed ($(prettier --version))."
}

_install_micro_lsp_plugin() {
  local plugin_dir="${HOME}/.config/micro/plug/lsp"
  if [[ -d "${plugin_dir}" ]]; then
    ok "micro lsp plugin already installed."
    return 0
  fi

  if ! command -v micro &>/dev/null; then
    warn "micro not found in PATH — skipping lsp plugin install."
    return 0
  fi

  progress "Installing micro lsp plugin…"
  micro -plugin install lsp \
    || warn "micro lsp plugin install failed — continuing."
  ok "micro lsp plugin installed."
}

_install_unite_extension() {
  local ext_name="unite@hardpixel.eu"
  local ext_base="${HOME}/.local/share/gnome-shell/extensions"
  local ext_dir="${ext_base}/${ext_name}"

  if [[ -d "${ext_dir}" ]]; then
    ok "Unite GNOME Shell extension already installed."
    return 0
  fi

  progress "Fetching latest Unite extension release…"
  check_battery

  local api_url="https://api.github.com/repos/hardpixel/unite-shell/releases/latest"
  local tag
  tag="$(curl -fsSL "${api_url}" \
    | grep '"tag_name"' \
    | head -1 \
    | cut -d'"' -f4)" \
    || die "Could not fetch Unite release tag from GitHub."

  info "Latest Unite release: ${tag}"

  local zip_url="https://github.com/hardpixel/unite-shell/releases/download/${tag}/${ext_name}.zip"
  local tmp_zip
  tmp_zip="$(mktemp --suffix='.zip')"

  curl -fsSL "${zip_url}" -o "${tmp_zip}" \
    || die "Failed to download Unite extension zip."

  mkdir -p "${ext_base}"
  unzip -q "${tmp_zip}" -d "${ext_base}/" \
    || die "Failed to unzip Unite extension."
  rm -f "${tmp_zip}"

  # Disable GNOME Shell extension version validation so the extension loads
  # on Fedora's bundled Shell version without needing a metadata.json patch.
  if command -v gnome-extensions &>/dev/null; then
    # Ignore exit code — older gnome-extensions builds lack this sub-command
    gnome-extensions disable-version-validation 2>/dev/null || true
  fi

  ok "Unite extension installed at ${ext_dir}."
  info "Log out and back in (or restart GNOME Shell) to activate it."
}

_restore_gnome_extension_settings() {
  local dconf_file="${REPO_DIR}/configs/gnome-extensions/gnome-extensions.txt"

  if [[ ! -f "${dconf_file}" ]]; then
    warn "gnome-extensions.txt not found at ${dconf_file} — skipping dconf restore."
    return 0
  fi

  if ! command -v dconf &>/dev/null; then
    warn "dconf not found — skipping GNOME extension settings restore."
    return 0
  fi

  progress "Restoring GNOME extension settings via dconf…"
  dconf load /org/gnome/shell/extensions/ < "${dconf_file}" \
    || warn "dconf load failed — settings may not be fully restored."
  ok "GNOME extension settings restored."
}

setup_editors() {
  info "Setting up editors and desktop tools…"
  _install_prettier
  _install_micro_lsp_plugin
  _install_unite_extension
  _restore_gnome_extension_settings
  ok "Editors stage complete."
}
