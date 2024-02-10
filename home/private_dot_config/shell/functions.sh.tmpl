# shellcheck shell=sh

######################################################################
# Colors
######################################################################

NO_COLOR="$(tput sgr0 2>/dev/null || printf '\033[0m')"
BOLD="$(tput bold 2>/dev/null || printf '\033[1m')"
DIM="$(tput dim 2>/dev/null || printf '\033[2m')"
ITALIC="$(tput sitm 2>/dev/null || printf '\033[3m')"
UNDERLINE="$(tput smul 2>/dev/null || printf '\033[4m')"

BLACK="$(tput setaf 0 2>/dev/null || printf '\033[38;5;0m')"
RED="$(tput setaf 1 2>/dev/null || printf '\033[38;5;1m')"
GREEN="$(tput setaf 2 2>/dev/null || printf '\033[38;5;2m')"
YELLOW="$(tput setaf 3 2>/dev/null || printf '\033[38;5;3m')"
BLUE="$(tput setaf 4 2>/dev/null || printf '\033[38;5;4m')"
MAGENTA="$(tput setaf 5 2>/dev/null || printf '\033[38;5;5m')"
CYAN="$(tput setaf 6 2>/dev/null || printf '\033[38;5;6m')"
WHITE="$(tput setaf 7 2>/dev/null || printf '\033[38;5;7m')"

BG_BLACK="$(tput setab 0 2>/dev/null || printf '\033[48;5;0m')"
BG_RED="$(tput setab 1 2>/dev/null || printf '\033[48;5;1m')"
BG_GREEN="$(tput setab 2 2>/dev/null || printf '\033[48;5;2m')"
BG_YELLOW="$(tput setab 3 2>/dev/null || printf '\033[48;5;3m')"
BG_BLUE="$(tput setab 4 2>/dev/null || printf '\033[48;5;4m')"
BG_MAGENTA="$(tput setab 5 2>/dev/null || printf '\033[48;5;5m')"
BG_CYAN="$(tput setab 6 2>/dev/null || printf '\033[48;5;6m')"
BG_WHITE="$(tput setab 7 2>/dev/null || printf '\033[48;5;7m')"

######################################################################
# Marks
# marks, shamelessly taken from https://github.com/nojhan/liquidprompt
######################################################################

CHARMAP="${CHARMAP:-"$(locale charmap)"}"

if [ "${CHARMAP}" = "UTF-8" ]; then
  MARK_BATTERY="⌁"        # in front of the battery charge
  MARK_ADAPTER="⏚"        # displayed when plugged
  MARK_LOAD="⌂"           # in front of the load
  MARK_TEMP="θ"           # in front of the temp
  MARK_PROXY="↥"          # indicate a proxy in use
  MARK_HG="☿"             # prompt mark in hg repositories
  MARK_SVN="‡"            # prompt mark in svn repositories
  MARK_GIT="±"            # prompt mark in git repositories
  MARK_FOSSIL="⌘"         # prompt mark in fossil repositories
  MARK_DISABLED="⌀"       # prompt mark in directory with disabled VCS info
  MARK_UNTRACKED="*"      # if git has untracked files
  MARK_STASH="+"          # if git has stashs
  MARK_SHORTEN_PATH=" … " # prompt mark in shortened paths
  MARK_PERM=":"           # separator between host and path
else
  # fallback to ASCII chars
  MARK_BATTERY="b"
  MARK_ADAPTER="p"
  MARK_LOAD="c"
  MARK_TEMP="T"
  MARK_PROXY="^"
  MARK_HG="m"
  MARK_SVN="="
  MARK_GIT="+"
  MARK_FOSSIL="f"
  MARK_DISABLED="!"
  MARK_UNTRACKED="*"
  MARK_STASH="+"
  MARK_SHORTEN_PATH=" ... "
  MARK_PERM=":"
fi
MARK_BRACKET_OPEN="["  # open bracket
MARK_BRACKET_CLOSE="]" # close bracket
#MARK_DEFAULT=""        # default prompt mark
MARK_PREFIX=" "        # prompt mark prefix

######################################################################
# Print
######################################################################

# Usage: print_info <message>
# Description: outputs a colorized, where applicable, info message
print_info() {
  printf "%s\n" "${CYAN}[*]${NO_COLOR} $*"
}

# Usage: print_warn <message>
# Description: outputs a colorized, where applicable, warning message
print_warn() {
  printf "%s\n" "${YELLOW}[!] $*${NO_COLOR}"
}

# Usage: print_error <message>
# Description: outputs a colorized, where applicable, error message
print_error() {
  printf "%s\n" "${RED}[x] $*${NO_COLOR}" >&2
}

# Usage: print_critical
# Description: outputs a colorized, where applicable, pre-defined critical message
print_critical() {
  print_error "Something unexpected has happened, please contact the maintainer"
}

# Usage: print_success <message>
# Description: outputs a colorized, where applicable, success message
print_success() {
  printf "%s\n" "${GREEN}[✓]${NO_COLOR} $*"
}

# Usage: print_prompt <question> [<default choice>]
# Description: prompts for input to y or n, defaults to n, unless passed
# Return: 0 if y or 1 if n
# Note: use of `local` is not, technically, POSIX compliant
print_prompt() {
  if [ ${FORCE:-0} -eq 1 ]; then
    return 0
  fi

  local _yes="y"
  local _no="N"
  local _rc=0
  local _answer=

  if [ "${2}" != "${2#[Yy]}" ]; then
    _yes="Y"
    _no="n"
  fi

  printf "%s %s? [%s/%s] " \
    "${MAGENTA}[?]${NO_COLOR}" \
    "${1}" \
    "${BOLD}${_yes}${NO_COLOR}" \
    "${BOLD}${_no}${NO_COLOR}"

  read -r _answer </dev/tty
  _rc=$?

  if [ $_rc -ne 0 ]; then
    print_error "Unable to read from prompt"
    return 1
  fi

  if [ -z "${_answer-}" ] \
    && [ "${_yes}" = "Y" ] \
    || [ "${_answer}" != "${_answer#[Yy]}" ]; then

    return 0
  else
    return 1
  fi
}

######################################################################
# Files and Directories
######################################################################

# Usage: create_dir <dir>
# Description: creates the directory, if it doesn't exist
create_dir() {
  mkdir -p "${1}"
}

# Usage: remove_dir <dir> [<recurse=0>]
# Description: attempts to remove the dir, can recurse
remove_dir() {
  local recurse=${2:-0}

  if [ "${recurse}" -eq 1 ]; then
    rm -rf "${1}"
  else
    rmdir "${1}"
  fi
}

# Usage: move_file <source> <destination>
# Description: moves the file, if it exists, to the destination
move_file() {
  if [ -e "${1}" ]; then
    mv "${1}" "${2}"
  fi
}

# Usage: remove_file <file>
# Description: removes the file, if it exists
remove_file() {
  if [ -e "${1}" ]; then
    rm -f "${1}"
  fi
}

# Usage: link_file <source> <target>
# Description: creates a symlink, to the provided source
link_file() {
  if [ -e "${1}" ] && [ ! -h "${2}" ]; then
    ln -s "${1}" "${2}"
    printf "${CYAN}[*]${NO_COLOR} linked %s ->${NO_COLOR} %s\n" \
      "${1}" "${2}"
  fi
}

# Usage: unlink_file <source>
# Description: removes the symlink, if it exists
unlink_file() {
  if [ -L "${1}" ]; then
    rm -f "${1}"
    printf "${CYAN}[*]${NO_COLOR} unlinked %s\n" "${1}"
  fi
}

# Usage: backup_link <file> [<backup_dir="${XDG_DATA_HOME}/backup">]
# Description: 
# Note: <backup_dir> is prepended to the <file> path
backup_link() {
  local backup_dir="${2:-"${XDG_DATA_HOME}/dotfiles"}"
  local file="$(basename -- "${1}")"

  create_dir "${backup_dir}"

  if [ ! -L "${1}" ]; then
    move_file "${1}" "${backup_dir}/${file}"
  fi
}

# Usage: list_dir_files <directory> [<extension>="*"]
# Description: lists the directories files, sans extension
# Note: use of `local` is not, technically, POSIX compliant
list_dir_files() {
  local _dir="${1%/*}"
  local _ext="${2:-"*"}"
  local _i= _f=
  local _blob=

  if [ "${_ext}" != "*" ] && [ "${_ext}" != "*.*" ]; then
    _ext="*.${_ext#.*}"
  fi

  _glob="${_dir}/${_ext}"

  _i=0
  for _f in ${_glob}; do
    _f="$(basename -- "${_f}")"
    _f="${_f%.[^.]*}"

    if [ -z "{$_f}" ]; then
      continue
    elif [ ${_i} -gt 0 ]; then
      printf " "
    fi

    if [ "${_f}" != "*" ]; then
      printf "%s" "${_f}"
    fi
    _i=$((_i + 1))
  done    
}

######################################################################
# Utility
######################################################################

# Usage: is_sourced
# Description: attempts to determine if script is sourced or called directly
# Return: 0 if called directly
#         1 if sourced
# https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
# Note: use of `local` is not, technically, POSIX compliant
is_sourced() {
  local _sourced=0

  if [ -n "${ZSH_EVAL_CONTEXT-}" ] && \
    [ "${ZSH_EVAL_CONTEXT}" != "toplevel" ]; then

    _sourced=1
  elif [ -n "${KSH_VERSION-}" ]; then
    [ "$(cd $(dirname -- $0) \
      && pwd -P)/$(basename -- $0)" != "$(cd $(dirname -- ${.sh.file}) \
      && pwd -P)/$(basename -- ${.sh.file})" ] \
      && _sourced=1
  elif [ -n "${BASH_VERSION-}" ]; then
    (return 0 2>/dev/null) && _sourced=1
  else # All other shells: examine $0 for known shell binary filenames
    # Detects `sh` and `dash`; add additional shell filenames as needed.
    case ${0##*/} in sh|dash) _sourced=1;; esac
  fi

  [ $_sourced -eq 1 ] && return 0 || return 1
}

# Usage: safe_source <file_path>
# Description: checks if file is readable, before sourcing
safe_source() {
  if [ -r "${1}" ]; then
    # shellcheck disable=SC1090
    . "${1}"
  fi
}

# Usage: check_if_sourced
# Description: check if sourced or not, print error and exit if not sourced 
check_if_sourced() {
  if ! is_sourced; then
    print_error "This file should not be called directly!"
    exit 1
  fi
}

# Usage: source_dotenv
# Description: attempts to source the dotenv file, from parent or HOME
# Return: 0 if dotenv file is sourced correctly
#         1 if dotenv file cannot be found
source_dotenv() {
  # source the dotenv file
  if [ -r "../.env" ]; then
    . "../.env"
    return $?
  fi

  if [ -r "../env" ]; then
    . "../env"
    return $?
  fi

  if [ -r "${HOME}/.env" ]; then
    . "${HOME}/.env"
    return $?
  fi

  print_error "Unable to find (.)env file in parent or ${HOME}"
  return 1
}

# Usage: get_script_cwd
# Description: determine's the script's current working directory
# Return: the script's current working directory--hopefully
# Note: this is by no means foolproof
get_script_cwd() {
  printf "%s" "$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)"
}

# Usage: get_script_name
# Description: determine's the script's file name
# Return: the script file name
get_script_name() {
  printf "%s" "$(basename -- "${0}")"
}

# Usage: str_contains <haystack> <needle>
# Description: determins if the needle is in the haystack string
str_contains() {
  if [ "${1#*$2}" != "$1" ]; then
    return 0
  else
    return 1
  fi
}

# Usage: str_ucase <string>
# Description: upper cases the string
str_ucase() {
  echo "${1}" | tr '[:lower:]' '[:upper:]'
}

# Usage: str_lcase <string>
# Description: lower cases the string
str_lcase() {
  echo "${1}" | tr '[:upper:]' '[:lower:]'
}

# Usage: term_colors
# Description: prints out the term's available color codes
term_colors() {
  _tc_cols=$(tput cols 2>/dev/null || echo 16)
  _tc_colors=$(tput colors 2>/dev/null || echo 8)
  for i in {0..$(( $_tc_colors - 1 ))}; do
    printf "%s" "$(tput setab $(( (255 - $i) / 128 * 255 )))"
    [ "$i" -gt 0 ] && [ "$(( $i % 16 ))" -eq 0 ] && printf "\n"
    printf "%s %03d %s" "$(tput setaf ${i})" "${i}" "$(tput sgr0)"
  done
}

# see: https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
# Usage: from_hex <#012345>
# Description: converts provided hex into dec
from_hex() {
  hex=${1#"#"}
  r=$(printf '0x%0.2s' "$hex")
  g=$(printf '0x%0.2s' "${hex#??}")
  b=$(printf '0x%0.2s' "${hex#????}")
  printf '%03d' "$((
                    (r<75?0:(r-35)/40)*6*6 + 
                    (g<75?0:(g-35)/40)*6   +
                    (b<75?0:(b-35)/40)     + 16
                ))"
}

# Usage: to_hex <255>
# Description: converts provided dec into hex
to_hex (){
  dec=$(( $1%256 )) # input must be a number in range 0-255
  if [ "$dec" -lt "16" ]; then
    bas=$(( dec%16 ))
    mul=128
    [ "$bas" -eq "7" ] && mul=192
    [ "$bas" -eq "8" ] && bas=7
    [ "$bas" -gt "8" ] && mul=255
    a="$((  (bas&1)    *mul ))"
    b="$(( ((bas&2)>>1)*mul ))" 
    c="$(( ((bas&4)>>2)*mul ))"
    printf 'dec= %3s basic= #%02x%02x%02x\n' "$dec" "$a" "$b" "$c"
  elif [ "$dec" -gt 15 ] && [ "$dec" -lt 232 ]; then
    b=$(( (dec-16)%6  )); b=$(( b==0?0: b*40 + 55 ))
    g=$(( (dec-16)/6%6)); g=$(( g==0?0: g*40 + 55 ))
    r=$(( (dec-16)/36 )); r=$(( r==0?0: r*40 + 55 ))
    printf 'dec= %3s color= #%02x%02x%02x\n' "$dec" "$r" "$g" "$b"
  else
    gray=$(( (dec-232)*10+8 ))
    printf 'dec= %3s  gray= #%02x%02x%02x\n' "$dec" "$gray" "$gray" "$gray"
  fi
}

# Usage: run_per_line "file" "brew install"
# Description: runs the command for each line of the provided file
# Note: empty lines, or lines starting with "#" are ignored
# TODO: this is a very brittle/naive implementation,
# i.e. what if one line's command errors?
run_per_line() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    printf "Usage: run_per_line <file> <command>\n"
    exit 1
  fi

  if [ ! -s "${1}" ]; then
    printf "\"${1}\" does not exist or is empty\n"
    exit 1
  fi

  while IFS= read -r line <&3 || [ -n "${line}" ]; do
  {
    # trim head|tail whitespace
    line="${line## }"
    line="${line%% }"

    case "${line}" in
      # ignore lines starting with "#"
      \#*)
        continue
        ;;

#      # allow for "$()" to be evaluated first,
#      # with the evaluated output used as the command's arguments
#      \$\(*\)|\(*\))
#        eval "output=\"${line}\""
#
#        # trim head|tail whitespace
#        output="${output## }"
#        output="${output%% }"
#
#        [ -n "${output}" ] && $2 "${output}"
#        ;;

      *)
        [ -n "${line}" ] && $2 "${line}"
        ;;
    esac
  } 3<&-
  done 3< "${1}"
}

# Usage: has_command <command>
# Description: checks if the command is in the current PATH
# Return: 0, if found in PATH
#         1, if not found in PATH
has_command() {
  command -v "${1}" 1>/dev/null 2>&1
}

# Usage: elevate_cmd <command>
# Description: attempts, using `sudo`, to elevate the provided command
# Return: 0, if success
#         1, if unable to elevate
# Note: use of `local` is not, technically, POSIX compliant
# TODO: very rudimentary/naive, needs improvement
elevate_cmd() {
  local _euid=${EUID:-$(id -u)}

  if [ $_euid -gt 0 ] && ! has_command sudo; then
    print_error "Non-root user and no sudo-like program"
    return 1
  elif [ $_euid -gt 0 ]; then
    print_info "Running: sudo -v ${@}"

    if ! sudo -v $@; then
      print_error "Superuser privileges not granted"
      return 1
    fi
  else
    # already running as an elevated user, just run the command
    $@
  fi
}

######################################################################
# Environment
######################################################################

# Usage: get_os_name
# Description: gets and lcase the os name; normalizes cygwin, msys, mingw 
# Outputs: the lcase os name
# Note: use of `local` is not, technically, POSIX compliant
get_os_name() {
  local _os_name="${OS_NAME:-"$(uname -s | tr '[:upper:]' '[:lower:]')"}"

  case "${_os_name}" in
    *bsd|dragonfly) _os_name="bsd" ;;
    sunos) _os_name="sun" ;;
    msys_nt*) _os_name="win" ;;
    cygwin_nt*) _os_name="win" ;;
    mingw*) _os_name="win" ;;
  esac

  printf "%s" "${_os_name}"
}

# Usage: get_os_arch
# Description: gets and lcase the os architecture; normalizes
# Outputs: the  lcase os architecture
# Note: use of `local` is not, technically, POSIX compliant
get_os_arch() {
  local _arch=

  if has_command arch; then
    _arch="$(arch)"
  else
    _arch="${ARCH:-"$(uname -m)"}"
  fi

  _arch="$(str_lcase "${_arch}")"

  case "${_arch}" in
    amd64*) _arch="x86_64" ;;
    armv*) _arch="arm" ;;
    arm64*) _arch="aarch64" ;;
  esac

  # uname may misreport 32-bit as 64-bit OS
  if [ "${_arch}" = "x86_64" ] && [ $(getconf LONG_BIT) -eq 32 ]; then
    _arch="i686"
  elif [ "${_arch}" = "aarch64" ] && [ $(getconf LONG_BIT) -eq 32 ]; then
    _arch="arm"
  fi 

  printf "%s" "${_arch}"
}

# Usage: indirect_expand PATH -> $PATH
indirect_expand () {
  env | sed -n "s/^$1=//p"
}

# Usage: path_remove /path/to/bin [PATH]
# Eg, to remove ~/bin from $PATH
#     path_remove ~/bin PATH
path_remove () {
  local IFS=':'
  local newpath=
  local dir=
  local var=${2:-PATH}
  # Bash has ${!var}, but this is not portable.
  for dir in $(indirect_expand "$var"); do
    IFS=''
    if [ "${dir}" != "$1" ]; then
      newpath=${newpath}:${dir}
    fi
  done
  export "${var}=${newpath#:}"
}

# Usage: path_prepend /path/to/bin [PATH]
# Eg, to prepend ~/bin to $PATH
#     path_prepend ~/bin PATH
path_prepend () {
  # if the path is already in the variable,
  # remove it so we can move it to the front
  path_remove "$1" "$2"
  #[ -d "${1}" ] || return
  local var="${2:-PATH}"
  local value=$(indirect_expand "${var}")
  export "${var}=${1}${value:+:${value}}"
}

# Usage: path_append /path/to/bin [PATH]
# Eg, to append ~/bin to $PATH
#     path_append ~/bin PATH
path_append () {
  path_remove "${1}" "${2}"
  #[ -d "${1}" ] || return
  local var=${2:-PATH}
  local value=$(indirect_expand "${var}")
  export "${var}=${value:+${value}:}${1}"
}

######################################################################
# Request/Response
######################################################################

# Usage: http_get <URL> [<file>]
# Description: HTTP GET a URL
# Return: 0 if success, with the file downloaded
# Return: 1 if no URL provided, a HTTP request command does not exist,
#         or the request fails
# Note: use of `local` is not, technically, POSIX compliant
http_get() {
  local _url="${1}"
  local _file="${2:-"$(basename -- "${_url}")"}"
  local _rc=0
  local _cmd=

  if [ -z "${_url-}" ]; then
    print_error "Usage: http_get <url> [<fielpath>]"
    return 1
  fi

  if has_command curl; then
    _cmd="curl -fsSL ${_url} -o ${_file}"
  elif has_command wget; then
    _cmd="wget -q -c ${_url} -O ${_file}"
  elif has_command fetch; then
    _cmd="fetch -q -o ${_file} ${_url}"
  else
    print_error "No HTTP request command found (curl, wget, fetch)"
    return 1
  fi

  $_cmd && return 0 || _rc=$?

  print_error "Failed to get URL (${_rc}): ${BLUE}${_cmd}${NO_COLOR}"
  return $_rc
}

# Usage: get_github_latest_release <"nvm-sh/nvm">
# Description: attempts to get, via API, the latest repo's release version
get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

######################################################################
# Prompt String (PS)
######################################################################

ps_init() {
  if [ -n "${KSH_VERSION##*PD KSH*}" ]; then
    printf "\001\r"
  else
    :;
  fi
}

ps_printf() {
  _p="${1}"
  shift
  if [ -n "${BASH_VERSION}" ]; then
    printf "\[${_p}\]" "$@"
  elif [ -n "${ZSH_VERSION}" ]; then
    setopt PROMPT_SUBST
    printf "%%{$_p%%}" "$@"
  elif [ -n "${KSH_VERSION##*PD KSH*}" ]; then
    printf "\001${_p}\001" "$@"
  else
    printf "$@"
  fi
}

ps_get_pwd() {
  _pwd="$(pwd)"
  if str_contains "${_pwd}" "${HOME}"; then
    printf "~${_pwd##${HOME}}"
  else
    printf "${_pwd}"
  fi
}

ps_git_status() {
  _ps_git_branch=$(git symbolic-ref HEAD 2>/dev/null | cut -d'/' -f3)
  if has_command git && [ -n "${_ps_git_branch}" ]; then
    _ps_git_changed=$(git status -s | wc -l | tr -d "[:blank:]" 2>/dev/null)
    if has_command __git_ps1; then
       GIT_PS1_SHOWDIRTYSTATE=1
       GIT_PS1_SHOWSTASHSTATE=1
       GIT_PS1_SHOWUNTRACKEDFILES=1
       GIT_PS1_SHOWCOLORHINTS=1
       GIT_PS1_HIDE_IF_PWD_IGNORED=1
       __git_ps1 " %s"
    else
      ps_printf "${NO_COLOR}"
      printf " ["
      if [ "${_ps_git_changed}" -eq 0 ]; then
        ps_printf "${GREEN}"
      else
        ps_printf "${RED}"
      fi
      printf "%s-%s" "${_ps_git_branch}" "${_ps_git_changed}"
      ps_printf "${NO_COLOR}"
      printf "]"
    fi
  fi
}

ps_title() {
  # update the title
  case "${TERM}" in
    xterm*|rxvt*|st*|screen*|tmux*)
      ps_printf "\033]0;%s\007" "${USER}@${HOSTNAME%%.*}:${PWD}"
      ;;
  esac
}

ps_prompt() {
  if [ -n "${ZSH_VERSION}" ]; then
    setopt PROMPT_SUBST
  fi

  PS1=$(
    ps_init
    ps_title
    printf "%s" "\${USER:-?}"
    ps_printf "${DIM}"
    printf "%s" "@"
    ps_printf "${NO_COLOR}"
    ps_printf "${ITALIC}"
    ps_printf "%s" "\${HOSTNAME%%.*}"
    ps_printf "${NO_COLOR}"
    printf "%s" ":"
    ps_printf "${DIM}"
    ps_printf "%s" "\$(ps_get_pwd)"
    ps_printf "${NO_COLOR}"
    printf "%s" "\$(ps_git_status)"
    printf "\n"
    if [ $? -eq 0 ]; then
      ps_printf "${GREEN}"
    else
      ps_printf "${RED}"
    fi
    printf "%s" "\\$ "
    ps_printf "${NO_COLOR}"
  )
}

# ensure the file is not called directly
check_if_sourced
