#!/bin/sh -e

cwd=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

# ensure env and functions exist
. "${cwd}/dotfiles/shell/common/env.sh"
. "${cwd}/dotfiles/shell/common/env_functions.sh"
ssource "${cwd}/dotfiles/shell/common/functions.sh"

# parse command
case "${1}" in
  i|install) command=install ;;
  r|rm|remove|uninstall) command=uninstall ;;
  *)
    printf "Usage: $(basename -- "${0}") i|install|r|rm|remove|uninstall\n"
    exit 1
    ;;
esac

# run the command if exists and non-0 sized
file="${cwd}/${OS_NAME}/${command}.sh"
if [ -s "${file}" ]; then
  ssource "${file}" "${cwd}"
  display_banner "Please run: exec \$SHELL" \
    "- or - restart the terminal/shell"
else
  printf "Unsupported OS \"${OS_NAME}\"\n"
  exit 1
fi
