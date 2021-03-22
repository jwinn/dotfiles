if [ -d "${NVM_DIR}" ] || [ -n "$(command -v nvm || true)" ]; then
  if q_prompt "Do you want to remove nvm" "y"; then
    if [ ! -d "${NVM_DIR}" ]; then
      read -r "Cannot find ${NVM_DIR:-\$NVM_DIR}, path: " NVM_DIR
    fi

    rm -rf $NVM_DIR
  fi
fi
