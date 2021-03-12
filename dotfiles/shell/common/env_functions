# shellcheck shell=sh
# originally taken from https://heptapod.host/flowblok/shell-startup/-/blob/branch/default/.shell/env_functions

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

# Usage: ssource filename
ssource () {
  if [ -r "$1" ]; then
    # shellcheck disable=SC1090
    . "$1"
  fi
}
