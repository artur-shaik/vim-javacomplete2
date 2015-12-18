" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>

" It doesn't make sense to do any work if vim doesn't support any Python since
" we relly on it to properly work.
if has("python")
  command! -nargs=1 JavacompletePy py <args>
  command! -nargs=1 JavacompletePyfile pyfile <args>
elseif has("python3")
  command! -nargs=1 JavacompletePy py3 <args>
  command! -nargs=1 JavacompletePyfile py3file <args>
else
  echoerr "Javacomplete needs Python support to run!"
  finish
endif

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


let g:J_PRIMITIVE_TYPES	= ['boolean', 'byte', 'char', 'int', 'short', 'long', 'float', 'double']
let g:J_KEYWORDS_MODS	= ['public', 'private', 'protected', 'static', 'final', 'synchronized', 'volatile', 'transient', 'native', 'strictfp', 'abstract']
let g:J_KEYWORDS_TYPE	= ['class', 'interface', 'enum']
let g:J_KEYWORDS		= g:J_PRIMITIVE_TYPES + g:J_KEYWORDS_MODS + g:J_KEYWORDS_TYPE + ['super', 'this', 'void'] + ['assert', 'break', 'case', 'catch', 'const', 'continue', 'default', 'do', 'else', 'extends', 'finally', 'for', 'goto', 'if', 'implements', 'import', 'instanceof', 'interface', 'new', 'package', 'return', 'switch', 'throw', 'throws', 'try', 'while', 'true', 'false', 'null']

let g:IS_WINDOWS = has("win32") || has("win64") || has("win16") || has("dos32") || has("dos16")
if g:IS_WINDOWS
  let g:PATH_SEP	= ';'
  let g:FILE_SEP	= '\'
else
  let g:PATH_SEP	= ':'
  let g:FILE_SEP	= '/'
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
let g:RE_TYPE_DECL	= '\<\C\(\%(' .g:RE_TYPE_MODS. '\s\+\)*\)' .g:RE_TYPE_DECL_HEAD. '\(' .g:RE_IDENTIFIER. '\)[{< \t\n\r]'

let g:RE_ARRAY_TYPE	= '^\s*\(' .g:RE_QUALID . '\)\(' . g:RE_BRACKETS . '\+\)\s*$'
let g:RE_SELECT_OR_ACCESS	= '^\s*\(' . g:RE_IDENTIFIER . '\)\s*\(\[.*\]\)\=\s*$'
let g:RE_ARRAY_ACCESS	= '^\s*\(' . g:RE_IDENTIFIER . '\)\s*\(\[.*\]\)\+\s*$'
let g:RE_CASTING	= '^\s*(\(' .g:RE_QUALID. '\))\s*\(' . g:RE_IDENTIFIER . '\)\>'

let g:RE_KEYWORDS	= '\<\%(' . join(g:J_KEYWORDS, '\|') . '\)\>'

let g:JAVA_HOME = $JAVA_HOME

let g:JavaComplete_Cache = {}	" FQN -> member list, e.g. {'java.lang.StringBuffer': classinfo, 'java.util': packageinfo, '/dir/TopLevelClass.java': compilationUnit}
let g:JavaComplete_Files = {}	" srouce file path -> properties, e.g. {filekey: {'unit': compilationUnit, 'changedtick': tick, }}

let g:Javacomplete_pom_properties={}   "maven project properties
let g:Javacomplete_pom_tags = ['build', 'properties']

fu! SScope()
  return s:
endfu

function! javacomplete#ClearCache()
  let g:JavaComplete_Cache = {}
  let g:JavaComplete_Files = {}
endfunction

function! javacomplete#Complete(findstart, base)
  return javacomplete#complete#complete#Complete(a:findstart, a:base)
endfunction

function! s:GetBase(extra)
  let base = expand("~". g:FILE_SEP. ".javacomplete2". g:FILE_SEP. a:extra)
  if !isdirectory(base)
    call mkdir(base, "p")
  endif

  return base
endfunction

function! s:ReadClassPathFile(classpath_file)
  let cp = ''
  let file = g:JavaComplete_Home. join(['', 'autoload', 'classpath.py'], g:FILE_SEP)
  execute "JavacompletePyfile" file
  JavacompletePy import vim
  JavacompletePy vim.command("let cp = '%s'" % os.pathsep.join(ReadClasspathFile(vim.eval('a:classpath_file'))).replace('\\', '/'))
  return cp
endfunction

function! s:FindClassPath() abort
  let cp = '.'

  if has('python') || has('python3')
    let classpath_file = fnamemodify(findfile('.classpath', escape(expand('.'), '*[]?{}, ') . ';'), ':p')
    if !empty(classpath_file) && filereadable(classpath_file)
      return s:ReadClassPathFile(classpath_file)
    endif
  endif

  let base = s:GetBase("classpath". g:FILE_SEP)

  if executable('mvn') && g:JavaComplete_PomPath != ""
    let key = substitute(g:JavaComplete_PomPath, '[\\/:;.]', '_', 'g')
    let path = base . key

    if filereadable(path)
      if getftime(path) >= getftime(g:JavaComplete_PomPath)
        return join(readfile(path), '')
      endif
    endif
    return s:GenerateMavenClassPath(path, g:JavaComplete_PomPath)
  endif

  if executable('gradle') || executable('./gradlew') || executable('.\gradlew.bat')
    if g:JavaComplete_GradlePath != ""
      let key = substitute(g:JavaComplete_GradlePath, '[\\/:;.]', '_', 'g')
      let path = base . key

      if filereadable(path)
        if getftime(path) >= getftime(g:JavaComplete_GradlePath)
          return join(readfile(path), '')
        endif
      endif
      return s:GenerateGradleClassPath(path, g:JavaComplete_GradlePath)
    endif
  endif

  return cp
endfunction

function! s:GenerateMavenClassPath(path, pom) abort
  let mvn_properties = s:GetMavenProperties(a:pom)
  let cp = get(mvn_properties, 'project.dependencybuildclasspath', '.')
  let cp .= g:PATH_SEP . get(mvn_properties, 'project.build.outputDirectory', join([fnamemodify(a:pom, ':h'), 'target', 'classes'], g:FILE_SEP))
  let cp .= g:PATH_SEP . get(mvn_properties, 'project.build.testOutputDirectory', join([fnamemodify(a:pom, ':h'), 'target', 'test-classes'], g:FILE_SEP))
  if cp != '.'
    call writefile([cp], a:path)
  endif
  return cp
endfunction

function! s:GetMavenProperties(pom)
  let mvn_properties = {}
  if !has_key(g:Javacomplete_pom_properties, a:pom)
    let mvn_cmd = 'mvn --file '. a:pom. ' help:effective-pom dependency:build-classpath -DincludeScope=test'
    let mvn_is_managed_tag = 1
    let mvn_settings_output = split(system(mvn_cmd), "\n")
    let current_path = 'project'
    for i in range(len(mvn_settings_output))
      if mvn_settings_output[i] =~ 'Dependencies classpath:'
        let mvn_properties['project.dependencybuildclasspath'] = mvn_settings_output[i + 1]
      endif
      let matches = matchlist(mvn_settings_output[i], '\m^\s*<\([a-zA-Z0-9\-\.]\+\)>\s*$')
      if mvn_is_managed_tag && !empty(matches)
        let mvn_is_managed_tag = index(g:Javacomplete_pom_tags, matches[1]) >= 0
        let current_path .= '.' . matches[1]
      else
        let matches = matchlist(mvn_settings_output[i], '\m^\s*</\([a-zA-Z0-9\-\.]\+\)>\s*$')
        if !empty(matches)
          let mvn_is_managed_tag = index(g:Javacomplete_pom_tags, matches[1]) < 0
          let current_path  = substitute(current_path, '\m\.' . matches[1] . '$', '', '')
        else
          let matches = matchlist(mvn_settings_output[i], '\m^\s*<\([a-zA-Z0-9\-\.]\+\)>\(.\+\)</[a-zA-Z0-9\-\.]\+>\s*$')
          if mvn_is_managed_tag && !empty(matches)
            let mvn_properties[current_path . '.' . matches[1]] = matches[2]
          endif
        endif
      endif
    endfor
    let g:Javacomplete_pom_properties[a:pom] = mvn_properties
  endif
  return g:Javacomplete_pom_properties[a:pom]
endfunction

function! s:GenerateGradleClassPath(path, gradle) abort
  try
    let f = tempname()
    if has("win32") || has("win16")
      let gradle = '.\gradlew.bat'
    else
      let gradle = './gradlew'
    endif
    if !executable(gradle)
      let gradle = 'gradle'
    endif
    call writefile(["allprojects{apply from: '". g:JavaComplete_Home. g:FILE_SEP. "classpath.gradle'}"], f)
    let ret = system(gradle. ' -q -I '. shellescape(f). ' classpath')
    if v:shell_error == 0
      let cp = filter(split(ret, "\n"), 'v:val =~ "^CLASSPATH:"')[0][10:]
      call writefile([cp], a:path)
      return cp
    endif
  catch
  finally
    call delete(f)
  endtry
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

" key of g:JavaComplete_Files for current buffer. It may be the full path of current file or the bufnr of unnamed buffer, and is updated when BufEnter, BufLeave.
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

function! s:HandleTextChangedI()
  if get(g:, 'JC_ClassnameCompletedFlag', 0)
    let g:JC_ClassnameCompletedFlag = 0
    call javacomplete#imports#Add()
  endif

  if get(g:, 'JC_DeclarationCompletedFlag', 0)
    let line = getline('.')
    if line[col('.') - 2] != ' ' 
      return
    endif

    let g:JC_DeclarationCompletedFlag = 0

    if line !~ '.*@Override.*'
      let line = getline(line('.') - 1)
    endif

    if line =~ '.*@Override\s\+\(\S\+\|\)\(\s\+\|\)$'
      return
    endif

    if !empty(javacomplete#util#Trim(getline('.')))
      call feedkeys("\b\r", "n")
    endif
    if get(g:, 'JavaComplete_ClosingBrace', 1)
      call feedkeys("}\eO", "n")
    endif
  endif
endfunction

function! s:HandleInsertLeave()
  if get(g:, 'JC_DeclarationCompletedFlag', 0)
    let g:JC_DeclarationCompletedFlag = 0
  endif
  if get(g:, 'JC_ClassnameCompletedFlag', 0)
    let g:JC_ClassnameCompletedFlag = 0
  endif
endfunction

function! javacomplete#UseFQN() 
  return get(g:, 'JavaComplete_UseFQN', 0)
endfunction

function! s:RemoveCurrentFromCache()
  let package = javacomplete#complete#complete#GetPackageName()
  let classname = split(expand('%:t'), '\.')[0]
  let fqn = package. '.'. classname
  if has_key(g:JavaComplete_Cache, fqn)
    call remove(g:JavaComplete_Cache, fqn)
  endif
  call javacomplete#server#Communicate('-clear-from-cache', fqn, 's:RemoveCurrentFromCache')
endfunction

augroup javacomplete
  autocmd!
  autocmd BufEnter *.java,*.jsp call s:SetCurrentFileKey()
  autocmd BufWrite *.java call s:RemoveCurrentFromCache()
  autocmd VimLeave * call javacomplete#server#Terminate()

  if has("patch-7.3.867")
    autocmd TextChangedI *.java,*.jsp call s:HandleTextChangedI()
  endif
  autocmd InsertLeave *.java,*.jsp call s:HandleInsertLeave()
augroup END

let g:JavaComplete_Home = fnamemodify(expand('<sfile>'), ':p:h:h:gs?\\?'. g:FILE_SEP. '?')
let g:JavaComplete_JavaParserJar = fnamemodify(g:JavaComplete_Home. join(['', 'libs', 'javaparser.jar'], g:FILE_SEP), "p")

call javacomplete#logger#Log("JavaComplete_Home: ". g:JavaComplete_Home)

let g:JavaComplete_SourcesPath = get(g:, 'JavaComplete_SourcesPath', '')
let s:sources = s:GlobPathList(getcwd(), 'src', 0)
for i in ['*/', '*/*/', '*/*/*/']
  call extend(s:sources, s:GlobPathList(getcwd(), i. g:FILE_SEP. 'src', 0))
endfor
for src in s:sources
  if match(src, '.*build.*') < 0
    let g:JavaComplete_SourcesPath = g:JavaComplete_SourcesPath. g:PATH_SEP.src
  endif
endfor
unlet s:sources

if filereadable(getcwd(). g:FILE_SEP. "build.gradle")
  let rjava = s:GlobPathList(getcwd(), join(['**', 'build', 'generated', 'source', '**', 'debug'], g:FILE_SEP), 0)
  for r in rjava
    let g:JavaComplete_SourcesPath = g:JavaComplete_SourcesPath. g:PATH_SEP.r
  endfor
endif

call javacomplete#logger#Log("Default sources: ". g:JavaComplete_SourcesPath)

if !exists('g:JavaComplete_MavenRepositoryDisable') || !g:JavaComplete_MavenRepositoryDisable
  if exists('g:JavaComplete_LibsPath')
    let g:JavaComplete_LibsPath .= g:PATH_SEP
  else
    let g:JavaComplete_LibsPath = ""
  endif

  if !exists('g:JavaComplete_PomPath')
    let g:JavaComplete_PomPath = findfile('pom.xml', escape(expand('.'), '*[]?{}, ') . ';')
    if g:JavaComplete_PomPath != ""
      let g:JavaComplete_PomPath = fnamemodify(g:JavaComplete_PomPath, ':p')
    endif
  endif

  if !exists('g:JavaComplete_GradlePath')
    if filereadable(getcwd(). g:FILE_SEP. "build.gradle")
      let g:JavaComplete_GradlePath = getcwd(). g:FILE_SEP. "build.gradle"
    else
      let g:JavaComplete_GradlePath = findfile('build.gradle', escape(expand('.'), '*[]?{}, '). ';')
    endif
    if g:JavaComplete_GradlePath != ""
      let g:JavaComplete_GradlePath = fnamemodify(g:JavaComplete_GradlePath, ':p')
    endif
  endif

  let g:JavaComplete_LibsPath .= s:FindClassPath()
endif

function! javacomplete#Start()
  call javacomplete#server#Start()
endfunction

" vim:set fdm=marker sw=2 nowrap:
