#!/bin/sh

set -eu

has_command() {
  command -v "${1}" 1>/dev/null 2>&1
}

safe_source() {
  if [ -r "${1}" ]; then
    . "${1}"
  fi
}

install_rustup() {
  if [ -z "${RUSTUP_HOME}" ]; then
    printf "%s\n" "Error: RUSTUP_HOME env not set, unable to proceed"
    return 1
  fi

  if ! has_command rustup; then
    if ! has_command curl; then
      printf "%s\n" "Required curl command not found in: $PATH"
      return 1
    fi

    printf "%s\n" "Installing rustup to: ${RUSTUP_HOME}"

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh || return $?

    printf "%s\n" "Successfully installed rustup to: ${RUSTUP_HOME}"

    safe_source "${CARGO_HOME}/env"
  else
    printf "%s\n" "rustup already installed at: ${RUSTUP_HOME}"
  fi

  rustup update
  return $?
}

install_rustup || exit $?
exec "${SHELL}"
