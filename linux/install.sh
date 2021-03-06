cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -z "$(command -v is_sourced || true)" ] && ! is_sourced; then
  printf "\"%s\" should not be called directly\n" "${script}"
  exit 1
fi

display_banner "${PKG_NAME}"

if q_prompt "Do you want to update ${PKG_NAME}" "y"; then
  elevate_cmd ${PKG_CMD} ${PKG_UPDATE}
fi
if q_prompt "Do you want to upgrade ${PKG_NAME}"; then
  elevate_cmd ${PKG_CMD} ${PKG_UPGRADE}
fi

display_banner "Installing for Linux..."

# update dotfile links
ssource "${cwd}/shared/link-files.sh"

# rust(up)
ssource "${cwd}/shared/rust/install.sh"

# fzf
ssource "${cwd}/shared/fzf/install.sh"

# asdf
ssource "${cwd}/shared/asdf/install.sh"
