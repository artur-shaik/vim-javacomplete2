" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" Last Change:	2015-09-14
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
      let lnum = search('\<import\s*=[''"]', 'Wc')
      if (lnum == 0)
        break
      endif

      let str = getline(lnum)
      if str =~ '<%\s*@\s*page\>' || str =~ '<jsp:\s*directive.page\>'
        let str = substitute(str, '.*import=[''"]\([a-zA-Z0-9_$.*, \t]\+\)[''"].*', '\1', '')
        for item in split(str, ',')
          call add(imports, [substitute(item, '\s', '', 'g'), lnum])
        endfor
      endif
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
      endif
    endwhile
  endif

  call cursor(lnum_old, col_old)
  return imports
endfunction

function! javacomplete#imports#GetImports(kind, ...)
  let filekey = a:0 > 0 && !empty(a:1) ? a:1 : javacomplete#GetCurrentFileKey()
  let props = get(b:j_files, filekey, {})
  let props['imports']	= filekey == javacomplete#GetCurrentFileKey() ? s:GenerateImports() : props.unit.imports
  let props['imports_static']	= []
  let props['imports_fqn']	= []
  let props['imports_star']	= ['java.lang.']
  if &ft == 'jsp' || filekey =~ '\.jsp$'
    let props.imports_star += ['javax.servlet.', 'javax.servlet.http.', 'javax.servlet.jsp.']
  endif

  for import in props.imports
    let subs = split(substitute(import[0], '^\s*\(static\s\+\)\?\(' .g:RE_QUALID. '\%(\s*\.\s*\*\)\?\)\s*$', '\1;\2', ''), ';', 1)
    let qid = substitute(subs[1] , '\s', '', 'g')
    if !empty(subs[0])
      call add(props.imports_static, qid)
    elseif qid[-1:] == '*'
      call add(props.imports_star, qid[:-2])
    else
      call add(props.imports_fqn, qid)
    endif
  endfor
  let b:j_files[filekey] = props
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
    if item[-1:] == '*'		" static import on demand
      call add(candidates, item[:-3])
    elseif item[strridx(item, '.')+1:] ==# a:name
          \ || (!a:fullmatch && item[strridx(item, '.')+1:] =~ '^' . a:name)
      call add(candidates, item[:strridx(item, '.')])
    endif
  endfor
  if empty(candidates)
    return result
  endif


  " read type info which are not in cache
  let commalist = ''
  for typename in candidates
    if !has_key(b:j_cache, typename)
      let commalist .= typename . ','
    endif
  endfor
  if commalist != ''
    let res = javacomplete#server#Communicate('-E', commalist, 's:SearchStaticImports in Batch')
    if res =~ "^{'"
      let dict = eval(res)
      for key in keys(dict)
        let b:j_cache[key] = s:Sort(dict[key])
      endfor
    endif
  endif

  " search in all candidates
  for typename in candidates
    let ti = get(b:j_cache, typename, 0)
    if type(ti) == type({}) && get(ti, 'tag', '') == 'CLASSDEF'
      let members = javacomplete#complete#SearchMember(ti, a:name, a:fullmatch, 12, 1, 0)
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
      call append(beginLine - 1, 'import '. imp. ';')
      let beginLine += 1
    endfor
    call setpos('.', saveCursor)
  endif
endfunction

function! s:AddImport(import)
  let imports_fqn = javacomplete#imports#GetImports('imports_fqn')
  for import in imports_fqn
    if import == a:import
      echo 'JavaComplete: import already exists'
      return
    endif
  endfor

  let imports_star = javacomplete#imports#GetImports('imports_star')
  let splittedImport = split(a:import, '\.')
  call remove(splittedImport, len(splittedImport) - 1)
  let imp = join(splittedImport, '.')
  for import in imports_star
    if import == imp. '.'
      echo 'JavaComplete: import already exists'
      return
    endif
  endfor

  let imports = javacomplete#imports#GetImports('imports')
  if empty(imports)
    let firstline = getline(1)
    if firstline =~ '^package.*'
      let insertline = 1
    else
      let insertline = 0
    endif

    call append(insertline, 'import '. a:import. ';')
    call append(insertline, '')
  else
    let lastLine = imports[len(imports) - 1][1]
    call append(lastLine, 'import '. a:import. ';')
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

  let response = javacomplete#server#Communicate("-class-packages", classname, 'Filter packages to add import')
  if response =~ '^['
    let result = eval(response)
    let import = ''
    if len(result) == 0
      echo "JavaComplete: classname '". classname. "' not found in any scope."

    elseif len(result) == 1
      let import = result[0]

    else
      if exists('g:ClassnameCompleted') && g:ClassnameCompleted
        return
      endif

      let index = 0
      for cn in result
        echo "candidate [". index. "]: ". cn
        let index += 1
      endfor
      let userinput = input('select one candidate [0]: ', '')
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

  let response = javacomplete#server#Communicate('-missing-imports -content', current, 'RemoveUnusedImports')
  if response =~ '^['
    let missing = eval(response)
    for import in missing
      if len(import) > 1
        let index = 0
        for cn in import
          echo "candidate [". index. "]: ". cn
          let index += 1
        endfor
        let userinput = input('select one candidate [0]: ', '')
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

