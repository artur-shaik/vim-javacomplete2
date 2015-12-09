" Vim completion script for java
" Maintainer:	artur shaik <ashaihullin@gmail.com>
"
" Java server bridge initiator and caller

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
  let value = 0
JavacompletePy << EOPC
try:
  vim.command("let value = '%d'" % bridgeState.poll())
except:
  # we'll get here if the bridgeState variable was not defined or if it's None.
  # In this case we stop the processing and return the default 0 value.
  pass
EOPC
  return value
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
      let sources = '-sources "'. s:ExpandAllPaths(g:JavaComplete_SourcesPath). '"'
    endif

    let args = ' kg.ash.javavi.Javavi '. sources
    if exists('g:JavaComplete_ServerAutoShutdownTime')
      let args .= ' -t '. g:JavaComplete_ServerAutoShutdownTime
    endif
    if exists('g:JavaComplete_JavaviDebug') && g:JavaComplete_JavaviDebug
      let args .= ' -d'
    endif
    call javacomplete#logger#Log("Server classpath: -cp ". classpath)
    call javacomplete#logger#Log("Server arguments:". args)

    let file = g:JavaComplete_Home. g:FILE_SEP. "autoload". g:FILE_SEP. "javavibridge.py"
    execute "JavacompletePyfile ". file

    JavacompletePy import vim
    JavacompletePy bridgeState = JavaviBridge()
    JavacompletePy bridgeState.setupServer(vim.eval('javacomplete#server#GetJVMLauncher()'), vim.eval('args'), vim.eval('classpath'))

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

function! javacomplete#server#GetCompiler()
  return exists('g:JavaComplete_JavaCompiler') && g:JavaComplete_JavaCompiler !~  '^\s*$' ? g:JavaComplete_JavaCompiler : 'javac'
endfunction

function! javacomplete#server#SetCompiler(compiler)
  let g:JavaComplete_JavaCompiler = a:compiler
endfunction

function! javacomplete#server#GetJVMLauncher()
  return exists('g:JavaComplete_JvmLauncher') && g:JavaComplete_JvmLauncher !~  '^\s*$' ? g:JavaComplete_JvmLauncher : 'java'
endfunction

function! javacomplete#server#SetJVMLauncher(interpreter)
  if javacomplete#server#GetJVMLauncher() != a:interpreter
    let g:JavaComplete_Cache = {}
  endif
  let g:JavaComplete_JvmLauncher = a:interpreter
endfunction

function! javacomplete#server#Compile()
  call javacomplete#server#Terminate()

  let javaviDir = g:JavaComplete_Home. g:FILE_SEP. join(['libs', 'javavi'], g:FILE_SEP). g:FILE_SEP
  if isdirectory(javaviDir. join(['target', 'classes'], g:FILE_SEP)) 
    if g:IS_WINDOWS
      silent exe '!rmdir \s "'. javaviDir.join(['target', 'classes'], g:FILE_SEP)
    else
      silent exe '!rm -r '. javaviDir.join(['target', 'classes'], g:FILE_SEP)
    endif
  endif

  if executable('mvn')
    exe '!'. 'mvn -f "'. javaviDir . g:FILE_SEP . 'pom.xml" compile'
  else
    call mkdir(javaviDir. join(['target', 'classes'], g:FILE_SEP), "p")
    exe '!'. javacomplete#server#GetCompiler(). ' -d '. javaviDir. 'target'. g:FILE_SEP. 'classes -classpath '. javaviDir. 'target'. g:FILE_SEP. 'classes'. g:PATH_SEP. g:JavaComplete_Home. g:FILE_SEP .'libs'. g:FILE_SEP. 'javaparser.jar'. g:PATH_SEP. ' -sourcepath '. javaviDir. 'src'. g:FILE_SEP. 'main'. g:FILE_SEP. 'java -g -nowarn -target 1.8 -source 1.8 -encoding UTF-8 '. javaviDir. join(['src', 'main', 'java', 'kg', 'ash', 'javavi', 'Javavi.java'], g:FILE_SEP)
  endif
endfunction

" Check if Javavi classes exists and return classpath directory.
" If not found, build Javavi library classes with maven or javac.
fu! s:GetJavaviClassPath()
  let javaviDir = g:JavaComplete_Home. join(['', 'libs', 'javavi', ''], g:FILE_SEP)
  if !isdirectory(javaviDir. "target". g:FILE_SEP. "classes")
    call javacomplete#server#Compile()
  endif

  if !empty(javacomplete#GlobPathList(javaviDir. 'target'. g:FILE_SEP. 'classes', '**'. g:FILE_SEP. '*.class', 1))
    return javaviDir. "target". g:FILE_SEP. "classes"
  else
    echo "No Javavi library classes found, it means that we couldn't compile it. Do you have JDK8+ installed?"
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
    let result = ""
JavacompletePy << EOPC
vim.command('let result = "%s"' % bridgeState.send(vim.eval("cmd")))
EOPC
    return result
  endif

  return ""
endfunction

function! javacomplete#server#GetClassPath()
  let jars = s:GetExtraPath()
  let path = s:GetJavaviClassPath() . g:PATH_SEP. s:GetJavaParserClassPath(). g:PATH_SEP
  let path = path . join(jars, g:PATH_SEP) . g:PATH_SEP

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
      let java = javacomplete#server#GetJVMLauncher()
      let javaSettings = split(s:System(java. " -XshowSettings", "Get java settings"), '\n')
      for line in javaSettings
        if line =~ 'java\.home'
          let g:JAVA_HOME = split(line, ' = ')[1]
        endif
      endfor
    endif
    return path. g:JAVA_HOME. g:FILE_SEP. 'lib'
  endif

  return path . $CLASSPATH
endfunction

function! s:ExpandAllPaths(path)
    let result = ''
    let list = s:_uniq(sort(split(a:path, g:PATH_SEP)))
    for l in list
      let result = result. substitute(expand(l), '\\', '/', 'g') . g:PATH_SEP
    endfor
    return result
endfunction

function! s:GetJavaParserClassPath()
  let path = g:JavaComplete_JavaParserJar . g:PATH_SEP
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
    let paths = split(g:JavaComplete_LibsPath, g:PATH_SEP)
    for path in paths
      let exp = s:ExpandPathToJars(path)
      if empty(exp)
        " ex: target/classes
        call extend(jars, [path])
      else
        call extend(jars, exp)
      endif
    endfor
  endif

  return jars
endfunction

function! s:ExpandPathToJars(path, ...)
  if isdirectory(a:path)
    return javacomplete#GlobPathList(a:path, "**5/*.jar", 1)
    \ + javacomplete#GlobPathList(a:path, "**5/*.zip", 1)
  elseif index(['zip', 'jar'], fnamemodify(a:path, ':e')) != -1
    return [a:path]
  endif
  return []
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
        let b:classpath_jsp .= g:PATH_SEP . path . '/WEB-INF/classes'
      endif
      if isdirectory(path . '/WEB-INF/lib')
        let b:classpath_jsp .= g:PATH_SEP . path . '/WEB-INF/lib/*.jar'
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
  return exists('s:classpath') ? join(s:classpath, g:PATH_SEP) : ''
endfu

" vim:set fdm=marker sw=2 nowrap:
