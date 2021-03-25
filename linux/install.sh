if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

display_banner "Installing for Linux..."

# rust(up)
ssource shared/rust/install.sh

# nvm
ssource shared/nvm/install.sh

# pyevm
ssource shared/pyenv/install.sh

# update dotfile links
ssource shared/link-files.sh
