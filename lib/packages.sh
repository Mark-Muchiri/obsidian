#!/usr/bin/env bash
# lib/packages.sh — Package installation module
# Sourced by scripts/setup.sh — do not run directly.

# ── Parser ────────────────────────────────────────────────────────────────────

# parse_packages SECTION CONF_FILE
#   Reads CONF_FILE, finds the [SECTION] block, and prints one package
#   name per line (strips inline comments and blank lines).
#
#   Usage:
#     mapfile -t dnf_pkgs < <(parse_packages "dnf" "${REPO_DIR}/packages.conf")
#
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

    # Skip blank lines and full-line comments
    [[ -z "${line}" || "${line}" == \#* ]] && continue

    # Section header detection: [section-name]
    if [[ "${line}" =~ ^\[([a-zA-Z0-9_-]+)\]$ ]]; then
      local current_section="${BASH_REMATCH[1]}"
      # Enter the requested section; exit any other section
      if [[ "${current_section}" == "${section}" ]]; then
        in_section=1
      else
        in_section=0
      fi
      continue
    fi

    # Inside the right section: strip inline comments, print the package name
    if (( in_section )); then
      local pkg="${line%%#*}"          # everything before the first #
      pkg="${pkg%"${pkg##*[![:space:]]}"}"  # trim trailing whitespace
      [[ -n "${pkg}" ]] && printf '%s\n' "${pkg}"
    fi
  done < "${conf_file}"
}

# ── Idempotent install helpers ─────────────────────────────────────────────────

# is_installed_dnf PACKAGE — returns 0 if already installed
is_installed_dnf() {
  rpm -q "$1" &>/dev/null
}

# is_installed_brew PACKAGE — returns 0 if already installed
is_installed_brew() {
  brew list "$1" &>/dev/null 2>&1
}

# is_installed_flatpak APP_ID — returns 0 if already installed
is_installed_flatpak() {
  flatpak list --app --columns=application 2>/dev/null | grep -qx "$1"
}

# install_dnf_packages — reads [dnf] from packages.conf, skips already-installed
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
  # sudo required for dnf; explained here so it's not a surprise
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

# ── Stage entry point (called by run_stage in setup.sh) ──────────────────────

install_packages() {
  install_dnf_packages
  install_brew_packages
  install_flatpak_packages
}
