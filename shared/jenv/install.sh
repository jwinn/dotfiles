if [ -d "${JENV_ROOT}" ] || [ -n "$(command -v jenv || true)" ]; then
  printf "Jenv already installed [${JENV_ROOT}]\n"
elif q_prompt "Do you want to install jenv" "y"; then
  git clone https://github.com/jenv/jenv.git $JENV_ROOT
fi
