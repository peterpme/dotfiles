setopt EXTENDED_GLOB
for rcfile in "~/dotfiles/prezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
