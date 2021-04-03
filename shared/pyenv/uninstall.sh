cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${PYENV_ROOT}" ] || [ -n "$(command -v pyenv || true)" ]; then
  if q_prompt "Do you want to remove pyenv" "y"; then
    # set requirements
    if [ "${OS_NAME}" = "macos" ]; then
      deps="$(${PKG_CMD} deps --1 --for-each pyenv | cut -d":" -f2)"
    elif [ "${OS_NAME}" = "linux" ]; then
      # libedit-dev is an alternative to libreadline-dev
      deps="build-essential curl git libbz2-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev llvm python-openssl tk-dev wget xz-utils zlib1g-dev"
    fi

    # uninstall requirements
    ssource "${cwd}/shared/pkg-uninstall.sh" "pyenv" "${deps}"

    if [ ! -d "${PYENV_ROOT}" ]; then
      read -r "Cannot find ${PYENV_ROOT:-\$PYENV_ROOT}, path: " PYENV_ROOT
    fi

    rm -rf ${PYENV_ROOT}
  fi
fi
