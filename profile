# OS determinations
os=${OSTYPE%%[0-9]*}
[ "${os}" = "darwin" ] && os_darwin=1

# Functions
resolve_link() {
  local has_readlink resolved
  has_readlink=$(command -v readlink || true)
  [ $has_readlink && $os_darwin ] && resolved=$(readlink $1) 
  [ $has_readlink && ! $os_darwin ] && resolved=$(readlink -f $1) 
  [ $(command -v realpath || true) ] && resolved=$(realpath $1)
  printf "%s" "${resolved}"
}

path_contains() {
  local contains
  contains=$(printf $PATH | grep -m 1 -o "$1" | head -1)
  printf "%s" "${contains}"
}

path_prepend() {
  local path
  path=$1:${PATH}
  printf "%s" "${path}"
}

path_append() {
  local path
  path=${PATH}:$1
  printf "%s" "${path}"
}

is_var () {
  [ $(declare | grep ${1}\=) ] && printf $1 || return 1
}

is_func () {
  [ $(declare -F $1) ] && printf $1 || return 1
}

is_set () {
  [ $(is_var $1) ] || [ $(is_func $1) ] || [ $(command -v $1) ] && return 0 || return 1
}

current_git_status() {
  if [ -n "$(__git_ps1)" ]; then
    gitdf=$(git status -s | wc -l | tr -d "[:blank:]" 2>/dev/null)
    gitb=$(__git_ps1 "%s")
    if [ $gitdf -eq 0 ]; then
      printf "%s%s%s%s " "${clr_rst}" "${clr_ok}" "${gitb}" "${clr_rst}"
    else
      printf "%s%s%s-%s%s " \
        "${clr_rst}" "${clr_err}" "$gitb" "$gitdf" "${clr_rst}"
    fi
  fi
}

print_tput_colors() {
  color=0
  while [ $color -lt $term_colors ]; do
    tput setaf $color
    printf " %3s " "$color"
    tput sgr0
    [ $((($color + 1) % 16)) == 0 ] && printf "\\n"
    color=$(($color + 1))
  done
}

print_ansi_colors() {
  color=0
  while [ $color -lt $term_colors ]; do
    printf "\e[38;5;%sm %3s \e[0m" "${color}" "${color}"
    [ $((($color + 1) % 16)) == 0 ] && printf "\\n"
    color=$(($color + 1))
  done
}

chrome() {
  if [ $os_darwin ]; then
    open -a "Google Chrome" $@ --args --allow-file-access-from-files
  elif [ $has_google_chrome ]; then
    google-chrome $@ --allow-file-access-from-files
  fi
}

# FreeDesktop XDG ENV variable declarations
export XDG_CACHE_HOME=${XDG_CACHE_HOME:="${HOME}/.cache"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:="${HOME}/.config"}
export XDG_DATA_HOME=${XDG_DATA_HOME:="${HOME}/.local/share"}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:="/etc/xdg"}
export XDG_DATA_DIRS=${XDG_DATA_DIRS:="/usr/local/share/:/usr/share/"}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:=""}

# brew
if [ -d ${HOME}/.brew ]; then
  brew_home=${HOME}/.brew
  [ -L "$brew_home" ] && brew_home=$(resolve_link $brew_home)
  has_brew=${brew_home}/bin/brew
else
  has_brew=$(command -v brew || true)
fi

if [ $has_brew ]; then
  brew_bin=$(dirname -- "${has_brew}")
  [ ! $(path_contains $brew_bin) ] && export PATH=$(path_prepend $brew_bin)

  brew_home=$(brew --prefix)

  # tap the core, if it doesn't exist
  [ ! -d "${brew_home}/Library/Taps/homebrew/homebrew-core" ] && \
    brew tap homebrew/homebrew-core

  [ -n "$(brew ls --versions nvm 2>/dev/null)" ] && \
    has_brew_nvm=$(brew --prefix nvm)
fi

# command/executable locations/existence
has_bash=$(echo $SHELL | grep bash)
has_git=$(command -v git || true)
has_google_chrome=$(command -v google-chrome || true)
has_java=$(command -v java || true)
has_java_home=$(command -v /usr/libexec/java_home || true)
has_less=$(command -v less || true)
has_node=$(command -v node || true)
has_sshfs=$(command -v sshfs || true)
has_tput=$(command -v tput || true)
has_vi=$(command -v vi || true)
has_vim=$(command -v vim || true)

case "$TERM" in
  *256*) term_colors=${term_colors:-256};;
  *) term_colors=${term_colors:-8}
esac
[ $has_tput ] && term_colors=$(tput colors)

# have vim "respect" XDG settings
[ $has_vim ] && \
  export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

# sshfs
if [ $has_sshfs ]; then
  # Remote Mount (sshfs)
  # creates mount folder and mounts the remote filesystem
  rmount() {
    local host folder mname
    host="${1%%:*}:"
    [ "${1%:}" = "${host%%:*}" ] && folder="" || folder=${1##*:}
    if [ $2 ]; then
      mname=$2
    else
      mname=${folder##*/}
      [ "$mname" = "" ] && mname=${host%%:*}
    fi
    if [ "$(grep -i "host ${host%%:*}" ~/.ssh/config)" != "" ]]; then
      mkdir -p ~/_mounts/g/$mname > /dev/null
      sshfs $host$folder ~/_mounts/g/$mname -oauto_cache,reconnect,defer_permissions,negative_vncache,volname=$mname,noappledouble && echo "mounted ~/_mounts/g/$mname"
    else
      echo "No entry found for ${host%%:*}"
      return 1
    fi
  }

  # Remote Umount, unmounts and deletes local folder
  # (experimental, watch your step)
  rumount() {
    if [ "$1" = "-a" ]]; then
      ls -1 ~/_mounts/g/ | \
        while read dir
        do
          [ $(mount | grep "_mounts/g/$dir") ] && umount ~/_mounts/g/$dir
          [ $(ls ~/_mounts/g/$dir) ] || rm -rf ~/_mounts/g/$dir
        done
    else
      [ $(mount | grep "_mounts/g/$1") ] && umount ~/_mounts/g/$1
      [ $(ls ~/_mounts/g/$1) ] || rm -rf ~/_mounts/g/$1
    fi
  }
fi

# Aliases
alias ls="ls -G"
alias ll="ls -la"
# use vim for vi, if available
[ $has_vim ] && alias vi=vim

# git prompt/completion
if [ $has_git ]; then
  git_version=$(git --version | sed -e 's/git version \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/')

  if [ -f "/usr/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    . /usr/doc/git-${git_version}/contrib/completion/git-prompt.sh
  elif [ -f "/usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh" ]; then
    . /usr/local/doc/git-${git_version}/contrib/completion/git-prompt.sh
  fi

  # git bash completion
  if [ $has_bash ]; then
    if [ -f "/usr/doc/git-${git_version}/contrib/completion/git-completion.bash" ]; then
      . /usr/doc/git-${git_version}/contrib/completion/git-completion.bash
    elif [ -f "/usr/local/doc/git-${git_version}/contrib/completion/git-completion.bash" ]; then
      . /usr/local/doc/git-${git_version}/contrib/completion/git-completion.bash
    fi
  fi

  if [ $has_brew ]; then
    if [ -e "${brew_home}/etc/bash_completion.d/git-prompt.sh" ]; then
      has_git_prompt=1
      . ${brew_home}/etc/bash_completion.d/git-prompt.sh
    fi
    # git bash completion
    [ $has_bash ] && [ -f "{brew_home}/etc/bash_completion" ] && \
      . ${brew_home}/etc/bash_completion
  fi
fi

# Load RVM into a shell session *as a function*
[ -s "${HOME}/.rvm/scripts/rvm" ] && . ${HOME}/.rvm/scripts/rvm

# rbenv config
[ $(command -v rbenv || true) ] && eval "$(rbenv init -)"
[ -d "${HOME}/.sm" ] && \
  export PATH="${PATH}:${HOME}/.sm/bin:${HOME}/.sm/pkg/active/bin:${HOME}/.sm/pkg/active/sbin"

if [ $has_node ]; then
  node_prefix=$(command -v node | sed 's#^\(.*\)/bin/node$#\1#')
  path_has_npm=$(path_contains "/npm/bin")

  [ $path_has_npm ] && [ -d "${node_prefix}/share/npm/bin" ] && \
    [ ! $(path_contains "${node_prefix}/share/npm/bin") ] && \
    export PATH=$(path_prepend "${node_prefix}/share/npm/bin")

  [ ! $(path_contains "./node_modules/.bin") ] && \
    export PATH=$(path_prepend "./node_modules/.bin")
fi

# nvm
export NVM_DIR=${NVM_DIR:-${HOME}/.nvm}
[ -s "${has_brew_nvm}/nvm.sh" ] && . ${has_brew_nvm}/nvm.sh
[ -s "${NVM_DIR}/nvm.sh" ] && . ${NVM_DIR}/nvm.sh  # This loads nvm
[ $has_bash ] && [ -r "${NVM_DIR}/bash_completion" ] && \
  . ${NVM_DIR}/bash_completion

# JAVA
if [ $has_java_home ] && [ -x $has_java_home ]; then
  should_install_java=$($has_java_home 2>&1 | grep -i "no java runtime")
  if [ ! $JAVA_HOME ] && [ -z "${should_install_java}" ]; then
    export JAVA_HOME=$($has_java_home)
    alias resetjdk="export JAVA_HOME=$($has_java_home)"
    alias setjdk17="export JAVA_HOME=$($has_java_home -v 1.7)"
    alias setjdk18="export JAVA_HOME=$($has_java_home -v 1.8)"
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
# Action	              Parameters
# Set background color	tput setab color
# Set foreground color	tput setaf color
# Set blink mode	      tput blink
# Set bold mode	        tput bold
# Set half-bright mode	tput dim
# Set underline mode	  tput smul
# Exit underline mode	  tput rmul
# Reverse mode	        tput rev
# Set standout mode	    tput smso
# Exit standout mode	  tput rmso
# Reset all attributes	tput sgr0
#
# Color   Code
# Black   0
# Red     1
# Green   2
# Yellow	3
# Blue	  4
# Magenta	5
# Cyan    6
# White   7

if [ $has_tput ]; then
  clr_bld=$(tput bold)
  clr_dim=$(tput dim)
  clr_rst=$(tput sgr0)
  clr_ulb=$(tput smul)
  clr_ule=$(tput rmul)

  if [ $term_colors -ge 256 ]; then
    clr_time=$(tput setaf 243)
    clr_user=$(tput setaf 172)
    clr_host=$(tput setaf 202)
    clr_pwd=$(tput setaf 216)
    clr_ok=$(tput setaf 40)
    clr_err=$(tput setaf 160)
    clr_uk=$(tput setaf 226)
  else
    clr_time=$(tput bold; tput setaf 0)
    clr_user=$(tput setaf 5)
    clr_host=$(tput setaf 6)
    clr_pwd=$(tput setaf 4)
    clr_ok=$(tput setaf 2)
    clr_err=$(tput setaf 1)
    clr_uk=$(tput setaf 3)
  fi
fi

# PS1
PS1="\[${clr_time}\]\t\[${clr_rst}\] "
[ $has_git_prompt ] && PS1="${PS1}\$(current_git_status)"
PS1="${PS1}\[${clr_user}\]\u\[${clr_rst}\]@\[${clr_host}\]\h"
PS1="${PS1}\[${clr_rst}\]:\[${clr_pwd}\]\w"
export PS1="${PS1}\[${clr_rst}\]\n\$ "

[ $has_bash ] && \
  [ -e "${HOME}/.iterm2_shell_integration.bash" ] && \
  source "${HOME}/.iterm2_shell_integration.bash"
