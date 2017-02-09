autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" syntax region javascriptLineComment start="^\s*//" end="\n" contains=@Spell,javascriptCommentTodo

" enable syntax highlighting for .js files too instead of just .jsx
let g:jsx_ext_required = 0

" flow syntax highlighting
let g:javascript_plugin_flow = 1

" JSDoc syntax highlighting
let g:javascript_plugin_jsdoc = 1

" https://github.com/othree/javascript-libraries-syntax.vim
let g:used_javascript_libs = 'underscore,react,flux,chai'

let g:ale_sign_column_always = 1
let g:ale_linters = {
\   'javascript': ['eslint'],
\}
