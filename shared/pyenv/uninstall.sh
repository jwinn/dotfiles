if [ -d "${PYENV_ROOT}" ] || [ -n "$(command -v pyenv || true)" ]; then
  if q_prompt "Do you want to remove pyenv" "y"; then
    if [ ! -d "${PYENV_ROOT}" ]; then
      read -r "Cannot find ${PYENV_ROOT:-\$PYENV_ROOT}, path: "
      PYENV_ROOT
    fi

    rm -rf $PYENV_ROOT
  fi
fi
