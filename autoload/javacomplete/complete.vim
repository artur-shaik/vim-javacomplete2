" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" Last Change:	2015-09-14
"
" This file contains everything related to completions

let s:CONTEXT_AFTER_DOT		        = 1
let s:CONTEXT_METHOD_PARAM	        = 2
let s:CONTEXT_IMPORT		        = 3
let s:CONTEXT_IMPORT_STATIC	        = 4
let s:CONTEXT_PACKAGE_DECL	        = 6 
let s:CONTEXT_NEED_TYPE		        = 7 
let s:CONTEXT_COMPLETE_CLASS	    = 8
let s:CONTEXT_METHOD_REFERENCE      = 9
let s:CONTEXT_ANNOTATION_FIELDS     = 10
let s:CONTEXT_OTHER 		        = 0

let s:MODIFIER_ABSTRACT         = '10000000001'

let b:context_type = s:CONTEXT_OTHER

" This function is used for the 'omnifunc' option.		{{{1
function! javacomplete#complete#Complete(findstart, base)
  let g:ClassnameCompleted = 0
  if a:findstart
    " reset enviroment
    let b:dotexpr = ''
    let b:incomplete = ''
    let b:context_type = s:CONTEXT_OTHER

    let statement = javacomplete#scanner#GetStatement()

    let s:et_whole = reltime()
    let start = col('.') - 1

    if javacomplete#util#GetClassNameWithScope() =~ '^[@A-Z][A-Za-z0-9_]*$'
      let b:context_type = s:CONTEXT_COMPLETE_CLASS

      let curline = getline(".")
      let start = col('.') - 1

      while start > 0 && curline[start - 1] =~ '[@A-Za-z0-9_]'
        let start -= 1
        if curline[start] == '@'
          break
        endif
      endwhile

      return start

    elseif statement =~ '[.0-9A-Za-z_]\s*$'
      let valid = 1
      if statement =~ '\.\s*$'
        let valid = statement =~ '[")0-9A-Za-z_\]]\s*\.\s*$' && statement !~ '\<\H\w\+\.\s*$' && statement !~ '\C\<\(abstract\|assert\|break\|case\|catch\|const\|continue\|default\|do\|else\|enum\|extends\|final\|finally\|for\|goto\|if\|implements\|import\|instanceof\|interface\|native\|new\|package\|private\|protected\|public\|return\|static\|strictfp\|switch\|synchronized\|throw\|throws\|transient\|try\|volatile\|while\|true\|false\|null\)\.\s*$'
      endif
      if !valid
        return -1
      endif

      let b:context_type = s:CONTEXT_AFTER_DOT

      " import or package declaration
      if statement =~# '^\s*\(import\|package\)\s\+'
        let statement = substitute(statement, '\s\+\.', '.', 'g')
        let statement = substitute(statement, '\.\s\+', '.', 'g')
        if statement =~ '^\s*import\s\+'
          let b:context_type = statement =~# '\<static\s\+' ? s:CONTEXT_IMPORT_STATIC : s:CONTEXT_IMPORT
          let b:dotexpr = substitute(statement, '^\s*import\s\+\(static\s\+\)\?', '', '')
        else
          let b:context_type = s:CONTEXT_PACKAGE_DECL
          let b:dotexpr = substitute(statement, '\s*package\s\+', '', '')
        endif

        " String literal
      elseif statement =~  '"\s*\.\s*$'
        let b:dotexpr = substitute(statement, '\s*\.\s*$', '\.', '')
        return start - strlen(b:incomplete)

      else
        " type declaration
        let idx_type = matchend(statement, '^\s*' . g:RE_TYPE_DECL)
        if idx_type != -1
          let b:dotexpr = strpart(statement, idx_type)
          " return if not after extends or implements
          if b:dotexpr !~ '^\(extends\|implements\)\s\+'
            return -1
          endif
          let b:context_type = s:CONTEXT_NEED_TYPE
        endif

        let b:dotexpr = javacomplete#scanner#ExtractCleanExpr(statement)
      endif

      " all cases: " java.ut|" or " java.util.|" or "ja|"
      let b:incomplete = strpart(b:dotexpr, strridx(b:dotexpr, '.')+1)
      let b:dotexpr = strpart(b:dotexpr, 0, strridx(b:dotexpr, '.')+1)
      return start - strlen(b:incomplete)

    elseif statement =~ '^@'. g:RE_IDENTIFIER
      let b:context_type = s:CONTEXT_ANNOTATION_FIELDS
      let b:incomplete = substitute(statement, '\s*(\s*$', '', '')

      return start

      " method parameters, treat methodname or 'new' as an incomplete word
    elseif statement =~ '(\s*$'
      " TODO: Need to exclude method declaration?
      let b:context_type = s:CONTEXT_METHOD_PARAM
      let pos = strridx(statement, '(')
      let s:padding = strpart(statement, pos+1)
      let start = start - (len(statement) - pos)

      let statement = substitute(statement, '\s*(\s*$', '', '')

      " new ClassName?
      let str = matchstr(statement, '\<new\s\+' . g:RE_QUALID . '$')
      if str != ''
        let str = substitute(str, '^new\s\+', '', '')
        if !s:IsKeyword(str)
          let b:incomplete = '+'
          let b:dotexpr = str
          return start - len(b:dotexpr)
        endif

        " normal method invocations
      else
        let pos = match(statement, '\s*' . g:RE_IDENTIFIER . '$')
        " case: "method(|)", "this(|)", "super(|)"
        if pos == 0
          let statement = substitute(statement, '^\s*', '', '')
          " treat "this" or "super" as a type name.
          if statement == 'this' || statement == 'super' 
            let b:dotexpr = statement
            let b:incomplete = '+'
            return start - len(b:dotexpr)

          elseif !s:IsKeyword(statement)
            let b:incomplete = statement
            return start - strlen(b:incomplete)
          endif

          " case: "expr.method(|)"
        elseif statement[pos-1] == '.' && !s:IsKeyword(strpart(statement, pos))
          let b:dotexpr = javacomplete#scanner#ExtractCleanExpr(strpart(statement, 0, pos))
          let b:incomplete = strpart(statement, pos)
          return start - strlen(b:incomplete)
        endif
      endif

    elseif statement =~ '[.0-9A-Za-z_\<\>]*::$'
      let b:context_type = s:CONTEXT_METHOD_REFERENCE
      let b:dotexpr = javacomplete#scanner#ExtractCleanExpr(statement)
      return start - strlen(b:incomplete)
    endif

    return -1
  endif

  call javacomplete#server#Start()

  let result = []

  " Try to complete incomplete class name
  if b:context_type == s:CONTEXT_COMPLETE_CLASS && a:base =~ '^[@A-Z][A-Za-z0-9_]*$'
    if a:base =~ g:RE_ANNOTATION
      let response = javacomplete#server#Communicate("-similar-annotations", a:base[1:], 'Filter packages by incomplete class name')
    else
      let response = javacomplete#server#Communicate("-similar-classes", a:base, 'Filter packages by incomplete class name')
    endif
    if response =~ '^['
      let result = eval(response)
    endif
    if !empty(result)
      let g:ClassnameCompleted = 1
      return result
    endif
  endif

  " Return list of matches.

  if b:dotexpr =~ '^\s*$' && b:incomplete =~ '^\s*$'
    return []
  endif

  if b:dotexpr !~ '^\s*$'
    if b:context_type == s:CONTEXT_AFTER_DOT || b:context_type == s:CONTEXT_METHOD_REFERENCE
      let result = s:CompleteAfterDot(b:dotexpr)
    elseif b:context_type == s:CONTEXT_IMPORT || b:context_type == s:CONTEXT_IMPORT_STATIC || b:context_type == s:CONTEXT_PACKAGE_DECL || b:context_type == s:CONTEXT_NEED_TYPE
      let result = s:GetMembers(b:dotexpr[:-2])
    elseif b:context_type == s:CONTEXT_METHOD_PARAM
      if b:incomplete == '+'
        let result = s:GetConstructorList(b:dotexpr)
      else
        let result = s:CompleteAfterDot(b:dotexpr)
      endif
    endif

    " only incomplete word
  elseif b:incomplete !~ '^\s*$'
    " only need methods
    if b:context_type == s:CONTEXT_METHOD_PARAM
      let methods = s:SearchForName(b:incomplete, 0, 1)[1]
      call extend(result, eval('[' . s:DoGetMethodList(methods) . ']'))

    elseif b:context_type == s:CONTEXT_ANNOTATION_FIELDS
      let last = split(b:incomplete, '@')[-1]
      let identList = matchlist(last, '\('. g:RE_IDENTIFIER. '\)\((\|$\)')
      if !empty(identList)
        let name = identList[1]
        let ti = s:DoGetClassInfo(name)
        if has_key(ti, 'methods') 
          let methods = []
          for m in ti.methods
            if m.m == s:MODIFIER_ABSTRACT && m.n !~ '^\(toString\|annotationType\|equals\|hashCode\)$'
              call add(methods, m)
            endif
          endfor
          call extend(result, eval('[' . s:DoGetMethodList(methods, 2) . ']'))
        endif

      endif
    else
      let result = s:CompleteAfterWord(b:incomplete)
    endif

    " then no filter needed
    let b:incomplete = ''
  endif


  if len(result) > 0
    " filter according to b:incomplete
    if len(b:incomplete) > 0 && b:incomplete != '+'
      let result = filter(result, "type(v:val) == type('') ? v:val =~ '^" . b:incomplete . "' : v:val['word'] =~ '^" . b:incomplete . "'")
    endif

    if exists('s:padding') && !empty(s:padding)
      for item in result
        if type(item) == type("")
          let item .= s:padding
        else
          let item.word .= s:padding
        endif
      endfor
      unlet s:padding
    endif

    call javacomplete#logger#Log('finish completion' . reltimestr(reltime(s:et_whole)) . 's')
    return result
  endif

  if len(b:errormsg) > 0
    echoerr 'javacomplete error: ' . b:errormsg
    let b:errormsg = ''
  endif
endfunction

" Precondition:	incomplete must be a word without '.'.
" return all the matched, variables, fields, methods, types, packages
function! s:CompleteAfterWord(incomplete)
  " packages in jar files
  if !exists('s:all_packages_in_jars_loaded')
    call s:DoGetInfoByReflection('-', '-P')
    let s:all_packages_in_jars_loaded = 1
  endif

  let pkgs = []
  let types = []
  for key in keys(b:j_cache)
    if key =~# '^' . a:incomplete
      if type(b:j_cache[key]) == type('') || get(b:j_cache[key], 'tag', '') == 'PACKAGE'
        call add(pkgs, {'kind': 'P', 'word': key})

        " filter out type info
      elseif b:context_type != s:CONTEXT_PACKAGE_DECL && b:context_type != s:CONTEXT_IMPORT && b:context_type != s:CONTEXT_IMPORT_STATIC
        call add(types, {'kind': 'C', 'word': key})
      endif
    endif
  endfor

  let pkgs += s:DoGetPackageInfoInDirs(a:incomplete, b:context_type == s:CONTEXT_PACKAGE_DECL, 1)


  " add accessible types which name beginning with the incomplete in source files
  " TODO: remove the inaccessible
  if b:context_type != s:CONTEXT_PACKAGE_DECL
    " single type import
    for fqn in javacomplete#imports#GetImports('imports_fqn')
      let name = fqn[strridx(fqn, ".")+1:]
      if name =~ '^' . a:incomplete
        call add(types, {'kind': 'C', 'word': name})
      endif
    endfor

    " current file
    let lnum_old = line('.')
    let col_old = col('.')
    call cursor(1, 1)
    while 1
      let lnum = search('\<\C\(class\|interface\|enum\)[ \t\n\r]\+' . a:incomplete . '[a-zA-Z0-9_$]*[< \t\n\r]', 'W')
      if lnum == 0
        break
      elseif javacomplete#util#InCommentOrLiteral(line('.'), col('.'))
        continue
      else
        normal w
        call add(types, {'kind': 'C', 'word': matchstr(getline(line('.'))[col('.')-1:], g:RE_IDENTIFIER)})
      endif
    endwhile
    call cursor(lnum_old, col_old)

    " other files
    let filepatterns = ''
    for dirpath in s:GetSourceDirs(expand('%:p'))
      let filepatterns .= escape(dirpath, ' \') . '/*.java '
    endfor
    exe 'vimgrep /\s*' . g:RE_TYPE_DECL . '/jg ' . filepatterns
    for item in getqflist()
      if item.text !~ '^\s*\*\s\+'
        let text = matchstr(javacomplete#util#Prune(item.text, -1), '\s*' . g:RE_TYPE_DECL)
        if text != ''
          let subs = split(substitute(text, '\s*' . g:RE_TYPE_DECL, '\1;\2;\3', ''), ';', 1)
          if subs[2] =~# '^' . a:incomplete && (subs[0] =~ '\C\<public\>' || fnamemodify(bufname(item.bufnr), ':p:h') == expand('%:p:h'))
            call add(types, {'kind': 'C', 'word': subs[2]})
          endif
        endif
      endif
    endfor
  endif


  let result = []

  " add variables and members in source files
  if b:context_type == s:CONTEXT_AFTER_DOT
    let matches = s:SearchForName(a:incomplete, 0, 0)
    let result += sort(eval('[' . s:DoGetFieldList(matches[2]) . ']'))
    let result += sort(eval('[' . s:DoGetMethodList(matches[1]) . ']'))
  endif
  let result += sort(pkgs)
  let result += sort(types)

  return result
endfunction


" Precondition:	expr must end with '.'
" return members of the value of expression
function! s:CompleteAfterDot(expr)
  let items = javacomplete#scanner#ParseExpr(a:expr)		" TODO: return a dict containing more than items
  if empty(items)
    return []
  endif


  " 0. String literal
  if items[-1] =~  '"$'
    call javacomplete#logger#Log('P1. "str".|')
    return s:GetMemberList("java.lang.String")
  endif


  let ti = {}
  let ii = 1		" item index
  let itemkind = 0

  "
  " optimized process
  "
  " search the longest expr consisting of ident
  let i = 1
  let k = i
  while i < len(items) && items[i] =~ '^\s*' . g:RE_IDENTIFIER . '\s*$'
    let ident = substitute(items[i], '\s', '', 'g')
    if ident == 'class' || ident == 'this' || ident == 'super'
      let k = i
      " return when found other keywords
    elseif s:IsKeyword(ident)
      return []
    endif
    let items[i] = substitute(items[i], '\s', '', 'g')
    let i += 1
  endwhile

  if i > 1
    " cases: "this.|", "super.|", "ClassName.this.|", "ClassName.super.|", "TypeName.class.|"
    if items[k] ==# 'class' || items[k] ==# 'this' || items[k] ==# 'super'
      call javacomplete#logger#Log('O1. ' . items[k] . ' ' . join(items[:k-1], '.'))
      let ti = s:DoGetClassInfo(items[k] == 'class' ? 'java.lang.Class' : join(items[:k-1], '.'))
      if !empty(ti)
        let itemkind = items[k] ==# 'this' ? 1 : items[k] ==# 'super' ? 2 : 0
        let ii = k+1
      else
        return []
      endif

      " case: "java.io.File.|"
    else
      let fqn = join(items[:i-1], '.')
      let srcpath = join(s:GetSourceDirs(expand('%:p'), s:GetPackageName()), ',')
      call javacomplete#logger#Log('O2. ' . fqn)
      call s:FetchClassInfo(fqn)
      if get(get(b:j_cache, fqn, {}), 'tag', '') == 'CLASSDEF'
        let ti = b:j_cache[fqn]
        let itemkind = 11
        let ii = i
      endif
    endif
  endif


  "
  " first item
  "
  if empty(ti)
    " cases:
    " 1) "int.|", "void.|"	- primitive type or pseudo-type, return `class`
    " 2) "this.|", "super.|"	- special reference
    " 3) "var.|"		- variable or field
    " 4) "String.|" 		- type imported or defined locally
    " 5) "java.|"   		- package
    if items[0] =~ '^\s*' . g:RE_IDENTIFIER . '\s*$'
      let ident = substitute(items[0], '\s', '', 'g')

      if s:IsKeyword(ident)
        " 1)
        call javacomplete#logger#Log('F1. "' . ident . '.|"')
        if ident ==# 'void' || s:IsBuiltinType(ident)
          let ti = g:J_PRIMITIVE_TYPE_INFO
          let itemkind = 11

          " 2)
          call javacomplete#logger#Log('F2. "' . ident . '.|"')
        elseif ident ==# 'this' || ident ==# 'super'
          let itemkind = ident ==# 'this' ? 1 : ident ==# 'super' ? 2 : 0
          let ti = s:DoGetClassInfo(ident)
        endif

      else
        " 3)
        let typename = s:GetDeclaredClassName(ident)
        call javacomplete#logger#Log('F3. "' . ident . '.|"  typename: "' . typename . '"')
        if (typename != '')
          if typename[0] == '[' || typename[-1:] == ']'
            let ti = g:J_ARRAY_TYPE_INFO
          elseif typename != 'void' && !s:IsBuiltinType(typename)
            let ti = s:DoGetClassInfo(typename)
          endif

        else
          " 4)
          call javacomplete#logger#Log('F4. "TypeName.|"')
          let ti = s:DoGetClassInfo(ident)
          let itemkind = 11

          if get(ti, 'tag', '') != 'CLASSDEF'
            let ti = {}
          endif

          " 5)
          if empty(ti)
            call javacomplete#logger#Log('F5. "package.|"')
            unlet ti
            let ti = s:GetMembers(ident)	" s:DoGetPackegInfo(ident)
            let itemkind = 20
          endif
        endif
      endif

      " method invocation:	"method().|"	- "this.method().|"
    elseif items[0] =~ '^\s*' . g:RE_IDENTIFIER . '\s*('
      let ti = s:MethodInvocation(items[0], ti, itemkind)

      " array type, return `class`: "int[] [].|", "java.lang.String[].|", "NestedClass[].|"
    elseif items[0] =~# g:RE_ARRAY_TYPE
      call javacomplete#logger#Log('array type. "' . items[0] . '"')
      let qid = substitute(items[0], g:RE_ARRAY_TYPE, '\1', '')
      if s:IsBuiltinType(qid) || (!s:HasKeyword(qid) && !empty(s:DoGetClassInfo(qid)))
        let ti = g:J_PRIMITIVE_TYPE_INFO
        let itemkind = 11
      endif

      " class instance creation expr:	"new String().|", "new NonLoadableClass().|"
      " array creation expr:	"new int[i=1] [val()].|", "new java.lang.String[].|"
    elseif items[0] =~ '^\s*new\s\+'
      call javacomplete#logger#Log('creation expr. "' . items[0] . '"')
      let subs = split(substitute(items[0], '^\s*new\s\+\(' .g:RE_QUALID. '\)\s*\([([]\)', '\1;\2', ''), ';')
      if subs[1][0] == '['
        let ti = g:J_ARRAY_TYPE_INFO
      elseif subs[1][0] == '('
        let ti = s:DoGetClassInfo(subs[0])
        " exclude interfaces and abstract class.  TODO: exclude the inaccessible
        if get(ti, 'flags', '')[-10:-10] || get(ti, 'flags', '')[-11:-11]
          echo 'cannot instantiate the type ' . subs[0]
          let ti = {}
          return []
        endif
      endif

      " casting conversion:	"(Object)o.|"
    elseif items[0] =~ g:RE_CASTING
      call javacomplete#logger#Log('Casting conversion. "' . items[0] . '"')
      let subs = split(substitute(items[0], g:RE_CASTING, '\1;\2', ''), ';')
      let ti = s:DoGetClassInfo(subs[0])

      " array access:	"var[i][j].|"		Note: "var[i][]" is incorrect
    elseif items[0] =~# g:RE_ARRAY_ACCESS
      let subs = split(substitute(items[0], g:RE_ARRAY_ACCESS, '\1;\2', ''), ';')
      if get(subs, 1, '') !~ g:RE_BRACKETS
        let typename = s:GetDeclaredClassName(subs[0])
        if type(typename) == type([])
          let typename = typename[0]
        endif
        call javacomplete#logger#Log('ArrayAccess. "' .items[0]. '.|"  typename: "' . typename . '"')
        if (typename != '')
          let ti = s:ArrayAccess(typename, items[0])
        endif
      endif
    endif
  endif


  "
  " next items
  "
  while !empty(ti) && ii < len(items)
    " method invocation:	"PrimaryExpr.method(parameters)[].|"
    if items[ii] =~ '^\s*' . g:RE_IDENTIFIER . '\s*('
      let ti = s:MethodInvocation(items[ii], ti, itemkind)
      let itemkind = 0
      let ii += 1
      continue


      " expression of selection, field access, array access
    elseif items[ii] =~ g:RE_SELECT_OR_ACCESS
      let subs = split(substitute(items[ii], g:RE_SELECT_OR_ACCESS, '\1;\2', ''), ';')
      let ident = subs[0]
      let brackets = get(subs, 1, '')

      " package members
      if itemkind/10 == 2 && empty(brackets) && !s:IsKeyword(ident)
        let qn = join(items[:ii], '.')
        call javacomplete#logger#Log("package members: ". qn)
        if type(ti) == type([])
          let idx = javacomplete#util#Index(ti, ident, 'word')
          if idx >= 0
            if ti[idx].kind == 'P'
              unlet ti
              let ti = s:GetMembers(qn)
              let ii += 1
              continue
            elseif ti[idx].kind == 'C'
              unlet ti
              let ti = s:DoGetClassInfo(qn)
              let itemkind = 11
              let ii += 1
              continue
            endif
          endif
        endif


        " type members
      elseif itemkind/10 == 1 && empty(brackets)
        if ident ==# 'class' || ident ==# 'this' || ident ==# 'super'
          call javacomplete#logger#Log("type members: ". ident)
          let ti = s:DoGetClassInfo(ident == 'class' ? 'java.lang.Class' : join(items[:ii-1], '.'))
          let itemkind = ident ==# 'this' ? 1 : ident ==# 'super' ? 2 : 0
          let ii += 1
          continue

        elseif !s:IsKeyword(ident) && type(ti) == type({}) && get(ti, 'tag', '') == 'CLASSDEF'
          " accessible static field
          call javacomplete#logger#Log("static fields: ". ident)
          let members = javacomplete#complete#SearchMember(ti, ident, 1, itemkind, 1, 0)
          if !empty(members[2])
            let ti = s:ArrayAccess(members[2][0].t, items[ii])
            let itemkind = 0
            let ii += 1
            continue
          endif

          " accessible nested type
          "if !empty(filter(copy(get(ti, 'classes', [])), 'strpart(v:val, strridx(v:val, ".")) ==# "' . ident . '"'))
          if !empty(members[0])
            let ti = s:DoGetClassInfo(join(items[:ii], '.'))
            let ii += 1
            continue
          endif
        endif


        " instance members
      elseif itemkind/10 == 0 && !s:IsKeyword(ident)
        if type(ti) == type({}) && get(ti, 'tag', '') == 'CLASSDEF'
          call javacomplete#logger#Log("instance members")
          let members = javacomplete#complete#SearchMember(ti, ident, 1, itemkind, 1, 0)
          let itemkind = 0
          if !empty(members[2])
            let ti = s:ArrayAccess(members[2][0].t, items[ii])
            let ii += 1
            continue
          endif
        endif
      endif
    endif

    return []
  endwhile


  " type info or package info --> members
  if !empty(ti)
    if type(ti) == type({})
      if get(ti, 'tag', '') == 'CLASSDEF'
        if get(ti, 'name', '') == '!'
          return [{'kind': 'f', 'word': 'class', 'menu': 'Class'}]
        elseif get(ti, 'name', '') == '['
          return g:J_ARRAY_TYPE_MEMBERS
        elseif itemkind < 20
          return s:DoGetMemberList(ti, itemkind)
        endif
      elseif get(ti, 'tag', '') == 'PACKAGE'
        " TODO: ti -> members, in addition to packages in dirs
        return s:GetMembers( substitute(join(items, '.'), '\s', '', 'g') )
      endif
    elseif type(ti) == type([])
      return ti
    endif
  endif

  return []
endfunction

function! s:MethodInvocation(expr, ti, itemkind)
  let subs = split(substitute(a:expr, '\s*\(' . g:RE_IDENTIFIER . '\)\s*\((.*\)', '\1;\2', ''), ';')

  " all methods matched
  if empty(a:ti)
    let methods = s:SearchForName(subs[0], 0, 1)[1]
  elseif type(a:ti) == type({}) && get(a:ti, 'tag', '') == 'CLASSDEF'
    let methods = javacomplete#complete#SearchMember(a:ti, subs[0], 1, a:itemkind, 1, 0, a:itemkind == 2)[1]
  else
    let methods = []
  endif

  let method = s:DetermineMethod(methods, subs[1])
  if !empty(method)
    return s:ArrayAccess(method.r, a:expr)
  endif
  return {}
endfunction

function! s:ArrayAccess(arraytype, expr)
  if a:expr =~ g:RE_BRACKETS	| return {} | endif
  let typename = a:arraytype

  call javacomplete#logger#Log("array access: ". typename)

  let dims = 0
  if typename[0] == '[' || typename[-1:] == ']' || a:expr[-1:] == ']'
    let dims = javacomplete#util#CountDims(a:expr) - javacomplete#util#CountDims(typename)
    if dims == 0
      let typename = typename[0 : stridx(typename, '[') - 1]
    elseif dims < 0
      return g:J_ARRAY_TYPE_INFO
    else
      "echoerr 'dims exceeds'
    endif
  endif
  if dims == 0
    if typename != 'void' && !s:IsBuiltinType(typename)
      return s:DoGetClassInfo(typename)
    endif
  endif
  return {}
endfunction

" searches for name of a var or a field and determines the meaning  {{{1

" The standard search order of a variable or field is as follows:
" 1. Local variables declared in the code block, for loop, or catch clause
"    from current scope up to the most outer block, a method or an initialization block
" 2. Parameters if the code is in a method or ctor
" 3. Fields of the type
" 4. Accessible inherited fields.
" 5. If the type is a nested type,
"    local variables of the enclosing block or fields of the enclosing class.
"    Note that if the type is a static nested type, only static members of an enclosing block or class are searched
"    Reapply this rule to the upper block and class enclosing the enclosing type recursively
" 6. Accessible static fields imported.
"    It is allowed that several fields with the same name.

" The standard search order of a method is as follows:
" 1. Methods of the type
" 2. Accessible inherited methods.
" 3. Methods of the enclosing class if the type is a nested type.
" 4. Accessible static methods imported.
"    It is allowed that several methods with the same name and signature.

" first		return at once if found one.
" fullmatch	1 - equal, 0 - match beginning
" return [types, methods, fields, vars]
function! s:SearchForName(name, first, fullmatch)
  let result = [[], [], [], []]
  if s:IsKeyword(a:name)
    return result
  endif

  let unit = javacomplete#parseradapter#Parse()
  let targetPos = java_parser#MakePos(line('.')-1, col('.')-1)
  let trees = javacomplete#parseradapter#SearchNameInAST(unit, a:name, targetPos, a:fullmatch)
  for tree in trees
    if tree.tag == 'VARDEF'
      call add(result[2], tree)
    elseif tree.tag == 'METHODDEF'
      call add(result[1], tree)
    elseif tree.tag == 'CLASSDEF'
      call add(result[0], tree.name)
    elseif tree.tag == 'LAMBDA'
      let t = s:DetermineLambdaArguments(unit, tree, a:name)
      if !empty(t)
        call add(result[2], t)
      endif
    endif
  endfor

  if a:first && result != [[], [], [], []]	| return result | endif

  " Accessible inherited members
  let type = get(javacomplete#parseradapter#SearchTypeAt(unit, targetPos), -1, {})
  if !empty(type)
    let members = javacomplete#complete#SearchMember(type, a:name, a:fullmatch, 2, 1, 0, 1)
    let result[0] += members[0]
    let result[1] += members[1]
    let result[2] += members[2]
  endif

  " static import
  let si = javacomplete#imports#SearchStaticImports(a:name, a:fullmatch)
  let result[1] += si[1]
  let result[2] += si[2]

  return result
endfunction

function! s:DetermineLambdaArguments(unit, ti, name)
  let nameInLambda = 0
  let argIdx = 0 " argument index in methods arguments declaration
  let argPos = 0
  if type(a:ti.args) == type({})
    if a:name == a:ti.args.name
      let nameInLambda = 1
    endif
  elseif type(a:ti.args) == type([])
    for arg in a:ti.args
      if arg.name == a:name
        let nameInLambda = 1
        let argPos = arg.pos
        break
      endif
      let argIdx += 1
    endfor
  endif

  if !nameInLambda
    return {}
  endif

  let t = a:ti
  let type = ''
  if has_key(t, 'meth') && !empty(t.meth)
    let result = []
    while 1
      if has_key(t, 'meth')
        let t = t.meth
      elseif t.tag == 'SELECT' && has_key(t, 'selected')
        call add(result, t.name. '()')
        let t = t.selected
      elseif t.tag == 'IDENT'
        call add(result, t.name)
        break
      endif
    endwhile

    let items = reverse(result)
    let typename = s:GetDeclaredClassName(items[0])
    let ti = {}
    if (typename != '')
      if typename[1] == '[' || typename[-1:] == ']'
        let ti = g:J_ARRAY_TYPE_INFO
      elseif typename != 'void' && !s:IsBuiltinType(typename)
        let ti = s:DoGetClassInfo(typename)
      endif
    endif

    let ii = 1
    while !empty(ti) && ii < len(items) - 1
      " method invocation:	"PrimaryExpr.method(parameters)[].|"
      if items[ii] =~ '^\s*' . g:RE_IDENTIFIER . '\s*('
        let ti = s:MethodInvocation(items[ii], ti, 0)
      endif
      let ii += 1
    endwhile

    if has_key(ti, 'methods')
      let method = {}
      for m in ti.methods
        if m.n == split(items[-1], '(')[0]
          let method = m
        endif
      endfor

      if a:ti.idx < len(method.p)
        let type = method.p[a:ti.idx]
      endif
    endif
  elseif has_key(t, 'stats') && !empty(t.stats)
    if t.stats.tag == 'VARDEF'
      let type = t.stats.t
    elseif t.stats.tag == 'RETURN'
      for ty in a:unit.types
        for def in ty.defs
          if def.tag == 'METHODDEF'
            if t.stats.pos >= def.body.pos && t.stats.endpos <= def.body.endpos
              let type = def.r
            endif
          endif
        endfor
      endfor

    endif
  endif

  " type should be FunctionInterface, and it contains only one abstract method
  if !empty(type)
    let functionalMembers = s:DoGetClassInfo(type)
    if has_key(functionalMembers, 'methods')
      for m in functionalMembers.methods
        if m.m == s:MODIFIER_ABSTRACT
          if argIdx < len(m.p)
            let type = m.p[argIdx]
            break
          endif
        endif
      endfor

      return {'tag': 'VARDEF', 'name': a:name, 'type': {'tag': 'IDENT', 'name': type}, 'vartype': {'tag': 'IDENT', 'name': type, 'pos': argPos}, 'pos': argPos}
    endif
  endif

  return {}
endfunction

" TODO: how to determine overloaded functions
function! s:DetermineMethod(methods, parameters)
  return get(a:methods, 0, {})
endfunction

" Parser.GetType() in insenvim
function! s:GetDeclaredClassName(var)
  let var = javacomplete#util#Trim(a:var)
  call javacomplete#logger#Log('GetDeclaredClassName for "' . var . '"')
  if var =~# '^\(this\|super\)$'
    return var
  endif


  " Special handling for builtin objects in JSP
  if &ft == 'jsp'
    if get(s:JSP_BUILTIN_OBJECTS, a:var, '') != ''
      return s:JSP_BUILTIN_OBJECTS[a:var]
    endif
  endif

  let variable = get(s:SearchForName(var, 1, 1)[2], -1, {})
  return get(variable, 'tag', '') == 'VARDEF' ? java_parser#type2Str(variable.vartype) : get(variable, 't', '')

endfunction

function! s:IsStatic(modifier)
  return a:modifier[strlen(a:modifier)-4]
endfunction

function! s:IsBuiltinType(name)
  return index(b:J_PRIMITIVE_TYPES, a:name) >= 0
endfunction

function! s:IsKeyword(name)
  return index(b:J_KEYWORDS, a:name) >= 0
endfunction

function! s:HasKeyword(name)
  return a:name =~# g:RE_KEYWORDS
endfunction

function! s:GetSourceDirs(filepath, ...)
  let dirs = exists('s:sourcepath') ? s:sourcepath : []

  if !empty(a:filepath)
    let filepath = fnamemodify(a:filepath, ':p:h')

    " get source path according to file path and package name
    let packageName = a:0 > 0 ? a:1 : s:GetPackageName()
    if packageName != ''
      let path = fnamemodify(substitute(filepath, packageName, '', 'g'), ':p:h')
      if index(dirs, path) < 0
        call add(dirs, path)
      endif
    endif

    " Consider current path as a sourcepath
    if index(dirs, filepath) < 0
      call add(dirs, filepath)
    endif
  endif
  return dirs
endfunction

" return only classpath which are directories
function! s:GetClassDirs()
  let dirs = []
  for path in split(javacomplete#server#GetClassPath(), b:PATH_SEP)
    if isdirectory(path)
      call add(dirs, fnamemodify(path, ':p:h'))
    endif
  endfor
  return dirs
endfunction

" s:GetPackageName()							{{{2
function! s:GetPackageName()
  let lnum_old = line('.')
  let col_old = col('.')

  call cursor(1, 1)
  let lnum = search('^\s*package[ \t\r\n]\+\([a-zA-Z][a-zA-Z0-9.]*\);', 'w')
  let packageName = substitute(getline(lnum), '^\s*package\s\+\([a-zA-Z][a-zA-Z0-9.]*\);', '\1', '')

  call cursor(lnum_old, col_old)
  return packageName
endfunction

" functions to get information						{{{1
" class information							{{{2

function! s:FetchClassInfo(fqn)
  if has_key(b:j_cache, a:fqn)
    return b:j_cache[a:fqn]
  endif

  let res = javacomplete#server#Communicate('-E', a:fqn, 'FetchClassInfo in Batch')
  if res =~ "^{'"
    let dict = eval(res)
    for key in keys(dict)
      if !has_key(b:j_cache, key)
        if type(dict[key]) == type({})
          let b:j_cache[key] = javacomplete#util#Sort(dict[key])
        elseif type(dict[key]) == type([])
          let b:j_cache[key] = sort(dict[key])
        endif
      endif
    endfor
  endif
endfunction

" a:1	filepath
" a:2	package name
function! s:DoGetClassInfo(class, ...)
  if has_key(b:j_cache, a:class)
    return b:j_cache[a:class]
  endif

  call javacomplete#logger#Log("DoGetClassInfo: ". a:class)

  " array type:	TypeName[] or '[I' or '[[Ljava.lang.String;'
  if a:class[-1:] == ']' || a:class[0] == '['
    return g:J_ARRAY_TYPE_INFO
  endif

  let filekey	= a:0 > 0 && len(a:1) > 0 ? a:1 : javacomplete#GetCurrentFileKey()
  let packagename = a:0 > 1 && len(a:2) > 0 ? a:2 : s:GetPackageName()

  " either this or super is not qualified
  let t = get(javacomplete#parseradapter#SearchTypeAt(javacomplete#parseradapter#Parse(), java_parser#MakePos(line('.')-1, col('.')-1)), -1, {})
  if a:class == 'this' || a:class == 'super' || (has_key(t, 'fqn') && t.fqn == packagename.'.'.a:class)
    if &ft == 'jsp'
      let ci = s:DoGetReflectionClassInfo('javax.servlet.jsp.HttpJspPage')
      if a:class == 'this'
        " TODO: search methods defined in <%! [declarations] %>
        "	search methods defined in other jsp files included
        "	avoid including self directly or indirectly
      endif
      return ci
    endif

    call javacomplete#logger#Log('A0. ' . a:class)
    " this can be a local class or anonymous class as well as static type
    if !empty(t)
      " What will be returned for super?
      " - the protected or public inherited fields and methods. No ctors.
      " - the (public static) fields of interfaces.
      " - the methods of the Object class.
      " What will be returned for this?
      " - besides the above, all fields and methods of current class. No ctors.
      return javacomplete#util#Sort(s:Tree2ClassInfo(t))
    endif
  endif

  let typename = a:class 
  "substitute(a:class, '\s', '', 'g')
  let typeArguments = ''

  let splittedType = s:SplitTypeArguments(typename)
  if type(splittedType) == type([])
    let typename = splittedType[0]
    let typeArguments = splittedType[1]
  endif

  if typename !~ '^\s*' . g:RE_QUALID . '\s*$' || s:HasKeyword(typename)
    call javacomplete#logger#Log("No qualid: ". typename)
    return {}
  endif


  let typeArgumentsCollected = s:CollectTypeArguments(typeArguments, packagename, filekey)

  let fqns = s:CollectFQNs(typename, packagename, filekey)
  for fqn in fqns
    let fqn = fqn. typeArgumentsCollected
    call s:FetchClassInfo(fqn)

    let key = s:KeyInCache(fqn)
    if !empty(key)
      return get(b:j_cache[key], 'tag', '') == 'CLASSDEF' ? b:j_cache[key] : {}
    endif
  endfor

  return {}
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
  let typeArgumentsCollected = ''
  if !empty(a:typeArguments)
    let typeArguments = a:typeArguments
    let i = 0
    let lbr = 0
    let stidx = 0
    while i < len(typeArguments)
      let c = typeArguments[i]
      if c == '<'
        let lbr += 1
      elseif c == '>'
        let lbr -= 1
      endif

      if c == ',' && lbr == 0
        let typeArguments = typeArguments[stidx : i - 1] . "<_split_>". typeArguments[i + 1 : -1]
        let stidx = i
      endif
      let i += 1
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

      let fqns = s:CollectFQNs(arg, a:packagename, a:filekey)
      let typeArgumentsCollected .= ''
      if len(fqns) > 1
        let typeArgumentsCollected .= '('
      endif
      for fqn in fqns
        if len(fqn) > 0
          let typeArgumentsCollected .= fqn. argTypeArguments. '|'
        endif
      endfor
      if len(fqns) > 1
        let typeArgumentsCollected = typeArgumentsCollected[0:-2]. '),'
      else
        let typeArgumentsCollected = typeArgumentsCollected[0:-2]. ','
      endif
    endfor
    if !empty(typeArgumentsCollected)
      let typeArgumentsCollected = '<'. typeArgumentsCollected[0:-2]. '>'
    endif
  endif

  return typeArgumentsCollected
endfunction

function! s:KeyInCache(fqn)
  let fqn = substitute(a:fqn, '<', '\\<', 'g')
  let fqn = substitute(fqn, '>', '\\>', 'g')
  let fqn = substitute(fqn, ']', '\\]', 'g')
  let fqn = substitute(fqn, '[', '\\[', 'g')

  let keys = keys(b:j_cache)
  let idx = match(keys, '\v'. fqn. '$')
  
  if idx >= 0
    return keys[idx]
  endif

  return ''
endfunction

function! s:CollectFQNs(typename, packagename, filekey)
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
  call add(fqns, 'java.lang.Object')
  return fqns
endfunction

" Parameters:
"   class	the qualified class name
" Return:	TClassInfo or {} when not found
" See ClassInfoFactory.getClassInfo() in insenvim.
function! s:DoGetReflectionClassInfo(fqn)
  if !has_key(b:j_cache, a:fqn)
    let res = javacomplete#server#Communicate('-C', a:fqn, 's:DoGetReflectionClassInfo')
    if res =~ '^{'
      let b:j_cache[a:fqn] = javacomplete#util#Sort(eval(res))
    elseif res =~ '^['
      for type in eval(res)
        if get(type, 'name', '') != ''
          let b:j_cache[type.name] = javacomplete#util#Sort(type)
        endif
      endfor
    else
      let b:errormsg = res
    endif
  endif
  return get(b:j_cache, a:fqn, {})
endfunction

function! s:Tree2ClassInfo(t)
  let t = a:t

  " fill fields and methods
  let t.fields = []
  let t.methods = []
  let t.ctors = []
  let t.classes = []
  for def in t.defs
    if def.tag == 'METHODDEF'
      call add(def.n == t.name ? t.ctors : t.methods, def)
    elseif def.tag == 'VARDEF'
      call add(t.fields, def)
    elseif def.tag == 'CLASSDEF'
      call add(t.classes, t.fqn . '.' . def.name)
    endif
  endfor

  " convert type name in extends to fqn for class defined in source files
  if has_key(a:t, 'filepath') && a:t.filepath != javacomplete#GetCurrentFileKey()
    let filepath = a:t.filepath
    let packagename = get(b:j_files[filepath].unit, 'package', '')
  else
    let filepath = expand('%:p')
    let packagename = s:GetPackageName()
  endif

  if !has_key(a:t, 'extends')
    let a:t.extends = ['java.lang.Object']
  endif

  let extends = a:t.extends

  let i = 0
  while i < len(extends)
    let ci = s:DoGetClassInfo(java_parser#type2Str(extends[i]), filepath, packagename)
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

" package information							{{{2

function! s:DoGetInfoByReflection(class, option)
  if has_key(b:j_cache, a:class)
    return b:j_cache[a:class]
  endif

  let res = javacomplete#server#Communicate(a:option, a:class, 's:DoGetInfoByReflection')
  if res =~ '^[{\[]'
    let v = eval(res)
    if type(v) == type([])
      let b:j_cache[a:class] = sort(v)
    elseif type(v) == type({})
      if get(v, 'tag', '') =~# '^\(PACKAGE\|CLASSDEF\)$'
        let b:j_cache[a:class] = v
      else
        call extend(b:j_cache, v, 'force')
      endif
    endif
    unlet v
  else
    let b:errormsg = res
  endif

  return get(b:j_cache, a:class, {})
endfunction

" search in members							{{{2
" TODO: what about default access?
" public for all              
" protected for this or super 
" private for this            
function! s:CanAccess(mods, kind)
  return (a:mods[-4:-4] || a:kind/10 == 0)
        \ &&   (a:kind == 1 || a:mods[-1:]
        \	|| (a:mods[-3:-3] && (a:kind == 1 || a:kind == 2))
        \	|| (a:mods[-2:-2] && a:kind == 1))
endfunction

function! javacomplete#complete#SearchMember(ci, name, fullmatch, kind, returnAll, memberkind, ...)
  let result = [[], [], []]

  if a:kind != 13
    for m in (a:0 > 0 && a:1 ? [] : get(a:ci, 'fields', [])) + ((a:kind == 1 || a:kind == 2) ? get(a:ci, 'declared_fields', []) : [])
      if empty(a:name) || (a:fullmatch ? m.n ==# a:name : m.n =~# '^' . a:name)
        if s:CanAccess(m.m, a:kind)
          call add(result[2], m)
        endif
      endif
    endfor

    for m in (a:0 > 0 && a:1 ? [] : get(a:ci, 'methods', [])) + ((a:kind == 1 || a:kind == 2) ? get(a:ci, 'declared_methods', []) : [])
      if empty(a:name) || (a:fullmatch ? m.n ==# a:name : m.n =~# '^' . a:name)
        if s:CanAccess(m.m, a:kind)
          call add(result[1], m)
        endif
      endif
    endfor
  endif

  if a:kind/10 != 0
    let types = get(a:ci, 'classes', [])
    for t in types
      if empty(a:name) || (a:fullmatch ? t[strridx(t, '.')+1:] ==# a:name : t[strridx(t, '.')+1:] =~# '^' . a:name)
        if !has_key(b:j_cache, t) || !has_key(b:j_cache[t], 'flags') || a:kind == 1 || b:j_cache[t].flags[-1:]
          call add(result[0], t)
        endif
      endif
    endfor
  endif

  " key `classpath` indicates it is a loaded class from classpath
  " All public members of a loaded class are stored in current ci
  if !has_key(a:ci, 'classpath') || (a:kind == 1 || a:kind == 2)
    for i in get(a:ci, 'extends', [])
      let ci = s:DoGetClassInfo(java_parser#type2Str(i))
      if type(ci) == type([])
        let ci = ci[0]
      endif
      let members = javacomplete#complete#SearchMember(ci, a:name, a:fullmatch, a:kind == 1 ? 2 : a:kind, a:returnAll, a:memberkind)
      let result[0] += members[0]
      let result[1] += members[1]
      let result[2] += members[2]
    endfor
  endif
  return result
endfunction

" generate member list							{{{2
function! s:DoGetFieldList(fields)
  let s = ''
  let useFQN = javacomplete#UseFQN()
  for field in a:fields
    if type(field.t) == type([])
      let fieldType = field.t[0]
      let args = ''
      for arg in field.t[1]
        let args .= arg. ','
      endfor
      if len(args) > 0
        let fieldType .= '<'. args[0:-2]. '>'
      endif
    else
      let fieldType = field.t
    endif
    if !useFQN
      let fieldType = javacomplete#util#CleanFQN(fieldType)
    endif
    let s .= "{'kind':'" . (s:IsStatic(field.m) ? "F" : "f") . "','word':'" . field.n . "','menu':'" . fieldType . "','dup':1},"
  endfor
  return s
endfunction

function! s:DoGetMethodList(methods, ...)
  let paren = a:0 == 0 || !a:1 ? '(' : (a:1 == 2) ? ' = ' : ''
  let abbrEnd = ''
  if b:context_type != s:CONTEXT_METHOD_REFERENCE 
    if a:0 == 0 || !a:1 
      let abbrEnd = '()'
    endif
  endif

  let useFQN = javacomplete#UseFQN()
  let s = ''
  for method in a:methods
    if !useFQN
      let method.d = javacomplete#util#CleanFQN(method.d)
    endif
    let s .= "{'kind':'" . (s:IsStatic(method.m) ? "M" : "m") . "','word':'" . method.n . (b:context_type == s:CONTEXT_METHOD_REFERENCE ? "" : paren) . "','abbr':'" . method.n . abbrEnd. "','menu':'" . method.d . "','dup':'1'},"
  endfor

  return s
endfunction

" kind:
"	0 - for instance, 1 - this, 2 - super, 3 - class, 4 - array, 5 - method result, 6 - primitive type
"	11 - for type, with `class` and static member and nested types.
"	12 - for import static, no lparen for static methods
"	13 - for import or extends or implements, only nested types
"	20 - for package
function! s:DoGetMemberList(ci, kind)
  let kind = a:kind
  if type(a:ci) != type({}) || a:ci == {}
    return []
  endif

  let s = ''
  if b:context_type == s:CONTEXT_METHOD_REFERENCE
    let kind = 0
    if a:kind != 0
      let s = "{'kind': 'M', 'word': 'new', 'menu': 'new'},"
    endif
  endif

  let s .= kind == 11 ? "{'kind': 'C', 'word': 'class', 'menu': 'Class'}," : ''

  let members = javacomplete#complete#SearchMember(a:ci, '', 1, kind, 1, 0, kind == 2)

  " add accessible member types
  if kind / 10 != 0
    " Use dup here for member type can share name with field.
    for class in members[0]
      "for class in get(a:ci, 'classes', [])
      let v = get(b:j_cache, class, {})
      if v == {} || v.flags[-1:]
        let s .= "{'kind': 'C', 'word': '" . substitute(class, a:ci.name . '\.', '\1', '') . "','dup':1},"
      endif
    endfor
  endif

  if kind != 13
    let fieldlist = []
    let sfieldlist = []
    for field in members[2]
      "for field in get(a:ci, 'fields', [])
      if s:IsStatic(field['m'])
        call add(sfieldlist, field)
      elseif kind / 10 == 0
        call add(fieldlist, field)
      endif
    endfor

    let methodlist = []
    let smethodlist = []
    for method in members[1]
      if s:IsStatic(method['m'])
        call add(smethodlist, method)
      elseif kind / 10 == 0
        call add(methodlist, method)
      endif
    endfor

    if kind / 10 == 0
      let s .= s:DoGetFieldList(fieldlist)
      let s .= s:DoGetMethodList(methodlist)
    endif
    if b:context_type != s:CONTEXT_METHOD_REFERENCE
      let s .= s:DoGetFieldList(sfieldlist)
    endif

    let s .= s:DoGetMethodList(smethodlist, kind == 12)

    let s = substitute(s, '\<' . a:ci.name . '\.', '', 'g')
    let s = substitute(s, '\<\(public\|static\|synchronized\|transient\|volatile\|final\|strictfp\|serializable\|native\)\s\+', '', 'g')
  endif
  return eval('[' . s . ']')
endfunction

" interface							{{{2

function! s:GetMemberList(class)
  if s:IsBuiltinType(a:class)
    return []
  endif

  return s:DoGetMemberList(s:DoGetClassInfo(a:class), 0)
endfunction

function! s:GetConstructorList(class)
  let ci = s:DoGetClassInfo(a:class)
  if empty(ci)
    return []
  endif

  let s = ''
  for ctor in get(ci, 'ctors', [])
    let s .= "{'kind': '+', 'word':'". a:class . "(','abbr':'" . ctor.d . "','dup':1},"
  endfor

  let s = substitute(s, '\<java\.lang\.', '', 'g')
  let s = substitute(s, '\<public\s\+', '', 'g')
  return eval('[' . s . ']')
endfunction

" Name can be a (simple or qualified) package name, or a (simple or qualified)
" type name.
function! s:GetMembers(fqn, ...)
  let list = []
  let isClass = 0

  let v = s:DoGetInfoByReflection(a:fqn, '-p')
  if type(v) == type([])
    let list = v
  elseif type(v) == type({}) && v != {}
    if get(v, 'tag', '') == 'PACKAGE'
      if b:context_type == s:CONTEXT_IMPORT_STATIC || b:context_type == s:CONTEXT_IMPORT
        call add(list, {'kind': 'P', 'word': '*;'})
      endif
      if b:context_type != s:CONTEXT_PACKAGE_DECL
        for c in sort(get(v, 'classes', []))
          call add(list, {'kind': 'C', 'word': c})
        endfor
      endif
      for p in sort(get(v, 'subpackages', []))
        call add(list, {'kind': 'P', 'word': p})
      endfor
    else
      let isClass = 1
      let list += s:DoGetMemberList(v, b:context_type == s:CONTEXT_IMPORT || b:context_type == s:CONTEXT_NEED_TYPE ? 13 : b:context_type == s:CONTEXT_IMPORT_STATIC ? 12 : 11)
    endif
  endif

  if !isClass
    let list += s:DoGetPackageInfoInDirs(a:fqn, b:context_type == s:CONTEXT_PACKAGE_DECL)
  endif

  return list
endfunction

" a:1		incomplete mode
" return packages in classes directories or source pathes
function! s:DoGetPackageInfoInDirs(package, onlyPackages, ...)
  let list = []

  let pathes = s:GetSourceDirs(expand('%:p'))
  for path in s:GetClassDirs()
    if index(pathes, path) <= 0
      call add(pathes, path)
    endif
  endfor

  let globpattern  = a:0 > 0 ? a:package . '*' : substitute(a:package, '\.', '/', 'g') . '/*'
  let matchpattern = a:0 > 0 ? a:package : a:package . '[\\/]'
  for f in split(globpath(join(pathes, ','), globpattern), "\n")
    for path in pathes
      let idx = matchend(f, escape(path, ' \') . '[\\/]\?\C' . matchpattern)
      if idx != -1
        let name = (a:0 > 0 ? a:package : '') . strpart(f, idx)
        if f[-5:] == '.java'
          if !a:onlyPackages
            call add(list, {'kind': 'C', 'word': name[:-6]})
          endif
        elseif name =~ '^' . g:RE_IDENTIFIER . '$' && isdirectory(f) && f !~# 'CVS$'
          call add(list, {'kind': 'P', 'word': name})
        endif
      endif
    endfor
  endfor
  return list
endfunction
