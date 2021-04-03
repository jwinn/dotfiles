cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

# check known homebrew paths
if [ -z "$(command -v brew || true)" ]; then
  # check if homebrew installed, but not in PATH
  if [ -x "${HOMEBREW_PREFIX}/bin/brew" ]; then
    path_prepend "${HOMEBREW_PREFIX}/bin"
  elif [ -x "/opt/homebrew/bin/brew" ]; then
    path_prepend "/opt/homebrew/bin"
  elif [ -x "${XDG_CONFIG_HOME}/brew/bin/brew" ]; then
    path_prepend "${XDG_CONFIG_HOME}/brew/bin"
  elif [ -x "${HOME}/.brew/bin/brew" ]; then
    path_prepend "${HOME}/.brew/bin"
  fi
fi

if [ -z "$(command -v brew || true)" ]; then
  # check for required bash and curl
  bash="$(command -v bash || true)"
  curl="$(command -v curl || true)"

  if [ -z "${bash}" ]; then
    printf "bash is required to run Homebrew\n"
  elif [ -z "${curl}" ]; then
    printf "curl is required to install Homebrew\n"
  elif q_prompt "Do you want to install Homebrew" "y"; then
    display_banner "Installing Homebrew..."
    ${bash} -c "$(${curl} -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # run doctor for new install
    brew doctor
  fi
fi

if [ -n "$(command -v brew || true)" ]; then
  if ! str_contains "$(brew tap)" "homebrew/cask-fonts" \
    && q_prompt "Do you want brew cask fonts" "y"; then
    brew tap homebrew/cask-fonts
  fi

  q_prompt "Do you want to update ${PKG_NAME}" "y" && ${PKG_CMD} ${PKG_UPDATE}
  q_prompt "Do you want to upgrade ${PKG_NAME}" && ${PKG_CMD} ${PKG_UPGRADE}

  # install formulae
  if q_prompt "Do you want to install forumlae" "y"; then
    printf "Installing Homebrew formulae...\n"
    run_per_line "${cwd}/macos/brew/formulae.bash" "brew install"
  fi
fi
