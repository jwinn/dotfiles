if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

display_banner "Uninstalling for Linux..."

# remove rust(up)
ssource shared/rust/uninstall.sh

# remove nvm
ssource shared/nvm/uninstall.sh

# remove pyenv
ssource shared/pyenv/uninstall.sh

# remove dotfile links
ssource shared/unlink-files.sh
