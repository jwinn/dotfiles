# shellcheck shell=bash

# this file gets run in two cases:
# 1. non-login interactive shell
# 2. remote shell (over ssh or similar)

# #2 happens when you run "ssh user@host bash" explicitly.
# in this case, /etc/bash.bashrc has not been previous executed (unlike #1).
# however, we assume that #2 is a recovery mode, so we don't want to do much.
# (also, my google-fu didn't find a way to distinguish them)

# shellcheck source=./bash/env
. "${XDG_CONFIG_HOME:-${HOME}/.config}"/shell/bash/env.bash

# shellcheck source=./bash/interactive
. "${XDG_CONFIG_HOME}"/shell/bash/interactive.bash

# keeping this here to prevent nvm install adding it
export NVM_DIR="${XDG_CONFIG_HOME}/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
