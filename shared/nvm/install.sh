cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

# check for required bash and curl
bash="$(command -v bash || true)"
curl="$(command -v curl || true)"

if [ -d "${NVM_DIR}" ] || [ -n "$(command -v nvm || true)" ]; then
  printf "Nvm already installed [%s]\n" "${NVM_DIR}"
elif [ -z "${bash}" ]; then
  printf "bash is required to install nvm\n"
elif [ -z "${curl}" ]; then
  printf "curl is required to install nvm\n"
elif q_prompt "Do you want to install nvm" "y"; then
  version=$(get_github_latest_release "nvm-sh/nvm")
  ${curl} -o- https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh | ${bash}
fi
