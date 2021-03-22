if [ -d "${PYENV_ROOT}" ] || [ -n "$(command -v pyenv || true)" ]; then
  printf "Pyenv already installed [${PYENV_ROOT}]\n"
elif q_prompt "Do you want to install pyenv" "y"; then
  printf "Installing pyenv..."
  curl https://pyenv.run | bash
fi
