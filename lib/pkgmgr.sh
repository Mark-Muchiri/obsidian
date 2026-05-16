#!/usr/bin/env bash
# lib/pkgmgr.sh — Package manager setup (Homebrew + Flatpak)
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_PKGMGR_LOADED:-}" ]] && return 0
_PKGMGR_LOADED=1

_install_homebrew() {
  if command -v brew &>/dev/null; then
    ok "Homebrew already installed ($(brew --version | head -1))."
    return 0
  fi

  progress "Installing Homebrew…"
  check_battery

  # NONINTERACTIVE=1 suppresses the installer's interactive prompts.
  NONINTERACTIVE=1 \
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    || die "Homebrew installation failed."

  # On Linux the installer lands in /home/linuxbrew/.linuxbrew.
  # Evaluate shellenv so brew is in PATH for the rest of this session.
  local brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
  if [[ -x "${brew_bin}" ]]; then
    eval "$("${brew_bin}" shellenv)"
  fi

  if ! command -v brew &>/dev/null; then
    warn "brew not found in PATH after install."
    warn "Add the following to your shell profile and re-run setup:"
    # SC2016: single quotes are intentional — $() must print literally as a
    # copyable shell snippet, not expand in this script's context.
    # shellcheck disable=SC2016
    printf '    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"\n'
    return 1
  fi

  ok "Homebrew installed ($(brew --version | head -1))."
}

_install_flatpak_and_flathub() {
  # Flatpak ships with Fedora Workstation; this is a safety net.
  if ! command -v flatpak &>/dev/null; then
    progress "flatpak not found — installing via dnf5…"
    # sudo required: dnf5 writes to the system package database
    sudo dnf5 install -y flatpak || die "Failed to install flatpak."
    ok "flatpak installed ($(flatpak --version))."
  else
    ok "flatpak already installed ($(flatpak --version))."
  fi

  # Prefer the user-scoped remote so Flathub apps install without sudo.
  if flatpak remote-list --user 2>/dev/null | grep -q '^flathub'; then
    ok "Flathub remote already configured (user scope)."
  elif flatpak remote-list 2>/dev/null | grep -q '^flathub'; then
    ok "Flathub remote already configured (system scope)."
  else
    progress "Adding Flathub remote (user scope)…"
    flatpak remote-add --user --if-not-exists flathub \
      https://dl.flathub.org/repo/flathub.flatpakrepo \
      || die "Failed to add Flathub remote."
    ok "Flathub remote added."
  fi
}

setup_package_managers() {
  info "Setting up supplementary package managers…"
  _install_homebrew
  _install_flatpak_and_flathub
  ok "Package manager stage complete."
}
