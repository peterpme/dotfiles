function! helpers#lightline#fileName() abort
    let filename = winwidth(0) > 70 ? expand('%') : expand('%:t')
    if filename =~ 'NERD_tree'
        return ''
    endif
    let modified = &modified ? ' +' : ''
    return fnamemodify(filename, ":~:.") . modified
endfunction

function! helpers#lightline#fileEncoding()
    " only show the file encoding if it's not 'utf-8'
    return &fileencoding == 'utf-8' ? '' : &fileencoding
endfunction

function! helpers#lightline#fileFormat()
    " only show the file format if it's not 'unix'
    let format = &fileformat == 'unix' ? '' : &fileformat
    return winwidth(0) > 70 ? format : ''
endfunction

function! helpers#lightline#fileType()
    return ""
endfunction

function! helpers#lightline#gitBranch()
    return "\uE725"
endfunction

function! helpers#lightline#currentFunction()
    return ""
endfunction

function! helpers#lightline#gitBlame()
    return ""
endfunction
