# shellcheck shell=sh

# Usage: is_sourced
is_sourced() {
  # https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
  # ([[ -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT =~ :file$ ]] ||
  #  [[ -n $KSH_VERSION && $(cd "$(dirname -- "$0")" &&
  #   printf '%s' "${PWD%/}/")$(basename -- "$0") != "${.sh.file}" ]] ||
  #  [[ -n $BASH_VERSION ]] && (return 0 2>/dev/null)) && sourced=1 || sourced=0
  local sourced=0
  if [ -n "${ZSH_EVAL_CONTEXT}" ]; then
    case $ZSH_EVAL_CONTEXT in *:file) sourced=1;; esac
  elif [ -n "${KSH_VERSION}" ]; then
    [ "$(cd $(dirname -- $0) && pwd -P)/$(basename -- $0)" != "$(cd $(dirname -- ${.sh.file}) && pwd -P)/$(basename -- ${.sh.file})" ] && sourced=1
  elif [ -n "${BASH_VERSION}" ]; then
    (return 0 2>/dev/null) && sourced=1
  else # All other shells: examine $0 for known shell binary filenames
    # Detects `sh` and `dash`; add additional shell filenames as needed.
    case ${0##*/} in sh|dash) sourced=1;; esac
  fi

  [ $sourced -eq 1 ] && return 0 || return 1
}

# Usage: elevate_cmd "command"
# TODO: very rudimentary/naive, needs improvement
elevate_cmd() {
  EUID="${EUID:-$(id -u)}"
  sudo="${sudo:-$(command -v sudo || true)}"

  if [ "${EUID}" -gt 0 ] && [ -z "$(command -v sudo || true)" ]; then 
    printf "Non-root user and no sudo-like program\n"
    return 1
  elif [ "${EUID}" -gt 0 ]; then
    args="${@}"
    printf "%s %s\n" "${sudo}" "${args}"
    unset -v args

    ${sudo} ${@}
  else
    ${@}
  fi
}

# Usage: q_prompt "Are you sure" ["y"]
q_prompt() {
  local yes="y"
  local no="N"
  if [ "${2}" != "${2#[Yy]}" ]; then
    yes="Y"
    no="n"
  fi

  printf "%s? [%s/%s] " "${1}" "${yes}" "${no}"
  read answer

  if [ -z "${answer}" ] && [ "${yes}" = "Y" ] || [ "${answer}" != "${answer#[Yy]}" ]; then
    return 0
  else
    return 1
  fi
}

# Usage: display_banner "line 1" "line 2" ...
display_banner() {
  printf "\n==================================================\n"
  for line in "$@"; do printf "%s\n" "${line}"; done
  printf "==================================================\n"
}

# Usage: create_dir dir
create_dir() {
  mkdir -p "${1}"
}

# Usage: remove_dir dir [1]
remove_dir() {
  local recurse=${2:-0}

  if [ "${recurse}" -eq 1 ]; then
    rm -rf "${1}"
  else
    rmdir "${1}"
  fi
}

# Usage: link_file source target
link_file() {
  if [ ! -h "$2" ]; then
    ln -s "$1" "$2"
    printf "linked %s -> %s\n" "$1" "$2"
  fi
}

# Usage: unlink_file source target
unlink_file() {
  rm -f "$1"
  printf "unlinked %s\n" "$1"
}

# Usage: resolve_link filename
resolve_link() {
  if [ "$(command -v readlink || true)" ]; then
    if [ -n "${IS_MACOS}" ]; then
      resolved=$(readlink "$1")
    else
      resolved=$(readlink -f "$1")
    fi
  elif [ "$(command -v realpath || true)" ]; then
    resolved=$(realpath "$1")
  else
    return 1
  fi
  printf "%s" "${resolved}"
}

# Usage: str_contains haystack needle
str_contains() {
  if [ "${1#*$2}" != "$1" ]; then
    return 0
  else
    return 1
  fi
}

# Usage: str_ucase string
str_ucase() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Usage: str_lcase string
str_lcase() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

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
# Usage: from_hex #012345
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

# Usage: to_hex 255
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
run_per_line() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    printf "Usage: run_per_line <file> <command>\n"
    exit 1
  fi

  if [ ! -s "${1}" ]; then
    printf "\"${1}\" does not exist or is empty\n"
    exit 1
  fi

  while read line; do
    # trim head|tail whitespace
    line="${line## }"
    line="${line%% }"

    case "${line}" in
      \#*) continue ;;

      \$\(*\)|\(*\))
        eval "output=\"${line}\""

        # trim head|tail whitespace
        output="${output## }"
        output="${output%% }"

        [ -n "${output}" ] && $2 $output
        ;;

      *)
        [ -n "${line}" ] && $2 $line
        ;;
    esac
  done < "${1}"
}

# Usage: get_github_latest_release "nvm-sh/nvm"
get_github_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
