let g:NERDSpaceDelims=1
let g:gitgutter_enabled = 0

" Auto open nerd tree on startup
let g:nerdtree_tabs_open_on_gui_startup = 0
" Focus in the main content window
let g:nerdtree_tabs_focus_on_files = 1

" Make nerdtree look nice
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:NERDTreeWinSize = 30

" faster bookmarking in NERDTree
autocmd Filetype nerdtree nnoremap <buffer> <leader>B :Bookmark<space>
autocmd Filetype nerdtree nnoremap <buffer> <leader>b :Bookmark<space><CR>

" NERDTree {{{
let NERDTreeIgnore = ['\.DS_Store$', '\.pyc$', '\.javac']
let g:NERDTreeShowHidden = 1
let g:NERDTreeShowBookmarks = 1

" NERDTree's File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
    exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
    exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('hs', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('rkt', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('py', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('scala', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('py3', 'Magenta', 'none', '#ff00ff', '#151515')
" }}}

" nerdtree mappings
let NERDTreeMapChangeRoot = 'u'
let NERDTreeMapUpdir = 'U'
let NERDTreeMapUpdirKeepOpen = 'c'
