" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
"
" This file contains everything related to collecting source data

" a:1	filepath
" a:2	package name
function! javacomplete#collector#DoGetClassInfo(class, ...)
  if type(a:class) == type({})
    let class = a:class.name
  else
    let class = a:class
  endif

  if has_key(g:JavaComplete_Cache, class)
    return g:JavaComplete_Cache[class]
  endif

  call javacomplete#logger#Log("DoGetClassInfo: ". class)

  " array type:	TypeName[] or '[I' or '[[Ljava.lang.String;'
  if class[-1:] == ']' || class[0] == '['
    return g:J_ARRAY_TYPE_INFO
  endif

  let filekey	= a:0 > 0 && len(a:1) > 0 ? a:1 : javacomplete#GetCurrentFileKey()
  let packagename = a:0 > 1 && len(a:2) > 0 ? a:2 : javacomplete#collector#GetPackageName()

  let t = get(javacomplete#parseradapter#SearchTypeAt(javacomplete#parseradapter#Parse(), java_parser#MakePos(line('.')-1, col('.')-1)), -1, {})
  if has_key(t, 'extends')
    if type(t.extends) == type({})
      let fqn = javacomplete#imports#SearchSingleTypeImport(t.extends[0].clazz.name, javacomplete#imports#GetImports('imports_fqn', filekey))
      let extends = fqn. '$'. a:class
    elseif type(t.extends) == type([])
      let extends = t.extends[1]. '$'. a:class
    else
      let extends = ''
    endif
  else
    let extends = ''
  endif
  if class == 'this' || class == 'super' || (has_key(t, 'fqn') && t.fqn == packagename. '.'. class)
    if &ft == 'jsp'
      let ci = javacomplete#collector#FetchClassInfo('javax.servlet.jsp.HttpJspPage')
      return ci
    endif

    call javacomplete#logger#Log('A0. ' . class)
    if !empty(t)
      return javacomplete#util#Sort(s:Tree2ClassInfo(t))
    endif
  endif

  let typename = class

  let typeArguments = ''
  let splittedType = s:SplitTypeArguments(typename)
  if type(splittedType) == type([])
    let typename = splittedType[0]
    let typeArguments = splittedType[1]
  endif

  if stridx(typename, '$') > 0
    let sc = split(typename, '\$')
    let typename = sc[0]
    let nested = '$'.sc[1]
  else
    let nested = ''
  endif
  
  if typename !~ '^\s*' . g:RE_QUALID . '\s*$' || javacomplete#util#HasKeyword(typename)
    call javacomplete#logger#Log("No qualid: ". typename)
    return {}
  endif

  let collectedArguments = s:CollectTypeArguments(typeArguments, packagename, filekey)

  let fqns = s:CollectFQNs(typename, packagename, filekey, extends)
  for fqn in fqns
    let fqn = fqn . nested . collectedArguments
    let fqn = substitute(fqn, ' ', '', 'g')
    call javacomplete#collector#FetchClassInfo(fqn)

    let key = s:KeyInCache(fqn)
    if !empty(key)
      return get(g:JavaComplete_Cache[key], 'tag', '') == 'CLASSDEF' ? g:JavaComplete_Cache[key] : {}
    endif
  endfor

  return {}
endfunction

function! javacomplete#collector#GetPackageName()
  let lnum_old = line('.')
  let col_old = col('.')

  call cursor(1, 1)
  let lnum = search('^\s*package[ \t\r\n]\+\([a-zA-Z][a-zA-Z0-9._]*\);', 'w')
  let packageName = substitute(getline(lnum), '^\s*package\s\+\([a-zA-Z][a-zA-Z0-9._]*\);', '\1', '')

  call cursor(lnum_old, col_old)
  return packageName
endfunction

function! javacomplete#collector#FetchClassInfo(fqn)
  call javacomplete#collector#FetchInfoFromServer(a:fqn, '-E')
endfunction

function! javacomplete#collector#FetchInfoFromServer(class, option)
  if has_key(g:JavaComplete_Cache, substitute(a:class, '\$', '.', 'g'))
    return g:JavaComplete_Cache[substitute(a:class, '\$', '.', 'g')]
  endif

  let res = javacomplete#server#Communicate(a:option, a:class, 'collector#FetchInfoFromServer')
  if res =~ "^{'"
    let dict = eval(res)
    for key in keys(dict)
      if !has_key(g:JavaComplete_Cache, key)
        if type(dict[key]) == type({})
          let g:JavaComplete_Cache[substitute(key, '\$', '.', '')] = javacomplete#util#Sort(dict[key])
        elseif type(dict[key]) == type([])
          let g:JavaComplete_Cache[substitute(key, '\$', '.', '')] = sort(dict[key])
        endif
      endif
    endfor
  else
    let b:errormsg = res
  endif
endfunction

function! s:SplitTypeArguments(typename)
  if a:typename =~ g:RE_TYPE_WITH_ARGUMENTS
    let lbridx = stridx(a:typename, '<')
    let typeArguments = a:typename[lbridx + 1 : -2]
    let typename = a:typename[0 : lbridx - 1]
    return [typename, typeArguments]
  endif

  let lbridx = stridx(a:typename, '<')
  if lbridx > 0
    let typename = a:typename[0 : lbridx - 1]
    return [typename, 0]
  endif

  return a:typename
endfunction

function! s:CollectTypeArguments(typeArguments, packagename, filekey)
  let collectedArguments = ''
  if !empty(a:typeArguments)
    let typeArguments = a:typeArguments
    let i = 0
    let lbr = 0
    while i < len(typeArguments)
      let c = typeArguments[i]
      if c == '<'
        let lbr += 1
      elseif c == '>'
        let lbr -= 1
      endif

      if c == ',' && lbr == 0
        let typeArguments = typeArguments[0 : i - 1] . "<_split_>". typeArguments[i + 1 : -1]
        let i += 9
      else
        let i += 1
      endif
    endwhile
    
    for arg in split(typeArguments, "<_split_>")
      let argTypeArguments = ''
      if arg =~ g:RE_TYPE_WITH_ARGUMENTS
        let lbridx = stridx(arg, '<')
        let argTypeArguments = arg[lbridx : -1]
        let arg = arg[0 : lbridx - 1]
      endif

      if arg =~ g:RE_TYPE_ARGUMENT_EXTENDS
        let i = matchend(arg, g:RE_TYPE)
        let arg = arg[i+1 : -1]
      endif

      let fqns = s:CollectFQNs(arg, a:packagename, a:filekey, '')
      let collectedArguments .= ''
      if len(fqns) > 1
        let collectedArguments .= '('
      endif
      for fqn in fqns
        if len(fqn) > 0
          let collectedArguments .= fqn. argTypeArguments. '|'
        endif
      endfor
      if len(fqns) > 1
        let collectedArguments = collectedArguments[0:-2]. '),'
      else
        let collectedArguments = collectedArguments[0:-2]. ','
      endif
    endfor
    if !empty(collectedArguments)
      let collectedArguments = '<'. collectedArguments[0:-2]. '>'
    endif
  endif

  return collectedArguments
endfunction

function! s:Tree2ClassInfo(t)
  let t = a:t

  " fill fields and methods
  let t.fields = []
  let t.methods = []
  let t.ctors = []
  let t.classes = []
  for def in t.defs
    if type(def) == type([]) && len(def) == 1
      let tmp = def[0]
      unlet def
      let def = tmp
      unlet tmp
    endif
    if def.tag == 'METHODDEF'
      call add(def.n == t.name ? t.ctors : t.methods, def)
    elseif def.tag == 'VARDEF'
      call add(t.fields, def)
    elseif def.tag == 'CLASSDEF'
      call add(t.classes, t.fqn . '.' . def.name)
    endif
    unlet def
  endfor

  " convert type name in extends to fqn for class defined in source files
  if has_key(a:t, 'filepath') && a:t.filepath != javacomplete#GetCurrentFileKey()
    let filepath = a:t.filepath
    let packagename = get(g:JavaComplete_Files[filepath].unit, 'package', '')
  else
    let filepath = expand('%:p')
    let packagename = javacomplete#collector#GetPackageName()
  endif

  if !has_key(a:t, 'extends')
    let a:t.extends = ['java.lang.Object']
  endif

  let extends = a:t.extends
  if has_key(a:t, 'implements')
    let extends += a:t.implements
  endif

  let i = 0
  while i < len(extends)
    if type(extends[i]) == type("") && extends[i] == get(t, 'fqn', '')
      let i += 1
      continue
    elseif type(extends[i]) == type({}) && extends[i].tag == 'ERRONEOUS'
      let i += 1
      continue
    endif
    let ci = javacomplete#collector#DoGetClassInfo(java_parser#type2Str(extends[i]), filepath, packagename)
    if type(ci) == type([])
      let ci = [0]
    endif
    if has_key(ci, 'fqn')
      let extends[i] = ci.fqn
    endif
    let i += 1
  endwhile

  return t
endfunction

function! s:CollectFQNs(typename, packagename, filekey, extends)
  if len(split(a:typename, '\.')) > 1
    return [a:typename]
  endif

  let brackets = stridx(a:typename, '[')
  let extra = ''
  if brackets >= 0
    let typename = a:typename[0 : brackets - 1]
    let extra = a:typename[brackets : -1]
  else
    let typename = a:typename
  endif

  let directFqn = javacomplete#imports#SearchSingleTypeImport(typename, javacomplete#imports#GetImports('imports_fqn', a:filekey))
  if !empty(directFqn)
    return [directFqn. extra]
  endif

  let fqns = []
  call add(fqns, empty(a:packagename) ? a:typename : a:packagename . '.' . a:typename)
  let imports = javacomplete#imports#GetImports('imports_star', a:filekey)
  for p in imports
    call add(fqns, p . a:typename)
  endfor
  if !empty(a:extends)
    call add(fqns, a:extends)
  endif
  if typename != 'Object'
    call add(fqns, 'java.lang.Object')
  endif
  return fqns
endfunction

function! s:KeyInCache(fqn)
  let fqn = substitute(a:fqn, '<', '\\<', 'g')
  let fqn = substitute(fqn, '>', '\\>', 'g')
  let fqn = substitute(fqn, ']', '\\]', 'g')
  let fqn = substitute(fqn, '[', '\\[', 'g')
  let fqn = substitute(fqn, '\$', '.', 'g')

  let keys = keys(g:JavaComplete_Cache)
  let idx = match(keys, '\v'. fqn. '$')
  
  if idx >= 0
    return keys[idx]
  endif

  return ''
endfunction

" vim:set fdm=marker sw=2 nowrap:
