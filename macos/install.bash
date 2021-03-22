if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

printf "Installing for MacOS...\n"

# homebrew
ssource macos/brew.bash

# nvm
ssource shared/nvm.sh

# pyevm
ssource shared/pyenv.sh

# update dotfile links
ssource macos/link-files.bash

# configure MacOS defaults
# should be run once or will reset future changes
if q_prompt "Do you want to overwrite Mac settings"; then
  ssource macos/defaults.bash
fi

printf "\nDONE\n"
