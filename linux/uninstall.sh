cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -z "$(command -v is_sourced || true)" ] && ! is_sourced; then
  printf "\"%s\" should not be called directly\n" "${script}"
  exit 1
fi

display_banner "Uninstalling for Linux..."

# remove pyenv
ssource "${cwd}/shared/pyenv/uninstall.sh"

# remove nvm
ssource "${cwd}/shared/nvm/uninstall.sh"

# remove jenv
ssource "${cwd}/shared/jenv/uninstall.sh"

# remove asdf
ssource "${cwd}/shared/asdf/uninstall.sh"

# remove fzf
ssource "${cwd}/shared/fzf/uninstall.sh"

# remove rust(up)
ssource "${cwd}/shared/rust/uninstall.sh"

# remove dotfile links
ssource "${cwd}/shared/unlink-files.sh"
