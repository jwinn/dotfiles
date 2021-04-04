cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${FZF_DIR}" ] || [ -n "$(command -v fzf || true)" ]; then
  printf "Fzf already installed [%s]\n" "${FZF_DIR}"
elif q_prompt "Do you want to install fzf" "y"; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "${FZF_DIR}"
  "${FZF_DIR}/install" --all \
    --xdg \
    --no-completion \
    --no-update-rc \
    --no-bash \
    --no-zsh \
    --no-fish
fi
