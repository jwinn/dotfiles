cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

# check for required bash and curl
bash="$(command -v bash || true)"
curl="$(command -v curl || true)"

if [ -d "${PYENV_ROOT}" ]; then
  printf "Pyenv already installed [%s]\n" "${PYENV_ROOT}"
elif [ -n "$(command -v pyenv || true)" ]; then
  printf "Pyenv already installed [%s]\n" "$(command -v pyenv || true)"
elif [ -z "${bash}" ]; then
  printf "bash is required to install pyenv\n"
elif [ -z "${curl}" ]; then
  printf "curl is required to install pyenv\n"
elif q_prompt "Do you want to install pyenv"; then
  # set requirements
  if [ "${OS_NAME}" = "macos" ]; then
    deps="openssl readline sqlite3 xz zlib$(${PKG_CMD} deps --1 --for-each asdf | cut -d":" -f2)"
  elif [ "${OS_NAME}" = "linux" ]; then
    # libedit-dev is an alternative to libreadline-dev
    deps="build-essential curl git libbz2-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev llvm make python-openssl tk-dev wget xz-utils zlib1g-dev"
  fi

  # install requirements
  ssource "${cwd}/shared/pkg-install.sh" "asdf" "${deps}"

  ${curl} https://pyenv.run | ${bash}
fi
