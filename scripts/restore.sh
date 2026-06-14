#!/usr/bin/env bash
# scripts/restore.sh — Link dotfiles from the repo into their system locations
# Usage:
#   bash scripts/restore.sh            # create all symlinks
#   bash scripts/restore.sh --check    # verify all symlinks, no changes
#   bash scripts/restore.sh --unlink   # remove symlinks, restore backups

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"

# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"

# ── Config map ────────────────────────────────────────────────────────────────
# Format: ["REPO_SOURCE"]="SYSTEM_DEST"
# To add a new config: add one line here. Nothing else needs changing.
#
# NOTE: configs managed by GUI apps that rewrite files atomically must NOT be
# symlinked — they break the link silently. Those are handled via dconf or
# direct copies in the relevant lib/ module. All entries below are safe.
declare -A CONFIG_MAP=(
  ["configs/zsh/.zshrc"]="${HOME}/.zshrc"
  ["configs/starship/starship.toml"]="${HOME}/.config/starship.toml"
  ["configs/wezterm/wezterm.lua"]="${HOME}/.config/wezterm/wezterm.lua"
  ["configs/micro/settings.json"]="${HOME}/.config/micro/settings.json"
  ["configs/micro/micro/bindings.json"]="${HOME}/.config/micro/bindings.json"
  ["configs/nano/nanorc"]="${HOME}/.config/nano/nanorc"
  ["configs/btop/btop.conf"]="${HOME}/.config/btop/btop.conf"
  ["configs/yazi/yazi.toml"]="${HOME}/.config/yazi/yazi.toml"
  ["configs/nvim"]="${HOME}/.config/nvim"
  ["configs/chrome-flags.conf"]="${HOME}/.config/chrome-flags.conf"
)

do_link() {
  progress_header "Restore — linking configs"
  local src dest
  for rel_src in "${!CONFIG_MAP[@]}"; do
    src="${REPO_DIR}/${rel_src}"
    dest="${CONFIG_MAP[${rel_src}]}"
    safe_symlink "${src}" "${dest}"
  done
  ok "All configs linked."
  info "Run 'exec zsh' to pick up the new .zshrc immediately."
}

do_check() {
  progress_header "Restore — checking symlinks"
  local src dest all_ok=1
  for rel_src in "${!CONFIG_MAP[@]}"; do
    src="${REPO_DIR}/${rel_src}"
    dest="${CONFIG_MAP[${rel_src}]}"
    if [[ ! -e "${src}" ]]; then
      warn "  MISSING source : ${src}"; all_ok=0
    elif [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
      ok "  OK             : ${dest}"
    elif [[ -e "${dest}" && ! -L "${dest}" ]]; then
      warn "  UNMANAGED FILE : ${dest}  (exists but is not a symlink)"; all_ok=0
    elif [[ -L "${dest}" ]]; then
      warn "  BROKEN LINK    : ${dest} → $(readlink "${dest}") (target missing)"; all_ok=0
    else
      warn "  NOT LINKED     : ${dest}  (run restore.sh to create it)"; all_ok=0
    fi
  done
  if (( all_ok )); then
    ok "All symlinks intact."
  else
    warn "Some configs are not correctly linked. Run restore.sh to fix."
    return 1
  fi
}

do_unlink() {
  progress_header "Restore — unlinking configs"
  warn "This will remove all managed symlinks."
  warn "If a backup exists (.bak.*), it will be restored in place."
  prompt_yes_no "Continue?" || { info "Aborted."; exit 0; }

  local dest backup
  for rel_src in "${!CONFIG_MAP[@]}"; do
    dest="${CONFIG_MAP[${rel_src}]}"
    if [[ ! -L "${dest}" ]]; then
      warn "  Not a symlink, skipping: ${dest}"
      continue
    fi
    rm "${dest}"
    backup="$(find "$(dirname "${dest}")" -maxdepth 1 \
                -name "$(basename "${dest}").bak.*" \
                2>/dev/null | sort -r | head -1)"
    if [[ -n "${backup}" ]]; then
      mv "${backup}" "${dest}"
      ok "  Restored backup: ${backup} → ${dest}"
    else
      info "  Removed symlink (no backup found): ${dest}"
    fi
  done
  ok "Unlink complete."
}

main() {
  case "${1:-}" in
    --check)  do_check  ;;
    --unlink) do_unlink ;;
    "")       do_link   ;;
    *)
      printf '%s  Usage: restore.sh [--check | --unlink]%s\n' "${C_DIM}" "${C_RESET}" >&2
      die "Unknown argument: ${1}"
      ;;
  esac
}

# Guard: only run main when executed directly, not when sourced by setup.sh.
# setup.sh sources this file to call do_link as a function via run_stage.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
