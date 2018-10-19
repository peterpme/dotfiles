autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

augroup fmt
  autocmd!
  autocmd BufWritePre *.js undojoin | Neoformat
augroup END

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
