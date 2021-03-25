if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

display_banner "Installing for MacOS..."

# update dotfile links
ssource shared/link-files.sh

# homebrew
ssource macos/brew/install.bash

# rust(up)
ssource shared/rust/install.sh

# nvm
ssource shared/nvm/install.sh

# pyenv
ssource shared/pyenv/install.sh

# configure MacOS defaults
# should be run once or will reset future changes
if q_prompt "Do you want to overwrite Mac settings"; then
  ssource macos/defaults/uninstall.bash
fi
