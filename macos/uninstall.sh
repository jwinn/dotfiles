if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

display_banner "Uninstalling for MacOS..."

# remove pyenv
ssource shared/pyenv/uninstall.sh

# remove nvm
ssource shared/nvm/uninstall.sh

# remove jenv
ssource shared/jenv/uninstall.sh

# remove fzf
ssource shared/fzf/uninstall.sh

# remove rust(up)
ssource shared/rust/uninstall.sh

# remove homebrew
ssource macos/brew/uninstall.bash

# remove dotfile links
ssource shared/unlink-files.sh

# TODO: ideally would reset mac defaults to before install
# configure MacOS defaults
if q_prompt "Do you want to revert Mac settings"; then
  ssource macos/defaults/install.bash
fi
