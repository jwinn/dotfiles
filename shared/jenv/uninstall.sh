if [ -d "${JENV_ROOT}" ] || [ -n "$(command -v jenv || true)" ]; then
  if q_prompt "Do you want to remove jenv" "y"; then
    if [ ! -d "${JENV_ROOT}" ]; then
      read -r "Cannot find ${JENV_ROOT:-\$JENV_ROOT}, path: " JENV_ROOT
    fi

    rm -rf $JENV_ROOT
  fi
fi
