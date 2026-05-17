#!/usr/bin/env bash
# lib/utils.sh — Shared utilities for Obsidian dotfiles scripts
# Sourced by all scripts. Never run directly.

[[ -n "${_UTILS_LOADED:-}" ]] && return 0
_UTILS_LOADED=1

# ── Colours ───────────────────────────────────────────────────────────────────
# $'...' causes bash to interpret \033 as ESC at assignment time.
# Single-quoted '\033[...' prints literally — do not use that form.
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[0;33m'
  C_RED=$'\033[0;31m'
  C_CYAN=$'\033[0;36m'
  C_DIM=$'\033[2m'
else
  C_RESET='' C_BOLD='' C_GREEN='' C_YELLOW='' C_RED='' C_CYAN='' C_DIM=''
fi

# ── Core print helpers ────────────────────────────────────────────────────────

ok() {
  printf '%s%s  ✔  %s%s\n' "${C_GREEN}" "${C_BOLD}" "$*" "${C_RESET}"
}

warn() {
  printf '%s%s  ⚠  %s%s\n' "${C_YELLOW}" "${C_BOLD}" "$*" "${C_RESET}" >&2
}

die() {
  printf '%s%s  ✖  ERROR: %s%s\n' "${C_RED}" "${C_BOLD}" "$*" "${C_RESET}" >&2
  exit 1
}

info() {
  printf '%s  →  %s%s\n' "${C_CYAN}" "$*" "${C_RESET}"
}

progress() {
  printf '%s  …  %s%s\n' "${C_DIM}" "$*" "${C_RESET}"
}

progress_header() {
  local name="$1"
  printf '\n'
  printf '%s══════════════════════════════════════════%s\n' "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s  ▶  Stage: %s%s\n'                            "${C_BOLD}${C_CYAN}" "${name}" "${C_RESET}"
  printf '%s══════════════════════════════════════════%s\n' "${C_BOLD}${C_CYAN}" "${C_RESET}"
}

# ── Spinner ───────────────────────────────────────────────────────────────────

_SPINNER_PID=''

spinner_start() {
  local msg="${1:-Working…}"
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  (
    local i=0
    while true; do
      printf "\r%s  %s  %s%s" "${C_CYAN}" "${frames[i]}" "${msg}" "${C_RESET}" >&2
      i=$(( (i + 1) % ${#frames[@]} ))
      sleep 0.1
    done
  ) &
  _SPINNER_PID=$!
  trap 'spinner_stop' EXIT
}

spinner_stop() {
  if [[ -n "${_SPINNER_PID}" ]]; then
    kill "${_SPINNER_PID}" 2>/dev/null
    wait "${_SPINNER_PID}" 2>/dev/null
    _SPINNER_PID=''
    printf '\r\033[K' >&2
  fi
}

# ── Battery check ─────────────────────────────────────────────────────────────

check_battery() {
  local battery_path
  battery_path="$(find /sys/class/power_supply -name 'capacity' -path '*/BAT*' 2>/dev/null | head -1)"
  [[ -z "${battery_path}" ]] && return 0

  local capacity
  capacity="$(cat "${battery_path}")"

  local status_path="${battery_path%capacity}status"
  local status
  status="$(cat "${status_path}" 2>/dev/null || printf 'Unknown')"

  if [[ "${status}" == "Discharging" && "${capacity}" -lt 50 ]]; then
    warn "Battery at ${capacity}% and discharging."
    warn "This operation may take a while. Consider plugging in before continuing."
    prompt_yes_no "Continue anyway?" || die "Aborted by user."
  fi
}

# ── Yes/No prompt ─────────────────────────────────────────────────────────────

prompt_yes_no() {
  local msg="$1"
  local reply
  while true; do
    printf '%s  ?  %s [Y/n]: %s' "${C_BOLD}" "${msg}" "${C_RESET}"
    read -r reply
    reply="${reply:-Y}"
    case "${reply}" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *)     warn "Please answer y or n." ;;
    esac
  done
}

# ── Symlink helper ────────────────────────────────────────────────────────────
# safe_symlink SRC DEST
#   Creates a symlink at DEST pointing to SRC.
#   - Skips if already correctly linked (idempotent).
#   - Backs up any existing file/symlink with a timestamp before replacing.
#   - Creates parent directories as needed.

safe_symlink() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "${src}" ]]; then
    die "safe_symlink: source does not exist: ${src}"
  fi

  if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
    warn "  Already linked: ${dest} → ${src}"
    return 0
  fi

  mkdir -p "$(dirname "${dest}")"

  if [[ -e "${dest}" || -L "${dest}" ]]; then
    local backup
    backup="${dest}.bak.$(date +%Y%m%dT%H%M%S)"
    info "  Backing up existing ${dest} → ${backup}"
    mv "${dest}" "${backup}"
  fi

  ln -s "${src}" "${dest}"
  ok "  Linked: ${dest} → ${src}"
}

# ── Banner & summary ──────────────────────────────────────────────────────────

print_banner() {
  printf '%s' "${C_BOLD}${C_CYAN}"
  # Fix 1: banner now spells OBSIDIAN (N column added on the right)
  printf '   ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗  ███╗   ██╗\n'
  printf '  ██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗ ████╗  ██║\n'
  printf '  ██║   ██║██████╔╝███████╗██║██║  ██║██║███████║ ██╔██╗ ██║\n'
  printf '  ██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║ ██║╚██╗██║\n'
  printf '  ╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║ ██║ ╚████║\n'
  printf '   ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝\n'
  printf '            Dotfiles — Fedora Workstation                     \n'
  printf '%s' "${C_RESET}"
  printf '%s  Repository : %s%s\n' "${C_DIM}" "${REPO_DIR}" "${C_RESET}"
  printf '%s  User       : %s%s\n' "${C_DIM}" "${USER}"     "${C_RESET}"
  printf '%s  Date       : %s%s\n' "${C_DIM}" "$(date '+%Y-%m-%d %H:%M')" "${C_RESET}"
  printf '\n'
}

print_success_summary() {
  printf '\n'
  printf '%s╔══════════════════════════════════════════╗%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf "%s║       Setup complete! What's next:       ║%s\n" "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '%s╚══════════════════════════════════════════╝%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '  %sSync changes to GitHub:%s\n'                 "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/sync.sh\n\n'                 "${REPO_DIR}"
  printf '  %sRestore configs on another machine:%s\n'     "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/restore.sh\n\n'              "${REPO_DIR}"
  printf '  %sRe-run setup (resumes from last stage):%s\n' "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/setup.sh --resume\n\n'       "${REPO_DIR}"
}
