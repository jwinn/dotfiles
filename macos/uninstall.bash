if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

printf "Uninstalling for MacOS...\n"

# remove homebrew
if q_prompt "Do you want to remove Homebrew"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
fi

# remove nvm
ssource shared/nvm/uninstall.sh

# remove pyenv
ssource shared/pyenv/uninstall.sh

# remove dotfile links
ssource shared/unlink-files.sh

printf "\nDONE\n"
