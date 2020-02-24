call functions#PlugLoad()
call plug#begin('~/.vim/bundle')

" *************************
" General
" *************************

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
"
" disable python2 since its been EOL
let g:loaded_python_provider = 0

let g:loaded_matchit = 1 " Don't need it
let g:loaded_gzip = 1 " Gzip is pointless
let g:loaded_zipPlugin = 1 " zip is also pointless
let g:loaded_logipat = 1 " No logs
let g:loaded_2html_plugin = 1 " Disable 2html
let g:loaded_rrhelper = 1 " I don't use r
let g:loaded_getscriptPlugin = 1 " Dont need it
let g:loaded_tarPlugin = 1 " Nope

" *************************
" Autocomplete
" *************************

" https://github.com/Shougo/deoplete.nvim
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else " for vim 8 with python
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

let g:deoplete#enable_at_startup = 1

" AutoComplete powered by machine learning https://tabnine.com/
Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }

"close deoplete scratch window automatically
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif


" *************************
" Explicit filetypes
" *************************
autocmd BufRead *.js set filetype=javascript
autocmd BufRead *.es6 set filetype=javascript
autocmd BufRead *.jsx set filetype=javascript
autocmd BufRead *.tsx set filetype=typescript
autocmd BufRead *.ts set filetype=typescript
autocmd BufRead *.re set filetype=reason
autocmd BufRead *.rei set filetype=reason
autocmd BufRead *.symlink set filetype=zsh
autocmd BufRead,BufNewFile *.fdoc set filetype=yaml
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile *.md set spell


" *************************
" LanguageClient
" https://github.com/autozimu/LanguageClient-neovim#quick-start
" *************************
Plug 'autozimu/LanguageClient-neovim', {
   \ 'branch': 'next',
   \ 'do': 'bash install.sh',
   \ }

let g:LanguageClient_serverCommands = {}

" https://github.com/jaredly/reason-language-server#vim
" https://github.com/jaredly/reason-language-server/releases/latest/download/bin.exe
if executable('reason-language-server')
 let g:LanguageClient_serverCommands.reason = ['reason-language-server']
endif

" https://github.com/theia-ide/typescript-language-server
if executable('typescript-language-server')
 let g:LanguageClient_serverCommands.javascript = ['typescript-language-server', '--stdio']
 let g:LanguageClient_serverCommands.typescript = ['typescript-language-server', '--stdio']
endif

" https://github.com/vscode-langservers/vscode-css-languageserver-bin
if executable('css-languageserver')
 let g:LanguageClient_serverCommands.css = ['css-languageserver', '--stdio']
 let g:LanguageClient_serverCommands.scss = ['css-languageserver', '--stdio']
 let g:LanguageClient_serverCommands.sass = ['css-languageserver', '--stdio']
endif

" https://github.com/vscode-langservers/vscode-json-languageserver-bin
if executable('json-languageserver')
 let g:LanguageClient_serverCommands.json = ['json-languageserver', '--stdio']
endif

" https://github.com/vscode-langservers/vscode-html-languageserver-bin
if executable('html-languageserver')
 let g:LanguageClient_serverCommands.html = ['html-languageserver', '--stdio']
endif

" https://github.com/redhat-developer/yaml-language-server
if executable('yaml-language-server')
 let g:LanguageClient_serverCommands.yaml = ['yaml-language-server', '--stdio']
endif

" Automatically start language servers.
let g:LanguageClient_autoStart = 1

" gd Show type info (and short doc) of identifier under cursor.
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<cr>

" gf Formats code in normal mode
nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<cr>

" Show type info (and short doc) of identifier under cursor.
nnoremap <silent> <cr> :call LanguageClient_textDocument_hover()<cr>

" Async Linting / Fixing using ALE
" https://github.com/dense-analysis/ale
Plug 'dense-analysis/ale'

" be explicit about whats running
let g:ale_set_balloons = 1

" be explicit about whats running
let g:ale_linters_explicit = 1

" keep side gutter open https://github.com/dense-analysis/ale#5ii-how-can-i-keep-the-sign-gutter-open
let g:ale_sign_column_always = 1

" run the linter only on these
let g:ale_linters = {
  \ 'html': ['eslint'],
  \ 'css': ['eslint'],
  \ 'json': ['eslint'],
  \ 'javascript': ['eslint'],
  \ 'typescript': ['eslint'],
  \}

let g:ale_fixers = {
  \ 'javascript': ['prettier', 'eslint'],
  \ 'typescript': ['prettier', 'eslint'],
  \ 'json': ['prettier', 'eslint'],
  \ 'css': ['prettier'],
  \}

" enable fix on save (prettier,refmt)
let g:ale_fix_on_save = 1

highlight ALEWarning ctermbg=DarkMagenta


" *************************
" Other Fun Stuff
" *************************

" https://github.com/Yggdroot/indentLine
Plug 'Yggdroot/indentLine'

" Wakatime time tracking
Plug 'git://github.com/wakatime/vim-wakatime.git'

" Bottom bar with all settings
Plug 'itchyny/lightline.vim'

" ale + lightline support
Plug 'maximbaz/lightline-ale'

" *************************
" Startify - Fancy Vim Startup Screen
" https://github.com/mhinz/vim-startify
" *************************

Plug 'mhinz/vim-startify'
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
  \ { 'h': '/Volumes/config' },
  \ { 'g': '~/.gitconfig' },
  \ { 'z': '~/.zshrc' }
\ ]

" *************************
" NERDTREE - Tree explorer / sidebar
" https://github.com/preservim/nerdtree
" *************************
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }

nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>

augroup nerdtree
  autocmd!
  autocmd FileType nerdtree setlocal nolist " turn off whitespace characters
  autocmd FileType nerdtree setlocal nocursorline " turn off line highlighting for performance
augroup END

let NERDTreeShowHidden=1

" Snap windows without ruining your layout using ,ww
Plug 'https://github.com/wesQ3/vim-windowswap'

" better terminal integration
" substitute, search, and abbreviate multiple variants of a word
Plug 'tpope/vim-abolish'

" Remaps . in a way that plugins can use it too!
Plug 'tpope/vim-repeat'

" Easily delete, change and add surroundings in pairs
Plug 'tpope/vim-surround'

" endings for html, xml, jsx, etc
Plug 'tpope/vim-ragtag'

"Bracket maps
Plug 'tpope/vim-unimpaired'

" Indent Guides
Plug 'nathanaelkane/vim-indent-guides', {'on': ['IndentGuidesToggle', 'IndentGuidesEnable']}
let g:indent_guides_enable_on_vim_startup = 1

" Set custom colors for indent guides
" let g:indent_guides_auto_colors = 0
" autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
" autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4

" Automatic closing of quotes, parenthesis, brackets, etc
Plug 'Raimondi/delimitMate'

" Change inside surroundings
Plug 'briandoll/change-inside-surroundings.vim'

" focus region, NR will open selected part in new split window
Plug 'chrisbra/NrrwRgn'

" Comments using gcc / gcgc
Plug 'git://github.com/tpope/vim-commentary.git'

" editorconfig support
Plug 'editorconfig/editorconfig-vim'

" vim-commentary, adjust commentstring to support other libs
autocmd FileType apache setlocal commentstring=#\ %s<Paste>

" Git
Plug 'tpope/vim-git'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

nmap <silent> <leader>gs :Gstatus<cr>
nmap <leader>ge :Gedit<c:>
nmap <silent><leader>gr :Gread<cr>
nmap <silent><leader>gb :Gblame<cr>

" Hub extension for fugitive
Plug 'tpope/vim-rhubarb'

" Commit browser https://github.com/junegunn/gv.vim
Plug 'junegunn/gv.vim'

" Branch management https://github.com/sodapopcan/vim-twiggy
Plug 'sodapopcan/vim-twiggy'

" *************************
" Themes
" *************************
Plug 'chriskempson/base16-vim'
Plug 'mike-hearn/base16-vim-lightline'

" *************************
" Text-Related
" *************************

" SOMETHING HERE IS BROKEN !!!
" Expands on commands like 'delete inside' by adding more targets
" Plug 'https://github.com/wellle/targets.vim'

" Better job of detecting sentences
" https://github.com/reedes/vim-textobj-sentence
" Plug 'https://github.com/reedes/vim-textobj-sentence'


" augroup textobj_sentence
  " autocmd!
  " autocmd FileType markdown call textobj#sentence#init()
  " autocmd FileType textile call textobj#sentence#init()
" augroup END

" Makes operating on columns super easy
Plug 'coderifous/textobj-word-column.vim'
Plug 'kana/vim-textobj-datetime'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'lucapette/vim-textobj-underscore'

" Mundo - Undo Search History as a Tree (:MundoToggle)
"https://github.com/simnalamburt/vim-mundo
Plug 'https://github.com/simnalamburt/vim-mundo'

" https://github.com/andymass/vim-matchup
Plug 'andymass/vim-matchup'

" *************************
" Search, Find, Replace
" *************************

" FZF
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

let g:fzf_layout = { 'down': '~25%' }

" Enable per-command history
" - History files will be stored in the specified directory
" - When set, CTRL-N and CTRL-P will be bound to 'next-history' and
"   'previous-history' instead of 'down' and 'up'.
let g:fzf_history_dir = '~/.local/share/fzf-history'

if isdirectory(".git")
    " if in a git project, use :GFiles
    nmap <silent> <leader>t :GitFiles --cached --others --exclude-standard<cr>
else
    " otherwise, use :FZF
    nmap <silent> <leader>t :FZF<cr>
endif

"Use ripgrep
let g:ackprg = 'rg --vimgrep --no-heading'
let g:grepprg='rg --vimgrep'

let g:rg_find_command = 'rg --files --follow  -g "!{.config,etc,node_modules,.git,target,.reast,.d,.cm}/*"'
command! -bang -nargs=* Rg call fzf#vim#files('.', {'source': g:rg_find_command}, 0)

command! -bang -nargs=* Find call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --follow --ignore-case --color=always '.<q-args>, 1,
  \ <bang>0 ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?'), <bang>0)

command! LS call fzf#run(fzf#wrap({'source': 'ls'}))

" *************************
" Language-Related
" *************************

" ReasonML https://github.com/reasonml-editor/vim-reason-plus
Plug 'reasonml-editor/vim-reason-plus'

" Handlebars / Mustache
Plug 'juvenn/mustache.vim'
Plug 'nono/vim-handlebars'

" Typescript
Plug 'HerringtonDarkholme/yats.vim'

" Javascript
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

" vim-javascript settings
let g:vim_jsx_pretty_colorful_config = 1
let g:vim_jsx_pretty_template_tags = ['html', 'javascript', 'jsx']

" json
Plug 'elzr/vim-json', { 'for': 'json' }
let g:vim_json_syntax_conceal = 0

" GraphQL
Plug 'jparise/vim-graphql'

" SCSS and CSS syntax highlighting
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'stephenway/postcss.vim', { 'for': 'css' }

" HTML
Plug 'AndrewRadev/splitjoin.vim'
Plug 'skwp/vim-html-escape'

" Lua
Plug 'https://github.com/xolox/vim-lua-ftplugin.git', {'for': ['lua']}
Plug 'https://github.com/xolox/vim-misc.git', {'for': ['lua']}

call plug#end()

" *************************
" General Enhancements
" *************************

" Normally `:set nocp` is not needed, because it is done automatically
" when .vimrc is found.
if &compatible
  " `:set nocp` has many side effects. Therefore this should be done
  " only when 'compatible' is set.
  set nocompatible
endif

" set default shell to zsh
set shell=/usr/local/bin/zsh

if has('mouse')
    set mouse=a
endif

if (has('nvim'))
  " show results of substition as they're happening
  " but don't open a split
  set inccommand=nosplit
endif

" enable 24 bit color support if supported
if (has("termguicolors"))
 set termguicolors
endif

" colorizer https://github.com/norcalli/nvim-colorizer.lua
" lua require'colorizer'.setup()

if &term =~ '256color'
  " disable background color erase
  set t_ut=
endif

" Override vim's italic codes
" https://www.reddit.com/r/vim/comments/24g8r8/italics_in_terminal_vim_and_tmux/
set t_ZH=^[[3m
set t_ZR=^[[23m
syntax on
syntax enable
filetype plugin indent on

" Marks 80th column
if (exists('+colorcolumn'))
    set colorcolumn=80
    highlight ColorColumn ctermbg=9
endif

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

set t_Co=256 " Explicitly tell vim that the terminal supports 256 colors
set guifont=Iosevka\ Nerd\ Font:h16
set ttyfast " faster redrawing
set conceallevel=0 "show quotes on json files

set autoindent
set autoread " reload files when changed on disk, i.e. via `git checkout`
set textwidth=80

set backspace=indent,eol,start " make backspace behave in a sane manner
set clipboard=unnamed

set directory-=.    " don't store swapfiles in the current directory
set expandtab       " expand tabs to spaces
set encoding=utf-8

set ignorecase  " case-insensitive search
set smartcase   " case-sensitive search if any caps
set hlsearch    " highlight search results
set incsearch   " search as you type
set nolazyredraw "don't redraw while executing macros

set magic " magic for regex"
set hidden " Required for operations modifying multiple buffers like rename.
set signcolumn=yes " sign columns

" error bells
set noerrorbells
set visualbell
set t_vb=
set tm=500
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=space:·,tab:▸\ ,trail:▫,extends:>,precedes:<,nbsp:+,eol:¬
set number                                                   " show line numbers
set ruler                                                    " show where you are
set scrolloff=3                                              " show context above/below cursorline
set shiftwidth=2                                             " normal mode indentation commands use 2 spaces
set showcmd
set softtabstop=2                                            " insert mode tab and backspace use 2 spaces
set smarttab " tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=4                                                " actual tabs occupy 8 characters
set lazyredraw
set synmaxcol=200
set updatetime=250
set nowb
set nobackup
set noswapfile
set nowrap
set linebreak
set undofile " Enable persistent undo so that undo history persists across vim sessions
set undodir=~/.vim/undo

" highlight all tabs and trailing whitespace characters.
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$\|\t/

" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =
autocmd VimResized * exe 'normal! \<c-w>='
autocmd BufWritePost .vimrc,.vimrc.local,init.vim source %
autocmd BufWritePost .vimrc.local source %

" *************************
" Lightline
" https://github.com/itchyny/lightline.vim
" *************************

let g:lightline = {
  \ 'colorscheme': 'base16_harmonic_dark',
  \ }

let g:lightline.component_expand = {
  \  'linter_checking': 'lightline#ale#checking',
  \  'linter_warnings': 'lightline#ale#warnings',
  \  'linter_errors': 'lightline#ale#errors',
  \  'linter_ok': 'lightline#ale#ok',
  \ }

let g:lightline.component_type = {
  \ 'linter_checking': 'left',
  \ 'linter_warnings': 'warning',
  \  'linter_errors': 'error',
  \  'linter_ok': 'left',
  \ }

let g:lightline.active = { 'right': [[ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ]] }

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


" *************************
" Misc Keyboard Shortcuts
" *************************
let mapleader = ','
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" map jj to exit vim (as well as esc)
inoremap jj <ESC>

" inner-line
xnoremap <silent> il :<c-u>normal! g_v^<cr>
onoremap <silent> il :<c-u>normal! g_v^<cr>

" around line
vnoremap <silent> al :<c-u>normal! $v0<cr>
onoremap <silent> al :<c-u>normal! $v0<cr>

" Don't copy the contents of an overwritten selection.
vnoremap p "_dP
