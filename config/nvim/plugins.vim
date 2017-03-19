call plug#begin('~/.vim/bundle')

" *************************
" General Enhancements
" *************************

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


" *************************
" Themes
" *************************

" Plug 'chriskempson/base16-vim'
" Plug 'crusoexia/vim-monokai'
Plug 'morhetz/gruvbox'


" *************************
" Text-Related
" *************************

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
Plug 'https://github.com/othree/javascript-libraries-syntax.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug 'thinca/vim-textobj-function-javascript',    { 'for': [ 'javascript', 'js', 'jsx' ]}
Plug '1995eaton/vim-better-javascript-completion', { 'for': [ 'javascript', 'js', 'jsx' ]}

Plug 'gavocanov/vim-js-indent', { 'for': [ 'javascript', 'js', 'jsx' ]} " Indent SUpport
Plug 'moll/vim-node', { 'for': [ 'javascript', 'js', 'jsx' ]} "Toolkit - no syntax highlighting https://github.com/moll/vim-node

" Plug 'othree/yajs.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}
" Plug 'othree/es.next.syntax.vim', { 'for': [ 'javascript', 'js', 'jsx' ]}

" Plug 'pangloss/vim-javascript', { 'for': [ 'javascript', 'js', 'jsx' ]} "Base syntax highlighter
" Plug 'mxw/vim-jsx', { 'for': [ 'javascript', 'js', 'jsx' ]}

Plug 'chemzqm/vim-jsx-improve', { 'for': [ 'javascript', 'js', 'jsx' ]}


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

" ReasonML
Plug 'reasonml/vim-reason-loader'

call plug#end()

"augroup load_us
"    autocmd!
   "autocmd InsertEnter * call plug#load('ultisnips', 'AutoTag')
   ""             \| autocmd! load_us
" augroup END
