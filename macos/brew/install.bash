if [ -z "$(command -v brew || true)" ]; then
  # check if homebrew installed, but not in PATH
  if [ -x "/opt/homebrew/bin/brew" ]; then
    path_prepend "/opt/homebrew/bin"
  elif [ -x "${XDG_CONFIG_HOME}/brew/bin/brew" ]; then
    path_prepend "${XDG_CONFIG_HOME}/brew/bin"
  elif [ -x "${HOME}/.brew/bin/brew" ]; then
    path_prepend "${HOME}/.brew/bin"
  fi
fi

if [ -z "$(command -v brew || true)" ]; then
  if [ -z "${brew}" ] && q_prompt "Do you want to install Homebrew" "y"; then
    display_banner "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # run doctor for new install
    brew doctor
  fi
fi

display_banner "Updating Homebrew..."
brew update && brew upgrade

# install formulae
if q_prompt "Do you want to install forumlae" "y"; then
  printf "Installing Homebrew formulae...\n"
  run_per_line "macos/brew/formulae.bash" "brew install"
fi
