#!/bin/sh -e -u

BIN_DIR="${HOME}/.local/bin"
CHEZMOI_URL="get.chezmoi.io"
DOTFILES_REPO="https://codeberg.org/jwinn/dotfiles.git"
# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
SCRIPT_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

has_command() {
  command -v "${1}" 1>/dev/null 2>&1
}

verify() {
  if ! has_command git; then
    printf "%s\n" "Error: unable to locate git in: ${PATH}"
    return 1
  fi

  if ! has_command curl && ! has_command wget; then
    printf "%s\n" "Error: curl nor wget found in: ${PATH}"
    return 1
  fi

  return 0
}

install_chezmoi() {
  install_script=

  if ! has_command chezmoi \
    && [ ! -x "${HOME}/bin/chezmoi" ] \
    && [ ! -x "${HOME}/.local/bin/chezmoi" ]; then

    printf "%s\n" "Installing chezmoi to: ${BIN_DIR}"
    if has_command curl; then
      install_script="$(curl -fsSL ${CHEZMOI_URL})"
    elif has_command wget; then
      install_script="$(wget -qO- ${CHEZMOI_URL})"
    else
      printf "%s\n" "Error: curl nor wget found in: ${PATH}"
      return 1
    fi
    sh -c "${install_script}" -- -b "${BIN_DIR}"

    unset -v install_script
    printf "%s\n" "Successfully installed chezmoi to: ${BIN_DIR}"
  fi

  if ! has_command chezmoi; then
    if [ -x "${HOME}/bin/chezmoi" ]; then
      PATH="${HOME}/bin:${PATH}"
    elif [ -x "${BIN_DIR}/chezmoi" ]; then
      PATH="${BIN_DIR}:${PATH}"
    else
      printf "%s\n" "Error: unable to find chezmoi in: ${PATH}"
      return 1
    fi
  fi

  # TODO: make this more robust and resilient
  printf "%s\n" "Initializing dotfiles from chezmoi: ${DOTFILES_REPO}"
  if [ -z "${CHEZMOI_ONESHOT}" ]; then
    chezmoi init --apply --verbose "${DOTFILES_REPO}"
  else
    chezmoi init --one-shot "${DOTFILES_REPO}"
  fi

  return 0
}

main() {
  verify || exit $?
  install_chezmoi || exit $?
}

# call main
main
