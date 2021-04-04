cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

# TODO: make backups of existing files
if q_prompt "Do you want to link files" "y"; then
  dotfiles="${cwd}/dotfiles"
  ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME}/zsh}"
  create_dir "${ZDOTDIR}"

  create_dir "${XDG_CONFIG_HOME}/shell"
  link_file "${dotfiles}/shell/bash" "${XDG_CONFIG_HOME}/shell/bash"
  link_file "${dotfiles}/shell/common" "${XDG_CONFIG_HOME}/shell/common"
  link_file "${dotfiles}/shell/sh" "${XDG_CONFIG_HOME}/shell/sh"
  link_file "${dotfiles}/shell/zsh" "${XDG_CONFIG_HOME}/shell/zsh"

  create_dir "${XDG_CONFIG_HOME}/emacs"
  link_file "${dotfiles}/emacs/init.el" "${XDG_CONFIG_HOME}/emacs/init.el"

  create_dir "${XDG_CONFIG_HOME}/nvim"
  link_file "${dotfiles}/nvim/lua" "${XDG_CONFIG_HOME}/nvim/lua"
  link_file "${dotfiles}/nvim/init.vim" "${XDG_CONFIG_HOME}/nvim/init.vim"

  create_dir "${XDG_CONFIG_HOME}/vim"
  link_file "${dotfiles}/vim/init.vim" "${XDG_CONFIG_HOME}/vim/vimrc"

  link_file "${dotfiles}/shell/.bash_logout" "${HOME}/.bash_logout"
  link_file "${dotfiles}/shell/.bash_profile" "${HOME}/.bash_profile"
  link_file "${dotfiles}/shell/.bashrc" "${HOME}/.bashrc"
  link_file "${dotfiles}/shell/.profile" "${HOME}/.profile"
  link_file "${dotfiles}/shell/.zshenv" "${HOME}/.zshenv"
  link_file "${dotfiles}/shell/.zlogin" "${ZDOTDIR}/.zlogin"
  link_file "${dotfiles}/shell/.zlogout" "${ZDOTDIR}/.zlogout"
  link_file "${dotfiles}/shell/.zshrc" "${ZDOTDIR}/.zshrc"

  link_file "${dotfiles}/asdfrc" "${ASDF_CONFIG_FILE}"
  link_file "${dotfiles}/editorconfig" "${HOME}/.editorconfig"
  link_file "${dotfiles}/gitconfig" "${HOME}/.gitconfig"
  link_file "${dotfiles}/gitignore" "${HOME}/.gitignore"
  link_file "${dotfiles}/shellcheckrc" "${HOME}/.shellcheckrc"
  link_file "${dotfiles}/tmux.conf" "${HOME}/.tmux.conf"
fi
