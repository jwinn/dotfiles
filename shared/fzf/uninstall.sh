if [ -d "${FZF_DIR}" ] || [ -n "$(command -v fzf || true)" ]; then
  if q_prompt "Do you want to remove fzf" "y"; then
    if [ ! -d "${FZF_DIR}" ]; then
      read -r "Cannot find ${FZF_DIR:-\$FZF_DIR}, path: " FZF_DIR
    fi

    "${FZF_DIR}/uninstall" --xdg
    rm -rf $FZF_DIR
  fi
fi
