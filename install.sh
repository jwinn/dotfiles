#!/bin/sh -e

#cwd=$(dirname -- "$0")
cwd=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
ignore="README.md install.sh base16-default.dark.itermcolors iterm.base16.itermcolors"

if [ -n "${XDG_CONFIG_HOME}" ]; then
  ignore="${ignore} vimrc"
  vimdir="${XDG_CONFIG_HOME}/vim"
  nvimdir="${XDG_CONFIG_HOME}/nvim"

  mkdir -p "${vimdir}"
  mkdir -p "${nvimdir}"

  ln -sf "${cwd}/vimrc" "${vimdir}/vimrc"
  printf "linked %s -> %s\\n" "${cwd}/vimrc" "${vimdir}/vimrc"
  ln -sf "${cwd}/vimrc" "${nvimdir}/init.vim"
  printf "linked %s -> %s\\n" "${cwd}/vimrc" "${nvimdir}/init.vim"
fi

str_in() { [ "${1#*$2}" != "$1" ] && return 0 || return 1; }

for file in "${cwd}"/[!.]*;
do
	filename=$(basename -- "${file}")
	if [ -f "${file}" ] && ! str_in "${ignore}" "${filename}"; then
		ln -sf "${file}" "${HOME}/.${filename}"
		printf "linked %s -> %s\\n" "${file}" ".${filename}"
	fi
done
