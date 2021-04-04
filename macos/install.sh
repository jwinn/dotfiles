cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -z "$(command -v is_sourced || true)" ] && ! is_sourced; then
  printf "\"%s\" should not be called directly\n" "${script}"
  exit 1
fi

display_banner "Installing for MacOS..."

# update dotfile links
ssource "${cwd}/shared/link-files.sh"

# homebrew
ssource "${cwd}/macos/brew/install.bash"

# rust(up)
ssource "${cwd}/shared/rust/install.sh"

# fzf
ssource "${cwd}/shared/fzf/install.sh"

# asdf
ssource "${cwd}/shared/asdf/install.sh"

# configure MacOS defaults
# should be run once or will reset future changes
if q_prompt "Do you want to overwrite Mac settings"; then
  ssource "${cwd}/macos/defaults/uninstall.bash"
fi
