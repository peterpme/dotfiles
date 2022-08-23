git clone --recursive https://github.com/peterpme/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# Symlink prezto dotfiles
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
