cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

if [ -d "${JENV_ROOT}" ] || [ -n "$(command -v jenv || true)" ]; then
  printf "Jenv already installed [%s]\n" "${JENV_ROOT}"
elif q_prompt "Do you want to install jenv"; then
  git clone https://github.com/jenv/jenv.git "${JENV_ROOT}"
fi
