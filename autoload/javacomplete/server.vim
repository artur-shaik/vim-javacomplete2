" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" Last Change:	2015-09-14
"
" Java server bridge initiator and caller

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

function! s:System(cmd, caller)
  let t = reltime()
  let res = system(a:cmd)
  call javacomplete#logger#Log(reltimestr(reltime(t)) . 's to exec "' . a:cmd . '" by ' . a:caller)
  return res
endfunction

if exists('*uniq')
  function! s:_uniq(list) abort
    return uniq(a:list)
  endfunction
else
  function! s:_uniq(list) abort
    let i = len(a:list) - 1
    while 0 < i
      if a:list[i] ==# a:list[i - 1]
        call remove(a:list, i)
        let i -= 2
      else
        let i -= 1
      endif
    endwhile
    return a:list
  endfunction
endif

function! s:Poll()
  let a:value = 0
JavacompletePy << EOPC
try:
  vim.command("let a:value = '%d'" % bridgeState.poll())
except:
  # we'll get here if the bridgeState variable was not defined or if it's None.
  # In this case we stop the processing and return the default 0 value.
  pass
EOPC
  return a:value
endfunction

function! javacomplete#server#Terminate()
  if s:Poll() != 0
    JavacompletePy bridgeState.terminateServer()
  endif
endfunction

function! javacomplete#server#Start()
  if s:Poll() == 0
    call javacomplete#logger#Log("Start server")

    let classpath = javacomplete#server#GetClassPath()
    let sources = ''
    if exists('g:JavaComplete_SourcesPath')
      let sources = '-sources "'. s:ExpandAllPaths(g:JavaComplete_SourcesPath). '" '
    endif

    let args = ' kg.ash.javavi.Javavi '. sources
    if exists('g:JavaComplete_ServerAutoShutdownTime')
      let args .= ' -t '. g:JavaComplete_ServerAutoShutdownTime
    endif
    let args .= ' -D '

    let file = g:JavaComplete_Home. "/autoload/javavibridge.py"
    execute "JavacompletePyfile ". file

    JavacompletePy import vim
    JavacompletePy bridgeState = JavaviBridge()
    JavacompletePy bridgeState.setupServer(vim.eval('s:GetJVMLauncher()'), vim.eval('args'), vim.eval('classpath'))

  endif
endfunction

function! javacomplete#server#ShowPort()
  if s:Poll()
    JavacompletePy vim.command('echo "Javavi port: %d"' % bridgeState.port())
  endif
endfunction

function! javacomplete#server#ShowPID()
  if s:Poll()
    JavacompletePy vim.command('echo "Javavi pid: %d"' % bridgeState.pid())
  endif
endfunction

fu! javacomplete#server#GetCompiler()
  return exists('s:compiler') && s:compiler !~  '^\s*$' ? s:compiler : 'javac'
endfu

fu! javacomplete#server#SetCompiler(compiler)
  let s:compiler = a:compiler
endfu

function! s:GetJVMLauncher()
  return exists('s:interpreter') && s:interpreter !~  '^\s*$' ? s:interpreter : 'java'
endfu

function! s:SetJVMLauncher(interpreter)
  if s:GetJVMLauncher() != a:interpreter
    let b:j_cache = {}
  endif
  let s:interpreter = a:interpreter
endfu

function! javacomplete#server#Compile()
  call javacomplete#server#Terminate()

  let javaviDir = g:JavaComplete_Home. "/libs/javavi/"
  if isdirectory(javaviDir. "target/classes") 
    if b:IS_WINDOWS
      silent exe '!rmdir \s "'. javaviDir. "target/classes"
    else
      silent exe '!rm -r '. javaviDir. "target/classes"
    endif
  endif

  if executable('mvn')
    exe '!'. 'mvn -f "'. javaviDir. '/pom.xml" compile'
  else
    call mkdir(javaviDir. "target/classes", "p")
    exe '!'. javacomplete#server#GetCompiler(). ' -d '. javaviDir. 'target/classes -classpath '. javaviDir. 'target/classes:'. g:JavaComplete_Home. '/libs/javaparser.jar'. b:PATH_SEP .' -sourcepath '. javaviDir. 'src/main/java: -g -nowarn -target 1.8 -source 1.8 -encoding UTF-8 '. javaviDir. 'src/main/java/kg/ash/javavi/Javavi.java'
  endif
endfunction

" Check if Javavi classes exists and return classpath directory.
" If not found, build Javavi library classes with maven or javac.
fu! s:GetJavaviClassPath()
  let javaviDir = g:JavaComplete_Home. "/libs/javavi/"
  if !isdirectory(javaviDir. "target/classes")
    call javacomplete#server#Compile()
  endif

  if !empty(javacomplete#GlobPathList(javaviDir. 'target/classes', '**/*.class', 1))
    return javaviDir. "target/classes"
  else
    echo "No Javavi library classes found, it means that we couldn't compile it. Do you have JDK7+ installed?"
  endif
endfu

" Function for server communication						{{{2
function! javacomplete#server#Communicate(option, args, log)
  if !s:Poll()
    call javacomplete#server#Start()
  endif

  if s:Poll()
    let args = substitute(a:args, '"', '\\"', 'g')
    let cmd = a:option. ' "'. args. '"'
    call javacomplete#logger#Log("Communicate: ". cmd. " [". a:log. "]")
    let a:result = ""
JavacompletePy << EOPC
vim.command('let a:result = "%s"' % bridgeState.send(vim.eval("cmd")))
EOPC
    return a:result
  endif

  return ""
endfunction

function! javacomplete#server#GetClassPath()
  let jars = s:GetExtraPath()
  let path = s:GetJavaviClassPath() . b:PATH_SEP. s:GetJavaParserClassPath(). b:PATH_SEP
  let path = path . join(jars, b:PATH_SEP) . b:PATH_SEP

  if &ft == 'jsp'
    let path .= s:GetClassPathOfJsp()
  endif

  if exists('b:classpath') && b:classpath !~ '^\s*$'
    call javacomplete#logger#Log(b:classpath)
    return path . b:classpath
  endif

  if exists('s:classpath')
    call javacomplete#logger#Log(s:classpath)
    return path . javacomplete#GetClassPath()
  endif

  if exists('g:java_classpath') && g:java_classpath !~ '^\s*$'
    call javacomplete#logger#Log(g:java_classpath)
    return path . g:java_classpath
  endif

  if empty($CLASSPATH)
    if g:JAVA_HOME == ''
      let java = s:GetJVMLauncher()
      let javaSettings = split(s:System(java. " -XshowSettings", "Get java settings"), '\n')
      for line in javaSettings
        if line =~ 'java\.home'
          let g:JAVA_HOME = split(line, ' = ')[1]
        endif
      endfor
    endif
    return path. g:JAVA_HOME. '/lib'
  endif

  return path . $CLASSPATH
endfunction

function! s:ExpandAllPaths(path)
    let result = ''
    let list = s:_uniq(sort(split(a:path, b:PATH_SEP)))
    for l in list
      let result = result. substitute(expand(l), '\\', '/', 'g') . b:PATH_SEP
    endfor
    return result
endfunction

function! s:GetJavaParserClassPath()
  let path = g:JavaComplete_JavaParserJar . b:PATH_SEP
  if exists('b:classpath') && b:classpath !~ '^\s*$'
    return path . b:classpath
  endif

  if exists('s:classpath')
    return path . s:GetClassPath()
  endif

  if exists('g:java_classpath') && g:java_classpath !~ '^\s*$'
    return path . g:java_classpath
  endif

  return path
endfunction

function! s:GetExtraPath()
  let jars = []
  let extrapath = ''
  if exists('g:JavaComplete_LibsPath')
    let paths = split(g:JavaComplete_LibsPath, b:PATH_SEP)
    for path in paths
      call extend(jars, s:ExpandPathToJars(path))
    endfor
  endif

  return jars
endfunction

function! s:ExpandPathToJars(path)
  if s:IsJarOrZip(a:path)
    return [a:path]
  endif

  let jars = []
  let files = javacomplete#GlobPathList(a:path, "*", 1)
  for file in files
    if s:IsJarOrZip(file)
      call add(jars, b:PATH_SEP . file)
    elseif isdirectory(file)
      call extend(jars, s:ExpandPathToJars(file))
    endif
  endfor

  return jars
endfunction

function! s:IsJarOrZip(path)
    let filetype = strpart(a:path, len(a:path) - 4)
    if filetype ==? ".jar" || filetype ==? ".zip"
      return 1
    endif

    return 0
endfunction

fu! s:GetClassPathOfJsp()
  if exists('b:classpath_jsp')
    return b:classpath_jsp
  endif

  let b:classpath_jsp = ''
  let path = expand('%:p:h')
  while 1
    if isdirectory(path . '/WEB-INF' )
      if isdirectory(path . '/WEB-INF/classes')
        let b:classpath_jsp .= b:PATH_SEP . path . '/WEB-INF/classes'
      endif
      if isdirectory(path . '/WEB-INF/lib')
        let b:classpath_jsp .= b:PATH_SEP . path . '/WEB-INF/lib/*.jar'
        endif
      endif
      return b:classpath_jsp
    endif

    let prev = path
    let path = fnamemodify(path, ":p:h:h")
    if path == prev
      break
    endif
  endwhile
  return ''
endfu

function! s:GetClassPath()
  return exists('s:classpath') ? join(s:classpath, b:PATH_SEP) : ''
endfu

let b:PATH_SEP	= ':'
let b:FILE_SEP	= '/'
let b:IS_WINDOWS = has("win32") || has("win64") || has("win16") || has("dos32") || has("dos16")
if b:IS_WINDOWS
  let b:PATH_SEP	= ';'
  let b:FILE_SEP	= '\'
endif
