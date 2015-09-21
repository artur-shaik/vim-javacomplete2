" Vim completion script for java
" Maintainer:   artur shaik <ashaihullin@gmail.com>
" Last Change:  2015-09-14
"
" Utility functions

" TODO: search pair used in string, like 
"   'create(ao.fox("("), new String).foo().'
function! javacomplete#util#GetMatchedIndexEx(str, idx, one, another)
    let pos = a:idx
    while 0 <= pos && pos < len(a:str)
        let pos = match(a:str, '['. a:one . escape(a:another, ']') .']', pos+1)
        if pos != -1
            if a:str[pos] == a:one
                let pos = javacomplete#util#GetMatchedIndexEx(a:str, pos, a:one, a:another)
            elseif a:str[pos] == a:another
                break
            endif
        endif
    endwhile
    return 0 <= pos && pos < len(a:str) ? pos : -3
endfunction

" set string literal empty, remove comments, trim begining or ending spaces
" test case: '  sb. /* block comment*/ append( "stringliteral" ) // comment '
function! javacomplete#util#Prune(str, ...)
    if a:str =~ '^\s*$' | return '' | endif

    let str = substitute(a:str, '"\(\\\(["\\''ntbrf]\)\|[^"]\)*"', '""', 'g')
    let str = substitute(str, '\/\/.*', '', 'g')
    let str = javacomplete#util#RemoveBlockComments(str)
    return a:0 > 0 ? str : str . ' '
endfunction

" Given argument, replace block comments with spaces of same number
function! javacomplete#util#RemoveBlockComments(str, ...)
    let result = a:str
    let ib = match(result, '\/\*')
    let ie = match(result, '\*\/')
    while ib != -1 && ie != -1 && ib < ie
        let result = strpart(result, 0, ib) . (a:0 == 0 ? ' ' : repeat(' ', ie-ib+2)) . result[ie+2: ]
        let ib = match(result, '\/\*')
        let ie = match(result, '\*\/')
    endwhile
    return result
endfunction

function! javacomplete#util#Trim(str)
    let str = substitute(a:str, '^\s*', '', '')
    return substitute(str, '\s*$', '', '')
endfunction

fu! javacomplete#util#SplitAt(str, index)
    return [strpart(a:str, 0, a:index+1), strpart(a:str, a:index+1)]
endfu

function! javacomplete#util#SearchPairBackward(str, idx, one, another)
    let idx = a:idx
    let n = 0
    while idx >= 0
        let idx -= 1
        if a:str[idx] == a:one
            if n == 0
                break
            endif
            let n -= 1
        elseif a:str[idx] == a:another  " nested 
            let n += 1
        endif
    endwhile
    return idx
endfunction

function! javacomplete#util#CountDims(str)
    if match(a:str, '[[\]]') == -1
        return 0
    endif

    " int[] -> [I, String[] -> 
    let dims = len(matchstr(a:str, '^[\+'))
    if dims == 0
        let idx = len(a:str)-1
        while idx >= 0 && a:str[idx] == ']'
            let dims += 1
            let idx = javacomplete#util#SearchPairBackward(a:str, idx, '[', ']')-1
        endwhile
    endif
    return dims
endfu

function! javacomplete#util#Index(list, expr, key)
    let i = 0
    while i < len(a:list)
        if get(a:list[i], a:key, '') == a:expr
            return i
        endif
        let i += 1
    endwhile
    return -1
endfunction

function! javacomplete#util#KeepCursor(cmd)
    let lnum_old = line('.')
    let col_old = col('.')
    exe a:cmd
    call cursor(lnum_old, col_old)
endfunction

function! javacomplete#util#InCommentOrLiteral(line, col)
    if has("syntax") && &ft != 'jsp'
        return synIDattr(synID(a:line, a:col, 1), "name") =~? '\(Comment\|String\|Character\)'
    endif
endfunction

function! javacomplete#util#InComment(line, col)
    if has("syntax") && &ft != 'jsp'
        return synIDattr(synID(a:line, a:col, 1), "name") =~? 'comment'
    endif
endfunction

fu! javacomplete#util#GotoUpperBracket()
    let searched = 0
    while (!searched)
        call search('[{}]', 'bW')
        if getline('.')[col('.')-1] == '}'
            normal %
        else
            let searched = 1
        endif
    endwhile
endfu

function! javacomplete#util#GetClassNameWithScope(...)
    let offset = a:0 > 0 ? a:1 : col('.')
    let curline = getline('.')
    let word_l = offset - 1
    let word_r = offset - 2
    while curline[word_l - 1] =~ '[@A-Za-z0-9_]'
        if curline[word_l - 1] == '@'
            break
        endif
        let word_l -= 1
    endwhile
    while curline[word_r + 1] =~ '[A-Za-z0-9_]'
        let word_r += 1
    endwhile

    return curline[word_l : word_r]
endfunction

function! s:MemberCompare(m1, m2)
    return a:m1['n'] == a:m2['n'] ? 0 : a:m1['n'] > a:m2['n'] ? 1 : -1
endfunction

function! javacomplete#util#Sort(ci)
    let ci = a:ci
    if has_key(ci, 'fields')
        call sort(ci['fields'], 's:MemberCompare')
    endif
    if has_key(ci, 'methods')
        call sort(ci['methods'], 's:MemberCompare')
    endif
    return ci
endfunction

function! javacomplete#util#CleanFQN(fqnDeclaration) 
    let start = 0
    let fqnDeclaration = a:fqnDeclaration
    let result = matchlist(fqnDeclaration, '\<'. g:RE_IDENTIFIER. '\%(\s*\.\s*\('. g:RE_IDENTIFIER. '\)\)*', start)
    while !empty(result)

        if len(result[1]) > 0
            let fqnDeclaration = substitute(fqnDeclaration, result[0], result[1], '')
            let shift = result[1]
        else
            let shift = result[0]
        endif
        let start = match(fqnDeclaration, shift, start) + len(shift)

        let result = matchlist(fqnDeclaration, '\<'. g:RE_IDENTIFIER. '\%(\s*\.\s*\('. g:RE_IDENTIFIER. '\)\)*', start)
    endwhile

    return fqnDeclaration
endfunction


" vim:set fdm=marker sw=2 nowrap:
function! javacomplete#util#JavaFileTypeInit()
    set omnifunc=javacomplete#Complete
    nnoremap <F4> :JCimportAdd<cr>
    inoremap <F4> <esc>:JCimportAddI<cr>
    inoremap <silent> <buffer>  .  <C-r>=javacomplete#util#WSDAutoComplete('.')<CR>
    inoremap <silent> <buffer>  A  <C-r>=javacomplete#util#WSDAutoComplete('A')<CR>
    inoremap <silent> <buffer>  B  <C-r>=javacomplete#util#WSDAutoComplete('B')<CR>
    inoremap <silent> <buffer>  C  <C-r>=javacomplete#util#WSDAutoComplete('C')<CR>
    inoremap <silent> <buffer>  D  <C-r>=javacomplete#util#WSDAutoComplete('D')<CR>
    inoremap <silent> <buffer>  E  <C-r>=javacomplete#util#WSDAutoComplete('E')<CR>
    inoremap <silent> <buffer>  F  <C-r>=javacomplete#util#WSDAutoComplete('F')<CR>
    inoremap <silent> <buffer>  G  <C-r>=javacomplete#util#WSDAutoComplete('G')<CR>
    inoremap <silent> <buffer>  H  <C-r>=javacomplete#util#WSDAutoComplete('H')<CR>
    inoremap <silent> <buffer>  I  <C-r>=javacomplete#util#WSDAutoComplete('I')<CR>
    inoremap <silent> <buffer>  J  <C-r>=javacomplete#util#WSDAutoComplete('J')<CR>
    inoremap <silent> <buffer>  K  <C-r>=javacomplete#util#WSDAutoComplete('K')<CR>
    inoremap <silent> <buffer>  L  <C-r>=javacomplete#util#WSDAutoComplete('L')<CR>
    inoremap <silent> <buffer>  M  <C-r>=javacomplete#util#WSDAutoComplete('M')<CR>
    inoremap <silent> <buffer>  N  <C-r>=javacomplete#util#WSDAutoComplete('N')<CR>
    inoremap <silent> <buffer>  O  <C-r>=javacomplete#util#WSDAutoComplete('O')<CR>
    inoremap <silent> <buffer>  P  <C-r>=javacomplete#util#WSDAutoComplete('P')<CR>
    inoremap <silent> <buffer>  Q  <C-r>=javacomplete#util#WSDAutoComplete('Q')<CR>
    inoremap <silent> <buffer>  R  <C-r>=javacomplete#util#WSDAutoComplete('R')<CR>
    inoremap <silent> <buffer>  S  <C-r>=javacomplete#util#WSDAutoComplete('S')<CR>
    inoremap <silent> <buffer>  T  <C-r>=javacomplete#util#WSDAutoComplete('T')<CR>
    inoremap <silent> <buffer>  U  <C-r>=javacomplete#util#WSDAutoComplete('U')<CR>
    inoremap <silent> <buffer>  V  <C-r>=javacomplete#util#WSDAutoComplete('V')<CR>
    inoremap <silent> <buffer>  W  <C-r>=javacomplete#util#WSDAutoComplete('W')<CR>
    inoremap <silent> <buffer>  X  <C-r>=javacomplete#util#WSDAutoComplete('X')<CR>
    inoremap <silent> <buffer>  Y  <C-r>=javacomplete#util#WSDAutoComplete('Y')<CR>
    inoremap <silent> <buffer>  Z  <C-r>=javacomplete#util#WSDAutoComplete('Z')<CR>
    compiler mvn
    if !filereadable("pom.xml")
        inoremap <F5> <esc>:w<CR>:!javac -cp classes/ -Djava.ext.dirs=lib/ -d classes/ % <CR>
        nnoremap <F5> :!javac -cp classes/ -Djava.ext.dirs=lib/ -d classes/ % <CR>
        nnoremap <F6> :!java -cp classes/ -Djava.ext.dirs=lib/ com.wsdjeg.util.TestMethod
        let g:JavaComplete_LibsPath = 'classes/:lib/:/home/wsdjeg/tools/apache-tomcat-8.0.24/lib'
    else
        no <F9> :make clean<CR><CR>
        no <F5> :wa<CR> :make compile<CR><CR>
        no <F6> :make exec:exec<CR>
    endif
endf

function! javacomplete#util#WSDAutoComplete(char)
    if(getline(".")=~?'^\s*.*\/\/')==0
        let line = getline('.')
        let col = col('.')
        if a:char == "."
            return a:char."\<c-x>\<c-o>\<c-p>"
        elseif line[col - 2] == " "||line[col -2] == "("
            return a:char."\<c-x>\<c-o>\<c-p>"
        else
            return a:char
        endif
    else
        let line = getline('.')
        let col = col('.')
        let [commentline,commentcol] = searchpos('//','nc','W')
        if line == getline(commentline)
            return a:char."\<c-x>\<c-o>\<c-p>"
        else
            return a:char
        endif
    endif
endf















