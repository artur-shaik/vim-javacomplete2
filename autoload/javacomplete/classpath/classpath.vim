function! javacomplete#classpath#classpath#BuildClassPath()
  if !get(g:, 'JavaComplete_MavenRepositoryDisabled', 0)
    if !exists('g:JavaComplete_PomPath')
      let g:JavaComplete_PomPath = javacomplete#util#FindFile('pom.xml')
      if g:JavaComplete_PomPath != ""
        let g:JavaComplete_PomPath = fnamemodify(g:JavaComplete_PomPath, ':p')
      endif
    endif
  endif

  if !get(g:, 'JavaComplete_GradleRepositoryDisabled', 0)
    if !exists('g:JavaComplete_GradlePath')
      if filereadable(getcwd(). g:FILE_SEP. "build.gradle")
        let g:JavaComplete_GradlePath = getcwd(). g:FILE_SEP. "build.gradle"
      else
        let g:JavaComplete_GradlePath = javacomplete#util#FindFile('build.gradle')
      endif
      if g:JavaComplete_GradlePath != ""
        let g:JavaComplete_GradlePath = fnamemodify(g:JavaComplete_GradlePath, ':p')
      endif
    endif
  endif

  let g:JavaComplete_LibsPath .= s:FindClassPath()
endfunction

function! s:ReadClassPathFile(classpathFile)
  let cp = ''
  let file = g:JavaComplete_Home. join(['', 'autoload', 'classpath.py'], g:FILE_SEP)
  execute "JavacompletePyfile" file
  JavacompletePy import vim
  JavacompletePy vim.command("let cp = '%s'" % os.pathsep.join(ReadClasspathFile(vim.eval('a:classpathFile'))).replace('\\', '/'))
  return cp
endfunction

fu! s:use_eclipse()
  if has('python') || has('python3')
    let classpathFile = fnamemodify(findfile('.classpath', escape(expand('.'), '*[]?{}, ') . ';'), ':p')
    if !empty(classpathFile) && filereadable(classpathFile)
      return s:ReadClassPathFile(classpathFile)
    endif
  endif
endf

fu! s:use_maven()
  if javacomplete#classpath#maven#IfMaven()
    return javacomplete#classpath#maven#Generate()
  endif
endf

fu! s:use_gradle()
  if javacomplete#classpath#gradle#IfGradle()
    return javacomplete#classpath#gradle#Generate()
  endif
endf

function! s:FindClassPath() abort
  let cp = '.'

  for ide in g:JavaComplete_ClassPathLoaddingOrder
    try
      exec "call s:use_".ide."()"
    catch
    endtry
  endfor

  return cp
endfunction

" vim:set fdm=marker sw=2 nowrap:
