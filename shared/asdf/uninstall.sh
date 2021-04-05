cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${ASDF_DIR}" ] || [ -n "$(command -v asdf || true)" ]; then
  if q_prompt "Do you want to remove asdf" "y"; then
    # get requirements
    ssource "${cwd}/shared/asdf/reqs.sh"

    # uninstall requirements
    [ -n "${asdf_reqs}" ] \
      && ssource "${cwd}/shared/pkg-uninstall.sh" "asdf" "${asdf_reqs}"
    [ -n "${golang_reqs}" ] \
      && ssource "${cwd}/shared/pkg-uninstall.sh" "golang" "${golang_reqs}"
    [ -n "${pyenv_reqs}" ] \
      && ssource "${cwd}/shared/pkg-uninstall.sh" "pyenv" "${pyenv_reqs}"

    if [ ! -d "${ASDF_DIR}" ]; then
      read -r "Cannot find ${ASDF_DIR:-\$ASDF_DIR}, path: " ASDF_DIR
    fi

    rm -rf "${ASDF_CONFIG_FILE}" "${ASDF_DIR}" "${ASDF_DATA_DIR}"
    rm -f "${HOME}/${ASDF_DEFAULT_TOOL_VERSIONS_FILENAME}"
  fi
fi
