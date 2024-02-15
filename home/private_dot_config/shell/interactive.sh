export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:"

# put your aliases here
[ -n "${OS_IS_MACOS}" ] && alias ls="ls -G"
[ -n "${OS_IS_LINUX}" ] && alias ls="ls --color=auto"
alias ll="ls -la"
[ -n "${OS_IS_MACOS}" ] || [ -n "${OS_IS_LINUX}" ] \
  && alias grep="grep --color=auto"

# allow scp/ssh without a known_hosts entry
alias scpx="scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
alias sshx="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# in order to support a system with vim XDG-config'd and neovim
# env vars need reset for neovim
if [ -d "${XDG_CONFIG_HOME}/nvim" ]; then
  alias nvim="env -u MYVIMRC -u VIMINIT -u VIM nvim"
fi

[ -x "/usr/local/sbin/mtr" ] \
  && alias mtr="PATH=/usr/local/sbin:${PATH} sudo mtr"

# homebrew
if [ -n "${OS_IS_MACOS}" ]; then
  if [ "$(get_os_arch)" = "aarch64" ]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
  #elif [ -d "${XDG_CONFIG_HOME}/.brew" ]; then
  #  export HOMEBREW_PREFIX="${XDG_CONFIG_HOME}/.brew"
  #elif [ -d "${HOME}/.brew" ]; then
  #  export HOMEBREW_PREFIX="${HOME}/.brew"
  else  
    export HOMEBREW_PREFIX="/usr/local"
    export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
    export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
    path_prepend "${HOMEBREW_PREFIX}/sbin"
    path_prepend "${HOMEBREW_PREFIX}/bin"
    path_prepend "${HOMEBREW_PREFIX}/share/man" MANPATH
    path_prepend "${HOMEBREW_PREFIX}/share/info" INFOPATH
  fi

  eval $("${HOMEBREW_PREFIX}/bin/brew" shellenv)
  path_prepend "${HOMEBREW_PREFIX}/share/" XDG_DATA_DIRS

  if has_command git; then
    if [ -s "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion.d/git-prompt.sh" ]; then
      safe_source "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion.d/git-prompt.sh"
    fi
    # git bash completion
    [ -s "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion" ] \
      && safe_source "${HOMEBREW_PREFIX}/etc/${SHELL_NAME}_completion"
  fi
fi

# git prompt/completion
# TODO: improve this to reduce subshells
if has_command git; then
  git_version=$(git --version | sed -e 's/git version \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')

  if [ -s "/usr/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    safe_source "/usr/doc/git-${git_version}/contrib/completion/git-prompt.sh"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    safe_source "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh"
  elif [ -n "${OS_IS_MACOS}" ] && [ -s "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh" ]; then
    safe_source "/Library/Developer/CommandLineTools/usr/share/git-core/git-prompt.sh"
  fi

  # git shell completion
  if [ -s "/usr/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}" ]; then
    safe_source "/usr/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}" ]; then
    safe_source "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}"
  elif [ -s "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}" ]; then
    safe_source "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.${SHELL_NAME}"
  fi

  unset -v git_version
fi

# rust(up)
# TODO: use asdf to manage?
[ -d "${HOME}/.cargo/bin" ] && path_prepend "${HOME}/.cargo/bin"

# fzf
[ -f "${XDG_CONFIG_HOME}/fzf/fzf.${SHELL_NAME}" ] \
  && safe_source "${XDG_CONFIG_HOME}/fzf/fzf.${SHELL_NAME}"
# TODO: move to bash-specific interactive script
[ -n "${BASH_VERSION}" ] \
  && [ -s "${XDG_CONFIG_HOME}/fzf/fzf.bash" ] \
  && safe_source "${XDG_CONFIG_HOME}/fzf/fzf.bash"

# asdf
# TODO: change all folders to XDG-related ones
[ -f "${ASDF_DIR}/asdf.sh" ] && safe_source "${ASDF_DIR}/asdf.sh"
# TODO: move to bash-specific interactive script
[ -n "${BASH_VERSION}" ] \
  && [ -s "${XDG_CONFIG_HOME}/asdf/asdf.bash" ] \
  && safe_source "${XDG_CONFIG_HOME}/asdf/asdf.bash"

# Load RVM into a shell session *as a function*
[ -s "${HOME}/.rvm/scripts/rvm" ] && safe_source "${HOME}/.rvm/scripts/rvm"
# rbenv config
has_command rbenv && eval "$(rbenv init -)"
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
  safe_source "${NVM_DIR}/nvm.sh"

  # This loads nvm bash_completion
  # TODO: move to bash-specific interactive script
  [ -n "${BASH_VERSION}" ] \
    && [ -s "${NVM_DIR}/bash_completion" ] \
    && safe_source "${NVM_DIR}/bash_completion"

  alias nvm_update="nvm install node --reinstall-packages-from=node"
fi

# pyenv
if [ -x "${PYENV_ROOT}/bin/pyenv" ]; then
  ! has_command pyenv && path_prepend "${PYENV_ROOT}/bin"

  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"

  if [ -n "${OS_IS_MACOS}" ] && [ "${OS_ARCH}" = "arm64" ]; then
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
if has_command node; then
  node_prefix=$(command -v node | sed 's#^\(.*\)/bin/node$#\1#')

  if [ -d "${node_prefix}/share/npm/bin" ]; then
    path_prepend "${node_prefix}/share/npm/bin"
  fi

  path_prepend "./node_modules/.bin"

  unset -v node_prefix
fi

# Android Dev env
if [ -z "${ANDROID_HOME-}" ]; then
  if [ -n "${OS_IS_MACOS}" ]; then
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
# if [ -n "${OS_IS_MACOS}" ] && [ -x "$(command -v /usr/libexec/java_home || true)" ]; then
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
if has_command sshfs; then
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

# if in a terminal
if [ -t 0 ]; then
  # other users shouldn't be able to message by default
  #mesg n

  # TODO: check for oh-my-posh, starship, powerlevel10k, et al
  if has_command oh-my-posh \
    && [ "${TERM_PROGRAM}" != "Apple_Terminal" ]; then

    eval "$(oh-my-posh init ${SHELL_NAME})"
    exec "${SHELL_NAME}"
  elif [ -n "${ZSH_VERSION}" ] \
    && [ -r "${XDG_CONFIG_HOME}/powerlevel10k/powerlevel10k.zsh-theme" ]; then

    safe_source "${XDG_CONFIG_HOME}/powerlevel10k/powerlevel10k.zsh-theme"
  else
    # default to personal quais-portable prompt, if no 3rd-party available
    ps_prompt
  fi
fi

safe_source "${XDG_CONFIG_HOME}/shell/interactive.local"

