#!/bin/sh -e

#cwd=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
cwd=$(cd -- "$(dirname -- "$0")" && pwd -P)

# ensure env and functions exist
if [ -z "$(command -v ssource || true)" ]; then
  . "${cwd}/dotfiles/shell/common/env.sh"
fi
if [ -z "$(command -v link_file || true)" ]; then
  ssource "${cwd}/dotfiles/shell/common/functions.sh"
fi

# parse command
case "${1}" in
  i|install) command=install ;;
  r|rm|remove|uninstall) command=uninstall ;;
  *)
    printf "Usage: $(basename -- "${0}") i|install|r|rm|remove|uninstall\n"
    exit
    ;;
esac

case "${OS_NAME}" in
  macos)
    ssource "${cwd}/${OS_NAME}/${command}.bash"
    ;;

  linux)
    ssource "${cwd}/${OS_NAME}/${command}.sh"
    ;;

  *)
    printf "Unsupported OS \"${OS_NAME}\"\n"
    exit
    ;;
esac
