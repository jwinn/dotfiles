if [ -d "${PYENV_ROOT}" ]; then
  printf "Pyenv already installed [${PYENV_ROOT}]\n"
elif [ -n "$(command -v pyenv || true)" ]; then
  printf "Pyenv already installed [$(command -v pyenv || true)]\n"
elif q_prompt "Do you want to install pyenv" "y"; then
  curl https://pyenv.run | bash
fi
