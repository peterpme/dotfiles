call plug#begin('~/.vim/bundle')

" *************************
" General Enhancements
" *************************

" Adds icons to stuff like NERDTREE, Airline, etc
" Plug 'https://github.com/ryanoasis/vim-devicons'

" Binary Search Tool
" Plug 'https://github.com/dahu/bisectly', { 'on': 'Bisectly'}
"

" Neoformat for stuff like Prettier
Plug 'sbdchd/neoformat'

" for neovim
if has('nvim')
  " Dark-powered Async completion (needs python3)
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" for vim 8 with python
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'

" Add flow to deoplete
  Plug 'wokalski/autocomplete-flow'

  " Function argument completion for Deoplete
  Plug 'Shougo/neosnippet'
  Plug 'Shougo/neosnippet-snippets'

  " the path to python3 is obtained through executing `:echo exepath('python3')` in vim
  let g:python3_host_prog = "/usr/local/bin/python3"
endif

Plug 'Yggdroot/indentLine'

" Wakatime
Plug 'git://github.com/wakatime/vim-wakatime.git'

" Bottom bar with all settings
Plug 'itchyny/lightline.vim'

" Alignment
Plug 'austintaylor/vim-indentobject'

" Align anything using `ga` command
Plug 'junegunn/vim-easy-align'

" Toggles a sidebar!
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

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

" Async linting
Plug 'w0rp/ale'

" Git
" Plug 'junegunn/vim-github-dashboard', { 'on': ['GHDashboard', 'GHActivity'] }
" https://github.com/junegunn/vim-github-dashboard
Plug 'https://github.com/rhysd/committia.vim', { 'for': ['gitcommit']}
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'airblade/vim-gitgutter'


" *************************
" Themes
" *************************
Plug 'ayu-theme/ayu-vim'
Plug 'drewtempelmeyer/palenight.vim'
" Plug 'morhetz/gruvbox'
" Plug 'mhartington/oceanic-next'

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

" Handlebars / Mustache
Plug 'juvenn/mustache.vim'
Plug 'nono/vim-handlebars'

" Javascript
Plug 'https://github.com/othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'thinca/vim-textobj-function-javascript',    { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug '1995eaton/vim-better-javascript-completion', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'chemzqm/vim-jsx-improve', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'gavocanov/vim-js-indent', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'leafgarland/typescript-vim'

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
Plug 'https://github.com/c9s/perlomni.vim', {'for': ['pl', 'perl', 'p6', 'pm']}

" ReasonML https://github.com/reasonml-editor/vim-reason-plus
Plug 'reasonml-editor/vim-reason-plus'

"Language Client https://github.com/autozimu/LanguageClient-neovim#quick-start
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

call plug#end()
