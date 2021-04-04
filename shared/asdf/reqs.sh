if [ "${OS_NAME}" = "macos" ]; then
  asdf_reqs="$(${PKG_CMD} deps --1 --for-each asdf | cut -d":" -f2)"

  pyenv_reqs="openssl readline sqlite3 xz zlib"
  pyenv_reqs="${pyenv_reqs}$(${PKG_CMD} deps --1 --for-each asdf | cut -d":" -f2)"
elif [ "${OS_NAME}" = "linux" ]; then
  # asdf has the same requirements for all linux package managers
  asdf_reqs="curl git"

  if [ "${PKG_NAME}" = "Apptitude" ]; then
    # Note: libedit-dev is an alternative to libreadline-dev
    pyenv_reqs="--no-install-recommends build-essential curl git libbz2-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev llvm make python-openssl tk-dev wget xz-utils zlib1g-dev"
  elif [ "${PKG_CMD}" = "dnf" ]; then
    pyenv_reqs="make gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel"
  elif [ "${PKG_CMD}" = "yum" ]; then
    pyenv_reqs="gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel"
  elif [ "${PKG_NAME}" = "Pacman" ]; then
    pyenv_reqs="base-devel openssl zlib"
  elif [ "${PKG_CMD}" = "zypper" ]; then
    pyenv_reqs="gcc automake bzip2 libbz2-devel xz xz-devel openssl-devel ncurses-devel readline-devel zlib-devel tk-devel libffi-devel sqlite3-devel"
  elif [ "${PKG_CMD}" = "apk" ]; then
    pyenv_reqs="--no-cache git bash build-base libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev"
    # for Python 3..7, the following may be required
    # https://bugs.python.org/issue34555
    pyenv_reqs="${pyenv_reqs} linux-headers" 
  fi
fi
