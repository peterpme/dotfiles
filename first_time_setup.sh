#!/usr/bin/env bash

echo "Read through this file first. Hit ctrl+c now."
read -n 1

# Install prezto from peterpme/prezto
zsh
git clone --recursive https://github.com/peterpme/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

echo 'MacOS Setup'
source scripts/osx.sh

echo 'Dock Setup'
source scripts/dock.sh

