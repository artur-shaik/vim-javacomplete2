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
    call append(0, 'package '. a:data['package']. ';')
    call append(line('$'), 'public class '. a:data['class']. ' {')
    call append(line('$'), '')
    call append(line('$'), '}')
    call cursor(4, 1)
  endif
endfunction

function! s:ParseInput(userinput, currentPath, currentPackage)
  let path = split(a:userinput, '\.')
  if len(path) == 1
    return {
          \ 'path' : '', 
          \ 'class' : path[0], 
          \ 'package' : join(a:currentPackage, '.')
          \ }
  elseif path[0] == '/' || path[0][0] == '/'
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
  let newPackage = join(a:currentPackage, '.'). '.'. join(a:path[:-2], '.')
  return {
        \ 'path' : join(a:path[:-2], g:FILE_SEP), 
        \ 'class' : a:path[-1], 
        \ 'package' : newPackage
        \ }
endfunction

" vim:set fdm=marker sw=2 nowrap:
