cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -z "$(command -v is_sourced || true)" ] && ! is_sourced; then
  printf "\"%s\" should not be called directly\n" "${script}"
  exit 1
fi

display_banner "Uninstalling for MacOS..."

# remove asdf
ssource "${cwd}/shared/asdf/uninstall.sh"

# remove fzf
ssource "${cwd}/shared/fzf/uninstall.sh"

# remove rust(up)
ssource "${cwd}/shared/rust/uninstall.sh"

# remove homebrew
ssource "${cwd}/shared/brew/uninstall.bash"

# remove dotfile links
ssource "${cwd}/shared/unlink-files.sh"

# TODO: ideally would reset mac defaults to before install
# configure MacOS defaults
if q_prompt "Do you want to revert Mac settings"; then
  ssource "${cwd}/macos/defaults/install.bash"
fi
