#!/usr/bin/env zsh

DOTFILES=$HOME/dotfiles

# ======================================
# creating ~/.vimrc, ~/.vim symlinks to use nvim
# ======================================
echo -e "\\n\\nCreating vim symlinks"
echo "=============================="
VIMFILES=( "$HOME/.vim:$DOTFILES/config/nvim"
        "$HOME/.vimrc:$DOTFILES/config/nvim/init.vim" )

for file in "${VIMFILES[@]}"; do
    KEY=${file%%:*}
    VALUE=${file#*:}
    if [ -e "${KEY}" ]; then
        echo "${KEY} already exists... skipping."
    else
        echo "Creating symlink for $KEY"
        ln -s "${VALUE}" "${KEY}"
    fi
done
