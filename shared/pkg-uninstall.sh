cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

pkg="${2}"
deps="${3}"

if q_prompt "Do you want to uninstall ${pkg} requirements: ${deps}"; then
  printf "Uninstalling %s...\n" "${deps}"
  elevate_cmd ${PKG_CMD} ${PKG_UNINSTALL} ${deps}
fi
