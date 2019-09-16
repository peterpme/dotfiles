autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

" enable syntax highlighting for .js files too instead of just .jsx
let g:jsx_ext_required = 0

" flow syntax highlighting
let g:javascript_plugin_flow = 1

" JSDoc syntax highlighting
let g:javascript_plugin_jsdoc = 1

" https://github.com/othree/javascript-libraries-syntax.vim
let g:used_javascript_libs = 'underscore,react,flux,chai'

"be explicit about the tools that are running
let g:ale_linters_explicit = 1

" automatic imports from external modules https://github.com/dense-analysis/ale#2iii-completion
let g:ale_completion_tsserver_autoimport = 1

" format on save
let g:ale_fix_on_save = 1

let g:ale_fixers = {
\   'html': ['prettier'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'css': ['prettier'],
\}

let g:ale_linters = {
\   'html': ['eslint'],
\   'javascript': ['eslint'],
\   'typescript': ['tsserver', 'tslint'],
\}

" the path to python3 is obtained through executing `:echo exepath('python3')` in vim
let g:python3_host_prog = "/usr/local/bin/python3"
