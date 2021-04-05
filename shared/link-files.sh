cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

# TODO: improve backup process
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
  backup_file "${XDG_CONFIG_HOME}/emacs/init.el" "${DOTFILES_BACKUP_DIR}/emacs"
  link_file "${dotfiles}/emacs/init.el" "${XDG_CONFIG_HOME}/emacs/init.el"

  create_dir "${XDG_CONFIG_HOME}/nvim"
  link_file "${dotfiles}/nvim/lua" "${XDG_CONFIG_HOME}/nvim/lua"
  backup_file "${XDG_CONFIG_HOME}/nvim/init.vim" "${DOTFILES_BACKUP_DIR}/nvim"
  link_file "${dotfiles}/nvim/init.vim" "${XDG_CONFIG_HOME}/nvim/init.vim"

  create_dir "${XDG_CONFIG_HOME}/vim"
  backup_file "${XDG_CONFIG_HOME}/vim/init.vim" "${DOTFILES_BACKUP_DIR}/vim"
  link_file "${dotfiles}/vim/init.vim" "${XDG_CONFIG_HOME}/vim/vimrc"

  for dfile in bash_logout bash_profile bashrc profile zshenv; do
    backup_file "${HOME}/.${dfile}" "${DOTFILES_BACKUP_DIR}"
    link_file "${dotfiles}/shell/.${dfile}" "${HOME}/.${dfile}"
  done

  for dfile in zlogin zlogout zshrc; do
    backup_file "${ZDOTDIR}/.${dfile}" "${DOTFILES_BACKUP_DIR}"
    link_file "${dotfiles}/shell/.${dfile}" "${ZDOTDIR}/.${dfile}"
  done

  backup_file "${ASDF_CONFIG_FILE}" "${DOTFILES_BACKUP_DIR}"
  link_file "${dotfiles}/asdfrc" "${ASDF_CONFIG_FILE}"

  for dfile in editorconfig gitconfig gitignore shellcheckrc tmux.conf; do
    backup_file "${HOME}/.${dfile}" "${DOTFILES_BACKUP_DIR}"
    link_file "${dotfiles}/${dfile}" "${HOME}/.${dfile}"
  done

  printf "\nFile backups are in: %s\n" "${XDG_DATA_HOME}/backup"
fi
