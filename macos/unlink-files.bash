if q_prompt "Do you want to unlink files"; then
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
