#!/usr/bin/env bash
# lib/wezterm.sh — WezTerm terminal emulator setup
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_WEZTERM_LOADED:-}" ]] && return 0
_WEZTERM_LOADED=1

_WEZTERM_COPR="wez/wezterm"
_WEZTERM_DNF_PKG="wezterm"
_WEZTERM_TERMINFO_URL="https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo"

_install_wezterm_copr() {
  if command -v wezterm &>/dev/null; then
    ok "wezterm already installed ($(wezterm --version | head -1))."
    return 0
  fi

  progress "Enabling wezterm COPR repository…"
  # sudo required: dnf5-plugins writes to /etc/yum.repos.d/
  sudo dnf5 copr enable -y "${_WEZTERM_COPR}" \
    || die "Failed to enable COPR ${_WEZTERM_COPR}."

  progress "Installing wezterm via dnf5…"
  # sudo required: dnf5 writes to the system package database
  sudo dnf5 install -y "${_WEZTERM_DNF_PKG}" \
    || die "Failed to install wezterm."

  ok "wezterm installed ($(wezterm --version | head -1))."
}

_install_wezterm_terminfo() {
  # infocmp exits 0 when the entry is found in the compiled terminfo DB.
  if infocmp wezterm &>/dev/null 2>&1; then
    ok "wezterm terminfo already installed."
    return 0
  fi

  progress "Installing wezterm terminfo…"

  local tmp_ti
  tmp_ti="$(mktemp --suffix='.terminfo')"

  curl -fsSL "${_WEZTERM_TERMINFO_URL}" -o "${tmp_ti}" \
    || die "Failed to download wezterm.terminfo."

  # -x compiles extended capabilities; output lands in ~/.terminfo/ by default.
  tic -x "${tmp_ti}" || die "tic failed — terminfo not installed."
  rm -f "${tmp_ti}"

  ok "wezterm terminfo installed."
}

_verify_wezterm_config_link() {
  local src="${REPO_DIR}/configs/wezterm/wezterm.lua"
  local dest="${HOME}/.config/wezterm/wezterm.lua"

  if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
    ok "wezterm config symlink already in place."
    return 0
  fi

  # safe_symlink handles backup, parent dir creation, and confirmation output.
  safe_symlink "${src}" "${dest}"
}

setup_wezterm() {
  info "Setting up WezTerm…"
  _install_wezterm_copr
  _install_wezterm_terminfo
  _verify_wezterm_config_link
  ok "WezTerm stage complete."
}
