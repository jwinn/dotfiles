cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -z "$(command -v is_sourced || true)" ] && ! is_sourced; then
  printf "\"%s\" should not be called directly\n" "${script}"
  exit 1
fi

display_banner "${PKG_NAME}"

q_prompt "Do you want to update ${PKG_NAME}" "y" && ${PKG_CMD} ${PKG_UPDATE}
q_prompt "Do you want to upgrade ${PKG_NAME}" && ${PKG_CMD} ${PKG_UPGRADE}

display_banner "Installing for Linux..."

# update dotfile links
ssource "${cwd}/shared/link-files.sh"

# rust(up)
ssource "${cwd}/shared/rust/install.sh"

# fzf
ssource "${cwd}/shared/fzf/install.sh"

# asdf
ssource "${cwd}/shared/asdf/install.sh"

# jenv
ssource "${cwd}/shared/jenv/install.sh"

# nvm
ssource "${cwd}/shared/nvm/install.sh"

# pyevm
ssource "${cwd}/shared/pyenv/install.sh"
