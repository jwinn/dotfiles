# shellcheck shell=sh

# WARNING: this will not be run for non-login, non-interactive shells.

# Also, you must run ../common/env, to get $ENV.
# shellcheck source=../common/env
. "${XDG_CONFIG_HOME:-${HOME}/.config}"/shell/common/env.sh
