#!/usr/bin/env bash

command_exists() {
    type "$1" > /dev/null 2>&1
}

echo "Read through this file first. Hit ctrl+c now."
read -n 1

# Disable Gatekeeper (unidentified developer)
sudo spctl --master-disable

# Git Config
echo 'Git Config'
# source scripts/git.sh

# gitconfig
# ln -s ~/dotfiles/.gitconfig.local ~/.gitconfig.local


echo -e "\\n\\nRunning on macOS"

# Install Homebrew
if test ! "$( command -v brew )"; then
    echo "Installing homebrew"
    ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install )"
fi

# Install brew dependencies from Brewfile
brew bundle

# Agree to Xcode & Download Tools
echo 'Agree to Xcode & Download'
source scripts/xcode.sh

echo 'Pull in All Submodules'
git submodule update --recursive --remote --init

# After the install, setup fzf
echo -e "\\n\\nRunning fzf install script..."
echo "=============================="
/usr/local/opt/fzf/install --all --no-bash --no-fish

# after the install, install neovim python libraries
echo -e "\\n\\nRunning Neovim Python install"
echo "=============================="
pip3 install --user pynvim

# Change the default shell to zsh
zsh_path="$( command -v zsh )"
if ! grep "$zsh_path" /etc/shells; then
    echo "adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells
fi

if [[ "$SHELL" != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
    echo "default shell changed to $zsh_path"
fi

echo 'Symlink setup'
source scripts/symlink.sh

echo 'MacOS Setup'
source scripts/osx.sh

echo 'Dock Setup'
./scripts/dock.sh

echo "Done. Reload your terminal!"

