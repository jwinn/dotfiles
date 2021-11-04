if [ -n "$(command -v brew || true)" ]; then
  # uninstall formulae
  if [ -n "$(brew list --formula)" ]; then
    if q_prompt "Do you want to uninstall forumlae" "y"; then
      printf "Uninstalling Homebrew formulae...\n"
      brew uninstall --force $(brew list --formula)
    fi
    brew cleanup
  fi

  if q_prompt "Do you want to remove Homebrew"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
  fi
fi
