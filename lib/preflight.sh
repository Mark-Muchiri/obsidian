#!/usr/bin/env bash
# lib/preflight.sh — Pre-flight checks for Obsidian dotfiles setup
# Sourced by scripts/setup.sh — do not run directly.
#
# Verifies the environment is safe and ready before any changes are made:
#   1. Running on Fedora 43+
#   2. Not running as root
#   3. Internet connectivity
#   4. Git presence + GitHub SSH authentication (optional, user-prompted)

# Guard against double-sourcing
[[ -n "${_PREFLIGHT_LOADED:-}" ]] && return 0
_PREFLIGHT_LOADED=1

# ── 1. OS check ───────────────────────────────────────────────────────────────

_check_fedora_version() {
  # /etc/os-release is the canonical source on all modern Linux distros.
  # We source it into a subshell to avoid polluting the current environment
  # with variables like NAME, VERSION_ID etc.
  local os_id version_id
  os_id="$(     grep '^ID='         /etc/os-release | cut -d= -f2 | tr -d '"' )"
  version_id="$( grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"' )"

  if [[ "${os_id}" != "fedora" ]]; then
    die "This script targets Fedora only. Detected OS: '${os_id}'."
  fi

  # VERSION_ID is a plain integer on Fedora ("43", "44", …)
  if [[ ! "${version_id}" =~ ^[0-9]+$ ]] || (( version_id < 43 )); then
    die "Fedora 43+ required. Detected version: ${version_id}."
  fi

  ok "OS check passed — Fedora ${version_id}."
}

# ── 2. Root check ─────────────────────────────────────────────────────────────

_check_not_root() {
  # EUID 0 means root. Running as root breaks home-directory assumptions
  # (e.g. ~ resolves to /root, not the real user's home) and is unnecessary
  # since we call sudo explicitly for the steps that need it.
  if (( EUID == 0 )); then
    die "Do not run this script as root. Run as your normal user — sudo is used internally where needed."
  fi
  ok "User check passed — running as '${USER}' (uid ${EUID})."
}

# ── 3. Internet check ─────────────────────────────────────────────────────────

_check_internet() {
  info "Checking internet connectivity…"
  # Ping Cloudflare's DNS (1.1.1.1) — fast, reliable, no hostname resolution
  # dependency. Two packets, 3-second deadline.
  if ! ping -c 2 -W 3 1.1.1.1 &>/dev/null; then
    die "No internet connection detected. Please connect and re-run."
  fi
  ok "Internet connectivity confirmed."
}

# ── 4. GitHub / SSH setup (optional) ─────────────────────────────────────────

_ensure_git_installed() {
  if ! command -v git &>/dev/null; then
    info "git not found — installing via dnf5…"
    # sudo required: dnf5 writes to system package database
    sudo dnf5 install -y git || die "Failed to install git."
    ok "git installed."
  else
    ok "git already installed ($(git --version))."
  fi
}

_configure_git_identity() {
  local git_user git_email

  git_user="$(git config --global user.name  2>/dev/null || true)"
  git_email="$(git config --global user.email 2>/dev/null || true)"

  if [[ -z "${git_user}" ]]; then
    printf '%s  ?  GitHub username (for git config): %s' "${C_BOLD}" "${C_RESET}"
    read -r git_user
    [[ -z "${git_user}" ]] && die "Git username cannot be empty."
    git config --global user.name "${git_user}"
  else
    info "Git user already set: ${git_user}"
  fi

  if [[ -z "${git_email}" ]]; then
    printf '%s  ?  GitHub email (for git config): %s' "${C_BOLD}" "${C_RESET}"
    read -r git_email
    [[ -z "${git_email}" ]] && die "Git email cannot be empty."
    git config --global user.email "${git_email}"
  else
    info "Git email already set: ${git_email}"
  fi

  ok "Git identity: ${git_user} <${git_email}>."
}

_ensure_ssh_key() {
  local key_path="${HOME}/.ssh/id_ed25519"
  local pub_path="${key_path}.pub"

  if [[ -f "${key_path}" && -f "${pub_path}" ]]; then
    ok "SSH key already exists at ${key_path}."
    return 0
  fi

  info "No SSH key found at ${key_path}. Generating one…"

  local git_email
  git_email="$(git config --global user.email 2>/dev/null || true)"
  [[ -z "${git_email}" ]] && die "Git email not set — run _configure_git_identity first."

  ssh-keygen -t ed25519 -C "${git_email}" -f "${key_path}" -N "" \
    || die "ssh-keygen failed."

  ok "SSH key generated."
  printf '\n'
  printf '%s  ══════════════════════════════════════════════════════%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '%s  Add the following public key to GitHub before continuing%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '%s  Settings → SSH and GPG keys → New SSH key            %s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '%s  ══════════════════════════════════════════════════════%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '\n'
  cat "${pub_path}"
  printf '\n'

  prompt_yes_no "Have you added the key to GitHub?" \
    || die "Please add your SSH key to GitHub, then re-run."
}

_test_github_ssh() {
  info "Testing SSH connection to GitHub…"
  # ssh -T exits with code 1 on success (GitHub's documented behaviour)
  # and code 255 on a genuine connection failure.
  # We capture stderr to check the greeting message directly.
  local ssh_output
  ssh_output="$(ssh -T -o StrictHostKeyChecking=accept-new \
                       -o ConnectTimeout=10 \
                       git@github.com 2>&1 || true)"

  if printf '%s' "${ssh_output}" | grep -q "successfully authenticated"; then
    ok "GitHub SSH authentication successful."
  else
    die "GitHub SSH test failed. Output was:\n  ${ssh_output}\nCheck that your public key is added to GitHub."
  fi
}

_setup_github() {
  _ensure_git_installed
  _configure_git_identity
  _ensure_ssh_key
  _test_github_ssh
}

# ── Stage entry point ─────────────────────────────────────────────────────────

preflight_checks() {
  _check_fedora_version
  _check_not_root
  _check_internet

  if prompt_yes_no "Set up GitHub backup (SSH)?"; then
    _setup_github
  else
    # Still need git identity for local commits even without GitHub
    _ensure_git_installed
    _configure_git_identity
    warn "GitHub backup skipped. You can set it up later by re-running setup.sh."
  fi

  ok "Pre-flight complete — all checks passed."
}
