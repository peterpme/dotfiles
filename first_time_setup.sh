#!/usr/bin/bash

# copy paste this file in bit by bit.
# don't run it.
  echo "do not run this script in one go. hit ctrl-c NOW"
  read -n 1

# Agree to Xcode & Download Tools
./scripts/xcode_devtools.sh

# Homebrew
# alternative to /usr/local to avoid sudo and lock down /usr/local
mkdir $HOME/.homebrew && curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
export PATH=$HOME/.homebrew/bin:$HOME/.homebrew/sbin:$PATH

# install brew packages
./scripts/brew_install.sh
./scripts/brew_cask_install.sh

# Z
# github.com/rupa/z
git clone https://github.com/rupa/z.git ~/dotfiles/z

# Disable Gatekeeper (unidentified developer)
sudo spctl --master-disable

# Neovim has an issue with ctrl + h escape key (READ THIS)
# https://github.com/neovim/neovim/issues/2048#issuecomment-98307896

###  Instructions:

# Edit -> Preferences -> Keys
# Press +
# Press Ctrl+h as Keyboard Shortcut
# Choose Send Escape Sequence as Action
# Type [104;5u for Esc+

# Change Shell to ZSH
ZSHPATH=$(brew --prefix)/bin/zsh
sudo bash -c 'echo $(brew --prefix)/bin/zsh >> /etc/shells'
chsh -s $ZSHPATH
echo zsh --version
