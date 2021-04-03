cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if q_prompt "Do you want to install ${1} requirements: ${2}"; then
  printf "Installing %s...\n" "${2}"
  ${PKG_CMD} ${PKG_INSTALL} ${2}
fi
