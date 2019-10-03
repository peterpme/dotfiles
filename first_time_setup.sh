#!/usr/bin/bash

# copy paste this file in bit by bit.  don't run it.
  echo "do not run this script in one go. hit ctrl-c NOW"
  read -n 1

# Agree to Xcode & Download Tools
echo 'Agree to Xcode & Download'
./scripts/xcode_devtools.sh

# Git Friendly https://github.com/jamiew/git-
curl -sS https://raw.githubusercontent.com/jamiew/git-friendly/master/install.sh | bash

# vim plug https://github.com/junegunn/vim-plug#neovim
touch ~/dotfiles/config/nvim/autoload/plug.vim
curl -fLo ~/dotfiles/config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Homebrew https://brew.sh

echo 'Install Homebrew'
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Disable Gatekeeper (unidentified developer)
sudo spctl --master-disable

echo 'Install Node Version Manager and set global default to node 7'
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | NODE_VERSION=7 bash

# install brew packages
echo 'Install Homebrew packages'
./scripts/brew_install.sh

echo 'Install Homebrew Cask packages'
./scripts/brew_cask_install.sh

echo 'macOS Setup'
./scripts/macos_setup.sh

echo 'Dock Setup'
./scripts/dock_setup.sh

echo 'Setup SSH'
./scripts/ssh_setup.sh

echo 'Pull in All Submodules'
git submodule update --recursive --remote

# Z
# github.com/rupa/z
echo 'Install Z'
git clone https://github.com/rupa/z.git ~/dotfiles/z

echo 'SSh-ADD -A'
curl -o ~/Library/LaunchAgents/ssh.add.a.plist https://raw.githubusercontent.com/jirsbek/SSH-keys-in-macOS-Sierra-keychain/master/ssh.add.a.plist

# Git Config
echo 'Git Config'
./scripts/git_config.sh

# Install Global Npm Modules
./scripts/global_node_modules.sh


# Neovim has an issue with ctrl + h escape key (READ THIS)
# https://github.com/neovim/neovim/issues/2048#issuecomment-98307896

###  Instructions:

# Edit -> Preferences -> Keys
# Press +
# Press Ctrl+h as Keyboard Shortcut
# Choose Send Escape Sequence as Action
# Type [104;5u for Esc+

# Change Shell to ZSH
echo 'Switch shell to ZSH'
ZSHPATH=$(brew --prefix)/bin/zsh
sudo bash -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells'
chsh -s $ZSHPATH
echo zsh --version

echo 'Symlink Setup'
./scripts/symlink_general_files.sh

# echo 'Symlink Nvim Dotfiles'
# ./scripts/symlink_nvim_dotfiles.sh

echo 'Symlink prezto dotfiles'
./scripts/symlink_prezto_dotfiles.sh

# gitconfig
ln -s ~/dotfiles/.gitconfig.local ~/.gitconfig.local

