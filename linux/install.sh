#!/bin/sh -e

if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

printf "Installing for Linux...\n"



printf "\nDONE\n"
