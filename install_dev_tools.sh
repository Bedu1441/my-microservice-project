#!/usr/bin/env bash
set -euo pipefail

log() { echo -e "\n[INFO] $*"; }
warn() { echo -e "\n[WARN] $*" >&2; }

require_sudo() {
  if [[ "$EUID" -ne 0 ]]; then
    SUDO="sudo"
  else
    SUDO=""
  fi
}

apt_update_once() {
  if [[ "${UPDATED:-0}" -eq 0 ]]; then
    $SUDO apt-get update -y
    UPDATED=1
  fi
}

install_pkg() {
  apt_update_once
  $SUDO apt-get install -y "$1"
}

is_installed() {
  command -v "$1" >/dev/null 2>&1
}

require_sudo
UPDATED=0

echo "Starting DevOps tools installation..."

# Docker
if is_installed docker; then
  echo "Docker already installed"
else
  install_pkg docker.io
  $SUDO systemctl enable --now docker || true
fi

# Docker Compose
if docker compose version >/dev/null 2>&1; then
  echo "Docker Compose already available"
else
  echo "Docker Compose not found."
  echo "If you're using Docker Desktop with WSL, enable WSL integration in Docker Desktop."
fi

# Python
if is_installed python3; then
  echo "Python already installed: $(python3 --version)"
else
  install_pkg python3
fi

# pip
if is_installed pip3; then
  echo "pip already installed"
else
  install_pkg python3-pip
fi

# Django
if python3 -m django --version >/dev/null 2>&1; then
  echo "Django already installed"
else
  sudo apt-get install -y python3-django
fi

echo "All tools installed successfully!"
