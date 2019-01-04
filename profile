# check if mac OS(X)
[ "$(uname -s)" = "Darwin" ] && os_darwin=1

# Functions
resolve_link() {
  if [ "$(command -v readlink || true)" ]; then
    [ $os_darwin ] && resolved=$(readlink "$1") 
    [ ! $os_darwin ] && resolved=$(readlink -f "$1") 
  elif [ "$(command -v realpath || true)" ]; then
    resolved=$(realpath "$1")
  else
    return 1
  fi
  printf %s "${resolved}"
}

string_contains() {
  contains=$(printf %s "$1" | grep -m 1 -o "$2" | head -1)
  [ -n "${contains}" ] && return 0 || return 1
}

path_contains() {
  string_contains $PATH $1
}
path_prepend() {
  path_contains $1 && export PATH=$PATH || export PATH="$1:${PATH}"
}
path_append() {
  path_contains $1 && export PATH=$PATH || export PATH="${PATH}:$1"
}

current_git_status() {
  if [ -n "$(__git_ps1)" ]; then
    gitdf=$(git status -s | wc -l | tr -d "[:blank:]" 2>/dev/null)
    gitb=$(__git_ps1 "%s")
    if [ "${gitdf}" -eq 0 ]; then
      printf "%s%s%s%s " "${clr_rst}" "${clr_ok}" "${gitb}" "${clr_rst}"
    else
      printf "%s%s%s-%s%s " \
        "${clr_rst}" "${clr_err}" "$gitb" "$gitdf" "${clr_rst}"
    fi
  fi
}

# local sbin added to PATH
path_has_local_sbin=$(path_contains "/usr/local/sbin")
[ -z "${path_has_local_sbin}" ] && [ -d "/usr/local/sbin" ] && \
  path_prepend "/usr/local/sbin"

# FreeDesktop XDG ENV variable declarations
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"${HOME}/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"${HOME}/.local/share"}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-"/etc/xdg"}
export XDG_DATA_DIRS=${XDG_DATA_DIRS:-"/usr/local/share/:/usr/share/"}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-""}

# homebrew
if [ -d "${HOME}/.brew" ]; then
  brew_home="${HOME}/.brew"
  [ -L "${brew_home}" ] && brew_home=$(resolve_link "${brew_home}")
  has_brew="${brew_home}/bin/brew"

  # tap the core, if it doesn't exist
  [ ! -d "${brew_home}/Library/Taps/homebrew/homebrew-core" ] && \
  #brew_tap=$(brew tap | awk '/homebrew/{f=1} f{print; if (/}/) exit}' || false)
  #[ -z "${brew_tap}" ] && brew tap homebrew/core
    brew tap homebrew/core
else
  has_brew="$(command -v brew || true)"
fi

if [ "${has_brew}" ]; then
  brew_bin=$(dirname -- "${has_brew}")
  path_prepend "${brew_bin}"

  brew_home="$(brew --prefix)"

  brew_share="${brew_home}/share"
  string_contains $XDG_DATA_DIRS $brew_share || \
    export XDG_DATA_DIRS="${brew_share}/:${XDG_DATA_DIRS}"
fi

# command/executable locations/existence
has_asdf=$(command -v asdf || true)
has_bash=$(printf %s "${SHELL}" | grep bash)
has_git=$(command -v git || true)
has_gpg=$(command -v gpg2 || true)
has_java_home=$(command -v /usr/libexec/java_home || true)
has_less=$(command -v less || true)
has_node=$(command -v node || true)
has_nvim=$(command -v nvim || true)
has_nvm=$(command -v nvm || true)
has_sshfs=$(command -v sshfs || true)
has_svn=$(command -v svn || true)
has_tput=$(command -v tput || true)
has_vim=$(command -v vim || true)

case "$TERM" in
  *256*) term_colors=${term_colors:-256} ;;
  *) term_colors=${term_colors:-8}
esac
[ "${has_tput}" ] && term_colors=$(tput colors)

# try to have certain programs respect/use XDG, instead of dot files/folders
[ "${has_gpg}" ] && export GNUPHOME="${XDG_CONFIG_HOME}/gnupg"
if [ "${has_less}" ]; then
  export LESSHISTFILE="${XDG_CONFIG_HOME}/less/history"
  export LESSKEY="${XDG_CONFIG_HOME}/less/keys"
fi
[ "${has_svn}" ] && export SUBVERSION_HOME="${XDG_CONFIG_HOME}/subversion"
if [ "${has_vim}" ]; then
  export MYVIMRC="${XDG_CONFIG_HOME}/vim/vimrc"
  export VIMDOTDIR="${XDG_CONFIG_HOME}/vim"
  export VIMINIT="source ${MYVIMRC}"
  #export VIMINIT="let $MYVIMRC=\"${XDG_CONFIG_HOME}/vim/vimrc\" | source ${MYVIMRC}"
fi

# sshfs
if [ "${has_sshfs}" ]; then
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

# Aliases
alias ls="ls -G"
alias ll="ls -la"
# use vim for vi, if available
#[ "${has_vim}" ] && alias vi=vim
#[ "${has_nvim}" ] && alias vi=nvim
[ -x "/usr/local/sbin/mtr" ] && alias mtr="PATH=/usr/local/sbin:$PATH sudo mtr"

# git prompt/completion
if [ "${has_git}" ]; then
  git_version=$(git --version | sed -e 's/git version \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')

  if [ -f "/usr/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    # shellcheck disable=SC1090
    . "/usr/doc/git-${git_version}/contrib/completion/git-prompt.sh"
  elif [ -f "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    # shellcheck disable=SC1090
    . "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh"
  fi

  # git bash completion
  if [ "${has_bash}" ]; then
    if [ -f "/usr/doc/git-${git_version}/contrib/completion/git-completion.bash" ]; then
      # shellcheck disable=SC1090
      . "/usr/doc/git-${git_version}/contrib/completion/git-completion.bash"
    elif [ -f "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.bash" ]; then
      # shellcheck disable=SC1090
      . "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.bash"
    fi
  fi

  if [ "${has_brew}" ]; then
    if [ -e "${brew_home}/etc/bash_completion.d/git-prompt.sh" ]; then
      has_git_prompt=1
      # shellcheck disable=SC1090
      . "${brew_home}/etc/bash_completion.d/git-prompt.sh"
    fi
    # git bash completion
    # shellcheck disable=SC1090
    [ "${has_bash}" ] && [ -f "${brew_home}/etc/bash_completion" ] && \
      . "${brew_home}/etc/bash_completion"
  fi
fi

# Load RVM into a shell session *as a function*
# shellcheck disable=SC1090
[ -s "${HOME}/.rvm/scripts/rvm" ] && . "${HOME}/.rvm/scripts/rvm"

# rbenv config
[ "$(command -v rbenv || true)" ] && eval "$(rbenv init -)"
[ -d "${HOME}/.sm" ] && \
  export PATH="${PATH}:${HOME}/.sm/bin:${HOME}/.sm/pkg/active/bin:${HOME}/.sm/pkg/active/sbin"

if [ "${has_node}" ]; then
  node_prefix=$(command -v node | sed 's#^\(.*\)/bin/node$#\1#')
  path_has_npm=$(path_contains "/npm/bin")

  [ "${path_has_npm}" ] && [ -d "${node_prefix}/share/npm/bin" ] && \
    path_prepend "${node_prefix}/share/npm/bin"

  path_prepend "./node_modules/.bin"
fi

#asdf
[ "${has_asdf}" ] && [ -f "/usr/local/opt/asdf/asdf.sh" ] && \
  source /usr/local/opt/asdf/asdf.sh

# nvm
if [ "${has_nvm}" -o \( -n "${has_brew}" -a "$(brew ls --versions nvm) > /dev/null" \) ]; then
  export NVM_DIR=${NVM_DIR:-${XDG_CONFIG_HOME}/nvm}
  [ ! -d $NVM_DIR ] && mkdir -p $NVM_DIR
  . "/usr/local/opt/nvm/nvm.sh"
  #[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"  # This loads nvm
  # shellcheck disable=SC1090
  [ "${has_bash}" ] && [ -r "${NVM_DIR}/bash_completion" ] && \
    . "${NVM_DIR}/bash_completion"
fi

# fzf
[ "${has_bash}" ] && [ -f "${HOME}/.fzf.bash" ] && source "${HOME}/.fzf.bash"

# JAVA
# OSX java
if [ "${has_java_home}" ] && [ -x "${has_java_home}" ]; then
  should_install_java=$($has_java_home 2>&1 | grep -i "no java runtime")
  if [ ! "${JAVA_HOME}" ] && [ -z "${should_install_java}" ]; then
    JAVA_HOME=$($has_java_home) && export JAVA_HOME
    jdk="$(${has_java_home})"
    jdk7="$(${has_java_home} -v 7 2>/dev/null)"
    jdk8="$(${has_java_home} -v 8 2>/dev/null)"
    jdk9="$(${has_java_home} -v 9 2>/dev/null)"
    # shellcheck disable=SC2139
    alias resetjdk="export JAVA_HOME=${jdk}"
    # shellcheck disable=SC2139
    [ -n "${jdk7}" ] && alias setjdk7="export JAVA_HOME=${jdk7}"
    # shellcheck disable=SC2139
    [ -n "${jdk8}" ] && alias setjdk8="export JAVA_HOME=${jdk8}"
    # shellcheck disable=SC2139
    [ -n "${jdk9}" ] && alias setjdk9="export JAVA_HOME=${jdk9}"
  fi
fi

# IRC Config
export IRCNICK=leviticus
export IRCALTNICK=lev
export IRCUSER=jon
#export IRCHOST=devnull.org
export IRCNAME="* I'm still too lame to read BitchX.doc *"
export IRCSERVER="us.undernet.org eu.undernet.org"
#export IRCPORT=6667
#export IRCUMODE="+iw"
export IRCFINGER="That tickles\
  "

#
# COLORS
#

# tput ref
#
# Action                 Parameters
# --------------------   ----------------
# Set background color   tput setab color
# Set foreground color   tput setaf color
# Set blink mode         tput blink
# Set bold mode	         tput bold
# Set half-bright mode   tput dim
# Set underline mode     tput smul
# Exit underline mode    tput rmul
# Reverse mode           tput rev
# Set standout mode      tput smso
# Exit standout mode     tput rmso
# Reset all attributes   tput sgr0
#
# Color     Code
# -------   ----
# Black     0
# Red       1
# Green     2
# Yellow    3
# Blu       4
# Magenta   5
# Cyan      6
# White     7

if [ "${has_tput}" ]; then
  #clr_bld=$(tput bold)
  #clr_dim=$(tput dim)
  clr_rst=$(tput sgr0)
  #clr_ulb=$(tput smul)
  #clr_ule=$(tput rmul)

  if [ "${term_colors}" -ge 256 ]; then
    clr_time=$(tput setaf 243)
    clr_user=$(tput setaf 172)
    clr_host=$(tput setaf 202)
    clr_pwd=$(tput setaf 216)
    clr_ok=$(tput setaf 40)
    clr_err=$(tput setaf 160)
    #clr_uk=$(tput setaf 226)
  else
    clr_time=$(tput bold; tput setaf 0)
    clr_user=$(tput setaf 5)
    clr_host=$(tput setaf 6)
    clr_pwd=$(tput setaf 4)
    clr_ok=$(tput setaf 2)
    clr_err=$(tput setaf 1)
    #clr_uk=$(tput setaf 3)
  fi
fi

# PS1
PS1="\[${clr_time}\]\t\[${clr_rst}\] "
[ $has_git_prompt ] && PS1="${PS1}\$(current_git_status)"
PS1="${PS1}\[${clr_user}\]\u\[${clr_rst}\]@\[${clr_host}\]\h"
PS1="${PS1}\[${clr_rst}\]:\[${clr_pwd}\]\w"
export PS1="${PS1}\[${clr_rst}\]\n\$ "

# base16 shell
BASE16_SHELL="${XDG_CONFIG_HOME}/base16-shell/"
[ -n "$PS1" ] && [ -s ${BASE16_SHELL}/profile_helper.sh ] && \
  eval "$(${BASE16_SHELL}/profile_helper.sh)"

# shellcheck disable=1090
[ "$has_bash" ] && \
  [ -e "${HOME}/.iterm2_shell_integration.bash" ] && \
  . "${HOME}/.iterm2_shell_integration.bash"
