# Peter's dotfiles

Dotfiles and automations that make my life easier (or harder lol)

- [Prezto](https://github.com/sorin-ionescu/prezto)
A lightweight zsh configuration framework with sensible defaults. It's fast, too!

- [Homebrew](https://brew.sh)
The Missing Package Manager for MacOS (or Linux)

- [Mac App Store CLI](https://github.com/mas-cli/mas)
A CLI for the Mac App Store. Installs all your favorite apps in just 1 line!

- [Hammerspoon](https://github.com/Hammerspoon/hammerspoon)
Staggeringly powerful MacOS desktop automation with Lua

- [Neovim](https://neovim.io/)
A modern, ground up rewrite of Vim

- [Kitty](https://sw.kovidgoyal.net/kitty/)
A fast, GPU based terminal alternative to iTerm

- [Tmux](https://github.com/tmux/tmux/wiki)
Create, split, save, move terminal tabs easily all within one window.

- [Fzf](https://github.com/junegunn/fzf)
The fastest way to search for ANYTHING on your computer

- [Forgit](https://github.com/wfxr/forgit)
Use git interactively. Powered by fzf

- [PowerLevel10k](https://github.com/romkatv/powerlevel10k)
A zsh theme that emphasizes speed, flexibility and an out-of-the-box experience

## Screenshots

## Getting Started

Check out `./install.sh`. You'll have to run `./install all` or pick the section you'd like to run.

- Install Homebrew & dependencies
- Install Xcode and Xcode CLI tools
- Setup symlinks and config

## Post-automation updates
- Install [NVChad](https://nvchad.github.io/quickstart/install#pre-requisites) if you haven't yet. This replaces the local nvim config

Files that store personal info or api keys are gitignored. Make sure you either comment these references out, or set them up:

- `~/.npmrc`
- `~/.gitconfig.local`
- `~/.ssh/config`
- [Nicer kitty icon](https://github.com/DinkDonk/kitty-icon)
- Download & Install into `~/.local/share/fonts/` [Symbols-2048-em Nerd Font Complete.ttf](https://github.com/ryanoasis/nerd-fonts/blob/master/src/glyphs/Symbols-2048-em%20Nerd%20Font%20Complete.ttf)

## Vim and Neovim Setup

[Neovim](https://neovim.io/) is a fork and drop-in replacement for vim. in most cases, you would not notice a difference between the two, other than Neovim allows plugins to run asynchronously so that they do not freeze the editor, which is the main reason I have switched over to it. Vim and Neovim both use Vimscript and most plugins will work in both (all of the plugins I use do work in both Vim and Neovim). For this reason, they share the same configuration files in this setup. Neovim uses the [XDG base directory specification](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html) which means it won't look for a `.vimrc` in your home directory. Instead, its configuration looks like the following:

|                         | Vim        | Neovim                    |
| ----------------------- | ---------- | ------------------------- |
| Main Configuration File | `~/.vimrc` | `~/.config/nvim/init.vim` |
| Configuration directory | `~/.vim`   | `~/.config/nvim`          |

## Thanks

I've been working on my dotfiles for over 8 years. A lot of it is thanks to the community and some of my favorite people / projects:

- [Maximum Awesome](https://github.com/square/maximum-awesome)
- [Paul Irish Dotfiles](https://github.com/paulirish/dotfiles)
- [Nick Nisi Dotfiles](https://github.com/nicknisi/dotfiles)
- [Mathias Bynens Dotfiles](https://github.com/mathiasbynens/dotfiles)

