cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

pkg="${2}"
deps="${3}"

if q_prompt "Do you want to install ${pkg} requirements: ${deps}" "y"; then
  printf "Installing %s...\n" "${deps}"
  if [ "${PKG_CMD}" = "brew" ]; then
    ${PKG_CMD} ${PKG_INSTALL} ${deps}
  else
    elevate_cmd ${PKG_CMD} ${PKG_INSTALL} ${deps}
  fi
fi
