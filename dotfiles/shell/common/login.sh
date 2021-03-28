# shellcheck shell=sh

# Put your environment variables here

# load the generic functions, if not already loaded
if [ -z "$(command -v ssource || true)" ]; then
  # shellcheck source=./functions
  . "${XDG_CONFIG_HOME}"/shell/common/env_functions.sh
fi
if [ -z "$(command -v str_contains || true)" ]; then
  # shellcheck source=./functions
  ssource "${XDG_CONFIG_HOME}"/shell/common/functions.sh
fi

# place the shell history in XDG folder
if [ -n "${HISTFILE-}" ]; then
  hf="${HISTFILE}"
else
  hf="${SHELL##*/}"_history
fi
export HISTFILE=${XDG_CONFIG_HOME}/${hf#\.}
export HISTSIZE=2000
export HISTFILESIZE=2000
export SAVEHIST=2000

# try to have certain programs respect/use XDG, instead of dot files/folders
# gnupg
export GNUPHOME="${XDG_CONFIG_HOME}/gnupg"
# less
export LESSHISTFILE="${XDG_CONFIG_HOME}/less/history"
export LESSKEY="${XDG_CONFIG_HOME}/less/keys"
# subversion
export SUBVERSION_HOME="${XDG_CONFIG_HOME}/subversion"
# vim
export MYVIMRC="${XDG_CONFIG_HOME}/vim/vimrc"
export VIMDOTDIR="${XDG_CONFIG_HOME}/vim"
export VIMINIT=":source ${MYVIMRC}"
#export VIMINIT="let $MYVIMRC=\"${XDG_CONFIG_HOME}/vim/vimrc\" | :source ${MYVIMRC}"

# Preferred programs
export PAGER=less
export EDITOR=vi
export VISUAL=$EDITOR

# Language
export LANG='en_US.UTF-8'
export LC_ALL=$LANG
export LC_COLLATE=$LANG
export LC_CTYPE=$LANG
export LC_MESSAGES=$LANG
export LC_MONETARY=$LANG
export LC_NUMERIC=$LANG
export LC_TIME=$LANG

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

# Path settings
# add local sbin to PATH, if not found
[ -d "/usr/local/sbin" ] && path_prepend "/usr/local/sbin"
#path_prepend ~/bin
#path_prepend ~/lib LD_LIBRARY_PATH
#path_prepend ~/include CPATH

# The current directory should never be in $PATH
#path_remove .
#path_remove ""
