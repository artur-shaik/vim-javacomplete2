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
    call javacomplete#generators#GenerateClass(options)
    silent execute "normal! gg=G"
    call search(a:data['class'])
    call javacomplete#imports#AddMissing()
  endif
endfunction

function! s:ParseInput(userinput, currentPath, currentPackage)
  let submatch = matchlist(a:userinput, '^\(\%(\/\|\/\.\|\)'. g:RE_TYPE. '\)\((.\{-})\|\)$')
  if !empty(submatch)
    let path = split(submatch[1], '\.')
    let classData = s:BuildPathData(path, a:currentPath, a:currentPackage)
    if !empty(submatch[2])
      let fieldsMap = s:ParseFields(submatch[2])
      if type(fieldsMap) == type({})
        let classData['fields'] = fieldsMap
      endif
    endif
    return classData
  endif
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

function! s:BuildPathData(path, currentPath, currentPackage)
  let path = a:path
  if path[0] == '/' || path[0][0] == '/'
    if path[0] == '/'
      let path = path[1:]
    else
      let path[0] = path[0][1:]
    endif
    let sameSubpackageIdx = index(a:currentPath, a:currentPackage[0])
    if sameSubpackageIdx < 0
      return s:RelativePath(path, a:currentPath, a:currentPackage)
    endif
    let currentPath = a:currentPath[:sameSubpackageIdx]
    let idx = index(currentPath, path[0])
    if idx < 0
      let newPath = repeat('..'. g:FILE_SEP, len(currentPath))
      let newPath .= join(path[:-2], g:FILE_SEP)
      let newPackage = path[:-2]
    else
      let newPath = repeat('..'. g:FILE_SEP, len(currentPath[:idx-1]))
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
    return s:RelativePath(path, a:currentPath, a:currentPackage)
  endif
endfunction

function! s:RelativePath(path, currentPath, currentPackage)
  let newPackage = join(a:currentPackage + a:path[:-2], '.')
  return {
        \ 'path' : join(a:path[:-2], g:FILE_SEP), 
        \ 'class' : a:path[-1], 
        \ 'package' : newPackage
        \ }
endfunction

" vim:set fdm=marker sw=2 nowrap:
