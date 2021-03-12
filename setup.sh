#!/bin/sh -e

#cwd=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
cwd=$(cd -- "$(dirname -- "$0")" && pwd -P)
dotfiles="${cwd}/dotfiles"

# ensure functions exist
if [ -z "$(command -v ssource || true)" ]; then
  . "${dotfiles}/shell/common/env_functions"
fi
if [ -z "$(command -v link_file || true)" ]; then
  ssource "${dotfiles}/shell/common/functions"
fi

# set xdg config home
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
ZDOTDIR=${ZDOTDIR:-${XDG_CONFIG_HOME}/shell/zsh}

case "$1" in
  i|install)
    create_dir "${XDG_CONFIG_HOME}"/shell
    link_file "${dotfiles}"/shell/bash "${XDG_CONFIG_HOME}"/shell/bash
    link_file "${dotfiles}"/shell/common "${XDG_CONFIG_HOME}"/shell/common
    link_file "${dotfiles}"/shell/sh "${XDG_CONFIG_HOME}"/shell/sh
    link_file "${dotfiles}"/shell/zsh "${XDG_CONFIG_HOME}"/shell/zsh
    create_dir "${XDG_CONFIG_HOME}"/emacs
    link_file "${dotfiles}"/emacs "${XDG_CONFIG_HOME}"/emacs/init.el
    create_dir "${XDG_CONFIG_HOME}"/nvim
    link_file "${dotfiles}"/vimrc "${XDG_CONFIG_HOME}"/nvim/init.vim
    create_dir "${XDG_CONFIG_HOME}"/vim
    link_file "${dotfiles}"/vimrc "${XDG_CONFIG_HOME}"/vim/vimrc

    link_file "${dotfiles}"/shell/.bash_logout "${HOME}"/.bash_logout
    link_file "${dotfiles}"/shell/.bash_profile "${HOME}"/.bash_profile
    link_file "${dotfiles}"/shell/.bashrc "${HOME}"/.bashrc
    link_file "${dotfiles}"/shell/.profile "${HOME}"/.profile
    link_file "${dotfiles}"/shell/.zlogin "${ZDOTDIR}"/.zlogin
    link_file "${dotfiles}"/shell/.zlogout "${ZDOTDIR}"/.zlogout
    link_file "${dotfiles}"/shell/.zshenv "${HOME}"/.zshenv
    link_file "${dotfiles}"/shell/.zshrc "${ZDOTDIR}"/.zshrc

    link_file "${dotfiles}"/editorconfig "${HOME}"/.editorconfig
    link_file "${dotfiles}"/gitconfig "${HOME}"/.gitconfig
    link_file "${dotfiles}"/gitignore "${HOME}"/.gitignore
    link_file "${dotfiles}"/shellcheckrc "${HOME}"/.shellcheckrc
    link_file "${dotfiles}"/tmux.conf "${HOME}"/.tmux.conf
    ;;
  rm|remove)
    printf "This is destructive, are you sure? (yN)"
    read -r shell_setup_answer
    if [ -z "${shell_setup_answer#[Yy]}" ]; then
      unlink_file "${HOME}"/.editorconfig
      unlink_file "${HOME}"/.gitconfig
      unlink_file "${HOME}"/.gitignore
      unlink_file "${HOME}"/.shellcheckrc
      unlink_file "${HOME}"/.tmux.conf

      unlink_file "${HOME}"/.bash_logout
      unlink_file "${HOME}"/.bash_profile
      unlink_file "${HOME}"/.bashrc
      unlink_file "${HOME}"/.profile
      unlink_file "${ZDOTDIR}"/.zlogin
      unlink_file "${ZDOTDIR}"/.zlogout
      unlink_file "${HOME}"/.zshenv
      unlink_file "${ZDOTDIR}"/.zshrc

      unlink_file "${XDG_CONFIG_HOME}"/shell/bash
      unlink_file "${XDG_CONFIG_HOME}"/shell/common
      unlink_file "${XDG_CONFIG_HOME}"/shell/sh
      unlink_file "${XDG_CONFIG_HOME}"/shell/zsh
      remove_dir "${XDG_CONFIG_HOME}"/shell
      unlink_file "${XDG_CONFIG_HOME}"/emacs/init.el
      remove_dir "${XDG_CONFIG_HOME}"/emacs
      unlink_file "${XDG_CONFIG_HOME}"/nvim/init.vim
      remove_dir "${XDG_CONFIG_HOME}"/nvim
      unlink_file "${XDG_CONFIG_HOME}"/vim/vimrc
      remove_dir "${XDG_CONFIG_HOME}"/vim
    fi
    ;;
  *)
    printf "Usage: $(basename -- "$0") i|install|rm|remove\n"
    exit 1
    ;;
esac
