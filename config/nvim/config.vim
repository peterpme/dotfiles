set nocompatible
set shell=/bin/sh

" enable autocomplete
" https://github.com/Shougo/deoplete.nvim
let g:deoplete#enable_at_startup = 1
" let g:neosnippet#enable_completed_snippet = 1

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

" https://neovim.io/doc/user/provider.html
" [nvim] set node path for neovim
let g:node_host_prog = '$HOME/npmbin/node_modules/.bin/neovim-node-host'

" https://neovim.io/doc/user/provider.html
" [nvim] disable ruby provider
let g:loaded_ruby_provider = 0

" https://neovim.io/doc/user/provider.html
" [nvim] the path to python3 is obtained through executing `:echo exepath('python3')` in vim
let g:python3_host_prog = "/usr/local/bin/python3"

" https://neovim.io/doc/user/provider.html
" [nvim] the path to python is obtained through executing `:echo exepath('python')` in vim
let g:python_host_prog = '/usr/local/bin/python'

" https://github.com/jaredly/reason-language-server#vim
" [reason] reason language server
let g:LanguageClient_serverCommands = {
    \ 'reason': ['$HOME/dotfiles/bin/reason-language-server.exe']
    \ }

" https://github.com/tbodt/deoplete-tabnine
" [tabnine]
call deoplete#custom#var('tabnine', {
    \ 'line_limit': 500,
    \ 'max_num_results': 5,
    \ })

" enable 24 bit color support if supported
if (has("termguicolors"))
 set termguicolors
endif

syntax on
syntax enable
filetype plugin indent on

" colorizer https://github.com/norcalli/nvim-colorizer.lua
" lua require'colorizer'.setup()

if &term =~ '256color'
  " disable background color erase
  set t_ut=
endif

" Marks 80th column
if (exists('+colorcolumn'))
    set colorcolumn=80
    highlight ColorColumn ctermbg=9
endif

set t_Co=256 " Explicitly tell vim that the terminal supports 256 colors
set guifont=Iosevka\ Nerd\ Font:h16
set ttyfast " faster redrawing
set autoindent
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set backspace=2                                              " Fix broken backspace in some setups
set backupcopy=yes                                           " see :help crontab
set clipboard=unnamed                                        " yank and paste with the system clipboard
set directory-=.                                             " don't store swapfiles in the current directory
set encoding=utf-8
set expandtab                                                " expand tabs to spaces
set ignorecase                                               " case-insensitive search
set hlsearch                                                 " highlight search results
set incsearch                                                " search as you type
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=space:·,tab:▸\ ,trail:▫,extends:>,precedes:<,nbsp:+,eol:¬
set number                                                   " show line numbers
set ruler                                                    " show where you are
set scrolloff=3                                              " show context above/below cursorline
set shiftwidth=2                                             " normal mode indentation commands use 2 spaces
set showcmd
set smartcase                                                " case-sensitive search if any caps
set softtabstop=2                                            " insert mode tab and backspace use 2 spaces
set smarttab " tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=4                                                " actual tabs occupy 8 characters
set lazyredraw
set synmaxcol=200
set updatetime=250
set nowb
set nobackup
set noswapfile
set mouse=a " Enable basic mouse behavior such as resizing buffers.
set nowrap
set linebreak
set undofile " Enable persistent undo so that undo history persists across vim sessions
set undodir=~/.vim/undo

" highlight all tabs and trailing whitespace characters.
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$\|\t/

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

" force javascript syntax
autocmd BufRead *.js set filetype=javascript
autocmd BufRead *.es6 set filetype=javascript
autocmd BufRead *.jsx set filetype=javascript

" vim-commentary, adjust commentstring to support other libs
autocmd FileType apache setlocal commentstring=#\ %s<Paste>

" fdoc is yaml
autocmd BufRead,BufNewFile *.fdoc set filetype=yaml
" md is markdown
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile *.md set spell
" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" Fix Cursor in TMUX
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Don't change to directory when selecting a file
let g:startify_files_number = 5
let g:startify_change_to_dir = 0
let g:startify_custom_header = [ ]
let g:startify_relative_path = 1
let g:startify_use_env = 1

" Custom startup list, only show MRU from current directory/project
let g:startify_lists = [
\  { 'type': 'dir',       'header': [ 'Files '. getcwd() ] },
\  { 'type': function('helpers#startify#listcommits'), 'header': [ 'Recent Commits' ] },
\  { 'type': 'sessions',  'header': [ 'Sessions' ]       },
\  { 'type': 'bookmarks', 'header': [ 'Bookmarks' ]      },
\  { 'type': 'commands',  'header': [ 'Commands' ]       },
\ ]

let g:startify_commands = [
\   { 'uc': [ 'Clean Plugins', ':PlugClean' ] },
\   { 'up': [ 'Update Plugins', ':PlugUpdate' ] },
\   { 'ug': [ 'Upgrade Plugin Manager', ':PlugUpgrade' ] },
\ ]

let g:startify_bookmarks = [
  \ { 'd': '~/dotfiles' },
  \ { 'c': '~/.config/nvim/init.vim' },
  \ { 'g': '~/.gitconfig' },
  \ { 'z': '~/.zshrc' }
\ ]

"https://github.com/itchyny/lightline.vim
let g:lightline = {
  \ 'colorscheme': 'base16_harmonic_dark',
\ }

" FZF
let g:fzf_layout = { 'down': '~25%' }

if isdirectory(".git")
    " if in a git project, use :GFiles
    nmap <silent> <leader>t :GitFiles --cached --others --exclude-standard<cr>
else
    " otherwise, use :FZF
    nmap <silent> <leader>t :FZF<cr>
endif

" https://github.com/nicknisi/dotfiles/blob/master/config/nvim/init.vim
" Colorscheme and final setup {{{
    " This call must happen after the plug#end() call to ensure
    " that the colorschemes have been loaded
    if filereadable(expand("~/.vimrc_background"))
        let base16colorspace=256
        source ~/.vimrc_background
    else
        let g:onedark_termcolors=256
        let g:onedark_terminal_italics=1
        colorscheme base16-horizon-dark
    endif
    syntax on
    filetype plugin indent on
    " make the highlighting of tabs and other non-text less annoying
    highlight SpecialKey ctermfg=19 guifg=#333333
    highlight NonText ctermfg=19 guifg=#333333

    " make comments and HTML attributes italic
    highlight Comment cterm=italic term=italic gui=italic
    highlight htmlArg cterm=italic term=italic gui=italic
    highlight xmlAttrib cterm=italic term=italic gui=italic
    " highlight Type cterm=italic term=italic gui=italic
    highlight Normal ctermbg=none
" }}}

" vim:set foldmethod=marker foldlevel=0
"
"
" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

" enable syntax highlighting for .js files too instead of just .jsx
let g:jsx_ext_required = 0

" flow syntax highlighting
" let g:javascript_plugin_flow = 1

" JSDoc syntax highlighting
" let g:javascript_plugin_jsdoc = 1

" https://github.com/othree/javascript-libraries-syntax.vim
" let g:used_javascript_libs = 'underscore,react,flux,chai'

" REMOVE ALE
"be explicit about the tools that are running
" let g:ale_linters_explicit = 1

" keep side gutter open https://github.com/dense-analysis/ale#5ii-how-can-i-keep-the-sign-gutter-open
" let g:ale_sign_column_always = 1

" automatic imports from external modules https://github.com/dense-analysis/ale#2iii-completion
" let g:ale_completion_tsserver_autoimport = 1

" format on save
" let g:ale_fix_on_save = 1

" let g:ale_fixers = {
" \   'html': ['prettier'],
" \   'javascript': ['prettier'],
" \   'typescript': ['prettier'],
" \   'css': ['prettier'],
" \}

" let g:ale_linters = {
" \   'html': ['eslint'],
" \   'javascript': ['eslint'],
" \   'typescript': ['tsserver', 'tslint'],
" \}

