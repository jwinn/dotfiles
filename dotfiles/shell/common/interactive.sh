# shellcheck shell=sh
# shellcheck disable=SC2181

# load the generic functions, if not already loaded
if [ -z "$(command -v ssource || true)" ]; then
  # shellcheck source=./functions
  . "${XDG_CONFIG_HOME}/shell/common/env_functions.sh"
fi
if [ -z "(command -v str_contains || true)" ]; then
  # shellcheck source=./functions
  ssource "${XDG_CONFIG_HOME}/shell/common/functions.sh"
fi

# TODO: normalize using XDG dirs, instead of HOME

# put your aliases here
[ -n "${IS_MACOS}" ] && alias ls="ls -G"
[ -n "${IS_LINUX}" ] && alias ls="ls --color=auto"
alias ll="ls -la"
[ -n "${IS_MACOS}" ] || [ -n "${IS_LINUX}" ] \
  && alias grep="grep --color=auto"
# in order to support a system with vim XDG-config'd and neovim
# env vars need reset for neovim
if [ -d "${XDG_CONFIG_HOME}/nvim" ]; then
  alias nvim='MYRVIMRC= VIMINIT= VIM= nvim'
fi
[ -x "/usr/local/sbin/mtr" ] \
  && alias mtr='PATH=/usr/local/sbin:${PATH} sudo mtr'

# if in a terminal
if [ -t 0 ]; then
  # other users shouldn't be able to message by default
  #mesg n

  if [ -z "${_PS_LANG-}" ]; then
    # shellcheck source=./prompt
    ssource "${XDG_CONFIG_HOME}/shell/common/prompt.sh"
  fi
fi

# homebrew
if [ -n "${IS_MACOS}" ]; then
  [ "${OS_ARCH}" = "arm64" ] \
    && export HOMEBREW_PREFIX="/opt/homebrew" \
    || export HOMEBREW_PREFIX="/usr/local"
elif [ -d "${XDG_CONFIG_HOME}/.brew" ]; then
  export HOMEBREW_PREFIX="${XDG_CONFIG_HOME}/.brew"
elif [ -d "${HOME}/.brew" ]; then
  export HOMEBREW_PREFIX="${HOME}/.brew"
fi

if [ -n "${HOMEBREW_PREFIX-}" ] && [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
  # per updated post-install
  if [ "${OS_ARCH}" = "arm64" ]; then
    eval $("${HOMEBREW_PREFIX}/bin/brew" shellenv)
  else
    export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
    export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
    path_prepend "${HOMEBREW_PREFIX}/sbin"
    path_prepend "${HOMEBREW_PREFIX}/bin"
    path_prepend "${HOMEBREW_PREFIX}/share/man" MANPATH
    path_prepend "${HOMEBREW_PREFIX}/share/info" INFOPATH
  fi

  path_prepend "${HOMEBREW_PREFIX}/share/" XDG_DATA_DIRS
fi

# git prompt/completion
# TODO: improve this to reduce subshells
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
  elif [ -n "${IS_MACOS}" ] && [ -s "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh" ]; then
    # shellcheck disable=SC1091
    ssource "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
  fi

  # git shell completion
  if [ -s "/usr/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}" ]; then
    # shellcheck disable=SC1090
    ssource "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}"
  fi

  if [ -n "${HOMEBREW_PREFIX}" ]; then
    if [ -s "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion.d/git-prompt.sh" ]; then
      # shellcheck disable=SC1090
      ssource "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion.d/git-prompt.sh"
    fi
    # git bash completion
    # shellcheck disable=SC1090
    [ -s "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion" ] \
      && ssource "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion"
  fi

  unset -v git_version
fi

# rust(up)
# TODO: use asdf to manage?
[ -d "${HOME}/.cargo/bin" ] && path_prepend "${HOME}/.cargo/bin"

# fzf
[ -f "${XDG_CONFIG_HOME}/fzf/fzf.${SHELL_NAME}" ] \
  && source "${XDG_CONFIG_HOME}/fzf/fzf.${SHELL_NAME}"
# TODO: move to bash-specific interactive script
[ -n "${BASH_VERSION}" ] \
  && [ -s "${XDG_CONFIG_HOME}/fzf/fzf.bash" ] \
  && ssource "${XDG_CONFIG_HOME}/fzf/fzf.bash"

# asdf
# TODO: change all folders to XDG-related ones
[ -f "${ASDF_DIR}/asdf.sh" ] && source "${ASDF_DIR}/asdf.sh"
# TODO: move to bash-specific interactive script
[ -n "${BASH_VERSION}" ] \
  && [ -s "${XDG_CONFIG_HOME}/asdf/asdf.bash" ] \
  && ssource "${XDG_CONFIG_HOME}/asdf/asdf.bash"

# Load RVM into a shell session *as a function*
# shellcheck disable=SC1090
[ -s "${HOME}/.rvm/scripts/rvm" ] && ssource "${HOME}/.rvm/scripts/rvm"
# rbenv config
[ "$(command -v rbenv || true)" ] && eval "$(rbenv init -)"
[ -d "${HOME}/.sm" ] \
  && PATH="${PATH}:${HOME}/.sm/bin:${HOME}/.sm/pkg/active/bin:${HOME}/.sm/pkg/active/sbin"

# jenv
if [ -x "${JENV_ROOT}/bin/jenv" ]; then
  path_prepend "${JENV_ROOT}/bin"
  eval "$(jenv init -)"
fi

# nvm
if [ -s "${NVM_DIR}/nvm.sh" ]; then
  # This loads nvm
  # shellcheck disable=SC1090
  ssource "${NVM_DIR}/nvm.sh"

  # This loads nvm bash_completion
  # TODO: move to bash-specific interactive script
  [ -n "${BASH_VERSION}" ] \
    && [ -s "${NVM_DIR}/bash_completion" ] \
    && ssource "${NVM_DIR}/bash_completion"

  alias nvm_update="nvm install node --reinstall-packages-from=node"
fi

# pyenv
if [ -x "${PYENV_ROOT}/bin/pyenv" ] || [ -x "${HOMEBREW_PREFIX}/bin/pyenv" ]; then
  [ -z "$(command -v pyenv || true)" ] \
    && path_prepend "${PYENV_ROOT}/bin"

  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"

  if [ -n "${IS_MACOS}" ] && [ "${OS_ARCH}" = "arm64" ]; then
    # issues related to Big Sur and M1
    alias pyenv="LDFLAGS=\"-L${SDKROOT}/usr/lib\" CFLAGS=\"-I${SDKROOT}/usr/include\" pyenv"

    alias pyenv_install="pyenv install --patch $1 < <(curl -sSL https://github.com/python/cpython/commit/8ea6353.patch)"
    alias pyenv_install_x86="arch -x86_64 pyenv install --patch $1 < <(curl -sSL https://github.com/python/cpython/commit/8ea6353.patch)"

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

# Android Dev env
if [ -z "${ANDROID_HOME-}" ]; then
  if [ -n "${IS_MACOS}" ]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
  else
    export ANDROID_HOME="${HOME}/Android/sdk"
  fi
  path_append "${ANDROID_HOME}/emulator"
  path_append "${ANDROID_HOME}/tools"
  path_append "${ANDROID_HOME}/tools/bin"
  path_append "${ANDROID_HOME}/platform-tools"
fi

# JAVA
# OSX java
# if [ -n "${IS_MACOS}" ] && [ -x "$(command -v /usr/libexec/java_home || true)" ]; then
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
#       [ -n "$(eval JAVA_HOME=\$JAVA_${i}_HOME)" ] \
#         && alias setjdk${i}="JAVA_HOME=${JAVA_HOME}"
#     done
#   fi
# fi

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
        -oauto_cache,reconnect,defer_permissions,negative_vncache,volname="${mname}",noappledouble \
          && printf "mounted %s/_mounts/g/%s" "${HOME}" "${mname}"
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
          mount | grep -q "_mounts/g/${dir}" \
            && umount "${HOME}/_mounts/g/${dir}"
          [ "$(ls "${HOME}/_mounts/g/${dir}")" ] \
            || rm -rf "${HOME}/_mounts/g/${dir}"
        done
    else
      mount | grep -q "_mounts/g/$1" && umount "${HOME}/_mounts/g/$1"
      [ "$(ls "${HOME}/_mounts/g/$1")" ] || rm -rf "${HOME}/_mounts/g/$1"
    fi
  }
fi
