if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

cwd=${2:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)}

display_banner "Installing for Linux..."

# rust(up)
ssource ${cwd}/shared/rust/install.sh

# nvm
ssource ${cwd}/shared/nvm/install.sh

# pyevm
ssource ${cwd}/shared/pyenv/install.sh

# update dotfile links
ssource ${cwd}/shared/link-files.sh
