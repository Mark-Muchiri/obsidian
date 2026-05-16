#!/usr/bin/env bash
# scripts/setup.sh — Obsidian dotfiles orchestrator
# Usage: bash scripts/setup.sh [--resume]
#
# Sources lib/ modules in the canonical fresh-install order.
# Safe to re-run; completed stages are skipped via state/.setup_state.

set -euo pipefail

# ── Resolve paths ────────────────────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"
STATE_FILE="${REPO_DIR}/state/.setup_state"

# ── Load utilities (must come first — every other module uses these) ──────────
# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"

# ── State helpers ─────────────────────────────────────────────────────────────
mkdir -p "${REPO_DIR}/state"

stage_done() {
  # Returns 0 (true) if $1 stage has already completed.
  grep -qxF "$1" "${STATE_FILE}" 2>/dev/null
}

mark_done() {
  # Records $1 as completed so a re-run skips it.
  echo "$1" >> "${STATE_FILE}"
}

run_stage() {
  local name="$1"
  local fn="$2"
  if stage_done "${name}"; then
    warn "Skipping '${name}' — already completed."
    return 0
  fi
  progress_header "${name}"   # defined in utils.sh — prints a banner + spinner
  "${fn}"                     # call the function
  mark_done "${name}"
  ok "'${name}' complete."
}

# ── Source all modules ────────────────────────────────────────────────────────
# Order matters: utils is already loaded; source the rest now so their
# functions are available to run_stage below.
for module in preflight shell pkgmgr packages editors wezterm docker; do
  # shellcheck disable=SC1090
  . "${LIB_DIR}/${module}.sh"
done

# ── Orchestration ─────────────────────────────────────────────────────────────
#
# Stages run in strict order. After 'shell', the user MUST restart their
# terminal — the script detects this via STATE_FILE and resumes cleanly.

main() {
  print_banner   # big ASCII art welcome, defined in utils.sh

  # ── Stage 1: Pre-flight ──────────────────────────────────────────────────
  run_stage "preflight"    preflight_checks
  # preflight_checks is defined in lib/preflight.sh

  # ── Stage 2: Shell & terminal ────────────────────────────────────────────
  run_stage "shell"        setup_shell
  # After this stage, the shell changed to zsh. We must stop and ask the
  # user to restart the terminal, then re-run the script to continue.
  if ! stage_done "shell_restart_done"; then
    warn "Shell changed to zsh. Please restart your terminal, then re-run:"
    printf '  bash %s --resume\n\n' "$0"
    mark_done "shell_restart_done"
    exit 0   # graceful exit — not an error
  fi

  # ── Stage 3: Package managers ────────────────────────────────────────────
  run_stage "pkgmgr"       setup_package_managers

  # ── Stage 4: Essential CLI packages ─────────────────────────────────────
  # Package lists are read from packages.conf — not hardcoded here.
  run_stage "packages"     install_packages

  # ── Stage 5: Editors & GNOME extensions ─────────────────────────────────
  run_stage "editors"      setup_editors

  # ── Stage 6: Wezterm ────────────────────────────────────────────────────
  run_stage "wezterm"      setup_wezterm

  # ── Stage 7: Docker & Winapps (optional) ────────────────────────────────
  if prompt_yes_no "Install Docker and Winapps? (lowest priority — skip if unsure)"; then
    run_stage "docker"     setup_docker
  fi

  # ── Stage 8: Finalise ───────────────────────────────────────────────────
  run_stage "finalise"     finalise_setup
  # finalise_setup: adds sync-dots/restore-dots aliases, prints summary

  print_success_summary
}

main "$@"