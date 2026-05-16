#!/usr/bin/env bash
# lib/utils.sh — Shared utilities for Obsidian dotfiles scripts
# Sourced by all scripts. Never run directly.
#
# Provides: colours, print helpers (ok/warn/die/progress/progress_header),
#           spinner, battery check, yes/no prompt, print_banner,
#           print_success_summary, symlink helper.

# Guard against double-sourcing
[[ -n "${_UTILS_LOADED:-}" ]] && return 0
_UTILS_LOADED=1

# ── Strict mode (inherited from the sourcing script) ─────────────────────────
# We do NOT set -euo pipefail here because utils.sh is sourced, not executed.
# The sourcing script (setup.sh etc.) sets it. We rely on that.

# ── Colours ───────────────────────────────────────────────────────────────────
# Detect if stdout is a terminal; disable colours if not (e.g. log redirect).
if [[ -t 1 ]]; then
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_GREEN='\033[0;32m'
  C_YELLOW='\033[0;33m'
  C_RED='\033[0;31m'
  C_CYAN='\033[0;36m'
  C_DIM='\033[2m'
else
  C_RESET='' C_BOLD='' C_GREEN='' C_YELLOW='' C_RED='' C_CYAN='' C_DIM=''
fi

# ── Core print helpers ────────────────────────────────────────────────────────

# ok MSG — green success line
ok() {
  printf "${C_GREEN}${C_BOLD}  ✔  %s${C_RESET}\n" "$*"
}

# warn MSG — yellow advisory (non-fatal)
warn() {
  printf "${C_YELLOW}${C_BOLD}  ⚠  %s${C_RESET}\n" "$*" >&2
}

# die MSG — red fatal error, exits 1
die() {
  printf "${C_RED}${C_BOLD}  ✖  ERROR: %s${C_RESET}\n" "$*" >&2
  exit 1
}

# info MSG — cyan informational line
info() {
  printf "${C_CYAN}  →  %s${C_RESET}\n" "$*"
}

# progress MSG — dim in-progress line (no newline, so spinner can follow)
progress() {
  printf "${C_DIM}  …  %s${C_RESET}\n" "$*"
}

# progress_header STAGE_NAME — section banner printed before each stage
progress_header() {
  local name="$1"
  printf '\n'
  printf '%s══════════════════════════════════════════%s\n' "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s  ▶  Stage: %s%s\n'                            "${C_BOLD}${C_CYAN}" "${name}" "${C_RESET}"
  printf '%s══════════════════════════════════════════%s\n' "${C_BOLD}${C_CYAN}" "${C_RESET}"
}

# ── Spinner ───────────────────────────────────────────────────────────────────
# Usage:
#   spinner_start "Doing something long"
#   some_long_command
#   spinner_stop   # call this whether the command succeeded or failed
#
# Runs the spinner in a background subshell; spinner_stop kills it cleanly.
# We store the PID in _SPINNER_PID so nested calls don't interfere.

_SPINNER_PID=''

spinner_start() {
  local msg="${1:-Working…}"
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  # Run spinner in background; it writes to stderr so it doesn't pollute
  # any command substitution capturing stdout.
  (
    local i=0
    while true; do
      printf "\r${C_CYAN}  %s  %s${C_RESET}" "${frames[i]}" "${msg}" >&2
      i=$(( (i + 1) % ${#frames[@]} ))
      sleep 0.1
    done
  ) &
  _SPINNER_PID=$!
  # Ensure the spinner is killed if the script exits unexpectedly
  trap 'spinner_stop' EXIT
}

spinner_stop() {
  if [[ -n "${_SPINNER_PID}" ]]; then
    kill "${_SPINNER_PID}" 2>/dev/null
    wait "${_SPINNER_PID}" 2>/dev/null
    _SPINNER_PID=''
    printf '\r\033[K' >&2   # clear the spinner line
  fi
}

# ── Battery check ─────────────────────────────────────────────────────────────
# Warns before long operations if the system is on battery below 50%.
# Safe to call anywhere; does nothing if no battery is detected.
check_battery() {
  local battery_path
   battery_path="$(find /sys/class/power_supply -name 'capacity' -path '*/BAT*' 2>/dev/null | head -1)"
  [[ -z "${battery_path}" ]] && return 0   # desktop — no battery, skip

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
# prompt_yes_no MSG — returns 0 for yes, 1 for no
# Defaults to Yes on Enter.
prompt_yes_no() {
  local msg="$1"
  local reply
  while true; do
    printf "${C_BOLD}  ?  %s [Y/n]: ${C_RESET}" "${msg}"
    read -r reply
    reply="${reply:-Y}"   # default to Y on bare Enter
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
#   - If DEST already is a symlink to SRC, skips (idempotent).
#   - If DEST exists (file or wrong symlink), backs it up with a timestamp
#     before replacing it.
#   - Creates parent directories as needed.
#
# This is the core of restore.sh — every config link goes through here.
safe_symlink() {
  local src="$1"
  local dest="$2"

  # Verify the source exists in the repo
  if [[ ! -e "${src}" ]]; then
    die "safe_symlink: source does not exist: ${src}"
  fi

  # Already correctly linked — nothing to do
  if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
    warn "  Already linked: ${dest} → ${src}"
    return 0
  fi

  # Parent directory must exist
  mkdir -p "$(dirname "${dest}")"

  # Backup any existing file/directory/wrong-symlink
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
  printf '                                                    \n'
  printf '   ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗  \n'
  printf '  ██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗ \n'
  printf '  ██║   ██║██████╔╝███████╗██║██║  ██║██║███████║ \n'
  printf '  ██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║ \n'
  printf '  ╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║ \n'
  printf '   ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝\n'
  printf '            Dotfiles — Fedora Workstation           \n'
  printf '                                                    \n'
  printf '%s' "${C_RESET}"
  printf '%s  Repository : %s%s\n' "${C_DIM}" "${REPO_DIR}" "${C_RESET}"
  printf '%s  User       : %s%s\n' "${C_DIM}" "${USER}"     "${C_RESET}"
  printf '%s  Date       : %s%s\n' "${C_DIM}" "$(date '+%Y-%m-%d %H:%M')" "${C_RESET}"
  printf '\n'
}

print_success_summary() {
  printf '\n'
  printf '%s╔══════════════════════════════════════════╗%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '%s║       Setup complete! What'"'"'s next:       ║%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '%s╚══════════════════════════════════════════╝%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '  %sSync changes to GitHub:%s\n'              "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/sync.sh\n\n'              "${REPO_DIR}"
  printf '  %sRestore configs on another machine:%s\n'  "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/restore.sh\n\n'           "${REPO_DIR}"
  printf '  %sRe-run setup (resumes from last stage):%s\n' "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/setup.sh --resume\n\n'    "${REPO_DIR}"
}
