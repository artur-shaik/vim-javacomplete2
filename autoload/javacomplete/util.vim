" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
"
" Utility functions

" TODO: search pair used in string, like 
" 	'create(ao.fox("("), new String).foo().'
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
" test case: ' 	sb. /* block comment*/ append( "stringliteral" ) // comment '
function! javacomplete#util#Prune(str, ...)
  if a:str =~ '^\s*$' | return '' | endif

  let str = substitute(a:str, '"\(\\\(["\\''ntbrf]\)\|[^"]\)*"', '""', 'g')
  let str = substitute(str, '\/\/.*', '', 'g')
  let str = javacomplete#util#RemoveBlockComments(str)
  let str = javacomplete#util#Trim(str)
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
  while curline[word_l - 1] =~ '[\.:@A-Za-z0-9_]'
    let word_l -= 1
    if curline[word_l] == '@'
      break
    endif
  endwhile
  while curline[word_r + 1] =~ '[A-Za-z0-9_]'
    let word_r += 1
  endwhile

  let c = curline[word_l : word_r]

  call javacomplete#logger#Log(c)
  return c
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
