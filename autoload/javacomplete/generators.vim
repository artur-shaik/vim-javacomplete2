" Vim completion script for java
" Maintainer: artur shaik <ashaihullin@gmail.com>
"
" Source code generators

function! s:Log(log)
  let log = type(a:log) == type("") ? a:log : string(a:log)
  call javacomplete#logger#Log("[generators] ". log)
endfunction

let g:JavaComplete_Templates = {}

let g:JavaComplete_Templates['setter'] = 
  \ "%modifiers% void %funcname%(%type% %varname%) {\n" .
  \ "    %accessor%.%varname% = %varname%;\n" .
  \ "}"

let g:JavaComplete_Templates['getter'] = 
  \ "%modifiers% %type% %funcname%() {\n" .
  \ "    return %varname%;\n" .
  \ "}"

let g:JavaComplete_Templates['abstractDeclaration'] =
  \ "@Override\n" .
  \ "%declaration% {\n" .
  \ "   throw new UnsupportedOperationException();\n" .
  \ "}"

function! javacomplete#generators#AbstractDeclaration()
  let s:ti = javacomplete#collector#DoGetClassInfo('this')
  let s = ''
  let abstractMethods = []
  let publicMethods = []
  for i in get(s:ti, 'extends', [])
    let parentInfo = javacomplete#collector#DoGetClassInfo(i)
    let members = javacomplete#complete#complete#SearchMember(parentInfo, '', 1, 1, 1, 14, 0)
    for m in members[1]
      if javacomplete#util#CheckModifier(m.m, [g:JC_MODIFIER_ABSTRACT])
        call add(abstractMethods, m)
      elseif javacomplete#util#CheckModifier(m.m, [g:JC_MODIFIER_PUBLIC]) 
        call add(publicMethods, m)
      endif
    endfor
    unlet i
  endfor

  let result = []
  let method = g:JavaComplete_Templates['abstractDeclaration']
  for m in abstractMethods
    if s:CheckImplementationExistense(s:ti, publicMethods, m)
      continue
    endif
    let declaration = javacomplete#util#GenMethodParamsDeclaration(m)
    let declaration = substitute(declaration, '\<\(abstract\|default\|native\)\s\+', '', 'g')
    let declaration = javacomplete#util#CleanFQN(declaration)

    call add(result, '')
    for line in split(substitute(method, '%declaration%', declaration, 'g'), '\n')
      call add(result, line)
    endfor
  endfor

  call s:InsertResults(result)
endfunction

" ti - this class info
" publicMethods - implemented methods from parent class
" method - method to check
function! s:CheckImplementationExistense(ti, publicMethods, method) 
  let methodDeclaration = javacomplete#util#CleanFQN(a:method.r . ' '. a:method.n)
  let paramsList = []
  if has_key(a:method, 'p')
    for p in a:method.p
      call add(paramsList, javacomplete#util#CleanFQN(p))
    endfor
  endif
  let methods = a:ti.methods
  call extend(methods, a:publicMethods)
  for em in methods
    if methodDeclaration ==# javacomplete#util#CleanFQN(em.r . ' '. em.n)
      let paramsList2 = []
      if has_key(em, 'params')
        for param in em.params
          if type(param) == type({}) && has_key(param, 'type') 
            if has_key(param.type, 'name')
              call add(paramsList2, javacomplete#util#CleanFQN(param.type.name))
            elseif has_key(param.type, 'clazz') && has_key(param.type.clazz, 'name')
              let name = javacomplete#util#CleanFQN(param.type.clazz.name)
              if has_key(param.type, 'arguments')
                let args = []
                for arg in param.type.arguments
                  call add(args, arg.name)
                endfor
                let name .= '<'. join(args, ',\s*'). '>'
              endif
              call add(paramsList2, name)
            endif
          endif
        endfor
      elseif has_key(em, 'p')
        for param in em.p
          if type(param) == type("")
            call add(paramsList2, javacomplete#util#CleanFQN(param))
          endif
        endfor
      endif

      " compare parameters need to be done with regexp because of separator of
      " arguments if paramater has generic arguments
      let i = 0
      for p in paramsList
        if i < len(paramsList2)
          if p !~ paramsList2[i]
            return 0
          endif
        else
          return 0;
        endif
        let i += 1
      endfor
      return 1
    endif
  endfor

  return 0
endfunction

function! s:CreateBuffer(name, title, commands)
	let n = bufwinnr(a:name)
	if n != -1
		execute "bwipeout!"
	endif
	exec 'silent! split '. a:name

	" Mark the buffer as scratch
	setlocal buftype=nofile
	setlocal bufhidden=wipe
	setlocal noswapfile
	setlocal nowrap
	setlocal nobuflisted

	nnoremap <buffer> <silent> q :bwipeout!<CR>

	syn match Comment "^\".*"
	put = '\"-----------------------------------------------------'
	put = '\" '. a:title
	put = '\" '
	put = '\" q                      - close this window'
    for command in a:commands
      put = '\" '. command.key . '                      - '. command.desc
    endfor
	put = '\"-----------------------------------------------------'

	return line(".") + 1
endfunction

function! javacomplete#generators#Accessors()
    let s:ti = javacomplete#collector#DoGetClassInfo('this')

    let commands = [{'key': 's', 'desc': 'generate accessors'}]
    let contentLine = s:CreateBuffer("__AccessorsBuffer__", "remove unnecessary accessors", commands)

	nnoremap <buffer> <silent> s :call <SID>generateAccessors()<CR>
     
    let b:currentFileVars = []
    for d in s:ti.defs
      if d.tag == 'VARDEF'
        let var = s:GetVariable(s:ti.name, d)
        call add(b:currentFileVars, var)
      endif
    endfor

    let lines = ""
    let idx = 0
    while idx < len(b:currentFileVars)
      let var = b:currentFileVars[idx]
      let varName = toupper(var.name[0]). var.name[1:]
      let lines = lines. "\n". "g". idx. " --> ". var.type . " get". varName . "()"
      if !var.final
        let lines = lines. "\n". "s". idx. " --> ". "set". varName . "(". var.type . " ". var.name. ")"
      endif
      let lines = lines. "\n"

      let idx += 1
    endwhile
    silent put = lines

    call cursor(contentLine + 1, 0)

endfunction

function! javacomplete#generators#Accessor(...)
  let s:ti = javacomplete#collector#DoGetClassInfo('this')
  call <SID>generateAccessors(a:000)
endfunction

function! s:AddAccessor(map, result, var, declaration, type)
  let method = g:JavaComplete_Templates[a:type]

  let mods = "public"
  if a:var.static
    let mods = mods . " static"
    let accessor = a:var.className
  else
    let accessor = 'this'
  endif

  let method = substitute(method, '%type%', a:var.type, 'g')
  let method = substitute(method, '%varname%', a:var.name, 'g')
  let method = substitute(method, '%funcname%', a:declaration, 'g')
  let method = substitute(method, '%modifiers%', mods, 'g')
  let method = substitute(method, '%accessor%', accessor, 'g')

  let begin = len(a:result)
  call add(a:result, '')
  for line in split(method, '\n')
    call add(a:result, line)
  endfor
  let end = len(a:result)
  call add(a:map, [begin, end])
endfunction

function! s:GetVariable(className, def)
  let var = {
    \ 'name': a:def.name, 
    \ 'type': a:def.t, 
    \ 'className': a:className, 
    \ 'static': javacomplete#util#IsStatic(a:def.m),
    \ 'final': javacomplete#util#CheckModifier(a:def.m, g:JC_MODIFIER_FINAL)}

  return var
endfunction

function! s:CreateAccessors(map, result, var, cmd)
  let varName = toupper(a:var.name[0]). a:var.name[1:]
  if !a:var.final && stridx(a:cmd, 's') > -1
    call s:AddAccessor(a:map, a:result, a:var, "set". varName, 'setter')
  endif
  if stridx(a:cmd, 'g') > -1
    call s:AddAccessor(a:map, a:result, a:var, "get". varName, 'getter')
  endif
endfunction

function! <SID>generateAccessors(...)
  let result = ['class tmp {']
  let locationMap = []
  if bufname('%') == "__AccessorsBuffer__"
    call s:Log("generate accessor for selected fields")
    let currentBuf = getline(1,'$')
    for line in currentBuf
      if line =~ '^\(g\|s\)[0-9]\+.*'
        let cmd = line[0]
        let idx = line[1:stridx(line, ' ')-1]
        let var = b:currentFileVars[idx]
        call s:CreateAccessors(locationMap, result, var, cmd)
      endif
    endfor

    execute "bwipeout!"
  else
    call s:Log("generate accessor for fields under cursor")
    if mode() == 'n'
      let currentLines = [line('.') - 1]
    elseif mode() == 'v'
      let [lnum1, col1] = getpos("'<")[1:2]
      let [lnum2, col2] = getpos("'>")[1:2]
      let currentLines = range(lnum1 - 1, lnum2 - 1)
    else
      let currentLines = []
    endif
    for d in s:ti.defs
      if get(d, 'tag', '') == 'VARDEF'
        let line = java_parser#DecodePos(d.pos).line
        if index(currentLines, line) >= 0
          let cmd = len(a:1) > 0 ? a:1[0] : 'sg'
          let var = s:GetVariable(s:ti.name, d)
          call s:CreateAccessors(locationMap, result, var, cmd)
        endif
      endif
    endfor

  endif
  call add(result, '}')

  call s:InsertResults(s:FilterExistedMethods(locationMap, result))
endfunction

" create temporary buffer with class declaration, then parse it to get new 
" methods definitions.
function! s:FilterExistedMethods(locationMap, result)
  let n = bufwinnr("__tmp_buffer__")
  if n != -1
      execute "bwipeout!"
  endif
  silent! split __tmp_buffer__
  call append(0, a:result)
  let tmpClassInfo = javacomplete#collector#DoGetClassInfo('this', '__tmp_buffer__')

  let resultMethods = []
  for def in get(tmpClassInfo, 'defs', [])
    if get(def, 'tag', '') == 'METHODDEF'
      if s:CheckImplementationExistense(s:ti, [], def)
        continue
      endif
      let begin = java_parser#DecodePos(def.pos).line
      let end = java_parser#DecodePos(def.body.endpos).line
      for m in a:locationMap 
        if m[0] <= begin && m[1] >= end
          let begin = m[0]
          let end = m[1] - 1
          break
        endif
      endfor
      call extend(resultMethods, a:result[begin : end])
    endif
  endfor

  execute "bwipeout!"

  return resultMethods
endfunction

function! s:InsertResults(result)
  if len(a:result) > 0
    let result = a:result
    let t = javacomplete#collector#CurrentFileInfo()
    let contentLine = line('.')
    let currentCol = col('.')
    let posResult = {}
    for clazz in values(t)
      if contentLine > clazz.pos[0] && contentLine <= clazz.endpos[0]
        let posResult[clazz.endpos[0] - clazz.pos[0]] = clazz.endpos
      endif
    endfor

    let saveCursor = getpos('.')
    if len(posResult) > 0
      let pos = posResult[min(keys(posResult))]
      let endline = pos[0]
      if pos[1] > 1 && !empty(javacomplete#util#Trim(getline(pos[0])[:pos[1] - 2]))
        let endline += 1
        call cursor(pos[0], pos[1])
        execute "normal! i\r"
      endif
    else
      let endline = java_parser#DecodePos(s:ti.endpos).line
    endif

    if empty(javacomplete#util#Trim(getline(endline - 1)))
      let result = result[1:]
    endif
    call append(endline - 1, result)
    call cursor(endline - 1, 1)
    silent execute "normal! =G"
    call setpos('.', saveCursor)
  endif
endfunction

" vim:set fdm=marker sw=2 nowrap:
