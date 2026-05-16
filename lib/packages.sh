#!/usr/bin/env bash
# lib/packages.sh — Package installation module
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_PACKAGES_LOADED:-}" ]] && return 0
_PACKAGES_LOADED=1

# parse_packages SECTION CONF_FILE
#   Reads CONF_FILE, finds [SECTION], prints one package name per line.
#   Strips inline comments and blank lines.
#   Usage: mapfile -t pkgs < <(parse_packages "dnf" "${REPO_DIR}/packages.conf")
parse_packages() {
  local section="$1"
  local conf_file="$2"
  local in_section=0

  if [[ ! -f "${conf_file}" ]]; then
    die "packages.conf not found at: ${conf_file}"
  fi

  while IFS= read -r line; do
    # Strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" || "${line}" == \#* ]] && continue

    if [[ "${line}" =~ ^\[([a-zA-Z0-9_-]+)\]$ ]]; then
      local current_section="${BASH_REMATCH[1]}"
      if [[ "${current_section}" == "${section}" ]]; then
        in_section=1
      else
        in_section=0
      fi
      continue
    fi

    if (( in_section )); then
      local pkg="${line%%#*}"
      pkg="${pkg%"${pkg##*[![:space:]]}"}"
      [[ -n "${pkg}" ]] && printf '%s\n' "${pkg}"
    fi
  done < "${conf_file}"
}

# is_installed_dnf PKG
#   Uses --whatprovides so that virtual provides and compat package names are
#   matched correctly.  For example: rpm -q wget fails on Fedora 44 because the
#   real package is wget2-wget, but rpm -q --whatprovides wget succeeds because
#   wget2-wget lists wget in its Provides.  Without this, packages whose names
#   differ from their provides land in to_install and dnf5 rejects the
#   transaction with "already installed".
is_installed_dnf()     { rpm -q --whatprovides "$1" &>/dev/null; }
is_installed_brew()    { brew list "$1" &>/dev/null 2>&1; }
is_installed_flatpak() { flatpak list --app --columns=application 2>/dev/null | grep -qx "$1"; }

install_dnf_packages() {
  local -a pkgs
  mapfile -t pkgs < <(parse_packages "dnf" "${REPO_DIR}/packages.conf")

  local -a to_install=()
  for pkg in "${pkgs[@]}"; do
    if is_installed_dnf "${pkg}"; then
      warn "  [dnf] ${pkg} already installed — skipping."
    else
      to_install+=("${pkg}")
    fi
  done

  if (( ${#to_install[@]} == 0 )); then
    ok "All dnf packages already installed."
    return 0
  fi

  progress "Installing ${#to_install[@]} dnf package(s)…"
  # sudo required: dnf5 writes to system package database
  sudo dnf5 install -y "${to_install[@]}" || die "dnf5 install failed."
  ok "dnf packages installed."
}

install_brew_packages() {
  local -a pkgs
  mapfile -t pkgs < <(parse_packages "homebrew" "${REPO_DIR}/packages.conf")

  for pkg in "${pkgs[@]}"; do
    if is_installed_brew "${pkg}"; then
      warn "  [brew] ${pkg} already installed — skipping."
    else
      progress "  [brew] Installing ${pkg}…"
      # warn (not die) on failure — brew packages are supplementary
      brew install "${pkg}" || warn "  [brew] ${pkg} failed — continuing."
    fi
  done
  ok "Homebrew packages done."
}

install_flatpak_packages() {
  local -a pkgs
  mapfile -t pkgs < <(parse_packages "flatpak" "${REPO_DIR}/packages.conf")

  for pkg in "${pkgs[@]}"; do
    if is_installed_flatpak "${pkg}"; then
      warn "  [flatpak] ${pkg} already installed — skipping."
    else
      progress "  [flatpak] Installing ${pkg}…"
      flatpak install -y flathub "${pkg}" || warn "  [flatpak] ${pkg} failed — continuing."
    fi
  done
  ok "Flatpak packages done."
}

# _install_bun
#   bun is not in the Fedora dnf repositories. The official installer script
#   places the binary at ~/.bun/bin/bun and appends the PATH entry to .zshrc.
#   Idempotent: skips if bun is already reachable in PATH or at its default
#   install location.
_install_bun() {
  if command -v bun &>/dev/null; then
    ok "  [bun] bun already installed ($(bun --version))."
    return 0
  fi
  # Check the default install location even when ~/.bun/bin is not yet in PATH
  if [[ -x "${HOME}/.bun/bin/bun" ]]; then
    ok "  [bun] bun binary found at ${HOME}/.bun/bin/bun (not yet in PATH — will be after shell restart)."
    return 0
  fi
  progress "  [bun] Installing bun via official installer…"
  check_battery
  curl -fsSL https://bun.sh/install | bash \
    || warn "  [bun] bun installer failed — continuing."
  if [[ -x "${HOME}/.bun/bin/bun" ]]; then
    ok "  [bun] bun installed. Add ~/.bun/bin to PATH or restart your shell."
  else
    warn "  [bun] bun binary not found after install — check installer output."
  fi
}

install_packages() {
  install_dnf_packages
  _install_bun
  install_brew_packages
  install_flatpak_packages
}
