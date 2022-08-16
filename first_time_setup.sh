#!/usr/bin/env bash

echo "Read through this file first. Hit ctrl+c now."
read -n 1

# Install prezto from peterpme/prezto
zsh
git clone --recursive https://github.com/peterpme/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

echo 'Agree to Xcode & Download'
source scripts/xcode.sh

echo 'Symlink setup'
source scripts/symlink.sh # todo remove prezto from here

echo 'MacOS Setup'
source scripts/osx.sh

echo 'Dock Setup'
source scripts/dock.sh

echo 'Install Yarn'
curl -o- -L https://yarnpkg.com/install.sh | bash

echo 'Install rust'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Done. Reload your terminal!"
