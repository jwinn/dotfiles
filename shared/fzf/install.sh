if [ -d "${FZF_DIR}" ] || [ -n "$(command -v fzf || true)" ]; then
  printf "Fzf already installed [${FZF_DIR}]\n"
elif q_prompt "Do you want to install fzf" "y"; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "${FZF_DIR}"
  "${FZF_DIR}/install" --all --xdg
fi
