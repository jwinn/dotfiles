#!/usr/bin/env bash

if [ -n "$(command -v brew || true)" ]; then
  printf "Homebrew already installed [$(brew --prefix)]\n"
  printf "Updating Homebrew..."
  brew update && brew upgrade
elif q_prompt "Do you want to install Homebrew" "y"; then
  printf "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # run doctor for new install
  brew doctor

  # update homebrew
  brew update

  # upgrade any formulae
  brew upgrade

  printf "\nInstalling Homebrew packages..."
  # formulae to install
  #brew install nvm # handle with their preferred install
  #brew install pyenv # handle with pyenv installer
  brew install shellcheck
fi
