" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" Last Change:	2015-09-14
"
" Debug methods

let s:log = []
let s:loglevel = 1
function! javacomplete#logger#Enable()
    let s:loglevel = 0
endfunction

function! javacomplete#logger#Disable()
    let s:loglevel = 1
endfunction

function! javacomplete#logger#GetContent()
    new
    put =s:log
endfunction

function! javacomplete#logger#Log(key)
    if 0 >= s:loglevel
        call add(s:log, a:key)
    endif
endfunction
