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
if [ -z "$(command -v git || true)" ]; then
  q_prompt "Git is missing, do you want to continue" || exit 1
fi
if [ -z "$(command -v curl || true)" ]; then
  q_prompt "Curl is missing, do you want to continue" || exit 1
fi

# run the command if exists and non-0 sized
file="${cwd}/${OS_NAME}/${command}.sh"
if [ -s "${file}" ]; then
  ssource "${cwd}/shared/pkg-managers.sh"

  if [ -z "${EUID}" ]; then
    EUID="${EUID:-$(id -u)}"
  fi
  sudo="$(command -v sudo || true)"

  if [ -n "${IS_LINUX}" ] && [ -z "$(command -v ${PKG_CMD} || true)" ]; then
    printf "%s not found in %s" "${PKG_CMD}" "${PATH}"
    exit 1
  elif [ -z "${IS_MACOS}" ] \
    && [ "${EUID}" -gt 0 ] \
    && [ -z "${sudo}" ] \
    && ! q_prompt "Not running as root, and sudo not found, continue?"; then
    exit 1
  fi

  ssource "${file}"
  display_banner "Please run: exec \$SHELL" \
    "- or - restart the terminal/shell"
else
  printf "Unsupported OS \"%s\"\n" "${OS_NAME}"
  exit 1
fi
