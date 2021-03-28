# shellcheck shell=sh

# https://www.freedesktop.org XDG ENV variable declarations
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"${HOME}/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"${HOME}/.local/share"}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-"/etc/xdg"}
export XDG_DATA_DIRS=${XDG_DATA_DIRS:-"/usr/local/share/:/usr/share/"}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-""}

# System env "normalization"
# set HOSTNAME, if not set
[ -z "${HOSTNAME-}" ] && export HOSTNAME=$(uname -n)
# set USER, if not set
[ -z "${USER-}" ] && export USER=$(whoami)
# set OSTYPE, if not set
[ -z "${OSTYPE-}" ] && export OSTYPE="$(uname -s)$(uname -r)"
# set OS_ARCH, if not set
[ -z "${OS_ARCH-}" ] && export OS_ARCH="$(uname -m)"
# set OS_NAME, if not set
case "${OS_NAME:-$(uname -s)}" in
  CYGWIN*)
    export IS_WINDOWS=1
    export OS_NAME="windows"
    ;;
  Darwin*)
    export IS_MACOS=1
    export OS_NAME="macos"

    export OS_VERSION="$(sw_vers -productVersion)"
    os_versions=( $(echo $OS_VERSION | tr '.' ' ') )
    # os_versions=( ${OS_VERSION//./ } )
    # as bash array are 0-based and zsh are 1-based, normalize
    i=0
    for v in "${os_versions[@]}"; do
      [ $i -eq 0 ] && export OS_VERSION_MAJOR=${v}
      [ $i -eq 1 ] && export OS_VERSION_MINOR=${v}
      [ $i -eq 2 ] && export OS_VERSION_PATCH=${v}
      i=$((i + 1))
    done
    unset -v i
    unset -v os_versions
    export OS_VERSION_BUILD="$(sw_vers -buildVersion)"
    export OS_VERSION_FULL="${OS_VERSION}+${OS_VERSION_BUILD}"

    if [ -z "${SDKROOT-}" ]; then
      export SDKROOT="$(xcrun --show-sdk-path)"
    fi

    if [ -z "${MACOSX_DEPLOYMENT_TARGET-}" ]; then
      export MACOSX_DEPLOYMENT_TARGET="${OS_VERSION_MAJOR}.${OS_VERSION_MINOR}"
    fi
    ;;
  Linux*)
    export IS_LINUX=1
    export OS_NAME="linux"
    ;;
  MINGW*)
    export IS_WINDOWS=1
    export OS_NAME="windows"
    ;;
esac

export SHELL_NAME="${SHELL##*/}"

export FZF_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && \
  printf %s "${HOME}/.fzf" || \
  printf %s "${XDG_CONFIG_HOME}/fzf")"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

export JENV_ROOT="$([ -z "${XDG_CONFIG_HOME-}" ] && \
  printf %s "${HOME}/.jenv" || \
  printf %s "${XDG_CONFIG_HOME}/jenv")"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && \
  printf %s "${HOME}/.nvm" || \
  printf %s "${XDG_CONFIG_HOME}/nvm")"

export PYENV_ROOT="$([ -z "${XDG_CONFIG_HOME-}" ] && \
  printf %s "${HOME}/.pyenv" || \
  printf %s "${XDG_CONFIG_HOME}/pyenv")"

# We need to set $ENV so that if you use shell X as your login shell,
# and then start "sh" as a non-login interactive shell the startup scripts
# will correctly run
export ENV="${XDG_CONFIG_HOME}"/shell/sh/interactive.sh

# We also need to set BASH_ENV, which is run for *non-interactive* shells
# (unlike $ENV, which is for interactive shells)
export BASH_ENV="${XDG_CONFIG_HOME}"/shell/bash/env.bash

# shellcheck source=./env_functions
if [ -s "${XDG_CONFIG_HOME}/shell/common/env_functions.sh" ]; then
  . "${XDG_CONFIG_HOME}"/shell/common/env_functions.sh
fi

# umask 0077
# umask 0027

# allow for local overrides
if [ -s "${XDG_CONFIG_HOME}/shell/common/env_local.sh" ]; then
  ssource "${XDG_CONFIG_HOME}"/shell/common/env_local.sh
fi
