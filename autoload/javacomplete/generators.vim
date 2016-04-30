" Vim completion script for java
" Maintainer: artur shaik <ashaihullin@gmail.com>
"
" Source code generators

function! s:Log(log)
  let log = type(a:log) == type("") ? a:log : string(a:log)
  call javacomplete#logger#Log("[generators] ". log)
endfunction

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
  for m in abstractMethods
    if s:CheckImplementationExistense(s:ti, publicMethods, m)
      continue
    endif
    let declaration = javacomplete#util#GenMethodParamsDeclaration(m)
    let declaration = substitute(declaration, '\<\(abstract\|default\|native\)\s\+', '', 'g')
    let declaration = javacomplete#util#CleanFQN(declaration)
    call add(result, "")
    call add(result, "@Override")
    call add(result, declaration)
    call add(result, "throw new UnsupportedOperationException();")
    call add(result, "}")
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
    if methodDeclaration == javacomplete#util#CleanFQN(em.r . ' '. em.n)
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
        let var = {'n': d.name, 't': d.t}
        call add(b:currentFileVars, var)
      endif
    endfor

    let lines = ""
    let idx = 0
    while idx < len(b:currentFileVars)
      let var = b:currentFileVars[idx]
      let varNameSubs = toupper(var.n[0]). var.n[1:]
      let lines = lines. "\n". "g". idx. " --> ". var.t . " get". varNameSubs . "()"
      let lines = lines. "\n". "s". idx. " --> ". "set". varNameSubs . "(". var.t . " ". var.n. ")"
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

function! s:AddSetter(result, var, declaration)
  call add(a:result, '')
  call add(a:result, a:declaration. ' {')
  call add(a:result, 'this.'. a:var.n . ' = '. a:var.n . ';')
  call add(a:result, '}')
endfunction

function! s:AddGetter(result, var, declaration)
  call add(a:result, '')
  call add(a:result, a:declaration. ' {')
  call add(a:result, 'return this.'. a:var.n . ';')
  call add(a:result, '}')
endfunction

function! <SID>generateAccessors(...)
  let result = ['class tmp {']
  if bufname('%') == "__AccessorsBuffer__"
    call s:Log("generate accessor for selected fields")
    let currentBuf = getline(1,'$')
    for line in currentBuf
      if line =~ '^\(g\|s\)[0-9]\+.*'
        let cmd = line[0]
        let idx = line[1:stridx(line, ' ')-1]
        let var = b:currentFileVars[idx]
        if cmd == 's'
          call s:AddSetter(result, var, 'public void '. line[stridx(line, ' ') + 5:])
        elseif cmd == 'g'
          call s:AddGetter(result, var, 'public '. line[stridx(line, ' ') + 5:])
        endif
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
      if d.tag == 'VARDEF'
        let line = java_parser#DecodePos(d.pos).line
        if index(currentLines, line) >= 0
          let varNameSubs = toupper(d.name[0]). d.name[1:]
          let getMethodName = d.t . " get". varNameSubs . "()"
          let setMethodName = "set". varNameSubs . "(". d.t . " ". d.name . ")"
          let var = {'n': d.name, 't': d.t}

          let cmd = 'sg'
          if len(a:1) > 0
            let cmd = a:1[0]
          endif

          if stridx(cmd, 's') > -1
            call s:AddSetter(result, var, 'public void '. setMethodName)
          endif

          if stridx(cmd, 'g') > -1
            call s:AddGetter(result, var, 'public '. getMethodName)
          endif
        endif
      endif
    endfor

  endif
  call add(result, '}')

  let n = bufwinnr("__tmp_buffer__")
  if n != -1
      execute "bwipeout!"
  endif
  silent! split __tmp_buffer__
  call append(0, result)
  let tmpClassInfo = javacomplete#collector#DoGetClassInfo('this')

  let resultMethods = []
  if has_key(tmpClassInfo, 'defs')
    for def in tmpClassInfo.defs
      if def.tag == 'METHODDEF'
        if s:CheckImplementationExistense(s:ti, [], def)
          continue
        endif
        let line = java_parser#DecodePos(def.pos).line
        call add(resultMethods, "")
        call extend(resultMethods, result[line : line + 2])
      endif
    endfor
  endif

  execute "bwipeout!"

  call s:InsertResults(resultMethods)
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
    execute "normal! =G"
    call setpos('.', saveCursor)
  endif
endfunction

" vim:set fdm=marker sw=2 nowrap:
