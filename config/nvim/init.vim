" ensure vim-plug is installed and then load it
call functions#PlugLoad()

if filereadable(expand("~/.config/nvim/plugins.vim"))
  source ~/.config/nvim/plugins.vim
endif

if filereadable(expand("~/.config/nvim/config.vim"))
  source ~/.config/nvim/config.vim
endif

if filereadable(expand("~/.config/nvim/mappings.vim"))
  source ~/.config/nvim/mappings.vim
endif

if filereadable(expand("~/.config/nvim/wildignore.vim"))
  source ~/.config/nvim/wildignore.vim
endif
