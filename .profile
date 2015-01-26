os=${OSTYPE%%[0-9]*}
has_bash=$(echo $SHELL | grep bash)

# Functions
is_var () {
  [ $(declare | grep ${1}\=) ] && echo $1 || return 1
}

is_func () {
  [ $(declare -F $1) ] && echo $1 || return 1
}

is_cmd () {
  [ $(command -v $1) ] && command -v $1 || return 1
}

is_set () {
  [ $(is_var $1) ] || [ $(is_func $1) ] || [ $(is_cmd $1) ] && return 0 || return 1
}

minify () {
  # use UglifyJS compressor
  [ $(is_cmd uglifyjs) ] && uglifyjs $@
}

chrome () {
  cmd=$(is_cmd google-chrome)
  if [ "$os" = "darwin" ]; then
    open -a "Google Chrome" $@ --args --allow-file-access-from-files
  elif [ $cmd ]; then
    $cmd $@ --allow-file-access-from-files
  fi
}

if [ $(is_cmd sshfs) ]; then
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
    if [ $(is_cmd less) ]; then
      ls -al "$1" | less
    else
      ls -al "$1" | more
    fi
  }
fi

# Sexy Bash Prompt, inspired by "Extravagant Zsh Prompt"
# Screenshot: http://i.imgur.com/uAQSa.png
# A big thanks to \amethyst on Freenode

if [ "${COLORTERM%%-*}" = "gnome" ] && [ "$TERM" = "xterm" ] && infocmp gnome-256color >/dev/null 2>&1; then TERM=gnome-256color; fi
if [ $(tput colors) -ge 256 ] 2>/dev/null; then
MAGENTA=$(tput setaf 9)
  ORANGE=$(tput setaf 172)
  GREEN=$(tput setaf 190)
  PURPLE=$(tput setaf 141)
  WHITE=$(tput setaf 256)
else
MAGENTA=$(tput setaf 5)
  ORANGE=$(tput setaf 4)
  GREEN=$(tput setaf 2)
  PURPLE=$(tput setaf 1)
  WHITE=$(tput setaf 7)
fi
BOLD=$(tput bold)
RESET=$(tput sgr0)

parse_git_dirty () {
  [ "$(git status 2> /dev/null | tail -n1)" != "nothing to commit (working directory clean)" ] && echo "Î"
}
parse_git_branch () {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

# git prompt/completion
has_git=$(command -v git)
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

	if [ "$os" = "darwin" ] && [ -x /usr/local/bin/brew ]; then
		if [ -d $(brew --prefix)/etc/bash_completion.d ]; then
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

if [ "$os" = "darwin" ] && [ -d /usr/local/Cellar ]; then
  path_has_local_bin=$(echo $PATH | grep -o '/usr/local/bin')
  if [ $path_has_local_bin ]; then
    # strip out other occurrences and add to first check
    PATH=$(echo $PATH | sed 's/:*\/usr\/local\/bin//g')
  fi
  export PATH=/usr/local/bin:$PATH

  path_has_local_sbin=$(echo $PATH | grep -o '/usr/local/sbin')
  if [ $path_has_local_sbin ]; then
    # strip out other occurrences and add to first check
    PATH=$(echo $PATH | sed 's/:*\/usr\/local\/sbin//g')
  fi
  export PATH=/usr/local/sbin:$PATH
fi

# Load RVM into a shell session *as a function*
[ -s "${HOME}/.rvm/scripts/rvm" ] && . "${HOME}/.rvm/scripts/rvm"

# rbenv config
[ $(command -v rbenv) ] && eval "$(rbenv init -)"

[ -d "${HOME}/.sm" ] && export PATH="${PATH}:${HOME}/.sm/bin:${HOME}/.sm/pkg/active/bin:${HOME}/.sm/pkg/active/sbin"

has_node=$(command -v node)
if [ "$has_node" ]; then
  node_prefix=$(command -v node | sed 's#^\(.*\)/bin/node$#\1#')
  path_has_npm=$(echo $PATH | grep -o '/npm/bin')
  path_has_local_npm=$(echo $PATH | grep -o './node_modules/.bin')

  if [ -z "$path_has_npm" ] && [ -d ${node_prefix}/share/npm/bin ]; then
    export PATH=${node_prefix}/share/npm/bin:$PATH
  fi

  [ -z "$path_has_local_npm" ] && export PATH=./node_modules/.bin:$PATH
fi

# nvm
if [ -x /usr/local/bin/brew ] && [ -d $(brew --prefix nvm) ]; then
	export NVM_DIR=$(brew --prefix)/var/nvm
	source $(brew --prefix nvm)/nvm.sh
elif [ -d ${HOME}/.nvm ]; then
	export NVM_DIR="${HOME}/.nvm"
	[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"  # This loads nvm
fi
if [ $(command -v nvm) ] && [ $has_bash ]; then
	[ -r ${NVM_DIR}/bash_completion ] && . ${NVM_DIR}/bash_completion
fi

has_vi=$(command -v vi)
has_vim=$(command -v vim)
if [ $has_vi ] && [ $has_vim ]; then
  vi_prefix=$(command -v vi | sed 's#^\(.*\)/vi$#\1#')
  vim_prefix=$(command -v vim | sed 's#^\(.*\)/vim$#\1#')
  [ ! -h "${vim_prefix}/vi" ] && [ -w "${vim_prefix}/vi" ] && ln -sf $has_vim ${vim_prefix}/vi
fi

# JAVA
has_java_home=$(command -v /usr/libexec/java_home)
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
export IRCFINGER="That tickles"

PS1="\[${BOLD}${MAGENTA}\]\u \[${WHITE}\]at \[${ORANGE}\]\h \[${WHITE}\]in \[${GREEN}\]\w\[${WHITE}\]\$([ -n \$(__git_ps1) ] && echo \" on \")\[${PURPLE}\]\$(parse_git_branch)\[${WHITE}\]\n\$ \[${RESET}\]"

