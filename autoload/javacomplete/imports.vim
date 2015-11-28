" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
"
" Everything to work with imports

" Similar with filter(), but returns a new list instead of operating in-place.
" `item` has the value of the current item.
function! s:filter(expr, string)
  if type(a:expr) == type([])
    let result = []
    for item in a:expr
      if eval(a:string)
        call add(result, item)
      endif
    endfor
    return result
  else
    let result = {}
    for item in items(a:expr)
      if eval(a:string)
        let result[item[0]] = item[1]
      endif
    endfor
    return result
  endif
endfu

function! s:GenerateImports()
  let imports = []

  let lnum_old = line('.')
  let col_old = col('.')
  call cursor(1, 1)

  if &ft == 'jsp'
    while 1
      let lnum = search('\<import\s*=\s*[''"]', 'Wc')
      if (lnum == 0)
        break
      endif

      let str = getline(lnum)
      if str =~ '<%\s*@\s*page\>' || str =~ '<jsp:\s*directive.page\>'
        let stat = matchlist(str, '.*import\s*=\s*[''"]\([a-zA-Z0-9_$.*, \t]\+\)[''"].*')
        if !empty(stat)
          for item in stat[1:]
            if !empty(item)
              for i in split(item, ',')
                call add(imports, [substitute(i, '\s', '', 'g'), lnum])
              endfor
            endif
          endfor
        endif
      endif
      call cursor(lnum + 1, 1)
    endwhile
  else
    while 1
      let lnum = search('\<import\>', 'Wc')
      if (lnum == 0)
        break
      elseif !javacomplete#util#InComment(line("."), col(".")-1)
        normal w
        " TODO: search semicolon or import keyword, excluding comment
        let stat = matchstr(getline(lnum)[col('.')-1:], '\(static\s\+\)\?\(' .g:RE_QUALID. '\%(\s*\.\s*\*\)\?\)\s*;')
        if !empty(stat)
          call add(imports, [stat[:-2], lnum])
        endif
      else
        let curPos = getcurpos()
        call cursor(curPos[1] + 1, curPos[2])
      endif
    endwhile
  endif

  call cursor(lnum_old, col_old)
  return imports
endfunction

function! javacomplete#imports#GetImports(kind, ...)
  let filekey = a:0 > 0 && !empty(a:1) ? a:1 : javacomplete#GetCurrentFileKey()
  let props = get(g:JavaComplete_Files, filekey, {})
  let props['imports']	= filekey == javacomplete#GetCurrentFileKey() ? s:GenerateImports() : props.unit.imports
  let props['imports_static']	= []
  let props['imports_fqn']	= []
  let props['imports_star']	= ['java.lang.']
  if &ft == 'jsp' || filekey =~ '\.jsp$'
    let props.imports_star += ['javax.servlet.', 'javax.servlet.http.', 'javax.servlet.jsp.']
  endif

  for import in props.imports
    let subs = matchlist(import[0], '^\s*\(static\s\+\)\?\(' .g:RE_QUALID. '\%(\s*\.\s*\*\)\?\)\s*$')
    if !empty(subs)
      let qid = substitute(subs[2] , '\s', '', 'g')
      if !empty(subs[1])
        if qid[-1:] == '*'
          call add(props.imports_static, qid[:-2])
        else
          call add(props.imports_static, qid)
          call add(props.imports_fqn, qid)
        endif
      elseif qid[-1:] == '*'
        call add(props.imports_star, qid[:-2])
      else
        call add(props.imports_fqn, qid)
      endif
    endif
  endfor
  let g:JavaComplete_Files[filekey] = props
  return get(props, a:kind, [])
endfu

" search for name in 
" return the fqn matched
function! javacomplete#imports#SearchSingleTypeImport(name, fqns)
  let matches = s:filter(a:fqns, 'item =~# ''\<' . a:name . '$''')
  if len(matches) == 1
    return matches[0]
  elseif !empty(matches)
    echoerr 'Name "' . a:name . '" conflicts between ' . join(matches, ' and ')
    return matches[0]
  endif
  return ''
endfu

" search for name in static imports, return list of members with the same name
" return [types, methods, fields]
function! javacomplete#imports#SearchStaticImports(name, fullmatch)
  let result = [[], [], []]
  let candidates = []		" list of the canonical name
  for item in javacomplete#imports#GetImports('imports_static')
    call javacomplete#logger#Log(item)
    if item[-1:] == '*'		" static import on demand
      call add(candidates, item[:-3])
    elseif item[strridx(item, '.')+1:] ==# a:name
          \ || (!a:fullmatch && item[strridx(item, '.')+1:] =~ '^' . a:name)
      call add(candidates, item[:strridx(item, '.') - 1])
    endif
  endfor
  if empty(candidates)
    return result
  endif

  " read type info which are not in cache
  let commalist = ''
  for typename in candidates
    if !has_key(g:JavaComplete_Cache, typename)
      let res = javacomplete#server#Communicate('-E', typename, 's:SearchStaticImports')
      if res =~ "^{'"
        let dict = eval(res)
        for key in keys(dict)
          let g:JavaComplete_Cache[key] = javacomplete#util#Sort(dict[key])
        endfor
      endif
    endif
  endfor

  " search in all candidates
  for typename in candidates
    let ti = get(g:JavaComplete_Cache, typename, 0)
    if type(ti) == type({}) && get(ti, 'tag', '') == 'CLASSDEF'
      let members = javacomplete#complete#complete#SearchMember(ti, a:name, a:fullmatch, 12, 1, 0)
      if !empty(members[1]) || !empty(members[2])
        call add(result[0], ti)
      endif
      let result[1] += members[1]
      let result[2] += members[2]
    else
      " TODO: mark the wrong import declaration.
    endif
  endfor
  return result
endfu

function! s:SortImports()
  let imports = javacomplete#imports#GetImports('imports')
  if (len(imports) > 0)
    let beginLine = imports[0][1]
    let lastLine = imports[len(imports) - 1][1]
    let importsList = []
    for import in imports 
      call add(importsList, import[0])
    endfor

    call sort(importsList)
    let saveCursor = getcurpos()
    silent execute beginLine.','.lastLine. 'delete _'
    for imp in importsList
      if &ft == 'jsp'
        call append(beginLine - 1, '<%@ page import = "'. imp. '" %>')
      else
        call append(beginLine - 1, 'import '. imp. ';')
      endif
      let beginLine += 1
    endfor
    call setpos('.', saveCursor)
  endif
endfunction

function! s:AddImport(import)
  let isStaticImport = a:import =~ "^static.*" ? 1 : 0
  let import = substitute(a:import, "\\$", ".", "g")
  if !isStaticImport
    let importsFqn = javacomplete#imports#GetImports('imports_fqn')
    let importsStar = javacomplete#imports#GetImports('imports_star')
  else
    let importsStar = javacomplete#imports#GetImports('imports_static')
    let importsFqn = importsStar
    let import = import[stridx(import, " ") + 1:]
  endif

  for imp in importsFqn
    if imp == import
      echo 'JavaComplete: import already exists'
      return
    endif
  endfor

  let splittedImport = split(import, '\.')
  let className = splittedImport[-1]
  call remove(splittedImport, len(splittedImport) - 1)
  let importPath = join(splittedImport, '.')
  for imp in importsStar
    if imp == importPath. '.'
      echo 'JavaComplete: import already exists'
      return
    endif
  endfor

  if className != '*'
    if has_key(g:JavaComplete_Cache, className)
      call remove(g:JavaComplete_Cache, className)
    endif
  endif

  let imports = javacomplete#imports#GetImports('imports')
  if empty(imports)
    let firstline = getline(1)
    if firstline =~ '^package.*'
      let insertline = 3
      call append(1, '')
    else
      let insertline = 1
    endif
    let saveCursor = getcurpos()
    let linesCount = line('$')
    while (javacomplete#util#Trim(getline(insertline)) == '' && insertline < linesCount)
      silent execute insertline. 'delete _'
      let saveCursor[1] -= 1
    endwhile
    call setpos('.', saveCursor)

    let insertline = insertline - 1
    let newline = 1
  else
    let insertline = imports[len(imports) - 1][1]
    let newline = 0
  endif

  if &ft == 'jsp'
    call append(insertline, '<%@ page import = "'. import. '" %>')
  else
    if isStaticImport
      call append(insertline, 'import static '. import. ';')
    else
      call append(insertline, 'import '. import. ';')
    endif
  endif

  if newline
    call append(insertline + 1, '')
  endif

endfunction

function! javacomplete#imports#Add(...)
  call javacomplete#server#Start()

  let i = 0
  let classname = ''
  while empty(classname)
    let offset = col('.') - i
    if offset <= 0
      return 
    endif
    let classname = javacomplete#util#GetClassNameWithScope(offset)
    let i += 1
  endwhile

  if classname =~ '^@.*'
    let classname = classname[1:]
  endif
  let response = javacomplete#server#Communicate("-class-packages", classname, 'Filter packages to add import')
  if response =~ '^['
    let result = eval(response)
    let import = ''
    if len(result) == 0
      echo "JavaComplete: classname '". classname. "' not found in any scope."

    elseif len(result) == 1
      let import = result[0]

    else
      let message = join(map(range(len(result)), '"candidate [".v:val."]: ".result[v:val]'), "\n")
      let message .= "\nselect one candidate [0]: "
      let userinput = input(message, '')
      if empty(userinput)
        let userinput = 0
      elseif userinput =~ '^[0-9]*$'
        let userinput = str2nr(userinput)
      else
        let userinput = -1
      endif
      redraw!
      
      if userinput < 0 || userinput >= len(result)
        echo "JavaComplete: wrong input"
      else
        let import = result[userinput]
      endif
    endif

    if !empty(import)
      call s:AddImport(import)
      call s:SortImports()
    endif

  endif

  if a:0 > 0 && a:1
    let cur = getcurpos()
    let cur[2] = cur[2] + 1
    execute 'startinsert'
    call setpos('.', cur)
  endif
endfunction

function! javacomplete#imports#RemoveUnused()
  let currentBuf = getline(1,'$')
  let current = join(currentBuf, '<_javacomplete-linebreak>')

  let response = javacomplete#server#Communicate('-unused-imports -content', current, 'RemoveUnusedImports')
  if response =~ '^['
    let saveCursor = getcurpos()
    let unused = eval(response)
    for unusedImport in unused
      let imports = javacomplete#imports#GetImports('imports')
      if stridx(unusedImport, '$') != -1
        let unusedImport = 'static '. substitute(unusedImport, "\\$", ".", "")
      endif
      for import in imports
        if import[0] == unusedImport
          silent execute import[1]. 'delete _'
        endif
      endfor
    endfor
    let saveCursor[1] = saveCursor[1] - len(unused)
    call setpos('.', saveCursor)
  endif
endfunction

function! javacomplete#imports#AddMissing()
  let currentBuf = getline(1,'$')
  let current = join(currentBuf, '<_javacomplete-linebreak>')

  let response = javacomplete#server#Communicate('-missing-imports -content', current, 'AddMissingImports')
  if response =~ '^['
    let missing = eval(response)
    for import in missing
      if len(import) > 1
        let message = join(map(range(len(import)), '"candidate [".v:val."]: ".import[v:val]'), "\n")
        let message .= "\nselect one candidate [0]: "
        let userinput = input(message, '')
        if empty(userinput)
          let userinput = 0
        elseif userinput =~ '^[0-9]*$'
          let userinput = str2nr(userinput)
        else
          let userinput = -1
        endif
        redraw!

        if userinput < 0 || userinput >= len(import)
          echo "JavaComplete: wrong input"
          continue
        endif

        call s:AddImport(import[userinput])
      else
        call s:AddImport(import[0])
      endif
    endfor
    call s:SortImports()
  endif
endfunction

" vim:set fdm=marker sw=2 nowrap:
