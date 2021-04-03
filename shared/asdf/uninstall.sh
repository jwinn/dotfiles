cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${ASDF_DIR}" ] || [ -n "$(command -v asdf || true)" ]; then
  if q_prompt "Do you want to remove asdf" "y"; then
    # set requirements
    if [ "${OS_NAME}" = "macos" ]; then
      deps="$(${PKG_CMD} deps --1 --for-each asdf | cut -d":" -f2)"
    elif [ "${OS_NAME}" = "linux" ]; then
      deps="curl git"
    fi

    # uninstall requirements
    ssource "${cwd}/shared/pkg-uninstall.sh" "asdf" "${deps}"

    if [ ! -d "${ASDF_DIR}" ]; then
      read -r "Cannot find ${ASDF_DIR:-\$ASDF_DIR}, path: " ASDF_DIR
    fi

    rm -rf "${ASDF_CONFIG_FILE}" "${ASDF_DIR}" "${ASDF_DATA_DIR}"
    rm -f "${HOME}/${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME}"
  fi
fi
