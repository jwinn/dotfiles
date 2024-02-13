# Put your environment variables here

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
# vim -- example
export MYVIMRC="${XDG_CONFIG_HOME}/vim/init.vim"
export VIMINIT=":source ${MYVIMRC}"

# Preferred programs
export PAGER="less -FirSwX"
if has_command nvim; then
  export EDITOR="env -u MYVIMRC -u VIMINIT -u VIM nvim"
elif has_command vim; then
  export EDITOR=vim
fi
if has_command wezterm; then
  export TERMINAL=wezterm
elif has_command kitty; then
  export TERMINAL=kitty
elif has_command alacritty; then
  export TERMINAL=alacritty
fi
export VISUAL=$EDITOR

# Language
export LANG="${LANG:-"en_US.UTF-8"}"
export LC_ALL=$LANG
export LC_COLLATE=$LANG
export LC_CTYPE=$LANG
export LC_MESSAGES=$LANG
export LC_MONETARY=$LANG
export LC_NUMERIC=$LANG
export LC_TIME=$LANG

# Less
#export LESS="-F -g -i -M -R -S -w -X -z-4"
export LESS="FRXQ"
export LESSCHARSET="UTF-8"
export LESSHISTFILE="-"
export LESSEDIT="$EDITOR ?lm+%lm. %f"

# Path settings

# add local sbin to PATH, if not found
[ -d "/usr/local/sbin" ] && path_prepend "/usr/local/sbin"

[ -d "${HOME}/share/man" ] && export MANPATH=${HOME}/share/man:${MANPATH}
[ -d "${HOME}/bin" ] && path_prepend ${HOME}/bin
[ -d "${HOME}/lib" ] && path_prepend ${HOME}/lib LD_LIBRARY_PATH
[ -d "${HOME}/include" ] && path_prepend ${HOME}/include CPATH

# the current directory should never be in $PATH
path_remove .
path_remove ""

safe_source "${XDG_CONFIG_HOME}/shell/login.local"

