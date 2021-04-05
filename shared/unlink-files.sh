cwd=$(CDPATH= cd -- "$(dirname -- "${0}")" && pwd -P)
script="$(basename -- "${0}")"

# TODO: revert backups of existing files
if q_prompt "Do you want to unlink files"; then
  ZDOTDIR="${ZDOTDIR:-${XDG_CONFIG_HOME}/zsh}"

  unlink_file "${ASDF_CONFIG_FILE}"
  move_file "${DOTFILES_BACKUP_DIR}/$(basename -- "${ASDF_CONFIG_FILE}")" \
    "${ASDF_CONFIG_FILE}"

  for dfile in editorconfig gitconfig gitignore shellcheckrc tmux.conf; do
    unlink_file "${HOME}/.${dfile}"
    move_file "${DOTFILES_BACKUP_DIR}/.${dfile}" "${HOME}/.${dfile}"
  done

  for dfile in bash_logout bash_profile bashrc profile zshenv; do
    unlink_file "${HOME}/.${dfile}"
    move_file "${DOTFILES_BACKUP_DIR}/.${dfile}" "${HOME}/.${dfile}"
  done

  for dfile in zlogin zlogout zshrc; do
    unlink_file "${ZDOTDIR}/.${dfile}"
    move_file "${DOTFILES_BACKUP_DIR}/.${dfile}" "${ZDOTDIR}/.${dfile}"
  done

  unlink_file "${XDG_CONFIG_HOME}/shell/bash"
  unlink_file "${XDG_CONFIG_HOME}/shell/common"
  unlink_file "${XDG_CONFIG_HOME}/shell/sh"
  unlink_file "${XDG_CONFIG_HOME}/shell/zsh"
  remove_dir "${XDG_CONFIG_HOME}/shell" 1

  unlink_file "${XDG_CONFIG_HOME}/emacs/init.el"
  move_file "${DOTFILES_BACKUP_DIR}/emacs/init.el" \
    "${XDG_CONFIG_HOME}/emacs/init.el"
  remove_dir "${XDG_CONFIG_HOME}/emacs" 1

  unlink_file "${XDG_CONFIG_HOME}/nvim/lua"
  unlink_file "${XDG_CONFIG_HOME}/nvim/init.vim"
  move_file "${DOTFILES_BACKUP_DIR}/nvim/init.el" \
    "${XDG_CONFIG_HOME}/nvim/init.el"
  remove_dir "${XDG_CONFIG_HOME}/nvim" 1

  unlink_file "${XDG_CONFIG_HOME}/vim/vimrc"
  move_file "${DOTFILES_BACKUP_DIR}/vim/vimrc" \
    "${XDG_CONFIG_HOME}/vim/vimrc"
  remove_dir "${XDG_CONFIG_HOME}/vim" 1

  remove_dir "${DOTFILES_BACKUP_DIR}" 1
fi
