autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

" Run on save
autocmd BufWritePre *.js Neoformat

" Pass in prettier arguments
autocmd FileType javascript setlocal formatprg=prettier-standard

" Use formatprg when available
let g:neoformat_try_formatprg = 1

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
