if [ -z "$(command -v is_sourced || true)" ] && ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

cwd=${2:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)}

display_banner "Uninstalling for MacOS..."

# remove pyenv
ssource ${cwd}/shared/pyenv/uninstall.sh

# remove nvm
ssource ${cwd}/shared/nvm/uninstall.sh

# remove jenv
ssource ${cwd}/shared/jenv/uninstall.sh

# remove fzf
ssource ${cwd}/shared/fzf/uninstall.sh

# remove rust(up)
ssource ${cwd}/shared/rust/uninstall.sh

# remove homebrew
ssource ${cwd}/shared/brew/uninstall.bash

# remove dotfile links
ssource ${cwd}/shared/unlink-files.sh

# TODO: ideally would reset mac defaults to before install
# configure MacOS defaults
if q_prompt "Do you want to revert Mac settings"; then
  ssource ${cwd}/macos/defaults/install.bash
fi
