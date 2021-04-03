if [ "$(command -v apt || true)"]; then
  cmd="apt"
  cmd_install="install"
  cmd_update="update"
  os="debian"
elif [ "$(command -v apt-get || true)"] then
  cmd="apt-get"
  cmd_install="install"
  cmd_update="update"
  os="debian"
  # TODO: add more linux package managers
fi

cwd=${2:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)}
prereqs="${cwd}/shared/brew/linux/${os}/pre-requisites.sh"

if [ -s "${prereqs}"] then
  printf "Installing pre-requisites...\n"
  [ -n "${cmd_update-}" ] && "${cmd} ${cmd_update}"
  run_per_line "${prereqs}" "${cmd} ${cmd_install}"
fi
