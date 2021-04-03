ag
alacritty

# if using git install,,
# comment out asdf* formulae and uncomment brew deps
# asdf
$(brew deps --1 --for-each asdf | cut -d":" -f2)

dotenv
fd
fff

# if using the jenv installer,
# comment out the nvm formula
# fzf # handle manually

fzy
git
gnupg
go
# iperf
iperf3
iterm2

# if using the jenv installer,
# comment out the nvm formula
# jenv # handle with jenv install

kitty
mosh
mtr

# neovim dev version
--HEAD luajit
--HEAD neovim

nmap
nnn
node

# if using the nvm installer,
# comment out the nvm formula
# nvm # handle with nvm install

# if using pyenv-installer,
# comment out pyenv* formulae and uncomment brew deps
# pyenv pyenv-virtualenv pyenv-which-ext
$(brew deps --1 --for-each pyenv | cut -d":" -f2)

python3

ranger
rg
# shellcheck
tmux
vim

# casks
--cask adobe-creative-cloud
--cask alfred
--cask battle-net
--cask brave-browser
--cask expressvpn
--cask firefox
--cask gog-galaxy
--cask google-chrome
# --cask intellij-idea
--cask little-snitch
--cask postman
--cask slack
--cask steam
--cask visual-studio-code
--cask zoom

# fonts
font-cascadia-code
font-fira-code
font-fira-code-nerd-font
font-hack
font-hack-nerd-font
font-input
font-iosevka
font-iosevka-nerd-font
font-jetbrains-mono
font-jetbrains-mono-nerd-font
font-source-code-pro
