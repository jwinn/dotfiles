#!/bin/sh -e

cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

# ensure env and functions exist
. "${cwd}/dotfiles/shell/common/env.sh"
. "${cwd}/dotfiles/shell/common/env_functions.sh"
ssource "${cwd}/dotfiles/shell/common/functions.sh"

# parse command
case "${1}" in
  i|install) command=install ;;
  r|rm|remove|uninstall) command=uninstall ;;
  *)
    printf "Usage: %s i|install|r|rm|remove|uninstall\n" "${script}"
    exit 1
    ;;
esac

# check potential--based on choice--requirements
if [ -z "$(command -v git)" ]; then
  q_prompt "Git is missing, do you want to continue" || exit 1
fi
if [ -z "$(command -v curl)" ]; then
  q_prompt "Curl is missing, do you want to continue" || exit 1
fi

# run the command if exists and non-0 sized
file="${cwd}/${OS_NAME}/${command}.sh"
if [ -s "${file}" ]; then
  # set package vars
  PKG_INSTALL="install"
  PKG_UNINSTALL="uninstall"
  PKG_UPDATE="update"
  PKG_UPGRADE="upgrade"

  if [ "${IS_MACOS}" -eq 1 ]; then
    PKG_NAME="Homebrew"
    PKG_CMD="brew"
  elif [ "${IS_LINUX}" -eq 1]; then
    # TODO: add more linux package managers
    if [ "$(command -v apt || true)" ]; then
      PKG_NAME="Aptitude"
      PKG_CMD="apt"
    elif [ "$(command -v apt-get || true)" ]; then
      PKG_NAME="Aptitude"
      PKG_CMD="apt-get"
    elif [ "$(command -v pacman || true)" ]; then
      PKG_NAME="Pacman"
      PKG_CMD="pacman -S"
    fi
  fi

  if [ -z "$(command -v ${PKG_CMD} || true)" ]; then
    printf "%s not found in %s" "${PKG_CMD}" "${PATH}"
    exit 1
  fi

  q_prompt "Do you want to update ${PKG_NAME}" "y" \
    && ${PKG_CMD} ${PKG_UPDATE}
  q_prompt "Do you want to upgrade ${PKG_NAME}" \
    && ${PKG_CMD} ${PKG_UPGRADE}

  ssource "${file}"
  display_banner "Please run: exec \$SHELL" \
    "- or - restart the terminal/shell"
else
  printf "Unsupported OS \"%s\"\n" "${OS_NAME}"
  exit 1
fi
