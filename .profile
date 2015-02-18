os=${OSTYPE%%[0-9]*}

has_bash=$(echo $SHELL | grep bash)
has_brew=$(command -v brew)
[ $has_brew ] && has_brew_nvm=$(brew --prefix nvm)
has_git=$(command -v git)
hass_google_chrome=$(command -v google-chrome)
has_java_home=$(command -v /usr/libexec/java_home)
has_less=$(command -v less)
has_node=$(command -v node)
has_nvm=$(command -v nvm)
has_sshfs=$(command -v sshfs)
has_tput=$(command -v tput)
has_vi=$(command -v vi)
has_vim=$(command -v vim)

case "$TERM" in
  *256*) term_colors=${term_colors:-256};;
  *) term_colors=${term_colors:-8}
esac
[ $has_tput ] && term_colors=$(tput colors)

# Functions
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
    gitdf=$(git status -s | wc -l | tr -d '[:blank:]' 2>/dev/null)
    gitb=$(__git_ps1 "%s")
    if [ $gitdf -eq 0 ]; then
      printf "%s|%s%s%s|" "${clr_rst}" "${clr_ok}" "${gitb}" "${clr_rst}"
    else
      printf "%s|%s%s [%s]%s|" \
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
    if [ $((($color + 1) % 16)) == 0 ]; then
      printf "\\n"
    fi
    color=$(($color + 1))
  done
}

print_ansi_colors() {
  color=0
  while [ $color -lt $term_colors ]; do
    printf "\e[38;5;%sm %3s \e[0m" "${color}" "${color}"
    if [ $((($color + 1) % 16)) == 0 ]; then
      printf "\\n"
    fi
    color=$(($color + 1))
  done
}

chrome () {
  if [ "$os" = "darwin" ]; then
    open -a "Google Chrome" $@ --args --allow-file-access-from-files
  elif [ $has_google_chrome ]; then
    google-chrome $@ --allow-file-access-from-files
  fi
}

if [ $has_sshfs ]; then
  # Remote Mount (sshfs)
  # creates mount folder and mounts the remote filesystem
  rmount () {
    local host folder mname
    host="${1%%:*}:"
    [ "${1%:}" = "${host%%:*}" ] && folder="" || folder=${1##*:}
    if [ $2 ]; then
      mname=$2
    else
      mname=${folder##*/}
      [ "$mname" = "" ] && mname=${host%%:*}
    fi
    if [ "$(grep -i 'host ${host%%:*}' ~/.ssh/config)" != "" ]]; then
      mkdir -p ~/_mounts/g/$mname > /dev/null
      sshfs $host$folder ~/_mounts/g/$mname -oauto_cache,reconnect,defer_permissions,negative_vncache,volname=$mname,noappledouble && echo "mounted ~/_mounts/g/$mname"
    else
      echo "No entry found for ${host%%:*}"
      return 1
    fi
  }

  # Remote Umount, unmounts and deletes local folder
  # (experimental, watch your step)
  rumount () {
    if [ "$1" = "-a" ]]; then
      ls -1 ~/_mounts/g/|while read dir
    do
      [ $(mount|grep "_mounts/g/$dir") ] && umount ~/_mounts/g/$dir
      [ $(ls ~/_mounts/g/$dir) ] || rm -rf ~/_mounts/g/$dir
    done
  else
    [ $(mount|grep "_mounts/g/$1") ] && umount ~/_mounts/g/$1
    [ $(ls ~/_mounts/g/$1) ] || rm -rf ~/_mounts/g/$1
  fi
}
fi

# Aliases
alias ls="ls -G"
alias ll="ls -la"
if [ ! $(is_set llg) ]; then
  llg () {
    ls -al "$1" | grep ${@:2}
  }
fi
if [ ! $(is_set llgi) ]; then
  llgi () {
    ls -al "$1" | grep -i ${@:2}
  }
fi
if [ ! $(is_set llm) ]; then
  function llm () {
  if [ $has_less ]; then
    ls -al "$1" | less
  else
    ls -al "$1" | more
  fi
}
fi

# git prompt/completion
if [ $has_git ]; then
  git_version=$(git --version | sed -e "s/git version \([0-9]*\.[0-9]*\.[0-9]*\).*/\1/")

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

  if [ "$os" = "darwin" ] && [ $has_brew ]; then
    if [ -d $(brew --prefix)/etc/bash_completion.d ]; then
      has_git_prompt=1
      . $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
    fi
    # git bash completion
    if [ $has_bash ]; then
      if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
      fi
    fi
  fi
fi

if [ "$os" = "darwin" ] && [ $has_brew ]; then
  path_has_local_bin=$(printf $PATH | grep -o '/usr/local/bin')
  if [ $path_has_local_bin ]; then
    # strip out other occurrences and add to first check
    PATH=$(printf $PATH | sed 's/:*\/usr\/local\/bin//g')
  fi
  export PATH=/usr/local/bin:$PATH

  path_has_local_sbin=$(printf $PATH | grep -o '/usr/local/sbin')
  if [ $path_has_local_sbin ]; then
    # strip out other occurrences and add to first check
    PATH=$(printf $PATH | sed 's/:*\/usr\/local\/sbin//g')
  fi
  export PATH=/usr/local/sbin:$PATH
fi

# Load RVM into a shell session *as a function*
[ -s "${HOME}/.rvm/scripts/rvm" ] && . ${HOME}/.rvm/scripts/rvm

# rbenv config
[ $(command -v rbenv) ] && eval "$(rbenv init -)"
[ -d "${HOME}/.sm" ] && export PATH="${PATH}:${HOME}/.sm/bin:${HOME}/.sm/pkg/active/bin:${HOME}/.sm/pkg/active/sbin"

if [ $has_node ]; then
  node_prefix=$(command -v node | sed 's#^\(.*\)/bin/node$#\1#')
  path_has_npm=$(printf $PATH | grep -o '/npm/bin')
  path_has_local_npm=$(printf $PATH | grep -o 'node_modules/.bin')

  if [ -z "$path_has_npm" ] && [ -d ${node_prefix}/share/npm/bin ]; then
    export PATH=${node_prefix}/share/npm/bin:$PATH
  fi

  [ -z "$path_has_local_npm" ] && export PATH=./node_modules/.bin:$PATH
fi

# nvm
if [ $has_nvm ] || [ $has_brew_nvm ]; then
  if [ -z "$NVM_DIR" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ $has_brew_nvm ] && export NVM_DIR=$has_brew_nvm
  fi
  [ -s "${NVM_DIR}/nvm.sh" ] && . ${NVM_DIR}/nvm.sh  # This loads nvm
  [ $has_bash ] && [ -r ${NVM_DIR}/bash_completion ] && . ${NVM_DIR}/bash_completion
fi

if [ $has_vi ] && [ $has_vim ]; then
  vi_prefix=$(command -v vi | sed 's#^\(.*\)/vi$#\1#')
  vim_prefix=$(command -v vim | sed 's#^\(.*\)/vim$#\1#')
  [ ! -h "${vim_prefix}/vi" ] && [ -w "${vim_prefix}/vi" ] && ln -sf $has_vim ${vim_prefix}/vi
fi

# JAVA
if [ $has_java_home ]; then
  if [ ! $JAVA_HOME ] && [ -x /usr/libexec/java_home ]; then
    export JAVA_HOME=$(/usr/libexec/java_home)
    alias resetjdk='export JAVA_HOME=$(/usr/libexec/java_home)'
    alias setjdk16='export JAVA_HOME=$(/usr/libexec/java_home -v 1.6)'
    alias setjdk17='export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)'
    alias setjdk18='export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)'
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
    clr_time=$(tput setaf 240)
    clr_user=$(tput setaf 93)
    clr_host=$(tput setaf 39)
    clr_pwd=$(tput setaf 25)
    clr_ok=$(tput setaf 34)
    clr_err=$(tput setaf 124)
    clr_uk=$(tput setaf 11)
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

PS1="\[${clr_time}\]\t\[${clr_rst}\] "
PS1="${PS1}\[${clr_user}\]\u\[${clr_rst}\]@\[${clr_host}\]\h"
PS1="${PS1}\[${clr_rst}\]:\[${clr_pwd}\]\w"
[ $has_git_prompt ] && PS1="$PS1 \$(current_git_status)"
export PS1="${PS1}\[${clr_rst}\]\n\$ "
