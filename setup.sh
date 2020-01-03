#!/bin/sh -e

#cwd=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
cwd=$(cd -- "$(dirname -- "$0")" && pwd -P)
# set xdg config home
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
ZDOTDIR=${ZDOTDIR:-${XDG_CONFIG_HOME}/shell/zsh}

case "$1" in
  i|install)
    mkdir -p "${ZDOTDIR}"
    cp -f "${cwd}"/shell/.bash_logout "${HOME}"/.bash_logout
    cp -f "${cwd}"/shell/.bash_profile "${HOME}"/.bash_profile
    cp -f "${cwd}"/shell/.bashrc "${HOME}"/.bashrc
    cp -f "${cwd}"/shell/.profile "${HOME}"/.profile
    cp -f "${cwd}"/shell/.zlogout "${ZDOTDIR}"/.zlogout
    cp -f "${cwd}"/shell/.zshenv "${HOME}"/.zshenv
    cp -f "${cwd}"/shell/.zshrc "${ZDOTDIR}"/.zshrc

    mkdir -p "${XDG_CONFIG_HOME}"/shell
    cp -Rf "${cwd}/"shell/bash "${XDG_CONFIG_HOME}"/shell/
    cp -Rf "${cwd}/"shell/common "${XDG_CONFIG_HOME}"/shell/
    cp -Rf "${cwd}/"shell/sh "${XDG_CONFIG_HOME}"/shell/
    cp -Rf "${cwd}/"shell/zsh "${XDG_CONFIG_HOME}"/shell/

    cp -Rf "${cwd}"/emacs "${XDG_CONFIG_HOME}"/emacs

    mkdir -p "${XDG_CONFIG_HOME}"/nvim
    cp -f "${cwd}"/vimrc "${XDG_CONFIG_HOME}"/nvim/init.vim
    mkdir -p "${XDG_CONFIG_HOME}"/vim
    cp -f "${cwd}"/vimrc "${XDG_CONFIG_HOME}"/vim/vimrc

    cp -f "${cwd}"/editorconfig "${HOME}"/.editorconfig
    cp -f "${cwd}"/gitconfig "${HOME}"/.gitconfig
    cp -f "${cwd}"/gitignore "${HOME}"/.gitignore
    cp -f "${cwd}"/shellcheckrc "${HOME}"/.shellcheckrc
    cp -f "${cwd}"/tmux.conf "${HOME}"/.tmux.conf
    ;;
  rm|remove)
    printf "This is destructive, are you sure? (yN)"
    read -r shell_setup_answer
    if [ -z "${shell_setup_answer#[Yy]}" ]; then
      rm -f "${HOME}"/.bash_logout
      rm -f "${HOME}"/.bash_profile
      rm -f "${HOME}"/.bashrc
      rm -f "${HOME}"/.profile
      rm -f "${ZDOTDIR}"/.zlogout
      rm -f "${HOME}"/.zshenv
      rm -f "${ZDOTDIR}"/.zshrc

      rm -rf "${XDG_CONFIG_HOME}"/shell

      rm -rf "${XDG_CONFIG_HOME}"/emacs

      rm -rf "${XDG_CONFIG_HOME}"/nvim
      rm -rf "${XDG_CONFIG_HOME}"/vim

      rm -f "${HOME}"/.editorconfig
      rm -f "${HOME}"/.gitconfig
      rm -f "${HOME}"/.gitignore
      rm -f "${HOME}"/.shellcheckrc
      rm -f "${HOME}"/.tmux.conf
    fi
    ;;
  *)
    printf "Usage: $(basename -- "$0") i|install|rm|remove\n"
    exit 1
    ;;
esac
