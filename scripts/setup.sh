#!/usr/bin/env bash
# scripts/setup.sh — Obsidian dotfiles setup orchestrator
# Usage:
#   bash scripts/setup.sh            # fresh install, runs all stages
#   bash scripts/setup.sh --resume   # skip completed stages, continue from last
#   bash scripts/setup.sh --reset    # clear state and start over (does NOT undo installs)

set -euo pipefail

# ── Resolve paths ─────────────────────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"
STATE_DIR="${REPO_DIR}/state"
STATE_FILE="${STATE_DIR}/.setup_state"

# ── Bootstrap: load utils first (all other modules depend on it) ──────────────
# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"

# ── Source all stage modules ───────────────────────────────────────────────────
# shellcheck source=lib/preflight.sh
. "${LIB_DIR}/preflight.sh"
# shellcheck source=lib/shell.sh
. "${LIB_DIR}/shell.sh"
# shellcheck source=lib/pkgmgr.sh
. "${LIB_DIR}/pkgmgr.sh"
# shellcheck source=lib/packages.sh
. "${LIB_DIR}/packages.sh"
# shellcheck source=lib/editors.sh
. "${LIB_DIR}/editors.sh"
# shellcheck source=lib/wezterm.sh
. "${LIB_DIR}/wezterm.sh"
# shellcheck source=lib/docker.sh
. "${LIB_DIR}/docker.sh"

# ── State helpers ─────────────────────────────────────────────────────────────
mkdir -p "${STATE_DIR}"

# Add state/ to .gitignore so ephemeral progress is never committed
if ! grep -qx 'state/' "${REPO_DIR}/.gitignore" 2>/dev/null; then
  printf 'state/\n' >> "${REPO_DIR}/.gitignore"
fi

stage_done() {
  # Returns 0 (true) if stage $1 is recorded as complete
  grep -qxF "$1" "${STATE_FILE}" 2>/dev/null
}

mark_done() {
  printf '%s\n' "$1" >> "${STATE_FILE}"
}

run_stage() {
  local name="$1"
  local fn="$2"

  if stage_done "${name}"; then
    printf '%s  ↷  Skipping: %s (already complete)%s\n' \
      "${C_DIM}" "${name}" "${C_RESET}"
    return 0
  fi

  progress_header "${name}"
  "${fn}"
  mark_done "${name}"
  ok "'${name}' complete."
}

# ── Argument handling ─────────────────────────────────────────────────────────
handle_args() {
  case "${1:-}" in
    --resume)
      info "Resuming from last completed stage."
      ;;
    --reset)
      warn "Clearing setup state. All stages will re-run."
      warn "This does NOT undo any installations."
      prompt_yes_no "Continue?" || exit 0
      rm -f "${STATE_FILE}"
      info "State cleared."
      ;;
    "")
      # Fresh run — if state file exists from a previous attempt, honour it
      if [[ -f "${STATE_FILE}" ]]; then
        warn "A previous setup run was detected."
        info "Use --resume to continue it, or --reset to start over."
			if prompt_yes_no "Resume previous run?"; then
        : # continue — state file stays, completed stages will be skipped
      elif prompt_yes_no "Reset and start over?"; then
        rm -f "${STATE_FILE}"
      else
        exit 0
      fi      fi
      ;;
    *)
      printf '%s  Usage: setup.sh [--resume | --reset]%s\n' "${C_DIM}" "${C_RESET}" >&2
      die "Unknown argument: ${1}"
      ;;
  esac
}

# ── Shell restart gate ────────────────────────────────────────────────────────
# After setup_shell changes the default shell to zsh, the user must open a
# new terminal for the change to take effect. We record a sentinel in the
# state file and exit cleanly, printing clear instructions.
# On re-run (--resume), the sentinel is already present so we continue past.
check_shell_restart() {
  if stage_done "shell" && ! stage_done "shell_restarted"; then
    printf '\n'
    printf '%s╔══════════════════════════════════════════════════════╗%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  Shell changed to zsh — action required              ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║                                                      ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  1. Close this terminal completely                   ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  2. Open a new terminal                              ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  3. Run: bash scripts/setup.sh --resume              ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s╚══════════════════════════════════════════════════════╝%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '\n'
    mark_done "shell_restarted"
    exit 0
  fi
}

# ── Main orchestration ────────────────────────────────────────────────────────
main() {
  handle_args "${@}"
  print_banner

  # ── Stage 1: Pre-flight ────────────────────────────────────────────────────
  run_stage "preflight"    preflight_checks

  # ── Stage 2: Shell & terminal ──────────────────────────────────────────────
  # Highest priority — shell must be correct before anything else.
  run_stage "shell"        setup_shell
  check_shell_restart

  # ── Stage 3: Package managers ──────────────────────────────────────────────
  run_stage "pkgmgr"       setup_package_managers

  # ── Stage 4: CLI packages (dnf → brew → flatpak) ──────────────────────────
  # Reads package lists from packages.conf — edit that file, not this script.
  run_stage "packages"     install_packages

  # ── Stage 5: Editors & GNOME extensions ───────────────────────────────────
  run_stage "editors"      setup_editors

  # ── Stage 6: Wezterm ──────────────────────────────────────────────────────
  run_stage "wezterm"      setup_wezterm

  # ── Stage 7: Docker & Winapps (optional) ──────────────────────────────────
  # Presented as an explicit opt-in — lowest priority, skip if unsure.
  if ! stage_done "docker"; then
    if prompt_yes_no "Install Docker and Winapps? (optional — skip if unsure)"; then
      run_stage "docker"   setup_docker
    else
      mark_done "docker"   # record skip so --resume doesn't ask again
      info "Docker skipped. Re-run with --reset if you change your mind."
    fi
  fi

  # ── Stage 8: Restore configs (symlink everything into place) ───────────────
  run_stage "restore"      do_link

  # ── Done ──────────────────────────────────────────────────────────────────
  print_success_summary
}

main "$@"
