#!/usr/bin/env bash

echo "Read through this file first. Hit ctrl+c now."
read -n 1

# Install Homebrew
if test ! "$( command -v brew )"; then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/peter/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo 'Install Homebrew dependencies'
# Install Homebrew dependencies with a Brewfile
brew bundle
brew bundle cleanup
brew cleanup

# Install prezto from peterpme/prezto
zsh
git clone --recursive https://github.com/peterpme/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Symlink prezto dotfiles
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

echo 'Pull in All Submodules'
git submodule update --recursive --remote --init

echo 'Agree to Xcode & Download'
source scripts/xcode.sh

echo 'Symlink setup'
source scripts/symlink.sh # todo remove prezto from here

echo 'MacOS Setup'
source scripts/osx.sh

echo 'Dock Setup'
source scripts/dock.sh

# Install neovim python libraries
echo -e "\\n\\nRunning Neovim Python install"
echo "=============================="
python3 -m pip install --user --upgrade pynvim

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

# Install neovim dependencies
echo 'Install neovim dependencies'
nvim +PlugInstall

# Create ~/.ssh/control file for multiplexing
echo 'Create .ssh/control file for multiplexing support'
mkdir -p ~/.ssh/control

echo 'Install Yarn'
curl -o- -L https://yarnpkg.com/install.sh | bash

echo 'Install Node LTS via fnm'
fnm install --lts

echo 'Install tmux plugin manager'
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo 'Install fzf options'
$(brew --prefix)/opt/fzf/install

echo "Done. Reload your terminal!"
