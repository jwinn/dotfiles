cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${ASDF_DIR}" ] || [ -n "$(command -v asdf || true)" ]; then
  printf "Asdf already installed [%s]\n" "${ASDF_DIR}"
elif q_prompt "Do you want to install asdf" "y"; then
  # get requirements
  ssource "${cwd}/shared/asdf/reqs.sh"

  # install requirements
  [ -n "${asdf_reqs}" ] \
    && ssource "${cwd}/shared/pkg-install.sh" "asdf" "${asdf_reqs}"

  if [ -n "{pyenv_reqs}" ] \
    && q_prompt "Do you want to install pyenv requirements" "y"; then
    ssource "${cwd}/shared/pkg-install.sh" "pyenv" "${pyenv_reqs}"
  fi

  # try to get latest release from API,
  # otherwise fallback to known version, since this file was last written
  version=$(get_github_latest_release "asdf-vm/asdf")
  if [ -z "${version}" ]; then
    version="v0.8.0"
  fi

  # retrieve from github
  git clone https://github.com/asdf-vm/asdf "${ASDF_DIR}" --branch ${version}
fi
