" Vim completion script for java
" Maintainer: artur shaik <ashaihullin@gmail.com>
"
" Source code generators

function! s:Log(log)
  let log = type(a:log) == type("") ? a:log : string(a:log)
  call javacomplete#logger#Log("[generators] ". log)
endfunction

function! javacomplete#generators#AbstractDeclaration()
  let ti = javacomplete#collector#DoGetClassInfo('this')
  let s = ''
  let abstractMethods = []
  let publicMethods = []
  for i in get(ti, 'extends', [])
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
    if s:CheckImplementationExistense(ti, publicMethods, m)
      continue
    endif
    let declaration = javacomplete#util#GenMethodParamsDeclaration(m)
    let declaration = substitute(declaration, '\<\(abstract\|default\|native\)\s\+', '', 'g')
    let declaration = javacomplete#util#CleanFQN(declaration)
    call add(result, "@Override")
    call add(result, declaration)
    call add(result, "throw new UnsupportedOperationException();")
    call add(result, "}")
    call add(result, "")
  endfor

  if len(result) > 0
    let saveCursor = getpos('.')
    let endline = java_parser#DecodePos(ti.endpos).line
    call append(endline - 1, result)
    call cursor(endline - 1, 1)
    execute "normal! =G"
    call setpos('.', saveCursor)
  endif
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
          if type(param) == type({}) && has_key(param, 'type') && has_key(param.type, 'name')
            call add(paramsList2, javacomplete#util#CleanFQN(param.type.name))
          endif
        endfor
      elseif has_key(em, 'p')
        for param in em.p
          if type(param) == type("")
            call add(paramsList2, javacomplete#util#CleanFQN(param))
          endif
        endfor
      endif
      if paramsList == paramsList2
        return 1
      endif
    endif
  endfor

  return 0
endfunction

" vim:set fdm=marker sw=2 nowrap:
