" Vim completion script for java
" Maintainer: artur shaik <ashaihullin@gmail.com>
"
" Classes generator

function! s:Log(log)
  let log = type(a:log) == type("") ? a:log : string(a:log)
  call javacomplete#logger#Log("[newclass] ". log)
endfunction

function! javacomplete#newclass#CreateClass()
  let message = "enter new class name: "
  let userinput = input(message, '')
  if empty(userinput)
    return
  endif
  call s:Log("input: ". userinput)

  let currentPackage = split(javacomplete#collector#GetPackageName(), '\.')
  let currentPath = expand('%:p:h')
  let currentPathList = split(currentPath, g:FILE_SEP)
  call filter(currentPathList, 'empty(v:val) == 0')
  let data = s:ParseInput(
        \ userinput, reverse(copy(currentPathList)), currentPackage)
  if type(data) != type({})
    echom "\n"
    echoerr "Error: could not parse input line"
    return
  endif
  let data['current_path'] = g:FILE_SEP. join(currentPathList, g:FILE_SEP). g:FILE_SEP
  call s:CreateClass(data)
endfunction

function! s:CreateClass(data)
  call s:Log("create class: ". string(a:data))

  let path = a:data['current_path']
        \ . g:FILE_SEP
        \ . a:data['path']
  if filewritable(path) != 2
    call mkdir(path, 'p')
  endif
  let fileName = fnamemodify(path. g:FILE_SEP. a:data['class'], ":p")
  execute ':e '. fileName. '.java'
  if filewritable(fileName. '.java') == 0
    let options = {
          \ 'name' : a:data['class'], 
          \ 'package' : a:data['package'] 
          \ }
    if has_key(a:data, 'fields')
      let options['fields'] = a:data['fields']
    endif
    if has_key(a:data, 'extends')
      let options['extends'] = a:data['extends']
    endif
    if has_key(a:data, 'implements')
      let options['implements'] = a:data['implements']
    endif
    if has_key(a:data, 'template')
      call javacomplete#generators#GenerateClass(options, a:data['template'])
    else
      call javacomplete#generators#GenerateClass(options)
    endif
    silent execute "normal! gg=G"
    call search(a:data['class'])
    silent execute "normal! j"
    call javacomplete#imports#AddMissing()
    call javacomplete#generators#AbstractDeclaration()
    if has_key(a:data, 'methods')
      let methods = a:data['methods']
      let vars = s:GetVariables(get(a:data, 'fields', {}))
      if has_key(methods, 'constructor')
        let command = {'template': 'constructor', 'replace': {'type': 'same'}, 'fields' : []}
        call s:InsertVars(command, methods['constructor'], vars)
        call javacomplete#generators#GenerateByTemplate(command)
      endif
      if has_key(methods, 'toString')
        let command = {'template': 'toString_StringBuilder', 'replace': {'type': 'similar'}, 'fields' : []}
        if empty(methods['toString'])
          call add(methods['toString'], '*')
        endif
        call s:InsertVars(command, methods['toString'], vars)
        call javacomplete#generators#GenerateByTemplate(command)
      endif
      if has_key(methods, 'equals')
        let command = {'template': 'equals', 'replace': {'type': 'similar'}, 'fields' : []}
        if empty(methods['equals'])
          call add(methods['equals'], '*')
        endif
        call s:InsertVars(command, methods['equals'], vars)
        call javacomplete#generators#GenerateByTemplate(command)
      endif
      if has_key(methods, 'hashCode')
        let command = {'template': 'hashCode', 'replace': {'type': 'similar'}, 'fields' : []}
        if empty(methods['hashCode'])
          call add(methods['hashCode'], '*')
        endif
        call s:InsertVars(command, methods['hashCode'], vars)
        call javacomplete#generators#GenerateByTemplate(command)
      endif
    endif
    if has_key(a:data, 'fields')
      call javacomplete#generators#Accessors()
    endif
  endif
endfunction

function! s:InsertVars(command, method, vars)
  for arg in a:method
    if arg == '*'
      let a:command['fields'] = values(a:vars)
      break
    endif

    call add(a:command['fields'], a:vars[arg])
  endfor
endfunction

function! s:GetVariables(fields)
  let result = {}
  for fieldIdx in keys(a:fields)
    let field = a:fields[fieldIdx]
    let var = {
          \ 'name' : field['name'],
          \ 'type' : field['type'],
          \ 'static' : field['mod'] =~ '.*\<static\>.*',
          \ 'final' : field['mod'] =~ '.*\<final\>.*',
          \ 'isArray' : field['type'] =~# g:RE_ARRAY_TYPE
          \ }
    let result[fieldIdx] = var
  endfor
  return result
endfunction

function! s:ParseInput(userinput, currentPath, currentPackage)
  let submatch = matchlist(a:userinput, '^\([A-Za-z0-9_]*:\)\=\(\[.\{-}\]:\)\=\(\%(\/\|\/\.\|\)'. g:RE_TYPE. '\)\(\s\+extends\s\+'. g:RE_TYPE. '\)\=\(\s\+implements\s\+'. g:RE_TYPE. '\)\=\((.\{-})\|\)\(:.*\)\=$')
  if !empty(submatch)
    let path = split(submatch[3], '\.')
    let subdir = !empty(submatch[2]) ? submatch[2][1:-3] : ''
    let classData = s:BuildPathData(path, subdir, a:currentPath, a:currentPackage)
    if !empty(submatch[1])
      let classData['template'] = submatch[1][:-2]
    endif
    if !empty(submatch[4])
      let m = matchlist(submatch[4], '.*extends\s\+\('. g:RE_TYPE. '\)')
      if !empty(m)
        let classData['extends'] = m[1]
      endif
    endif
    if !empty(submatch[5])
      let m = matchlist(submatch[5], '.*implements\s\+\('. g:RE_TYPE. '\)')
      if !empty(m)
        let classData['implements'] = m[1]
      endif
    endif
    if !empty(submatch[6])
      let fieldsMap = s:ParseFields(submatch[6])
      if type(fieldsMap) == type({})
        let classData['fields'] = fieldsMap
      endif
    endif
    if !empty(submatch[7])
      let methodsMap = s:ParseMethods(submatch[7])
      if !empty(methodsMap)
        let classData['methods'] = methodsMap
      endif
    endif
    return classData
  endif
endfunction

function! s:ParseMethods(methods)
  let methodsMap = {}
  let methods = split(a:methods[1:], ':')
  for method in methods
    let bracketsIdx = stridx(method, '(')
    if bracketsIdx > 0
      let methodName = method[:bracketsIdx - 1]
      let methodsMap[methodName] = []
      let args = split(method[bracketsIdx + 1:-2], ',')
      for arg in args
        if arg != '*'
          let arg = arg*1
        endif
        call add(methodsMap[methodName], arg)
      endfor
    else
      let methodsMap[method] = []
    endif
  endfor
  return methodsMap
endfunction

function! s:ParseFields(fields)
  let fields = javacomplete#util#Trim(a:fields[1:-2])
  if !empty(fields)
    let fieldsList = split(fields, ',')
    let fieldsMap = {}
    let idx = 1
    for field in fieldsList
      let fieldMatch = matchlist(field, '^\s*\(\%('. g:RE_TYPE_MODS. '\s\+\)\+\)\=\('. g:RE_TYPE. '\)\s\+\('. g:RE_IDENTIFIER. '\).*$')
      if !empty(fieldMatch)
        let fieldMap = {}
        let fieldMap['mod'] = empty(fieldMatch[1]) ? 
              \ 'private' : javacomplete#util#Trim(fieldMatch[1])
        let fieldMap['type'] = fieldMatch[2]
        let fieldMap['name'] = fieldMatch[3]
        let fieldsMap[string(idx)] = fieldMap
        let idx += 1
      endif
    endfor
    return fieldsMap
  endif
  return 0
endfunction

function! s:BuildPathData(path, subdir, currentPath, currentPackage)
  if !empty(a:subdir)
    let idx = index(a:currentPath, 'src')
    let newPath = repeat('..'. g:FILE_SEP, idx)
    let newPath .= a:subdir. g:FILE_SEP. 'java'. g:FILE_SEP
    let newPath .= join(a:currentPackage, g:FILE_SEP). g:FILE_SEP
  else
    let newPath = ''
  endif

  let path = a:path
  if path[0] == '/' || path[0][0] == '/'
    if path[0] == '/'
      let path = path[1:]
    else
      let path[0] = path[0][1:]
    endif
    let sameSubpackageIdx = index(a:currentPath, a:currentPackage[0])
    if sameSubpackageIdx < 0
      return s:RelativePath(path, newPath, a:currentPath, a:currentPackage)
    endif
    let currentPath = a:currentPath[:sameSubpackageIdx]
    let idx = index(currentPath, path[0])
    if idx < 0
      let newPath .= repeat('..'. g:FILE_SEP, len(currentPath))
      let newPath .= join(path[:-2], g:FILE_SEP)
      let newPackage = path[:-2]
    else
      let newPath .= idx > 0 ? 
            \ repeat('..'. g:FILE_SEP, 
            \ len(currentPath[:idx-1])) 
            \ : 
            \ ''
      let newPath .= join(path[1:-2], g:FILE_SEP)
      let newPackage = path[1:-2]
      call extend(newPackage, reverse(currentPath)[:-idx-1], 0)
    endif
    return {
          \ 'path' : newPath, 
          \ 'class' : path[-1], 
          \ 'package' : join(newPackage, '.')
          \ }
  else
    return s:RelativePath(path, newPath, a:currentPath, a:currentPackage)
  endif
endfunction

function! s:RelativePath(path, newPath, currentPath, currentPackage)
  let newPackage = join(a:currentPackage + a:path[:-2], '.')
  return {
        \ 'path' : a:newPath. join(a:path[:-2], g:FILE_SEP), 
        \ 'class' : a:path[-1], 
        \ 'package' : newPackage
        \ }
endfunction

" vim:set fdm=marker sw=2 nowrap:
