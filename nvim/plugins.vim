call plug#begin('~/.vim/bundle')

" General enhancements
Plug 'austintaylor/vim-indentobject'
Plug 'junegunn/vim-easy-align'
" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'mhinz/vim-startify'
Plug 'https://github.com/wesQ3/vim-windowswap'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'nathanaelkane/vim-indent-guides', {'on': ['IndentGuidesToggle', 'IndentGuidesEnable']}
Plug 'Raimondi/delimitMate'
Plug 'briandoll/change-inside-surroundings.vim'
Plug 'chrisbra/NrrwRgn'
Plug 'chriskempson/base16-vim'

" Themes
Plug 'https://github.com/kenwheeler/glow-in-the-dark-gucci-shark-bites-vim'
Plug 'https://github.com/rhysd/vim-color-shiny-white'
Plug 'crusoexia/vim-monokai'
Plug 'mhartington/oceanic-next'
Plug 'jacoborus/tender'

" Text
Plug 'https://github.com/wellle/targets.vim'
Plug 'https://github.com/reedes/vim-textobj-sentence'
Plug 'coderifous/textobj-word-column.vim'
Plug 'kana/vim-textobj-datetime'
Plug 'kana/vim-textobj-entire'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'lucapette/vim-textobj-underscore'
Plug 'vim-scripts/argtextobj.vim'

" Powerline, airline, etc
Plug 'itchyny/lightline.vim'
Plug 'https://github.com/dahu/bisectly', { 'on': 'Bisectly'}
Plug 'https://github.com/ryanoasis/vim-devicons'


" Build tools
Plug 'https://github.com/neomake/neomake', { 'on': ['Neomake'] }


" Find & replace, etc
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'rking/ag.vim'
Plug 'junegunn/vim-fnr' | Plug 'junegunn/vim-pseudocl' " find & replace
Plug 'vim-scripts/greplace.vim'
Plug 'https://github.com/simnalamburt/vim-mundo'
Plug 'https://github.com/tpope/vim-abolish' " AWESOME case-sensitive replace
Plug 'vim-scripts/matchit.zip'


" Handlebars / Mustache
Plug 'juvenn/mustache.vim'
Plug 'nono/vim-handlebars'

" Git
" Plug 'junegunn/vim-github-dashboard', { 'on': ['GHDashboard', 'GHActivity'] }
" https://github.com/junegunn/vim-github-dashboard
Plug 'https://github.com/rhysd/committia.vim', { 'for': ['gitcommit']}
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'airblade/vim-gitgutter'


" Javascript
Plug 'https://github.com/othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'js', 'javascript.jsx' ]}
" Plug 'thinca/vim-textobj-function-javascript',    { 'for': [ 'javascript', 'js', 'javascript.jsx' ]}
" Plug '1995eaton/vim-better-javascript-completion', { 'for': [ 'javascript', 'js', 'javascript.jsx' ]}

Plug 'gavocanov/vim-js-indent', { 'for': 'javascript' } " JavaScript indent support
Plug 'moll/vim-node', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'othree/yajs.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'othree/es.next.syntax.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'mxw/vim-jsx', { 'for': [ 'javascript', 'js', 'jsx' ]}

" Javascript Tools
Plug 'flowtype/vim-flow', { 'for': ['javascript', 'js', 'javascript.jsx' ]}

" SCSS and CSS syntax highlighting
if v:version < 704
  Plug 'JulesWang/css.vim'
endif
Plug 'cakebaker/scss-syntax.vim'


" HTML
Plug 'tpope/vim-ragtag'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'skwp/vim-html-escape', {'for': ['html']}


" Lua
Plug 'https://github.com/xolox/vim-lua-ftplugin.git', {'for': ['lua']}
Plug 'https://github.com/xolox/vim-misc.git', {'for': ['lua']}


" Perl
Plug 'https://github.com/c9s/perlomni.vim', {'for': ['pl', 'perl', 'p6', 'pm']}

" Wakatime
Plug 'git://github.com/wakatime/vim-wakatime.git'

call plug#end()

"augroup load_us
"    autocmd!
   "autocmd InsertEnter * call plug#load('ultisnips', 'AutoTag')
   ""             \| autocmd! load_us
" augroup END
