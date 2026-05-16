#!/usr/bin/env bash
# lib/docker.sh — Docker CE + WinApps setup (optional stage)
# Sourced by scripts/setup.sh — do not run directly.
#
# Follows the exact winapps-org/winapps install flow:
#   Step 1 (README §1) : Configure a Windows VM — Docker + compose.yaml
#   Step 2 (README §2) : Install dependencies (Fedora section)
#   Step 3 (README §3) : Create ~/.config/winapps/winapps.conf
#   Step 4 (README §4) : Test FreeRDP connection
#   Step 5 (README §5) : Run WinApps installer (setup.sh)
#
# Automated sub-steps run unconditionally (all idempotent).
# Manual gates print instructions, run a test, and return 1 if the test fails.
# setup.sh set -e means return 1 → exits without marking the stage done.
# Re-running with --resume re-enters here; automated steps skip cleanly.

[[ -n "${_DOCKER_LOADED:-}" ]] && return 0
_DOCKER_LOADED=1

_DOCKER_REPO_URL="https://download.docker.com/linux/fedora/docker-ce.repo"
_WINAPPS_REPO="https://github.com/winapps-org/winapps.git"
_WINAPPS_DIR="${HOME}/.config/winapps"          # clone target per README
_WINAPPS_CONF="${_WINAPPS_DIR}/winapps.conf"
_WINAPPS_COMPOSE="${_WINAPPS_DIR}/compose.yaml"

# ── Output helper ─────────────────────────────────────────────────────────────

_manual_step_header() {
  local step="$1" total="$2" title="$3"
  printf '\n'
  printf '%s┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄%s\n' \
    "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '%s  Manual step %s/%s: %s%s\n' \
    "${C_BOLD}${C_YELLOW}" "${step}" "${total}" "${title}" "${C_RESET}"
  printf '%s┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄%s\n' \
    "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '\n'
}

# ── Automated sub-steps ───────────────────────────────────────────────────────

_install_docker() {
  if command -v docker &>/dev/null; then
    ok "Docker already installed ($(docker --version))."
    return 0
  fi
  progress "Adding Docker CE repository…"
  # sudo required: dnf5 config-manager writes to /etc/yum.repos.d/
  sudo dnf5 config-manager addrepo --from-repofile="${_DOCKER_REPO_URL}" \
    || die "Failed to add Docker CE repository."
  progress "Installing Docker CE…"
  # sudo required: dnf5 writes to the system package database
  sudo dnf5 install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin \
    || die "Docker CE installation failed."
  ok "Docker CE installed ($(docker --version))."
}

_add_user_to_docker_group() {
  if id -nG "${USER}" | grep -qw docker; then
    ok "User '${USER}' already in the docker group."
    return 0
  fi
  info "Adding '${USER}' to the docker group…"
  # sudo required: usermod writes to /etc/group
  sudo usermod -aG docker "${USER}" \
    || die "Failed to add '${USER}' to the docker group."
  warn "Docker group change takes effect on next login."
}

_enable_docker_service() {
  if ! systemctl is-enabled --quiet docker 2>/dev/null; then
    progress "Enabling Docker service…"
    # sudo required: systemctl enable writes to /etc/systemd/system/
    sudo systemctl enable docker || die "Failed to enable Docker service."
  fi
  if ! systemctl is-active --quiet docker 2>/dev/null; then
    progress "Starting Docker service…"
    sudo systemctl start docker || die "Failed to start Docker service."
  fi
  ok "Docker service enabled and running."
}

_install_winapps_deps() {
  # Exact dependency list from winapps-org/winapps README — Fedora/RHEL section.
  # dialog    : interactive menus used by the WinApps setup wizard
  # freerdp   : FreeRDP v3 on Fedora 43/44 (provides xfreerdp3)
  # iproute   : 'ip' command for libvirt VM IP auto-detection
  # libnotify : desktop notifications emitted by winapps scripts
  # nmap-ncat : 'nc' command used by winapps for RDP port checks
  local -a deps=(curl dialog freerdp git iproute libnotify nmap-ncat)
  local -a to_install=()
  for pkg in "${deps[@]}"; do
    if rpm -q --whatprovides "${pkg}" &>/dev/null; then
      warn "  [dnf] ${pkg} already installed — skipping."
    else
      to_install+=("${pkg}")
    fi
  done
  if (( ${#to_install[@]} > 0 )); then
    progress "Installing WinApps dependencies: ${to_install[*]}…"
    # sudo required: dnf5 writes to the system package database
    sudo dnf5 install -y "${to_install[@]}" \
      || die "Failed to install WinApps dependencies."
  fi
  ok "WinApps dependencies satisfied."

  # Confirm FreeRDP v3 is available; offer Flatpak fallback if not found.
  if command -v xfreerdp3 &>/dev/null; then
    ok "FreeRDP v3 command: xfreerdp3"
  elif command -v xfreerdp &>/dev/null; then
    ok "FreeRDP command: xfreerdp (verify v3 with: xfreerdp --version)"
  else
    warn "Neither xfreerdp3 nor xfreerdp found."
    info "Install FreeRDP v3 via Flatpak as a fallback:"
    printf '    flatpak install flathub com.freerdp.FreeRDP\n'
    printf '    sudo flatpak override --filesystem=home com.freerdp.FreeRDP\n'
    die "FreeRDP v3 is required. Install it and re-run."
  fi
}

_check_iptables_modules() {
  # Required per docs/docker.md: iptables modules must be loaded for
  # host/VM folder sharing (\\tsclient\home) to work.
  local needs_load=0
  lsmod | grep -q 'ip_tables'  || needs_load=1
  lsmod | grep -q 'iptable_nat' || needs_load=1
  if (( needs_load )); then
    info "Loading iptables kernel modules and persisting across reboots…"
    printf 'ip_tables\niptable_nat\n' \
      | sudo tee /etc/modules-load.d/iptables.conf >/dev/null
    # modprobe may report the module is built-in — that is acceptable.
    sudo modprobe ip_tables   2>/dev/null || true
    sudo modprobe iptable_nat 2>/dev/null || true
  fi
  ok "iptables modules ready (ip_tables + iptable_nat)."
}

_clone_winapps() {
  if [[ -f "${_WINAPPS_COMPOSE}" ]]; then
    ok "WinApps repo already present at ${_WINAPPS_DIR}."
    return 0
  fi
  # If the directory exists without compose.yaml, a previous partial clone
  # left it in a bad state. Back it up before cloning fresh.
  if [[ -d "${_WINAPPS_DIR}" ]]; then
    local bak_dir
    bak_dir="${_WINAPPS_DIR}.bak.$(date +%Y%m%dT%H%M%S)"
    warn "${_WINAPPS_DIR} exists but compose.yaml is missing — backing up to ${bak_dir}"
    mv "${_WINAPPS_DIR}" "${bak_dir}"
  fi
  progress "Cloning winapps-org/winapps to ${_WINAPPS_DIR}…"
  check_battery
  git clone --depth=1 "${_WINAPPS_REPO}" "${_WINAPPS_DIR}" \
    || die "Failed to clone WinApps from ${_WINAPPS_REPO}."
  ok "WinApps cloned to ${_WINAPPS_DIR}."
}

# ── Manual gate 1: Review compose.yaml, then start Windows installation ───────
# README §1 / docs/docker.md: edit compose.yaml → docker compose up → VNC

_gate_install_windows() {
  _manual_step_header 1 4 "Install Windows (Docker + VNC)"

  # Auto-advance: if port 3389 is already reachable, Windows is up.
  if nc -z -w 5 127.0.0.1 3389 2>/dev/null; then
    ok "Port 3389 is open — Windows is already running. Skipping install step."
    return 0
  fi

  # Prompt user to review compose.yaml before first boot.
  # Auto-skip if USERNAME has already been customised from the default.
  local compose_user
  compose_user="$(grep 'USERNAME:' "${_WINAPPS_COMPOSE}" 2>/dev/null \
    | head -1 | sed 's/.*USERNAME:[[:space:]]*//' | tr -d '"' | xargs || true)"
  if [[ "${compose_user}" == "MyWindowsUser" ]] || [[ -z "${compose_user}" ]]; then
    info "Before starting, review ${_WINAPPS_COMPOSE} and set:"
    printf '\n'
    printf '    %-14s  RAM available to Windows (default: 4G)\n'      "RAM_SIZE:"
    printf '    %-14s  CPU cores for Windows   (default: 2)\n'        "CPU_CORES:"
    printf '    %-14s  Windows version          (default: tiny11)\n'   "VERSION:"
    printf '    %-14s  RDP username ← set this now\n'                  "USERNAME:"
    printf '    %-14s  RDP password ← set this now\n'                  "PASSWORD:"
    printf '\n'
    warn "Set USERNAME and PASSWORD now — they cannot be changed after Windows installs."
    printf '    micro %s\n\n' "${_WINAPPS_COMPOSE}"
    prompt_yes_no "Have you reviewed/edited compose.yaml and are ready to install Windows?" \
      || { info "Re-run setup.sh --resume after editing compose.yaml."; return 1; }
  else
    ok "compose.yaml has custom USERNAME='${compose_user}' — skipping review prompt."
  fi

  # Start the Windows container (docs/docker.md: docker compose up).
  info "Starting Windows Docker container…"
  docker compose --file "${_WINAPPS_COMPOSE}" up -d \
    || die "Failed to start Windows container."
  ok "Windows container started."

  printf '\n'
  printf '%s  ══════════════════════════════════════════════════════%s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s  Windows is now installing.                           %s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s                                                        %s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s    1. Open http://127.0.0.1:8006 in your browser      %s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s    2. Wait for the Windows setup wizard (~15-30 min)   %s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s    3. Once at the Windows desktop, enable RDP:         %s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s       Settings → System → Remote Desktop → Enable      %s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s    4. Return here and run:                             %s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s       bash %s/scripts/setup.sh --resume%s\n' \
    "${C_BOLD}${C_CYAN}" "${REPO_DIR}" "${C_RESET}"
  printf '%s  ══════════════════════════════════════════════════════%s\n' \
    "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '\n'

  # Test: RDP port 3389 open = Windows is up and accessible.
  info "Checking RDP port 3389 (open = Windows ready)…"
  if nc -z -w 5 127.0.0.1 3389 2>/dev/null; then
    ok "Port 3389 is open — Windows is up and RDP is accessible."
  else
    warn "Port 3389 is not yet reachable — Windows is still installing."
    info "Run 'bash ${REPO_DIR}/scripts/setup.sh --resume' once Windows is fully set up."
    return 1
  fi
}

# ── Manual gate 2: Create and validate winapps.conf ───────────────────────────
# README §3: create ~/.config/winapps/winapps.conf

_gate_create_conf() {
  _manual_step_header 2 4 "Create ~/.config/winapps/winapps.conf"

  if [[ ! -f "${_WINAPPS_CONF}" ]]; then
    info "Scaffolding ${_WINAPPS_CONF} with defaults…"
    # Read USERNAME from compose.yaml to pre-populate RDP_USER.
    local compose_user compose_pass
    compose_user="$(grep 'USERNAME:' "${_WINAPPS_COMPOSE}" 2>/dev/null \
      | head -1 | sed 's/.*USERNAME:[[:space:]]*//' | tr -d '"' | xargs || true)"
    compose_pass="$(grep 'PASSWORD:' "${_WINAPPS_COMPOSE}" 2>/dev/null \
      | head -1 | sed 's/.*PASSWORD:[[:space:]]*//' | tr -d '"' | xargs || true)"
    compose_user="${compose_user:-MyWindowsUser}"
    compose_pass="${compose_pass:-MyWindowsPassword}"

    # Values pre-filled from compose.yaml; user must verify and save.
    # SC2016 is not applicable: heredoc does not contain single-quoted shell expansions.
    cat > "${_WINAPPS_CONF}" << EOF
# WinApps configuration — generated by obsidian setup
# Full reference: https://github.com/winapps-org/winapps/blob/main/README.md

RDP_USER="${compose_user}"
RDP_PASS="${compose_pass}"
RDP_IP="127.0.0.1"
WAFLAVOR="docker"
RDP_SCALE="100"
RDP_FLAGS="/cert:tofu /sound /microphone +home-drive"
DEBUG="true"
EOF
    # Restrict permissions: winapps.conf contains the Windows password.
    chmod 600 "${_WINAPPS_CONF}"
    ok "Config scaffolded at ${_WINAPPS_CONF} (chmod 600)."
    info "Verify the credentials match what you set in compose.yaml:"
    printf '    micro %s\n\n' "${_WINAPPS_CONF}"
  else
    ok "${_WINAPPS_CONF} already exists."
  fi

  # Test: RDP_USER and RDP_PASS must not be the static placeholders.
  local rdp_user rdp_pass
  rdp_user="$(grep '^RDP_USER=' "${_WINAPPS_CONF}" \
    | head -1 | cut -d= -f2 | tr -d '"' | xargs || true)"
  rdp_pass="$(grep '^RDP_PASS=' "${_WINAPPS_CONF}" \
    | head -1 | cut -d= -f2 | tr -d '"' | xargs || true)"

  if [[ "${rdp_user}" == "MyWindowsUser" ]] || [[ -z "${rdp_user}" ]]; then
    warn "RDP_USER is still the placeholder value — edit ${_WINAPPS_CONF}:"
    printf '    micro %s\n' "${_WINAPPS_CONF}"
    printf '  Then run: bash %s/scripts/setup.sh --resume\n\n' "${REPO_DIR}"
    return 1
  fi
  if [[ "${rdp_pass}" == "MyWindowsPassword" ]] || [[ -z "${rdp_pass}" ]]; then
    warn "RDP_PASS is still the placeholder value — edit ${_WINAPPS_CONF}:"
    printf '    micro %s\n' "${_WINAPPS_CONF}"
    printf '  Then run: bash %s/scripts/setup.sh --resume\n\n' "${REPO_DIR}"
    return 1
  fi

  ok "winapps.conf validated (RDP_USER='${rdp_user}', non-placeholder password set)."
}

# ── Manual gate 3: Test FreeRDP connection ────────────────────────────────────
# README §4: xfreerdp3 /u:... /p:... /v:127.0.0.1 /cert:tofu

_gate_test_freerdp() {
  _manual_step_header 3 4 "Test FreeRDP connection (README §4)"

  local freerdp_cmd
  if command -v xfreerdp3 &>/dev/null; then
    freerdp_cmd="xfreerdp3"
  elif command -v xfreerdp &>/dev/null; then
    freerdp_cmd="xfreerdp"
  else
    die "No FreeRDP command found. Install freerdp and re-run."
  fi

  local rdp_user rdp_pass
  rdp_user="$(grep '^RDP_USER=' "${_WINAPPS_CONF}" \
    | head -1 | cut -d= -f2 | tr -d '"' | xargs || true)"
  rdp_pass="$(grep '^RDP_PASS=' "${_WINAPPS_CONF}" \
    | head -1 | cut -d= -f2 | tr -d '"' | xargs || true)"

  info "Run the following command in a separate terminal:"
  printf '\n'
  printf '    %s /u:"%s" /p:"%s" /v:127.0.0.1 /cert:tofu\n' \
    "${freerdp_cmd}" "${rdp_user}" "${rdp_pass}"
  printf '\n'
  printf '  Expected result: a Windows desktop opens in a FreeRDP window.\n'
  printf '  If prompted to accept a certificate, choose to accept permanently.\n'
  printf '  Disconnect from the session before answering below.\n'
  printf '\n'
  info "If the connection fails, common fixes:"
  printf '  1. Windows still booting — wait 60 seconds and retry.\n'
  printf '  2. Stale FreeRDP certificate:\n'
  printf '       rm ~/.config/freerdp/server/127.0.0.1_3389.pem\n'
  printf '  3. Credentials mismatch — verify RDP_USER/RDP_PASS vs compose.yaml.\n'
  printf '  4. RDP not enabled in Windows:\n'
  printf '       Settings → System → Remote Desktop → Enable\n'
  printf '\n'

  prompt_yes_no "Did the Windows desktop appear in the FreeRDP window?" || {
    info "Fix the issue above, then run: bash ${REPO_DIR}/scripts/setup.sh --resume"
    return 1
  }

  ok "FreeRDP connection test passed."
}

# ── Manual gate 4: Run WinApps installer ─────────────────────────────────────
# README §5: bash <(curl .../setup.sh)

_gate_run_installer() {
  _manual_step_header 4 4 "Run WinApps installer (README §5)"

  if command -v winapps &>/dev/null; then
    ok "WinApps already installed — skipping installer."
    return 0
  fi

  info "Launching WinApps interactive installer from ${_WINAPPS_DIR}/setup.sh…"
  info "Follow the on-screen prompts:"
  printf '  Q1: Install or uninstall?        → Install\n'
  printf '  Q2: Current user or system?      → Current User (recommended)\n'
  printf '  Q3: Auto or manual app install?  → your choice\n'
  printf '\n'

  # Run installer from the already-cloned repo — no extra network download.
  bash "${_WINAPPS_DIR}/setup.sh" \
    || die "WinApps installer exited with an error."

  # Test: winapps command must be reachable after install.
  if ! command -v winapps &>/dev/null; then
    # The installer places winapps in ~/.local/bin — check there explicitly.
    if [[ -x "${HOME}/.local/bin/winapps" ]]; then
      warn "winapps is at ~/.local/bin/winapps but not in PATH."
      warn "Add ~/.local/bin to PATH, then run: bash ${REPO_DIR}/scripts/setup.sh --resume"
    else
      warn "winapps command not found after install — check installer output above."
    fi
    return 1
  fi

  ok "WinApps installed successfully."
}

# ── Public entry point ────────────────────────────────────────────────────────

setup_docker() {
  # Fast path: full install already present — nothing to do.
  if command -v winapps &>/dev/null; then
    ok "WinApps already installed — Docker stage complete."
    return 0
  fi

  info "Setting up Docker CE and WinApps…"

  # ── Automated sub-steps (all idempotent, safe to re-run on resume) ────────
  _install_docker
  _add_user_to_docker_group
  _enable_docker_service
  _install_winapps_deps
  _check_iptables_modules
  _clone_winapps

  # ── Manual gated steps ────────────────────────────────────────────────────
  # Each gate returns 1 if action is needed. setup.sh set -e then exits
  # without marking the docker stage done — --resume re-enters here.
  _gate_install_windows          || return 1
  _gate_create_conf              || return 1
  _gate_test_freerdp             || return 1
  _gate_run_installer            || return 1

  ok "Docker + WinApps stage complete."
  warn "Log out and back in if you were just added to the docker group."
}
