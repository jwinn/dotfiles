if [ -d "${NVM_DIR}" ] || [ -n "$(command -v nvm || true)" ]; then
  printf "Nvm already installed [${NVM_DIR}]\n"
elif q_prompt "Do you want to install nvm" "y"; then
  version=$(get_github_latest_release "nvm-sh/nvm")
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh | bash
fi
