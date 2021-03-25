if [ -d "${HOME}/.cargo" ] || [ -n "$(command -v rustup || true)" ]; then
  printf "Rust(up) already installed\n"
elif q_prompt "Do you want to install rust(up)" "y"; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
