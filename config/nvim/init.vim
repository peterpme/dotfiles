" *************************
" VimPlug
" *************************
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

" https://github.com/Shougo/deoplete.nvim
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else " for vim 8 with python
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" https://github.com/mhartington/nvim-typescript
" Plug 'mhartington/nvim-typescript', {'do': './install.sh'}

let g:deoplete#enable_at_startup = 1

" disable default snippets
" let g:neosnippet#disable_runtime_snippets = 1

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

" Tabnine AutoComplete https://tabnine.com/
Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }

" omnifuncs
augroup omnifuncs
  autocmd!
  " autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  " autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  " autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  " autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup end

"close deoplete scratch window automatically
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" Normally `:set nocp` is not needed, because it is done automatically
" when .vimrc is found.
if &compatible
  " `:set nocp` has many side effects. Therefore this should be done
  " only when 'compatible' is set.
  set nocompatible
endif

set shell=/usr/local/bin/zsh "set default shell to zsh

" *************************
" Language Server Related
" *************************
autocmd BufRead *.js set filetype=javascript
autocmd BufRead *.es6 set filetype=javascript
autocmd BufRead *.jsx set filetype=javascript
autocmd BufRead *.tsx set filetype=typescript
autocmd BufRead *.ts set filetype=typescript
autocmd BufRead *.re set filetype=reason
autocmd BufRead *.rei set filetype=reason
autocmd BufRead,BufNewFile *.fdoc set filetype=yaml
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile *.md set spell

set hidden " Required for operations modifying multiple buffers like rename.
set signcolumn=yes " sign columns

" *************************
" VIM LSP
" *************************
" Plug 'prabirshrestha/async.vim'
" Plug 'prabirshrestha/vim-lsp'

" if executable('reason-language-server')
"   au User lsp_setup call lsp#register_server({
"     \ 'name': 'reason-language-server',
"     \ 'cmd': {server_info->[&shell, &shellcmdflag, 'reason-language-server']},
"     \ 'whitelist': ['reason'],
"     \ })
" endif

" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('~/vim-lsp.log')

" " for asyncomplete.vim log
" let g:asyncomplete_log_file = expand('~/asyncomplete.log')

" *************************
" LanguageClient
" *************************
"
" Language Client https://github.com/autozimu/LanguageClient-neovim#quick-start
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

" Async linting ALE
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

" vim-commentary, adjust commentstring to support other libs
autocmd FileType apache setlocal commentstring=#\ %s<Paste>

Plug 'Yggdroot/indentLine'

" https://github.com/norcalli/nvim-colorizer.lua/blob/master/README.md
Plug 'norcalli/nvim-colorizer.lua'

Plug 'elzr/vim-json', { 'for': 'json' }
let g:vim_json_syntax_conceal = 0

" Wakatime time tracking
Plug 'git://github.com/wakatime/vim-wakatime.git'

" Bottom bar with all settings
Plug 'itchyny/lightline.vim'

" ale + lightline support
Plug 'maximbaz/lightline-ale'

" Alignment
Plug 'austintaylor/vim-indentobject'

" Align anything using `ga` command
Plug 'junegunn/vim-easy-align'

" NERDTREE sidebar
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
" Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
nnoremap <leader>g :GitGutterToggle<CR>

" let NERDTreeDirArrowExpandable = "\u00a0" " make arrows invisible
" let NERDTreeDirArrowCollapsible = "\u00a0" " make arrows invisible
" let NERDTreeNodeDelimiter = "\u263a" " smiley face

augroup nerdtree
  autocmd!
  autocmd FileType nerdtree setlocal nolist " turn off whitespace characters
  autocmd FileType nerdtree setlocal nocursorline " turn off line highlighting for performance
augroup END

let NERDTreeShowHidden=1

" let g:NERDTreeIndicatorMapCustom = {
"   \ "Modified"  : "✹",
"   \ "Staged"    : "✚",
"   \ "Untracked" : "✭",
"   \ "Renamed"   : "➜",
"   \ "Unmerged"  : "═",
"   \ "Deleted"   : "✖",
"   \ "Dirty"     : "✗",
"   \ "Clean"     : "✔︎",
"   \ 'Ignored'   : '☒',
"   \ "Unknown"   : "?"
"   \ }

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
" Plug 'lucapette/vim-textobj-underscore'
Plug 'vim-scripts/argtextobj.vim'

" FZF
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

" Using floating windows of Neovim to start fzf
if has('nvim')
  let $FZF_DEFAULT_OPTS .= ' --border --margin=0,2'

  function! FloatingFZF()
    let width = float2nr(&columns * 0.9)
    let height = float2nr(&lines * 0.6)
    let opts = { 'relative': 'editor',
               \ 'row': (&lines - height) / 2,
               \ 'col': (&columns - width) / 2,
               \ 'width': width,
               \ 'height': height }

    let win = nvim_open_win(nvim_create_buf(v:false, v:true), v:true, opts)
    call setwinvar(win, '&winhighlight', 'NormalFloat:Normal')
  endfunction

  let g:fzf_layout = { 'window': 'call FloatingFZF()' }
endif

" Enable per-command history
" - History files will be stored in the specified directory
" - When set, CTRL-N and CTRL-P will be bound to 'next-history' and
"   'previous-history' instead of 'down' and 'up'.
let g:fzf_history_dir = '~/.local/share/fzf-history'

autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

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
" command! -bang -nargs=* Find call fzf#vim#grep(
"  \ 'rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color always '
"  \ .shellescape(<q-args>), 1, <bang>0)
command! -bang -nargs=* Rg call fzf#vim#files('.', {'source': g:rg_find_command}, 0)

command! -bang -nargs=* Find call fzf#vim#grep(
  \ 'rg --column --line-number --no-heading --follow --ignore-case --color=always '.<q-args>, 1,
  \ <bang>0 ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?'), <bang>0)
" command! -bang -nargs=? -complete=dir Files
"   \ call fzf#vim#files(<q-args>, fzf#vim#with_preview('right:50%', '?'), <bang>0)
" command! -bang -nargs=? -complete=dir GitFiles
"   \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview('right:50%', '?'), <bang>0)

command! LS call fzf#run(fzf#wrap({'source': 'ls'}))

" https://github.com/junegunn/vim-fnr
Plug 'junegunn/vim-pseudocl'
Plug 'junegunn/vim-fnr'
Plug 'vim-scripts/greplace.vim'
"READ MORE https://github.com/simnalamburt/vim-mundo
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
" https://github.com/leafgarland/typescript-vim
Plug 'leafgarland/typescript-vim', { 'for': ['typescript'] }
Plug 'HerringtonDarkholme/yats.vim'
" Plug 'ianks/vim-tsx'

let g:typescript_indent_disable = 1

" Javascript
Plug 'https://github.com/othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'thinca/vim-textobj-function-javascript',    { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug '1995eaton/vim-better-javascript-completion', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'chemzqm/vim-jsx-improve', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'gavocanov/vim-js-indent', { 'for': [ 'javascript', 'js', 'jsx' ]}

" GraphQL
Plug 'jparise/vim-graphql'

" Toolkit - no syntax highlighting https://github.com/moll/vim-node
" gf already does something else so disabled this for now ...
" Plug 'moll/vim-node', { 'for': [ 'javascript', 'js', 'jsx' ]}

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
" Plug 'ryanoasis/vim-devicons'

call plug#end()

" *************************
" Snippets (deoplete needs to be under plug#end)
" *************************
" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'

" https://github.com/Shougo/deoplete.nvim/blob/378feff8772d0e9f9ef2c94284947f3666576500/doc/deoplete.txt
call deoplete#custom#option({
\ 'prev_completion_mode': "mirror",
\ })

" https://github.com/tbodt/deoplete-tabnine
" [tabnine]
call deoplete#custom#var('tabnine', {
    \ 'line_limit': 800,
    \ 'max_num_results': 5,
    \ })

" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

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

" Override vim's italic codes
" https://www.reddit.com/r/vim/comments/24g8r8/italics_in_terminal_vim_and_tmux/
set t_ZH=^[[3m
set t_ZR=^[[23m

" Marks 80th column
if (exists('+colorcolumn'))
    set colorcolumn=80
    highlight ColorColumn ctermbg=9
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
  \ { 'h': '/Volumes/config' },
  \ { 'g': '~/.gitconfig' },
  \ { 'z': '~/.zshrc' }
\ ]

"https://github.com/itchyny/lightline.vim
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

" enable syntax highlighting for .js files too instead of just .jsx
let g:jsx_ext_required = 0

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


" Don't copy the contents of an overwritten selection.
vnoremap p "_dP

set suffixes=~,.aux,.bak,.bkp,.dvi,.hi,.o,.pdf,.gz,.idx,.log,.ps,.swp,.tar,.ilg,.bbl,.toc,.ind
set wildmenu   " show a navigable menu for tab completion
set wildcharm=<Tab>
set wildmode=list:longest
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
