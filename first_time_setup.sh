#!/usr/bin/env bash

command_exists() {
    type "$1" > /dev/null 2>&1
}

echo "Read through this file first. Hit ctrl+c now."
read -n 1

# Disable Gatekeeper (unidentified developer)
sudo spctl --master-disable

# ====================================
# ====================================

# Set up symlinks
source scripts/symlink.sh

echo 'Symlink Setup'
./scripts/symlink_general_files.sh

echo 'Symlink prezto dotfiles'
./scripts/symlink_prezto_dotfiles.sh

# ====================================
# ====================================

# Agree to Xcode & Download Tools
echo 'Agree to Xcode & Download'
source scripts/xcode.sh

# Git Config
echo 'Git Config'
source scripts/git.sh

# gitconfig
# ln -s ~/dotfiles/.gitconfig.local ~/.gitconfig.local

echo 'Pull in All Submodules'
git submodule update --recursive --remote

echo -e "\\n\\nRunning on macOS"

if test ! "$( command -v brew )"; then
    echo "Installing homebrew"
    ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install )"
fi

# install brew dependencies from Brewfile
brew bundle

# After the install, setup fzf
echo -e "\\n\\nRunning fzf install script..."
echo "=============================="
/usr/local/opt/fzf/install --all --no-bash --no-fish

# after the install, install neovim python libraries
echo -e "\\n\\nRunning Neovim Python install"
echo "=============================="
pip3 install pynvim

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

echo 'MacOS Setup'
source scripts/osx.sh

echo 'Dock Setup'
./scripts/dock_setup.sh

echo "Creating vim directories"
mkdir -p ~/.vim-tmp

if ! command_exists zsh; then
    echo "zsh not found. Please install and then re-run installation scripts"
    exit 1
elif ! [[ $SHELL =~ .*zsh.* ]]; then
    echo "Configuring zsh as default shell"
    chsh -s "$(command -v zsh)"
fi

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

echo "Done. Reload your terminal."
