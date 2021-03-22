#!/bin/sh -e

if [ -z "$(command -v pyenv || true)" ]; then
  printf "Installing pyenv and dependencies..."
  if [ -n "$(command -v apt || true)" ]; then
    sudo apt update && \
    sudo apt install -y \
      build-essential \
      libssl-dev \
      zlib1g-dev \
      libbz2-dev \
      libreadline-dev \
      libsqlite3-dev \
      wget \
      curl \
      llvm \
      libncurses5-dev \
      libncursesw5-dev \
      xz-utils \
      tk-dev \
      libffi-dev \
      liblzma-dev \
      python3-openssl \
      git
  fi

  ssource shared/pyenv.sh

  printf "DONE\n"
fi
