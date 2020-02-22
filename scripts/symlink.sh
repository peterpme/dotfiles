#!/usr/bin/env zsh

DOTFILES=$HOME/dotfiles

setopt EXTENDED_GLOB
echo 'Symlinking zprezto files'
for rcfile in "${ZDOTDIR:-$HOME}"/dotfiles/prezto/runcoms/^README.md(.N); do
	echo $rcfile
	ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

echo "symlinking .symlink files"
for file in $(fd . $DOTFILES -a -d 3 -e symlink); do
	echo "file" $file
	target="$HOME/.$( basename "$file" '.symlink' )"
	echo "target" $target
	if [ -e "$target" ]; then
		echo "~${target#$HOME} already exists... Skipping."
	else
		echo "Creating symlink for $file"
		ln -s "$file" "$target"
	fi
done;

echo -e "\\n\\ninstalling to ~/.config"
echo "=============================="
if [ ! -d "$HOME/.config" ]; then
    echo "Creating ~/.config"
    mkdir -p "$HOME/.config"
fi

# Creating symlinks for ~/.config
for config in $(fd . $DOTFILES/config -d 1 2>/dev/null); do
    target="$HOME/.config/$( basename "$config" )"
    echo $config
    echo $target
    if [ -e "$target" ]; then
        echo "~${target#$HOME} already exists... Skipping."
    else
        echo "Creating symlink for $config"
        ln -s "$config" "$target"
    fi
done

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
