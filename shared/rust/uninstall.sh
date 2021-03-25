if [ -d "${HOME}/.cargo" ] || [ -n "$(command -v rustup || true)" ]; then
  if q_prompt "Do you want to remove rust(up)" "y"; then
    if [ -n "$(command -v rustup || true)" ]; then
      path_prepend "${HOME}/.cargo/bin"
    fi
    rustup self uninstall
  fi
fi
