" ensure vim-plug is installed and then load it
call functions#PlugLoad()

call plug#begin('~/.vim/bundle')

" *************************
" General Enhancements
" *************************
if has('mouse')
    set mouse=a
endif

if (has('nvim'))
  " show results of substition as they're happening
  " but don't open a split
  set inccommand=nosplit
endif

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" for vim 8 with python
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'

  " Function argument completion for Deoplete
  " Plug 'Shougo/neosnippet'
  " Plug 'Shougo/neosnippet-snippets'
endif

"Language Client https://github.com/autozimu/LanguageClient-neovim#quick-start
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

Plug 'Yggdroot/indentLine'

" https://github.com/norcalli/nvim-colorizer.lua/blob/master/README.md
Plug 'norcalli/nvim-colorizer.lua'

Plug 'elzr/vim-json', { 'for': 'json' }
let g:vim_json_syntax_conceal = 0

" tabnine
" Plug 'zxqfl/tabnine-vim'
Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }

" Wakatime
" Plug 'git://github.com/wakatime/vim-wakatime.git'

" Bottom bar with all settings
Plug 'itchyny/lightline.vim'

" ale + lightline support
Plug 'maximbaz/lightline-ale'

" Async linting ALE
" Plug 'w0rp/ale'

" Alignment
Plug 'austintaylor/vim-indentobject'

" Align anything using `ga` command
Plug 'junegunn/vim-easy-align'

" NERDTREE sidebar
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Fancy start screen. Lets you open empty buffers, multiple files, etc
Plug 'mhinz/vim-startify'

" Snap windows without ruining your layout using ,ww
Plug 'https://github.com/wesQ3/vim-windowswap'

" Remaps . in a way that plugins can use it too!
Plug 'tpope/vim-repeat'

" Easily delete, change and add surroundings in pairs
Plug 'tpope/vim-surround'

"Bracket maps
Plug 'tpope/vim-unimpaired'

" Indent Guides
Plug 'nathanaelkane/vim-indent-guides', {'on': ['IndentGuidesToggle', 'IndentGuidesEnable']}

" Automatic closing of quotes, parenthesis, brackets, etc
Plug 'Raimondi/delimitMate'

" Change inside surroundings
Plug 'briandoll/change-inside-surroundings.vim'

" focus region, NR will open selected part in new split window
Plug 'chrisbra/NrrwRgn'

" Comments using gcc / gcgc
Plug 'git://github.com/tpope/vim-commentary.git'

" editorconfig support
Plug 'sgur/vim-editorconfig'

" Git
Plug 'tpope/vim-git'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

nmap <silent> <leader>gs :Gstatus<cr>
nmap <leader>ge :Gedit<cr>
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

" Expands on commands like 'delete inside' by adding more targets
Plug 'https://github.com/wellle/targets.vim'

" Better job of detecting sentences
Plug 'https://github.com/reedes/vim-textobj-sentence'

" Makes operating on columns super easy
Plug 'coderifous/textobj-word-column.vim'
Plug 'kana/vim-textobj-datetime'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'lucapette/vim-textobj-underscore'
Plug 'vim-scripts/argtextobj.vim'

" Find & replace, etc
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'rking/ag.vim'
Plug 'junegunn/vim-fnr' | Plug 'junegunn/vim-pseudocl' " find & replace
Plug 'vim-scripts/greplace.vim'
Plug 'https://github.com/simnalamburt/vim-mundo'
Plug 'https://github.com/tpope/vim-abolish' " AWESOME case-sensitive replace
Plug 'andymass/vim-matchup'

" *************************
" Language-Related
" *************************

" ReasonML https://github.com/reasonml-editor/vim-reason-plus
Plug 'reasonml-editor/vim-reason-plus'

" Handlebars / Mustache
Plug 'juvenn/mustache.vim'
Plug 'nono/vim-handlebars'

" Typescript
Plug 'leafgarland/typescript-vim'
Plug 'ianks/vim-tsx'

" Javascript
Plug 'https://github.com/othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'thinca/vim-textobj-function-javascript',    { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug '1995eaton/vim-better-javascript-completion', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'chemzqm/vim-jsx-improve', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'gavocanov/vim-js-indent', { 'for': [ 'javascript', 'js', 'jsx' ]}

" Graphql
Plug 'jparise/vim-graphql'

" Toolkit - no syntax highlighting https://github.com/moll/vim-node
Plug 'moll/vim-node', { 'for': [ 'javascript', 'js', 'jsx' ]}

" SCSS and CSS syntax highlighting
if v:version < 704
  Plug 'JulesWang/css.vim'
endif
Plug 'cakebaker/scss-syntax.vim'

" HTML
Plug 'tpope/vim-ragtag'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'skwp/vim-html-escape'

" Lua
Plug 'https://github.com/xolox/vim-lua-ftplugin.git', {'for': ['lua']}
Plug 'https://github.com/xolox/vim-misc.git', {'for': ['lua']}

" Perl
" Plug 'https://github.com/c9s/perlomni.vim', {'for': ['pl', 'perl', 'p6', 'pm']}

" devicons https://github.com/ryanoasis/vim-devicons
" always load as last one!
Plug 'ryanoasis/vim-devicons'

call plug#end()

" Normally `:set nocp` is not needed, because it is done automatically
" when .vimrc is found.
if &compatible
  " `:set nocp` has many side effects. Therefore this should be done
  " only when 'compatible' is set.
  set nocompatible
endif

" set default shell
set shell=/bin/sh

" enable autocomplete
" https://github.com/Shougo/deoplete.nvim
let g:deoplete#enable_at_startup = 1
" let g:neosnippet#enable_completed_snippet = 1

" https://github.com/Shougo/deoplete.nvim/blob/378feff8772d0e9f9ef2c94284947f3666576500/doc/deoplete.txt
call deoplete#custom#option({
\ 'prev_completion_mode': "mirror",
\ })

" https://github.com/tbodt/deoplete-tabnine
" [tabnine]
call deoplete#custom#var('tabnine', {
    \ 'line_limit': 500,
    \ 'max_num_results': 5,
    \ })

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
    \ 'reason': ['/Users/peter/bin/reason-language-server']
    \ }

let g:loaded_matchit = 1 " Don't need it
let g:loaded_gzip = 1 " Gzip is pointless
let g:loaded_zipPlugin = 1 " zip is also pointless
let g:loaded_logipat = 1 " No logs
let g:loaded_2html_plugin = 1 " Disable 2html
let g:loaded_rrhelper = 1 " I don't use r
let g:loaded_getscriptPlugin = 1 " Dont need it
let g:loaded_tarPlugin = 1 " Nope

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
set conceallevel=0 "show quotes on json files"
set autoindent
set autoread " reload files when changed on disk, i.e. via `git checkout`
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
set nowrap
set linebreak
set undofile " Enable persistent undo so that undo history persists across vim sessions
set undodir=~/.vim/undo

" highlight all tabs and trailing whitespace characters.
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$\|\t/

" FZF
let g:fzf_layout = { 'down': '~25%' }

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

" TBD about this one
let g:rg_find_command = 'rg --files --follow  -g "!{.config,etc,node_modules,.git,target}/*"'
command! -bang -nargs=* Find call fzf#vim#grep('rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)
command! -bang -nargs=* Rg call fzf#vim#files('.', {'source': g:rg_find_command}, 0)

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

" omnifuncs
augroup omnifuncs
  autocmd!
  " autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  " autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  " autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  " autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup end

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

" keyboard shortcuts

let mapleader = ','
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
nnoremap <leader>a :Ag<space>

nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
nnoremap <leader>t :FZF<CR>
nnoremap <leader>g :GitGutterToggle<CR>

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

inoremap jj <ESC>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" inner-line
xnoremap <silent> il :<c-u>normal! g_v^<cr>
onoremap <silent> il :<c-u>normal! g_v^<cr>

" around line
vnoremap <silent> al :<c-u>normal! $v0<cr>
onoremap <silent> al :<c-u>normal! $v0<cr>

"gd Show type info (and short doc) of identifier under cursor.
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<cr>
"gf Formats code in normal mode
nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<cr>
"Show type info (and short doc) of identifier under cursor.
nnoremap <silent> <cr> :call LanguageClient_textDocument_hover()<cr>

" Don't copy the contents of an overwritten selection.
vnoremap p "_dP

"close deoplete scratch window automatically
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" neomake
" nmap <Leader><Space>o :lopen<CR>      " open location window
" nmap <Leader><Space>, :ll<CR>         " go to current error/warning
" nmap <Leader><Space>n :lnext<CR>      " next error/warning
" nmap <Leader><Space>p :lprev<CR>      " previous error/warning

set suffixes=~,.aux,.bak,.bkp,.dvi,.hi,.o,.pdf,.gz,.idx,.log,.ps,.swp,.tar,.ilg,.bbl,.toc,.ind
set wildmenu                                                 " show a navigable menu for tab completion
set wildcharm=<Tab>
set wildmode=list:longest
" set wildmode=longest,list,full
set wildignore+=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildignore+=*.egg,*.egg-info
set wildignore+=*.gem
set wildignore+=*.gem
set wildignore+=*.javac
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*.png,*.jpg,*.gif
set wildignore+=*.pyc
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/Library/**,*/.rbenv/**
set wildignore+=*/.nx/**,*.app
set wildignore+=*DS_Store*
set wildignore+=*sass-cache*
set wildignore+=*vim/backups*
set wildignore+=.coverage
set wildignore+=.coverage/**
set wildignore+=.env
set wildignore+=.env-pypy
set wildignore+=.env[0-9]+
set wildignore+=.git,.gitkeep
set wildignore+=.idea/**
set wildignore+=.sass-cache/
set wildignore+=.tmp
set wildignore+=.tox/**
set wildignore+=.vagrant/**
set wildignore+=.webassets-cache/
set wildignore+=__pycache__/
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=vendor/cache/**
set wildignore+=vendor/rails/**
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
