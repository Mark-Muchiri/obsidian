#!/usr/bin/env bash
# lib/docker.sh — Docker CE + Winapps setup (optional stage)
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_DOCKER_LOADED:-}" ]] && return 0
_DOCKER_LOADED=1

_DOCKER_REPO_URL="https://download.docker.com/linux/fedora/docker-ce.repo"
_WINAPPS_REPO="https://github.com/winapps-org/winapps.git"
_WINAPPS_DIR="${HOME}/.local/share/winapps"

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
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    || die "Docker CE installation failed."

  ok "Docker CE installed ($(docker --version))."
}

_add_user_to_docker_group() {
  if id -nG "${USER}" | grep -qw docker; then
    ok "User '${USER}' is already in the docker group."
    return 0
  fi
  info "Adding '${USER}' to the docker group…"
  # sudo required: usermod writes to /etc/group
  sudo usermod -aG docker "${USER}" \
    || die "Failed to add '${USER}' to the docker group."
  warn "Group change takes effect on next login — log out and back in before running docker without sudo."
}

_enable_docker_service() {
  if systemctl is-enabled --quiet docker 2>/dev/null; then
    ok "Docker service already enabled."
  else
    progress "Enabling Docker service…"
    # sudo required: systemctl enable writes to /etc/systemd/system/
    sudo systemctl enable docker || die "Failed to enable Docker service."
    ok "Docker service enabled."
  fi

  if systemctl is-active --quiet docker 2>/dev/null; then
    ok "Docker service already running."
  else
    progress "Starting Docker service…"
    # sudo required: systemctl start requires elevated privileges
    sudo systemctl start docker || die "Failed to start Docker service."
    ok "Docker service started."
  fi
}

_install_winapps_prerequisites() {
  # freerdp provides the RDP client Winapps drives; curl and git are build deps.
  local -a prereqs=(freerdp curl git)
  local -a to_install=()

  for pkg in "${prereqs[@]}"; do
    if rpm -q "${pkg}" &>/dev/null; then
      warn "  [dnf] ${pkg} already installed — skipping."
    else
      to_install+=("${pkg}")
    fi
  done

  if (( ${#to_install[@]} > 0 )); then
    progress "Installing Winapps prerequisites: ${to_install[*]}…"
    # sudo required: dnf5 writes to the system package database
    sudo dnf5 install -y "${to_install[@]}" \
      || die "Failed to install Winapps prerequisites."
  fi

  ok "Winapps prerequisites satisfied."
}

_install_winapps() {
  if [[ -d "${_WINAPPS_DIR}" ]]; then
    ok "Winapps already cloned at ${_WINAPPS_DIR}."
  else
    progress "Cloning Winapps…"
    check_battery
    git clone --depth=1 "${_WINAPPS_REPO}" "${_WINAPPS_DIR}" \
      || die "Failed to clone Winapps from ${_WINAPPS_REPO}."
    ok "Winapps cloned."
  fi

  local installer="${_WINAPPS_DIR}/installer.sh"
  if [[ ! -f "${installer}" ]]; then
    die "Winapps installer not found at ${installer}."
  fi

  progress "Running Winapps installer…"
  bash "${installer}" || die "Winapps installation failed."
  ok "Winapps installed."
}

setup_docker() {
  info "Setting up Docker and Winapps…"
  _install_docker
  _add_user_to_docker_group
  _enable_docker_service
  _install_winapps_prerequisites
  _install_winapps
  ok "Docker stage complete."
  warn "Log out and back in for docker group membership to take effect."
}
