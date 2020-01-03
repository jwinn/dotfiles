# shellcheck shell=sh

# WARNING: if you delete .bash_profile, this file becomes part of bash's startup
# sequence, which means this file suddenly has to cater for two different
# shells.

# shellcheck source=./sh/env
. "${XDG_CONFIG_HOME:-${HOME}/.config}"/shell/sh/env

# shellcheck source=./sh/login
. "${XDG_CONFIG_HOME}"/shell/sh/login
