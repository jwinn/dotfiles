# shellcheck shell=bash

# We need to do two things here:

# 1. Ensure ./bash/env gets run first
# shellcheck source=./bash/env
. "${XDG_CONFIG_HOME:-${HOME}/.config}"/shell/bash/env

# 2. Prevent it from being run later, since we need to use $BASH_ENV for
# non-login non-interactive shells.
# We don't export it, as we may have a non-login non-interactive shell as
# a child.
BASH_ENV=

# 3. Join the spanish inquisition. ;)
# so much for only two things...

# 4. Run ./bash/login
# shellcheck source=./bash/login
. "${XDG_CONFIG_HOME}"/shell/bash/login

# 5. Run ./bash/interactive if this is an interactive shell.
if [ -n "$PS1" ]; then
  # shellcheck source=./bash/interactive
  . "${XDG_CONFIG_HOME}"/shell/bash/interactive
fi
