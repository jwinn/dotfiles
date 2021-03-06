# shellcheck shell=sh
# shellcheck disable=SC2039
# shellcheck disable=SC2059

# load the generic functions, if not already loaded
# shellcheck source=./functions
ssource "${XDG_CONFIG_HOME}"/shell/common/functions.sh

# determine env language
if [ -n "${LANG}" ]; then
  _PS_LANG=${LANG##*.}
else
  _PS_LANG=$(locale -k LC_CTYPE)
  _PS_LANG=${_PS_LANG#charmap=}
fi
_PS_LANG=${_PS_LANG#\"}
_PS_LANG=${_PS_LANG%\"}
_PS_LANG=$(str_ucase $_PS_LANG)

#
# marks, shamelessly taken from https://github.com/nojhan/liquidprompt
#
if [ "${_PS_LANG}" = "UTF-8" ]; then
  _PS_MARK_BATTERY="⌁"        # in front of the battery charge
  _PS_MARK_ADAPTER="⏚"        # displayed when plugged
  _PS_MARK_LOAD="⌂"           # in front of the load
  _PS_MARK_TEMP="θ"           # in front of the temp
  _PS_MARK_PROXY="↥"          # indicate a proxy in use
  _PS_MARK_HG="☿"             # prompt mark in hg repositories
  _PS_MARK_SVN="‡"            # prompt mark in svn repositories
  _PS_MARK_GIT="±"            # prompt mark in git repositories
  _PS_MARK_FOSSIL="⌘"         # prompt mark in fossil repositories
  _PS_MARK_DISABLED="⌀"       # prompt mark in directory with disabled VCS info
  _PS_MARK_UNTRACKED="*"      # if git has untracked files
  _PS_MARK_STASH="+"          # if git has stashs
  _PS_MARK_SHORTEN_PATH=" … " # prompt mark in shortened paths
  _PS_MARK_PERM=":"           # separator between host and path
else
  # fallback to ASCII chars
  _PS_MARK_BATTERY="b"
  _PS_MARK_ADAPTER="p"
  _PS_MARK_LOAD="c"
  _PS_MARK_TEMP="T"
  _PS_MARK_PROXY="^"
  _PS_MARK_HG="m"
  _PS_MARK_SVN="="
  _PS_MARK_GIT="+"
  _PS_MARK_FOSSIL="f"
  _PS_MARK_DISABLED="!"
  _PS_MARK_UNTRACKED="*"
  _PS_MARK_STASH="+"
  _PS_MARK_SHORTEN_PATH=" ... "
  _PS_MARK_PERM=":"
fi
_PS_MARK_BRACKET_OPEN="["  # open bracket
_PS_MARK_BRACKET_CLOSE="]" # close bracket
#_PS_MARK_DEFAULT=""        # default prompt mark
_PS_MARK_PREFIX=" "        # prompt mark prefix
_PS_PS1_PREFIX=""
_PS_PS1_POSTFIX=""

#
# ref: https://en.wikipedia.org/wiki/ANSI_escape_code
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

_PS_COLOR_BLD=$(tput bold)
_PS_COLOR_DIM=$(tput dim)
_PS_COLOR_RST=$(tput sgr0)
_PS_COLOR_ULB=$(tput smul)
_PS_COLOR_ULE=$(tput rmul)

if [ "$(tput colors)" -ge 256 ]; then
  _PS_COLOR_TIME="$(tput bold)$(tput setaf 243)"
  _PS_COLOR_USER=$(tput setaf 172)
  _PS_COLOR_HOST=$(tput setaf 202)
  _PS_COLOR_PWD=$(tput setaf 216)
  _PS_COLOR_OK=$(tput setaf 40)
  _PS_COLOR_ERROR=$(tput setaf 160)
  _PS_COLOR_ALERT=$(tput setaf 226)
elif [ "$(tput colors)" -ge 8 ]; then
  _PS_COLOR_TIME="$(tput bold)$(tput setf 0)"
  _PS_COLOR_USER=$(tput setaf 5)
  _PS_COLOR_HOST=$(tput setaf 6)
  _PS_COLOR_PWD=$(tput setaf 4)
  _PS_COLOR_OK=$(tput setaf 2)
  _PS_COLOR_ERROR=$(tput setaf 1)
  _PS_COLOR_ALERT=$(tput setaf 3)
fi

#
# see: https://blog.w1r3.net/2018/07/07/portable-shell-prompt.html
#
_ps_init() {
  :;
}
_ps_unprintf() {
  printf "$@";
}
if [ -n "${BASH_VERSION}" ]; then
  _ps_unprintf() {
    p="$1"
    shift
    printf "\[$p\]" "$@"
  }
elif [ -n "${ZSH_VERSION}" ]; then
  setopt PROMPT_SUBST
  _ps_unprintf() {
    p="$1"
    shift
    printf "%%{$p%%}" "$@"
  }
elif [ -n "${KSH_VERSION##*PD KSH*}" ]; then
  _ps_init() {
    printf "\001\r"
  }
  _ps_unprintf() {
    p="$1"
    shift
    printf "\001$p\001" "$@"
  }
fi

_ps_os_name() {
  case "$(uname -s)" in
    Darwin) printf "Darwin" ;;
    DragonFly|FreeBSD) printf "FreeBSD" ;;
    Linux) printf "Linux" ;;
    OpenBSD) printf "OpenBSD" ;;
    SunOS) printf "SunOS" ;;
    *) printf "%s" "$(uname -s)" ;;
  esac
}

_ps_os_arch() {
  case "$(uname -m)" in
    i386*|i686*) printf "32" ;;
    *64|armv*) printf "64" ;;
    *) printf "%s" "$(uname -m)" ;;
  esac
}

_ps_battery_status() {
  case "$(_ps_os_name)" in
    Darwin|FreeBSD|OpenBSD)
      # $ pmset -g batt
      # Now drawing from 'AC Power'
      # -InternalBattery-0 (id=7667811)        100%; charged; 0:00 remaining present: true

      # $ pmset -g batt
      # Now drawing from 'Battery Power'
      # -InternalBattery-0 (id=7667811)        76%; discharging; 2:30 remaining present: true

      # $ pmset -g batt
      # Now drawing from 'Battery Power'
      # -InternalBattery-0 (id=7667811)        76%; discharging; (no estimate) present: true

      # $ pmset -g batt
      # Now drawing from 'AC Power'
      # -InternalBattery-0 (id=7667811)        80%; charging; 1:21 remaining present: true

      # $ pmset -g batt
      # Now drawing from 'AC Power'
      # -InternalBattery-0 (id=7667811)        100%; charged; 0:00 remaining present: true

      eval "$(pmset -g batt 2>/dev/null | \
        tr -d '\n' | \
        tr -d '\t' | \
        sed -n 's#.* from [^[:alpha:]]\([A-Za-z ]*\).*)[:space:]*\([0-9]*\)%; \([a-z]*\); \([0-9]*:[0-9]*\).*#_PS_BATT_DRAWING="\1" _PS_BATT_PERCENT="\2" _PS_BATT_STATUS="\3" _PS_BATT_REMAINING="\4"#p' \
      )"
      ;;
    Linux)
      local acpi="$(acpi --battery 2>/dev/null)"
      local batt="${acpi#Battery *, }"
      _PS_BATT_PERCENT="${batt%%%*}"
      ;;
  esac
}

_ps_display_batt_icon() {
  [ -z "${_PS_BATT_PERCENT-}" ] && return

  # determine icon and color to display
}

_ps_cmd_status() {
  _ps_unprintf "${_PS_COLOR_RST}"
  printf "("
  if [ "$?" -eq 0 ]; then
    _ps_unprintf "${_PS_COLOR_OK}"
  else
    _ps_unprintf "${_PS_COLOR_ERROR}"
  fi
  printf "%s" "$?"
  _ps_unprintf "${_PS_COLOR_RST}"
  printf ") "
}

_ps_cpu_load() {
  case "$(_ps_os_name)" in
    Darwin|FreeBSD|OpenBSD)
      printf "%s" "$(LC_ALL=C sysctl -n vm.loadavg)"
      ;;
    Linux)
      printf "%s" "$(cat /proc/loadavg)"
      ;;
    SunOS)
      printf "%s" "$(LC_ALL=C uptime | sed 's/.*load average: *\([0-9.]*\).*/\1/')"
      ;;
  esac
}

_ps_cpu_num() {
  case "$(_ps_os_name)" in
    Darwin|FreeBSD|OpenBSD)
      printf "%s" "$(sysctl -n hw.ncpu)"
      ;;
    Linux)
      printf "%s" "$(nproc 2>/dev/null || grep -c '^[Pp]rocessor' /proc/cpuinfo)"
      ;;
    SunOS)
      printf "%s" "$(kstat -m cpu_info | grep -c 'module: cpu_info')"
      ;;
  esac
}

_ps_get_pwd() {
  if str_contains $PWD $HOME; then
    printf "~${PWD##${HOME}}"
  else
    printf "${PWD}"
  fi
}

_ps_git_status() {
  _ps_git_branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
  if [ "$(command -v git || true)" ] && [ -n "${_ps_git_branch}" ]; then
    _ps_git_changed=$(git status -s | wc -l | tr -d "[:blank:]" 2>/dev/null)
    # if [ __git_ps1 ]; then
    #   GIT_PS1_SHOWDIRTYSTATE=1
    #   GIT_PS1_SHOWSTASHSTATE=1
    #   GIT_PS1_SHOWUNTRACKEDFILES=1
    #   GIT_PS1_SHOWCOLORHINTS=1
    #   GIT_PS1_HIDE_IF_PWD_IGNORED=1
    #   __git_ps1 "%s"
    # else
      _ps_unprintf "${_PS_COLOR_RST}"
      printf " ["
      if [ "${_ps_git_changed}" -eq 0 ]; then
        _ps_unprintf "${_PS_COLOR_OK}"
      else
        _ps_unprintf "${_PS_COLOR_ERROR}"
      fi
      printf "%s-%s" "$_ps_git_branch" "$_ps_git_changed"
      _ps_unprintf "${_PS_COLOR_RST}"
      printf "]"
    # fi
  fi
}

PS1=$(
  _ps_init
  printf "%s" "\$(_ps_cmd_status)"
  _ps_unprintf "${_PS_COLOR_USER}"
  printf "%s" "\${USER:-?}"
  _ps_unprintf "${_PS_COLOR_RST}"
  printf "%s" "@"
  _ps_unprintf "${_PS_COLOR_HOST}"
  printf "%s" "\${HOSTNAME%%.*}"
  _ps_unprintf "${_PS_COLOR_RST}"
  printf "%s" ":"
  _ps_unprintf "${_PS_COLOR_PWD}"
  printf "%s" "\$(_ps_get_pwd)"
  _ps_unprintf "${_PS_COLOR_RST}"
  printf "%s" "\$(_ps_git_status)"
  printf "\n\\$ "
  case "${TERM}" in
    xterm*|rxvt*|st*|screen*|tmux*)
      _ps_unprintf "\033]0;%s\007" "${USER}@${HOSTNAME%%.*}:${PWD}"
      ;;
  esac
)
