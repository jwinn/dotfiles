# shellcheck shell=bash

# WARNING: this will $BASH_ENV to get a correct startup sequence
# shellcheck source=../common/env
. "${XDG_CONFIG_HOME:-${HOME}/.config}"/shell/common/env.sh
