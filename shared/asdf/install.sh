cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${ASDF_DIR}" ] || [ -n "$(command -v asdf || true)" ]; then
  printf "Asdf already installed [%s]\n" "${ASDF_DIR}"
elif q_prompt "Do you want to install asdf" "y"; then
  # get requirements
  ssource "${cwd}/shared/asdf/reqs.sh"

  # install requirements
  [ -n "${asdf_reqs}" ] \
    && ssource "${cwd}/shared/pkg-install.sh" "asdf" "${asdf_reqs}"
  [ -n "{golang_reqs}" ] \
    && ssource "${cwd}/shared/pkg-install.sh" "golang" "${golang_reqs}"
  [ -n "{pyenv_reqs}" ] \
    && ssource "${cwd}/shared/pkg-install.sh" "pyenv" "${pyenv_reqs}"

  # retrieve from github and checkout latest branch
  git clone https://github.com/asdf-vm/asdf.git "${ASDF_DIR}" \
    && cd "${ASDF_DIR}" \
    && git switch -c "$(git describe --abbrev=0 --tags)" \
    && cd - \
    && [ -s "${ASDF_DIR}/asdf.sh" ] && source "${ASDF_DIR}/asdf.sh" \
    && asdf plugin-add golang https://github.com/kennyp/asdf-golang.git \
    && asdf plugin-add java https://github.com/halcyon/asdf-java.git \
    && asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
    && asdf plugin-add python \
    && asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
fi
