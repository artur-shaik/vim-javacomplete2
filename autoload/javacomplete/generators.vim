" Vim completion script for java
" Maintainer: artur shaik <ashaihullin@gmail.com>
"
" Source code generators

function! s:Log(log)
  let log = type(a:log) == type("") ? a:log : string(a:log)
  call javacomplete#logger#Log("[generators] ". log)
endfunction

let g:JavaComplete_Templates = {}
let g:JavaComplete_Generators = {}

let g:JavaComplete_Templates['setter'] = 
  \ "$modifiers void $funcname($type $varname) {\n" .
    \ "$accessor.$varname = $varname;\n" .
  \ "}"

let g:JavaComplete_Templates['getter'] = 
  \ "$modifiers $type $funcname() {\n" .
    \ "return $varname;\n" .
  \ "}"

let g:JavaComplete_Templates['abstractDeclaration'] =
  \ "@Override\n" .
  \ "$declaration {\n" .
    \ "throw new UnsupportedOperationException();\n" .
  \ "}"

" class:
"   name - name of the class,
"   fields:
"       name
"       type
"       static
"       final
"       isArray
"       getter
let g:JavaComplete_Generators['toString_concat'] = join([
  \ 'function! s:__toString_concat(class)',
  \ '   let result = "@Override\n"',
  \ '   let result .= "public String toString() {\n"',
  \ '   let result .= "return \"". a:class.name ."{\" +\n"',
  \ '   let i = 0',
  \ '   for field in a:class.fields',
  \ '       if i > 0',
  \ '           let result .= "\n\", "',
  \ '       else',
  \ '           let result .= "\""',
  \ '           let i += 1',
  \ '       endif',
  \ '       if has_key(field, "getter")',
  \ '           let f = field.getter',
  \ '       else',
  \ '           let f = field.name',
  \ '       endif',
  \ '       let f = field.isArray ? "java.util.Arrays.toString(". f .")" : f',
  \ '       let result .= field.name ." = \" + ". f. " +"',
  \ '   endfor',
  \ '   return result . "\n\"}\";\n}"',
  \ 'endfunction'
  \], "\n")

let g:JavaComplete_Generators['toString_StringBuilder'] = join([
  \ 'function! s:__toString_StringBuilder(class)',
  \ '   let result = "@Override\n"',
  \ '   let result .= "public String toString() {\n"',
  \ '   let result .= "final StringBuilder sb = new StringBuilder(\"". a:class.name . "{\");\n"',
  \ '   let i = 0',
  \ '   for field in a:class.fields',
  \ '       if i > 0',
  \ '           let result .= "\nsb.append(\", "',
  \ '       else',
  \ '           let result .= "sb.append(\""',
  \ '           let i += 1',
  \ '       endif',
  \ '       if has_key(field, "getter")',
  \ '           let f = field.getter',
  \ '       else',
  \ '           let f = field.name',
  \ '       endif',
  \ '       let f = field.isArray ? "java.util.Arrays.toString(". f .")" : f',
  \ '       let result .= field.name ." = \").append(". f. ");"',
  \ '   endfor',
  \ '   return result . "\nreturn sb.append(\"}\").toString();\n}"',
  \ 'endfunction'
  \], "\n")

let g:JavaComplete_Generators['hashCode'] = join([
  \ 'function! s:__hashCode(class)',
  \ '   let result = "@Override\n"',
  \ '   let result .= "public int hashCode() {\n"',
  \ '   let result .= "int result = 17;\n"',
  \ '   for field in a:class.fields',
  \ '       if index(g:J_PRIMITIVE_TYPES, field.type) > -1',
  \ '           if field.type == "boolean"',
  \ '               let result .= "result = 31 * result + (". field.name . " ? 0 : 1);\n"',
  \ '           elseif field.type == "long"',
  \ '               let result .= "result = 31 * result + (int)(". field.name . " ^ (". field.name . " >>> 32));\n"',
  \ '           elseif field.type == "float"',
  \ '               let result .= "result = 31 * result + Float.floatToIntBits(". field.name . ");\n"',
  \ '           elseif field.type == "double"',
  \ '               let result .= "long ". field.name . "Long = Double.doubleToLongBits(". field.name .");\n"',
  \ '               let result .= "result = 31 * result + (int)(". field.name . "Long ^ (". field.name . "Long >>> 32));\n"',
  \ '           else',
  \ '               let result .= "result = 31 * result + (int)". field.name . ";\n"',
  \ '           endif',
  \ '       elseif field.isArray',
  \ '           let result .= "result = 31 * result + java.util.Arrays.hashCode(". field.name . ");\n"',
  \ '       else',
  \ '           let result .= "result = 31 * result + (". field.name . " != null ? ". field.name .".hashCode() : 0);\n"',
  \ '       endif',
  \ '   endfor',
  \ '   return result. "return result;\n}"',
  \ 'endfunction'
  \], "\n")

let g:JavaComplete_Generators['equals'] = join([
  \ 'function! s:__equals(class)',
  \ '   let result = "@Override\n"',
  \ '   let result .= "public boolean equals(Object o) {\n"',
  \ '   let result .= "if (this == o) return true;\n"',
  \ '   let result .= "if (o == null || getClass() != o.getClass()) return false;\n\n"',
  \ '   let result .= a:class.name ." object = (". a:class.name .") o;\n\n"',
  \ '   let idx = 0',
  \ '   for field in a:class.fields',
  \ '       if idx != len(a:class.fields) - 1',
  \ '           let result .= "if "',
  \ '       else',
  \ '           let result .= "return !"',
  \ '       endif',
  \ '       if index(g:J_PRIMITIVE_TYPES, field.type) > -1',
  \ '           if field.type == "double"',
  \ '               let result .= "(Double.compare(". field.name .", object.". field.name .") != 0)"',
  \ '           elseif field.type == "float"',
  \ '               let result .= "(Float.compare(". field.name .", object.". field.name .") != 0)"',
  \ '           else',
  \ '               let result .= "(". field.name ." != object.". field.name .")"',
  \ '           endif',
  \ '       elseif field.isArray',
  \ '           let result .= "(!java.util.Arrays.equals(". field.name .", object.". field.name ."))"',
  \ '       else',
  \ '           let result .= "(". field.name ." != null ? !". field.name .".equals(object.". field.name .") : object.". field.name ." != null)"',
  \ '       endif',
  \ '       if idx != len(a:class.fields) - 1',
  \ '           let result .= " return false;\n"',
  \ '       else',
  \ '           let result .= ";\n"',
  \ '       endif',
  \ '       let idx += 1',
  \ '   endfor',
  \ '   return result. "}"',
  \ 'endfunction'
  \], "\n")

let g:JavaComplete_Generators['constructor'] = join([
  \ 'function! s:__constructor(class, ...)',
  \ '   let parameters = ""',
  \ '   let body = ""',
  \ '   let idx = 0',
  \ '   if a:0 == 0 || a:1.default != 1',
  \ '       for field in a:class.fields',
  \ '           if idx != 0',
  \ '               let parameters .= ", "',
  \ '           endif',
  \ '           let parameters .= field.type . " ". field.name',
  \ '           let body .= "this.". field.name ." = ". field.name .";\n"',
  \ '           let idx += 1',
  \ '       endfor',
  \ '   endif',
  \ '   let result = "public ". a:class.name ."(". parameters. ") {\n"',
  \ '   let result .= body',
  \ '   return result . "}"',
  \ 'endfunction'
  \], "\n")

function! s:CollectVars()
  let currentFileVars = []
  for d in s:ti.defs
    if d.tag == 'VARDEF'
      let var = s:GetVariable(s:ti.name, d)
      call add(currentFileVars, var)
    endif
  endfor
  return currentFileVars
endfunction

function! javacomplete#generators#GenerateConstructor(default)
  let defaultConstructorCommand = {'key': '1', 'desc': 'generate default constructor', 'call': '<SID>generateByTemplate', 'template': 'constructor', 'replace': {'type': 'same'}, 'options': {'default': 1}}
  if a:default == 0
    let commands = [
          \ defaultConstructorCommand,
          \ {'key': '2', 'desc': 'generate constructor', 'call': '<SID>generateByTemplate', 'template': 'constructor', 'replace': {'type': 'same'}}
          \ ]
    call s:FieldsListBuffer(commands)
  else
    let s:ti = javacomplete#collector#DoGetClassInfo('this')
    let s:savedCursorPosition = getpos('.')
    call <SID>generateByTemplate(defaultConstructorCommand)
  endif
endfunction

function! javacomplete#generators#GenerateEqualsAndHashCode()
  let commands = [
        \ {'key': '1', 'desc': 'generate `equals` method', 'call': '<SID>generateByTemplate', 'template': 'equals', 'replace': {'type': 'similar'}},
        \ {'key': '2', 'desc': 'generate `hashCode` method', 'call': '<SID>generateByTemplate', 'template': 'hashCode', 'replace': {'type': 'similar'}},
        \ {'key': '3', 'desc': 'generate `equals` and `hashCode` methods', 'call': '<SID>generateByTemplate', 'template': ['hashCode', 'equals'], 'replace': {'type': 'similar'}}
        \ ]
  call s:FieldsListBuffer(commands)
endfunction

function! javacomplete#generators#GenerateToString()
  let commands = [
        \ {'key': '1', 'desc': 'generate `toString` method using concatination', 'call': '<SID>generateByTemplate', 'template': 'toString_concat', 'replace': {'type': 'similar'}},
        \ {'key': '2', 'desc': 'generate `toString` method using StringBuilder', 'call': '<SID>generateByTemplate', 'template': 'toString_StringBuilder', 'replace': {'type': 'similar'}}
        \ ]
  call s:FieldsListBuffer(commands)
endfunction

function! s:FieldsListBuffer(commands)
  let s:ti = javacomplete#collector#DoGetClassInfo('this')
  let s:savedCursorPosition = getpos('.')
  let contentLine = s:CreateBuffer("__FieldsListBuffer__", "remove unnecessary fields", a:commands)

  let b:currentFileVars = s:CollectVars()

  let lines = ""
  let idx = 0
  while idx < len(b:currentFileVars)
    let var = b:currentFileVars[idx]
    let lines = lines. "\n". "f". idx. " --> ". var.type . " ". var.name
    let idx += 1
  endwhile
  silent put = lines

  call cursor(contentLine + 1, 0)
endfunction

" a:1 - method declaration to replace
function! <SID>generateByTemplate(command)
  let fields = []
  if bufname('%') == "__FieldsListBuffer__"
    call s:Log("generate method with template: ". string(a:command.template))

    let currentBuf = getline(1,'$')
    for line in currentBuf
      if line =~ '^f[0-9]\+.*'
        let cmd = line[0]
        let idx = line[1:stridx(line, ' ')-1]
        let var = b:currentFileVars[idx]
        call add(fields, var)
      endif
    endfor

    execute "bwipeout!"
  endif

  let result = []
  let templates = type(a:command.template) != type([]) ? [a:command.template] : a:command.template
  let class = {"name": s:ti.name, "fields": fields}
  for template in templates
    if has_key(g:JavaComplete_Generators, template)
      execute g:JavaComplete_Generators[template]

      let arguments = [class]
      if has_key(a:command, 'options')
        call add(arguments, a:command.options)
      endif
      let TemplateFunction = function('s:__'. template)
      call add(result, '')
      for line in split(call(TemplateFunction, arguments), '\n')
        call add(result, line)
      endfor
    endif
  endfor

  if len(result) > 0
    if has_key(a:command, 'replace')
      let toReplace = []
      if a:command.replace.type == 'same'
        let defs = s:GetNewMethodsDefinitions(result)
        for def in defs
          call add(toReplace, def.d)
        endfor
      elseif a:command.replace.type == 'similar'
        let defs = s:GetNewMethodsDefinitions(result)
        for def in defs
          let m = s:FindMethod(s:ti.methods, def)
          if !empty(m)
            call add(toReplace, m.d)
          endif
        endfor
      endif

      let idx = 0
      while idx < len(s:ti.defs)
        let def = s:ti.defs[idx]
        if get(def, 'tag', '') == 'METHODDEF' 
          \ && index(toReplace, get(def, 'd', '')) > -1
          \ && has_key(def, 'body') && has_key(def.body, 'endpos')

          let startline = java_parser#DecodePos(def.pos).line
          if !empty(getline(startline))
            let startline += 1
          endif
          let endline = java_parser#DecodePos(def.body.endpos).line + 1
          silent! execute startline.','.endline. 'delete _'

          call setpos('.', s:savedCursorPosition)
          let s:ti = javacomplete#collector#DoGetClassInfo('this')
          let idx = 0
        else
          let idx += 1
        endif
      endwhile
    endif
    call s:InsertResults(result)
    call setpos('.', s:savedCursorPosition)
  endif
endfunction

function! javacomplete#generators#AbstractDeclaration()
  let s:ti = javacomplete#collector#DoGetClassInfo('this')
  let s = ''
  let abstractMethods = []
  let implementedMethods = []
  for i in get(s:ti, 'extends', [])
    let parentInfo = javacomplete#collector#DoGetClassInfo(i)
    let members = javacomplete#complete#complete#SearchMember(parentInfo, '', 1, 1, 1, 14, 0)
    for m in members[1]
      if javacomplete#util#CheckModifier(m.m, [g:JC_MODIFIER_ABSTRACT])
        call add(abstractMethods, m)
      elseif javacomplete#util#CheckModifier(m.m, [g:JC_MODIFIER_PUBLIC]) 
        call add(implementedMethods, m)
      endif
    endfor
    unlet i
  endfor

  let result = []
  let method = g:JavaComplete_Templates['abstractDeclaration']
  for m in abstractMethods
    if !empty(s:CheckImplementationExistense(s:ti, implementedMethods, m))
      continue
    endif
    let declaration = javacomplete#util#GenMethodParamsDeclaration(m)
    let declaration = substitute(declaration, '\<\(abstract\|default\|native\)\s\+', '', 'g')
    let declaration = javacomplete#util#CleanFQN(declaration)

    call add(result, '')
    for line in split(substitute(method, '$declaration', declaration, 'g'), '\n')
      call add(result, line)
    endfor

    call add(implementedMethods, m)
  endfor

  call s:InsertResults(result)
endfunction

" ti - this class info
" implementedMethods - implemented methods from parent class
" method - method to check
function! s:CheckImplementationExistense(ti, implementedMethods, method) 
  let methods = a:ti.methods
  call extend(methods, a:implementedMethods)
  return s:FindMethod(methods, a:method)
endfunction

function! s:GetParams(params)
  let params = []
  for param in a:params
    if type(param) == type({}) && has_key(param, 'type') 
      if has_key(param.type, 'name')
        call add(params, javacomplete#util#CleanFQN(param.type.name))
      elseif has_key(param.type, 'clazz') && has_key(param.type.clazz, 'name')
        let name = javacomplete#util#CleanFQN(param.type.clazz.name)
        if has_key(param.type, 'arguments')
          let args = []
          for arg in param.type.arguments
            if type(arg) == type({})
              if len(arg.name) == 1
                call add(params, '\('. g:RE_TYPE_ARGUMENT_EXTENDS. '\|'. g:RE_TYPE. '\)')
              else
                call add(params, arg.name)
              endif
            else
              call add(params, '?')
            endif
          endfor
          let name .= '<'. join(args, ',\s*'). '>'
        endif
        call add(params, name)
      elseif has_key(param.type, 'typetag')
        call add(params, param.type.typetag)
      elseif has_key(param.type, 'tag') && param.type.tag == 'TYPEARRAY'
        if has_key(param.type, 'elementtype') && has_key(param.type.elementtype, 'name')
          call add(params, param.type.elementtype.name . '[]')
        endif
      endif
    endif
  endfor
  return params
endfunction

function! s:FindMethod(methods, method)
  let searchMethodParamList = []
  if has_key(a:method, 'p')
    for p in a:method.p
      call add(searchMethodParamList, javacomplete#util#CleanFQN(p))
    endfor
  elseif has_key(a:method, 'params')
    call extend(searchMethodParamList, s:GetParams(a:method.params))
  endif

  let methodDeclaration = javacomplete#util#CleanFQN(a:method.r . ' '. a:method.n)
  for method in a:methods
    if methodDeclaration ==# javacomplete#util#CleanFQN(method.r . ' '. method.n)
      let methodParamList = []
      if has_key(method, 'params')
        call extend(methodParamList, s:GetParams(method.params))
      elseif has_key(method, 'p')
        for param in method.p
          if type(param) == type("")
            call add(methodParamList, javacomplete#util#CleanFQN(param))
          endif
        endfor
      endif

      " compare parameters need to be done with regexp because of separator of
      " arguments if paramater has generic arguments
      let i = 0
      let _continue = 0
      for p in searchMethodParamList
        if i < len(methodParamList)
          if p !~ methodParamList[i]
            let _continue = 1
            break
          endif
        else
          let _continue = 1
          break
        endif
        let i += 1
      endfor
      if _continue == 1
        continue
      endif
      return method
    endif
  endfor
  return {}
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
    if has_key(command, 'call')
      exec "nnoremap <buffer> <silent> ". command.key . " :call ". command.call . "(". string(command). ")<CR>"
    endif
  endfor
  put = '\"-----------------------------------------------------'

  return line(".") + 1
endfunction

function! javacomplete#generators#Accessors()
  let s:ti = javacomplete#collector#DoGetClassInfo('this')

  let commands = [{'key': 's', 'desc': 'generate accessors', 'call': '<SID>generateAccessors'}]
  let contentLine = s:CreateBuffer("__AccessorsBuffer__", "remove unnecessary accessors", commands)

  let b:currentFileVars = s:CollectVars()

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

  let method = substitute(method, '$type', a:var.type, 'g')
  let method = substitute(method, '$varname', a:var.name, 'g')
  let method = substitute(method, '$funcname', a:declaration, 'g')
  let method = substitute(method, '$modifiers', mods, 'g')
  let method = substitute(method, '$accessor', accessor, 'g')

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
    \ 'final': javacomplete#util#CheckModifier(a:def.m, g:JC_MODIFIER_FINAL),
    \ 'isArray': a:def.t =~# g:RE_ARRAY_TYPE}

  let varName = toupper(var.name[0]). var.name[1:]
  for def in get(s:ti, 'defs', [])
    if get(def, 'tag', '') == 'METHODDEF'
      if stridx(get(def, 'd', ''), var.type. ' get'. varName. '()') > -1
        let var.getter = 'get'. varName. '()'
        break
      endif
    endif
  endfor
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
  let result = []
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
    for d in get(s:ti, 'defs', [])
      if get(d, 'tag', '') == 'VARDEF'
        let line = java_parser#DecodePos(d.pos).line
        if has_key(d, 'endpos')
          let endline = java_parser#DecodePos(d.endpos).line
        else
          let endline = line
        endif
        for l in currentLines
          if l >= line && l <= endline
            let cmd = len(a:1) > 0 ? a:1[0] : 'sg'
            let var = s:GetVariable(s:ti.name, d)
            call s:CreateAccessors(locationMap, result, var, cmd)
          endif
        endfor
      endif
    endfor

  endif

  call s:InsertResults(s:FilterExistedMethods(locationMap, result))
endfunction

function! s:FilterExistedMethods(locationMap, result)
  let resultMethods = []
  for def in s:GetNewMethodsDefinitions(a:result)
    if !empty(s:CheckImplementationExistense(s:ti, [], def))
      continue
    endif
    for m in a:locationMap 
      if m[0] <= def.beginline && m[1] >= def.endline
        call extend(resultMethods, a:result[m[0] : m[1] -1])
        break
      endif
    endfor
  endfor

  return resultMethods
endfunction

" create temporary buffer with class declaration, then parse it to get new 
" methods definitions.
function! s:GetNewMethodsDefinitions(declarations)
  let n = bufwinnr("__tmp_buffer__")
  if n != -1
      execute "bwipeout!"
  endif
  silent! split __tmp_buffer__
  let result = ['class Tmp {']
  call extend(result, a:declarations)
  call add(result, '}')
  call append(0, result)
  let tmpClassInfo = javacomplete#collector#DoGetClassInfo('this', '__tmp_buffer__')
  let defs = []
  for def in get(tmpClassInfo, 'defs', [])
    if get(def, 'tag', '') == 'METHODDEF'
      let def.beginline = java_parser#DecodePos(def.pos).line
      let def.endline = java_parser#DecodePos(def.body.endpos).line
      call add(defs, def)
    endif
  endfor
  execute "bwipeout!"

  return defs
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
    elseif has_key(s:ti, 'endpos')
      let endline = java_parser#DecodePos(s:ti.endpos).line
    else
      call s:Log("cannot find `endpos` [InsertResult]")
      return
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
