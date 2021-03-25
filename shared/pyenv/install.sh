if [ -d "${PYENV_ROOT}" ] || [ -n "$(command -v pyenv || true)" ]; then
  printf "Pyenv already installed [${PYENV_ROOT}]\n"
elif q_prompt "Do you want to install pyenv" "y"; then
  curl https://pyenv.run | bash
fi
