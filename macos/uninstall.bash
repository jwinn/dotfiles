if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

printf "Uninstalling for MacOS...\n"

# remove homebrew
if q_prompt "Do you want to remove Homebrew"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
fi

# remove nvm
if [ -d "${NVM_DIR}" ] || [ -n "$(command -v nvm || true)" ]; then
  if q_prompt "Do you want to remove nvm" "y"; then
    if [ ! -d "${NVM_DIR}" ]; then
      read -r "Cannot find ${NVM_DIR:-\$NVM_DIR}, path: " NVM_DIR
    fi

    rm -rf $NVM_DIR
  fi
fi

# remove pyenv
if [ -d "${PYENV_ROOT}" ] || [ -n "$(command -v pyenv || true)" ]; then
  if q_prompt "Do you want to remove pyenv" "y"; then
    if [ ! -d "${PYENV_ROOT}" ]; then
      read -r "Cannot find ${PYENV_ROOT:-\$PYENV_ROOT}, path: "
      PYENV_ROOT
    fi

    rm -rf $PYENV_ROOT
  fi
fi

# remove dotfile links
ssource macos/unlink-files.bash

printf "\nDONE\n"
