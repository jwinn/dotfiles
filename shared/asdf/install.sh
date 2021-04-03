cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${ASDF_DIR}" ] || [ -n "$(command -v asdf || true)" ]; then
  printf "Asdf already installed [%s]\n" "${ASDF_DIR}"
elif q_prompt "Do you want to install asdf" "y"; then
  # set requirements
  if [ "${OS_NAME}" = "macos" ]; then
    deps="$(${PKG_CMD} deps --1 --for-each asdf | cut -d":" -f2)"
  elif [ "${OS_NAME}" = "linux" ]; then
    deps="curl git"
  fi

  # install requirements
  ssource "${cwd}/shared/pkg-install.sh" "asdf" "${deps}"

  # try to get latest release from API,
  # otherwise fallback to known version, since this file was last written
  version=$(get_github_latest_release "asdf-vm/asdf")
  if [ -z "${version}" ]; then
    version="v0.8.0"
  fi

  # retrieve from github
  git clone https://github.com/asdf-vm/asdf "${ASDF_DIR}" --branch ${version}
fi
