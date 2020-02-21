#!/bin/zsh
setopt EXTENDED_GLOB
echo 'set dotfiles'
for rcfile in "${ZDOTDIR:-$HOME}"/dotfiles/prezto/runcoms/^README.md(.N); do
	echo $rcfile
	ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
