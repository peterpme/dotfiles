#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew install zsh zsh-completions
brew install tmux
brew install reattach-to-user-namespace #tmux requirement"

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils 
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

# Docker related
brew install docker docker-machine docker-compose

# Dock Utility
brew install dockutil

#Neovim
brew install neovim/neovim/neovim

# Install `wget` with IRI support.
brew install wget --with-iri

# Install more recent versions of some macOS tools.
brew install homebrew/dupes/grep
# brew install homebrew/dupes/openssh

# Heroku toolbelt
brew install heroku-toolbelt

# Install font tools.
#brew tap bramstein/webfonttools
#brew install sfnt2woff
#brew install sfnt2woff-zopfli
#brew install woff2

# Install other useful binaries.

# Github
brew install hub

# Silver Searcher
brew install the_silver_searcher

brew install git
brew install imagemagick --with-webp

# faster archive operations
# alias tar='tar --use-compress-program=pigz'
brew install pigz

# monitor progress through pipeline
brew install pv
# brew install rename


# install ssh keys remotely
brew install ssh-copy-id
brew install testssl
brew install tree
brew install vbindiff

# Website Screenshots
# chmod a+x /path/to/webkit2png
brew install webkit2png

# very good but slow compression
brew install zopfli

# colored logcat
brew install pidcat

brew install terminal-notifier

# file path picker
brew install fpp

# Flow type
brew install flow

# Bat cat replacement https://github.com/sharkdp/bat
brew install bat

# Yarn package manager to replace npm
brew install yarn --without-node

# Remove outdated versions from the cellar.
brew cleanup
