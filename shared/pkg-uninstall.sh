cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if q_prompt "Do you want to uninstall ${1} requirements: ${2}"; then
  printf "Uninstalling %s...\n" "${2}"
  ${PKG_CMD} ${PKG_UNINSTALL} ${2}
fi
