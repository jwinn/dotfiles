# shellcheck shell=sh
# shellcheck disable=SC2181

# load the generic functions, if not already loaded
if [ -z "$(command -v ssource || true)" ]; then
  # shellcheck source=./functions
  . "${XDG_CONFIG_HOME}"/shell/common/env_functions.sh
fi
if [ -z "(command -v str_contains || true)" ]; then
  # shellcheck source=./functions
  ssource "${XDG_CONFIG_HOME}"/shell/common/functions.sh
fi

# TODO: normalize using XDG dirs, instead of HOME

# put your aliases here
alias ls="ls -G"
alias ll="ls -la"
# use vim for vi, if available
#[ "$(command -v vim || true)" ] && alias vi=vim
#[ "$(command -v nvim || true)" ] && alias vi=nvim
[ -x "/usr/local/sbin/mtr" ] && \
  alias mtr='PATH=/usr/local/sbin:${PATH} sudo mtr'

# if in a terminal
if [ -t 0 ]; then
  # other users shouldn't be able to message by default
  #mesg n

  if [ -z "${_PS_LANG-}" ]; then
    # shellcheck source=./prompt
    ssource "${XDG_CONFIG_HOME}"/shell/common/prompt.sh
  fi
fi

# homebrew
# TODO: support homebrew on linux
# [ -z "${HOMEBREW_PREFIX-}" ] && export HOMEBREW_PREFIX=$(brew --prefix)
if [ $IS_MACOS -eq 1 ]; then
  if [ -d "${HOME}/.brew" ]; then
    brew_home="${HOME}/.brew"
    [ -L "${brew_home}" ] && brew_home=$(resolve_link "${brew_home}")
    has_brew="${brew_home}/bin/brew"

    # tap the core, if it doesn't exist
    [ ! -d "${brew_home}/Library/Taps/homebrew/homebrew-core" ] && \
    #brew_tap=$(brew tap | awk '/homebrew/{f=1} f{print; if (/}/) exit}' || false)
    #[ -z "${brew_tap}" ] && brew tap homebrew/core
      brew tap homebrew/core

    unset -v brew_home
  else
    [ -d "/opt/homebrew/bin" ] && path_prepend "/opt/homebrew/bin"
    has_brew="$(command -v brew || true)"
  fi

  if [ -n "${has_brew}" ]; then
    # per updated post-install
    echo "eval $($has_brew shellenv)"

    path_prepend "$(dirname -- ${has_brew})"
    HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-$($has_brew --prefix)}

    path_prepend "${HOMEBREW_PREFIX}/share/" XDG_DATA_DIRS
  fi

  unset -v has_brew
fi

# sshfs
if [ -n "$(command -v sshfs || true)" ]; then
  # Remote Mount (sshfs)
  # creates mount folder and mounts the remote filesystem
  rmount() {
    host="${1%%:*}:"
    [ "${1%:}" = "${host%%:*}" ] && folder="" || folder="${1##*:}"
    if [ "$2" ]; then
      mname="$2"
    else
      mname="${folder##*/}"
      [ "${mname}" = "" ] && mname="${host%%:*}"
    fi
    if grep -q -i "host ${host%%:*}" "${HOME}/.ssh/config"; then
      mkdir -p "${HOME}/_mounts/g/${mname}" > /dev/null
      sshfs "${host}${folder}" "${HOME}/_mounts/g/${mname}" \
        -oauto_cache,reconnect,defer_permissions,negative_vncache,volname="${mname}",noappledouble && \
        printf "mounted %s/_mounts/g/%s" "${HOME}" "${mname}"
    else
      printf "No entry found for %s" "${host%%:*}"
      return 1
    fi
  }

  # Remote Umount, unmounts and deletes local folder
  # (experimental, watch your step)
  rumount() {
    if [ "$1" = "-a" ]; then
      find . -maxdepth 1 -name "${HOME}/_mounts/g" | \
        while read -r dir;
        do
          mount | grep -q "_mounts/g/${dir}" && \
            umount "${HOME}/_mounts/g/${dir}"
          [ "$(ls "${HOME}/_mounts/g/${dir}")" ] || \
            rm -rf "${HOME}/_mounts/g/${dir}"
        done
    else
      mount | grep -q "_mounts/g/$1" && umount "${HOME}/_mounts/g/$1"
      [ "$(ls "${HOME}/_mounts/g/$1")" ] || rm -rf "${HOME}/_mounts/g/$1"
    fi
  }
fi

# git prompt/completion
if [ "$(command -v git || true)" ]; then
  git_version=$(git --version | sed -e 's/git version \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')

  if [ -s "/usr/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/doc/git-${git_version}/contrib/completion/git-prompt.sh"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh"
  elif [ $IS_MACOS -eq 1 ] && [ -s "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh" ]; then
    # shellcheck disable=SC1091
    ssource "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
  fi

  # git shell completion
  if [ -s "/usr/doc/git-${git_version}/contrib/completion/git-completion.${SHELL}" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/doc/git-${git_version}/contrib/completion/git-completion.${SHELL}"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL}" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL}"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL}" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL}"
  fi

  if [ -n "$(command -v brew || true)" ]; then
    if [ -s "$(brew --prefix)/etc/${SHELL}_completion.d/git-prompt.sh" ]; then
      # shellcheck disable=SC1090
      ssource "$(brew --prefix)/etc/${SHELL}_completion.d/git-prompt.sh"
    fi
    # git bash completion
    # shellcheck disable=SC1090
    [ -s "$(brew --prefix)/etc/${SHELL}_completion" ] && \
      ssource "$(brew --prefix)/etc/${SHELL}_completion"
  fi

  unset -v git_version
fi

[ -d "${HOME}/.cargo/bin" ] && path_prepend "${HOME}/.cargo/bin"

# Load RVM into a shell session *as a function*
# shellcheck disable=SC1090
[ -s "${HOME}/.rvm/scripts/rvm" ] && ssource "${HOME}/.rvm/scripts/rvm"
# rbenv config
[ "$(command -v rbenv || true)" ] && eval "$(rbenv init -)"
[ -d "${HOME}/.sm" ] && \
  PATH="${PATH}:${HOME}/.sm/bin:${HOME}/.sm/pkg/active/bin:${HOME}/.sm/pkg/active/sbin"

# nvm
NVM_DIR=${NVM_DIR:-${XDG_CONFIG_HOME}/nvm}
if [ -s "${NVM_DIR}/nvm.sh" ]; then
  # This loads nvm
  # shellcheck disable=SC1090
  ssource "${NVM_DIR}/nvm.sh"

  # This loads nvm bash_completion
  [ -n "${BASH_VERSION}" ] && \
    [ -s "${NVM_DIR}/bash_completion" ] && \
    ssource "${NVM_DIR}/bash_completion"

  alias nvm_update="nvm install node --reinstall-packages-from=node"
fi

# pyenv
PYENV_ROOT=${PYENV_ROOT:-${XDG_CONFIG_HOME}/pyenv}
if [ -x "${PYENV_ROOT}/bin/pyenv" ]; then
  [ -z "$(command -v pyenv || true)" ] && \
    path_prepend "${PYENV_ROOT}/bin"

  eval "$(pyenv init -)"
  [ "$(command -v pyenv-virtualenv || true)" ] && \
    eval "$(pyenv virtualenv-init -)"

  if [ $IS_MACOS -eq 1 ] && [ "${OS_ARCH}" = "arm64" ]; then
    # issues related to Big Sur and M1
    alias pyenv="LDFLAGS=\"-L${SDKROOT}/usr/lib\" CFLAGS=\"-I${SDKROOT}/usr/include\" pyenv"

    alias pyenv_install="CFLAGS=\"-I${HOMEBREW_PREFIX}/openssl/include
    -I${HOMEBREW_PREFIX}/bzip2/include -I${HOMEBREW_PREFIX}/readline/include
    -I${SDKROOT}/usr/include\" LDFLAGS=\"-L${HOMEBREW_PREFIX}/openssl/lib
    -L${HOMEBREW_PREFIX}/readline/lib -L${HOMEBREW_PREFIX}/zlib/lib
    -L${HOMEBREW_PREFIX}/bzip2/lib -L${SDKROOT}/usr/lib\" pyenv install --patch $1 < <(curl -sSL https://github.com/python/cpython/commit/8ea6353.patch\?full_index\=1)"

    # make pyenv play nice with homebrew and nvm
    # https://github.com/pyenv/pyenv/issues/106
    alias brew="env PATH=\"${PATH//${PYENV_ROOT}\/shims:/}\" brew"
    alias nvm="PATH=\"${PATH//${PYENV_ROOT}\/shims:/}\" nvm"
  fi
fi

# node
if [ "$(command -v node || true)" ]; then
  node_prefix=$(command -v node | sed 's#^\(.*\)/bin/node$#\1#')

  if [ -d "${node_prefix}/share/npm/bin" ]; then
    path_prepend "${node_prefix}/share/npm/bin"
  fi

  path_prepend "./node_modules/.bin"

  unset -v node_prefix
fi

# fzf
[ -n "${BASH_VERSION}" ] && \
  [ -s "${HOME}/.fzf.bash" ] && \
  ssource "${HOME}/.fzf.bash"

# Android Dev env
if [ -z "${ANDROID_HOME-}" ]; then
  if [ $IS_MACOS -eq 1 ]; then
    export ANDROID_HOME=${HOME}/Library/Android/sdk
  else
    export ANDROID_HOME=${HOME}/Android/sdk
  fi
  path_append ${ANDROID_HOME}/emulator
  path_append ${ANDROID_HOME}/tools
  path_append ${ANDROID_HOME}/tools/bin
  path_append ${ANDROID_HOME}/platform-tools
fi

# JAVA
# OSX java
# if [ $IS_MACOS -eq 1 ] && [ -x "$(command -v /usr/libexec/java_home || true)" ]; then
#   has_java_home=$(command -v /usr/libexec/java_home || true)
#   no_java_runtime=$($has_java_home 2>&1 | grep -i "no java runtime")
#   if [ -z "${JAVA_HOME-}" ] && [ -z "${no_java_runtime}" ]; then
#     export JAVA_HOME=$($has_java_home) && JAVA_HOME
#     jdk="$(${has_java_home})"
#     # shellcheck disable=SC2139
#     alias resetjdk="JAVA_HOME=${jdk}"

#     i=7
#     end=13
#     while [ $i -le $end ]; do
#       export JAVA_${i}_HOME="$(${has_java_home} -v ${i} 2>/dev/null)"
#       # shellcheck disable=SC2139
#       [ -n "$(eval JAVA_HOME=\$JAVA_${i}_HOME)" ] && \
#         alias setjdk${i}="JAVA_HOME=${JAVA_HOME}"
#     done
#   fi
# fi
