# set package vars
PKG_INSTALL="install"
PKG_UNINSTALL="uninstall"
PKG_UPDATE="update"
PKG_UPGRADE="upgrade"

if [ -n "${IS_MACOS}" ]; then
  PKG_NAME="Homebrew"
  PKG_CMD="brew"
elif [ -n "${IS_BSD}" ]; then
  if [ -n "$(command -v pkg_add || true)" ]; then
    PKG_NAME="OpenBSD pkg"
    PKG_CMD=""
    PKG_INSTALL="pkg_add"
    PKG_UNINSTALL="pkg_add"
    PKG_UPDATE=""
    PKG_UPGRADE=""
  elif [ -n "$(command -v pkg || true)" ]; then
    PKG_NAME="FreeBSD pkg"
    PKG_CMD="pkg"
  fi
elif [ -n "${IS_LINUX}" ]; then
  if [ -n "$(command -v apt || true)" ]; then
    PKG_NAME="Aptitude"
    PKG_CMD="apt"
  elif [ -n "$(command -v apt-get || true)" ]; then
    PKG_NAME="Aptitude"
    PKG_CMD="apt-get"
  elif [ -n "$(command -v dnf || true)" ]; then
    PKG_NAME="Dandified YUM"
    PKG_CMD="dnf"
  elif [ -n "$(command -v yum || true)" ]; then
    PKG_NAME="Yellow-Dog Updater Modified"
    PKG_CMD="yum"
  elif [ -n "$(command -v pacman || true)" ]; then
    PKG_NAME="Pacman"
    PKG_CMD="pacman"
    PKG_INSTALL="-S"
    PKG_UNINSTALL="-Rs"
    PKG_UPDATE="-Syy"
    PKG_UPGRADE="-Syu"
  elif [ -n "$(command -v zypper || true)" ]; then
    PKG_NAME="Zypper"
    PKG_CMD="zypper"
  elif [ -n "$(command -v apk || true)" ]; then
    # apk are also used as Android packages,
    # so may be problematic
    PKG_NAME="Alpine Linux package management"
    PKG_CMD="apk"
    PKG_INSTALL="add"
    PKG_UNINSTALL="del"
  fi
fi
