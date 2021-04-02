# TODO: verify required are installed (bash, curl, etc)
# TODO: support homebrew on linux, including installing deps

# check known homebrew paths
if [ -z "$(command -v brew || true)" ]; then
  # check if homebrew installed, but not in PATH
  if [ -x "/opt/homebrew/bin/brew" ]; then
    path_prepend "/opt/homebrew/bin"
  elif [ -x "${XDG_CONFIG_HOME}/brew/bin/brew" ]; then
    path_prepend "${XDG_CONFIG_HOME}/brew/bin"
  elif [ -x "${HOME}/.linuxbrew/bin/brew" ]; then
    path_prepend "${HOME}/.linuxbrew/bin"
  elif [ -x "${HOME}/.brew/bin/brew" ]; then
    path_prepend "${HOME}/.brew/bin"
  fi
fi

if [ -z "$(command -v brew || true)" ]; then
  if q_prompt "Do you want to install Homebrew" "y"; then
    display_banner "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # run doctor for new install
    brew doctor
  fi
fi

if [ -n "$(command -v brew || true)" ]; then
  cwd=${2:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)}

  if ! str_contains "$(brew tap)" "homebrew/cask-fonts"; then
    if q_prompt "Do you want brew cask fonts" "y"; then
      brew tap homebrew/cask-fonts
    fi
  fi

  if q_prompt "Do you want to update homebrew" "y"; then
    brew update && brew upgrade
  fi

  # install formulae
  if q_prompt "Do you want to install forumlae" "y"; then
    printf "Installing Homebrew formulae...\n"
    run_per_line "${cwd}/shared/brew/formulae.bash" "brew install"
  fi
fi
