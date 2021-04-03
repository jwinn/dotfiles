if [ -n "$(command -v brew || true)" ]; then
  # uninstall formulae
  if q_prompt "Do you want to uninstall forumlae" "y"; then
    printf "Uninstalling Homebrew formulae...\n"
    brew uninstall --force $(brew list --formula)
    brew cleanup
  fi

  if q_prompt "Do you want to remove Homebrew"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
  fi
fi
