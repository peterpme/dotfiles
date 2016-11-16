#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew install zsh zsh-completions

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names

brew install docker docker-machine

#Neovim
brew install neovim/neovim/neovim

# Switch to using brew-installed zsh as default shell
if ! fgrep -q '/Users/peter/.homebrew/bin/zsh' /etc/shells; then
  echo '/Users/peter/.homebrew/bin/zsh' | sudo tee -a /etc/shells;
  chsh -s /Users/peter/.homebrew/bin/zsh;
fi;

# Install `wget` with IRI support.
brew install wget --with-iri

# Install more recent versions of some macOS tools.
brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh

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

# file path picker
brew install fpp

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

# Remove outdated versions from the cellar.
brew cleanup
