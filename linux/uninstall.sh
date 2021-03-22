#!/bin/sh -e

if [ -z "$(command -v is_sourced || true)" ] || ! is_sourced; then
  printf "File should not be called directly\n"
  exit 1
fi

printf "Uninstalling for MacOS...\n"



printf "\nDONE\n"
