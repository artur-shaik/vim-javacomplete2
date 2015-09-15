" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" Last Change:	2015-09-14

let g:J_ARRAY_TYPE_MEMBERS = [
      \	{'kind': 'm',		'word': 'clone(',	'abbr': 'clone()',	'menu': 'Object clone()', },
      \	{'kind': 'm',		'word': 'equals(',	'abbr': 'equals()',	'menu': 'boolean equals(Object)', },
      \	{'kind': 'm',		'word': 'getClass(',	'abbr': 'getClass()',	'menu': 'Class Object.getClass()', },
      \	{'kind': 'm',		'word': 'hashCode(',	'abbr': 'hashCode()',	'menu': 'int hashCode()', },
      \	{'kind': 'f',		'word': 'length',				'menu': 'int'},
      \	{'kind': 'm',		'word': 'notify(',	'abbr': 'notify()',	'menu': 'void Object.notify()', },
      \	{'kind': 'm',		'word': 'notifyAll(',	'abbr': 'notifyAll()',	'menu': 'void Object.notifyAll()', },
      \	{'kind': 'm',		'word': 'toString(',	'abbr': 'toString()',	'menu': 'String toString()', },
      \	{'kind': 'm',		'word': 'wait(',	'abbr': 'wait()',	'menu': 'void Object.wait() throws InterruptedException', },
      \	{'kind': 'm', 'dup': 1, 'word': 'wait(',	'abbr': 'wait()',	'menu': 'void Object.wait(long timeout) throws InterruptedException', },
      \	{'kind': 'm', 'dup': 1, 'word': 'wait(',	'abbr': 'wait()',	'menu': 'void Object.wait(long timeout, int nanos) throws InterruptedException', }]

let g:J_ARRAY_TYPE_INFO = {'tag': 'CLASSDEF', 'name': '[', 'ctors': [], 
      \     'fields': [{'n': 'length', 'm': '1', 't': 'int'}],
      \     'methods':[
      \	{'n': 'clone',	  'm': '1',		'r': 'Object',	'p': [],		'd': 'Object clone()'},
      \	{'n': 'equals',	  'm': '1',		'r': 'boolean',	'p': ['Object'],	'd': 'boolean Object.equals(Object obj)'},
      \	{'n': 'getClass', 'm': '100010001',	'r': 'Class',	'p': [],		'd': 'Class Object.getClass()'},
      \	{'n': 'hashCode', 'm': '100000001',	'r': 'int',	'p': [],		'd': 'int Object.hashCode()'},
      \	{'n': 'notify',	  'm': '100010001',	'r': 'void',	'p': [],		'd': 'void Object.notify()'},
      \	{'n': 'notifyAll','m': '100010001',	'r': 'void',	'p': [],		'd': 'void Object.notifyAll()'},
      \	{'n': 'toString', 'm': '1', 		'r': 'String',	'p': [],		'd': 'String Object.toString()'},
      \	{'n': 'wait',	  'm': '10001',		'r': 'void',	'p': [],		'd': 'void Object.wait() throws InterruptedException'},
      \	{'n': 'wait',	  'm': '100010001',	'r': 'void',	'p': ['long'],		'd': 'void Object.wait(long timeout) throws InterruptedException'},
      \	{'n': 'wait',	  'm': '10001',		'r': 'void',	'p': ['long','int'],	'd': 'void Object.wait(long timeout, int nanos) throws InterruptedException'},
      \    ]}

let g:J_PRIMITIVE_TYPE_INFO = {'tag': 'CLASSDEF', 'name': '!', 'fields': [{'n': 'class','m': '1','t': 'Class'}]}

let g:J_JSP_BUILTIN_OBJECTS = {'session':	'javax.servlet.http.HttpSession',
      \	'request':	'javax.servlet.http.HttpServletRequest',
      \	'response':	'javax.servlet.http.HttpServletResponse',
      \	'pageContext':	'javax.servlet.jsp.PageContext', 
      \	'application':	'javax.servlet.ServletContext',
      \	'config':	'javax.servlet.ServletConfig',
      \	'out':		'javax.servlet.jsp.JspWriter',
      \	'page':		'javax.servlet.jsp.HttpJspPage', }


let b:J_PRIMITIVE_TYPES	= ['boolean', 'byte', 'char', 'int', 'short', 'long', 'float', 'double']
let b:J_KEYWORDS_MODS	= ['public', 'private', 'protected', 'static', 'final', 'synchronized', 'volatile', 'transient', 'native', 'strictfp', 'abstract']
let b:J_KEYWORDS_TYPE	= ['class', 'interface', 'enum']
let b:J_KEYWORDS		= b:J_PRIMITIVE_TYPES + b:J_KEYWORDS_MODS + b:J_KEYWORDS_TYPE + ['super', 'this', 'void'] + ['assert', 'break', 'case', 'catch', 'const', 'continue', 'default', 'do', 'else', 'extends', 'finally', 'for', 'goto', 'if', 'implements', 'import', 'instanceof', 'interface', 'new', 'package', 'return', 'switch', 'throw', 'throws', 'try', 'while', 'true', 'false', 'null']

let b:PATH_SEP	= ':'
let b:FILE_SEP	= '/'
let b:IS_WINDOWS = has("win32") || has("win64") || has("win16") || has("dos32") || has("dos16")
if b:IS_WINDOWS
  let b:PATH_SEP	= ';'
  let b:FILE_SEP	= '\'
endif

let g:RE_BRACKETS	= '\%(\s*\[\s*\]\)'
let g:RE_IDENTIFIER	= '[a-zA-Z_$][a-zA-Z0-9_$]*'
let g:RE_ANNOTATION	= '@[a-zA-Z_][a-zA-Z0-9_$]*'
let g:RE_QUALID		= g:RE_IDENTIFIER. '\%(\s*\.\s*' .g:RE_IDENTIFIER. '\)*'

let g:RE_REFERENCE_TYPE	= g:RE_QUALID . g:RE_BRACKETS . '*'
let g:RE_TYPE		= g:RE_REFERENCE_TYPE

let g:RE_TYPE_ARGUMENT	= '\%(?\s\+\%(extends\|super\)\s\+\)\=' . g:RE_TYPE
let g:RE_TYPE_ARGUMENT_EXTENDS	= '\%(?\s\+\%(extends\|super\)\s\+\)' . g:RE_TYPE
let g:RE_TYPE_ARGUMENTS	= '<' . g:RE_TYPE_ARGUMENT . '\%(\s*,\s*' . g:RE_TYPE_ARGUMENT . '\)*>'
let g:RE_TYPE_WITH_ARGUMENTS_I	= g:RE_IDENTIFIER . '\s*' . g:RE_TYPE_ARGUMENTS
let g:RE_TYPE_WITH_ARGUMENTS	= g:RE_TYPE_WITH_ARGUMENTS_I . '\%(\s*' . g:RE_TYPE_WITH_ARGUMENTS_I . '\)*'

let g:RE_TYPE_MODS	= '\%(public\|protected\|private\|abstract\|static\|final\|strictfp\)'
let g:RE_TYPE_DECL_HEAD	= '\(class\|interface\|enum\)[ \t\n\r]\+'
let g:RE_TYPE_DECL	= '\<\C\(\%(' .g:RE_TYPE_MODS. '\s\+\)*\)' .g:RE_TYPE_DECL_HEAD. '\(' .g:RE_IDENTIFIER. '\)[< \t\n\r]'

let g:RE_ARRAY_TYPE	= '^\s*\(' .g:RE_QUALID . '\)\(' . g:RE_BRACKETS . '\+\)\s*$'
let g:RE_SELECT_OR_ACCESS	= '^\s*\(' . g:RE_IDENTIFIER . '\)\s*\(\[.*\]\)\=\s*$'
let g:RE_ARRAY_ACCESS	= '^\s*\(' . g:RE_IDENTIFIER . '\)\s*\(\[.*\]\)\+\s*$'
let g:RE_CASTING	= '^\s*(\(' .g:RE_QUALID. '\))\s*\(' . g:RE_IDENTIFIER . '\)\>'

let g:RE_KEYWORDS	= '\<\%(' . join(b:J_KEYWORDS, '\|') . '\)\>'

let g:JAVA_HOME = $JAVA_HOME

let b:dotexpr = ''			" expression ends with '.'
let b:incomplete = ''			" incomplete word: 1. dotexpr.method(|) 2. new classname(|) 3. dotexpr.ab|, 4. ja|, 5. method(|
let b:errormsg = ''

let b:j_cache = {}	" FQN -> member list, e.g. {'java.lang.StringBuffer': classinfo, 'java.util': packageinfo, '/dir/TopLevelClass.java': compilationUnit}
let b:j_files = {}	" srouce file path -> properties, e.g. {filekey: {'unit': compilationUnit, 'changedtick': tick, }}

fu! SScope()
  return s:
endfu

function! javacomplete#ClearCache()
  let b:j_cache = {}
  let b:j_files = {}
endfunction

function! javacomplete#Complete(findstart, base)
  return javacomplete#complete#Complete(a:findstart, a:base)
endfunction

function! s:GetBase(extra)
  let base = expand("~/.javacomplete2/". a:extra)
  if !isdirectory(base)
    call mkdir(base, "p")
  endif

  return base
endfunction

function! s:FindClassPath() abort
  if executable('mvn')
    let base = s:GetBase("mvnclasspath/")
    let key = substitute(g:JavaComplete_PomPath, b:FILE_SEP, '_', 'g')
    let path = base . key

    if g:JavaComplete_PomPath != "" && filereadable(path)
      if getftime(path) >= getftime(g:JavaComplete_PomPath)
        return join(readfile(path), '')
      endif
    endif
    return s:GenerateClassPath(path, g:JavaComplete_PomPath)
  else
    return '.'
  endif
endfunction

function! s:GenerateClassPath(path, pom) abort
  let lines = split(system('mvn --file ' . a:pom . ' dependency:build-classpath -DincludeScope=test'), "\n")
  for i in range(len(lines))
    if lines[i] =~ 'Dependencies classpath:'
      let cp = lines[i+1]
      call writefile([cp], a:path)
      return cp
    endif
  endfor
  return '.'
endfunction

" workaround for https://github.com/artur-shaik/vim-javacomplete2/issues/20
" should be removed in future versions
function! javacomplete#GlobPathList(path, pattern, suf)
  return s:GlobPathList(a:path, a:pattern, a:suf)
endfunction

function! s:GlobPathList(path, pattern, suf)
  if has("patch-7.4.279")
    return globpath(a:path, a:pattern, a:suf, 1)
  else
    return split(globpath(a:path, a:pattern, a:suf), "\n")
  endif
endfunction

" key of b:j_files for current buffer. It may be the full path of current file or the bufnr of unnamed buffer, and is updated when BufEnter, BufLeave.
function! javacomplete#GetCurrentFileKey()
  return s:GetCurrentFileKey()
endfunction

function! s:GetCurrentFileKey()
  return has("autocmd") ? s:curfilekey : empty(expand('%')) ? bufnr('%') : expand('%:p')
endfunction

function! s:SetCurrentFileKey()
  let s:curfilekey = empty(expand('%')) ? bufnr('%') : expand('%:p')
endfunction
call s:SetCurrentFileKey()

function! s:CheckForExistCompletedClassName()
  if exists('g:ClassnameCompleted') && g:ClassnameCompleted
    call javacomplete#imports#Add()
    let g:ClassnameCompleted = 0
  endif
endfu

function! javacomplete#UseFQN() 
  if exists('g:JavaComplete_UseFQN') && g:JavaComplete_UseFQN
    return 1
  endif
  return 0
endfunction

augroup javacomplete
  autocmd!
  autocmd BufEnter *.java call s:SetCurrentFileKey()
  autocmd VimLeave * call javacomplete#server#Terminate()
  autocmd TextChangedI *.java call s:CheckForExistCompletedClassName()
augroup END

let g:JavaComplete_Home = fnamemodify(expand('<sfile>'), ':p:h:h:gs?\\?/?')
let g:JavaComplete_JavaParserJar = fnamemodify(g:JavaComplete_Home. "/libs/javaparser.jar", "p")

call javacomplete#logger#Log("JavaComplete_Home: ". g:JavaComplete_Home)

if !exists("g:JavaComplete_SourcesPath")
  let g:JavaComplete_SourcesPath = ''
  let sources = s:GlobPathList(getcwd(), '**/src', 0)
  for src in sources
    if match(src, '.*build.*') < 0
      let g:JavaComplete_SourcesPath = g:JavaComplete_SourcesPath. src. b:PATH_SEP
    endif
  endfor
  call javacomplete#logger#Log("Default sources: ". g:JavaComplete_SourcesPath)
endif

if !exists('g:JavaComplete_MavenRepositoryDisable') || !g:JavaComplete_MavenRepositoryDisable
  if exists('g:JavaComplete_LibsPath')
    let g:JavaComplete_LibsPath .= b:PATH_SEP
  else
    let g:JavaComplete_LibsPath = ""
  endif

  if !exists('g:JavaComplete_PomPath')
    let g:JavaComplete_PomPath = findfile('pom.xml', escape(expand('.'), '*[]?{}, ') . ';')
  endif

  if g:JavaComplete_PomPath != ""
    let g:JavaComplete_LibsPath .= s:FindClassPath()
  endif
endif

function! javacomplete#Start()
  call javacomplete#server#Start()
endfunction
