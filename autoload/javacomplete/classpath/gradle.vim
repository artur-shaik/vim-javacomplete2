function! javacomplete#classpath#gradle#IfGradle()
  if exists("g:JavaComplete_GradleExecutable")
    if executable(g:JavaComplete_GradleExecutable)
      return 1
    else
      return 0
    end
  endif

  if g:JavaComplete_GradlePath != "" && (executable('gradle') || executable(fnamemodify(g:JavaComplete_GradlePath, ':p:h') . (javacomplete#util#IsWindows() ? '\gradlew.bat' : '/gradlew')))
    return 1
  endif
  return 0
endfunction

function! javacomplete#classpath#gradle#BuildClasspathHandler(jobId, data, event)
  if a:event == 'exit'
    if a:data == "0"
      let cp = filter(s:gradleOutput, 'v:val =~ "^CLASSPATH:"')[0][10:]
      let g:JavaComplete_LibsPath .= ':'. cp

      call writefile([cp], s:gradlePath)

      call javacomplete#util#RemoveFile(javacomplete#util#GetBase('cache'). g:FILE_SEP. 'class_packages_'. g:JavaComplete_ProjectKey. '.dat')

      call javacomplete#server#UnblockStart()
      call javacomplete#server#Terminate()
      call javacomplete#server#Start()

      echomsg "Gradle classpath built successfully"
    else
      echohl WarningMsg | echomsg "Failed to build gradle classpath" | echohl None
    endif

    call delete(s:temporaryGradleFile)

    unlet s:temporaryGradleFile
    unlet s:gradleOutput
    unlet s:gradlePath

  elseif a:event == 'stdout'
    for data in filter(a:data,'v:val !~ "^\\s*$"')
      if g:JavaComplete_ShowExternalCommandsOutput
        echomsg data
      endif
    endfor
    if exists('s:gradleOutput')
      call extend(s:gradleOutput, a:data)
    endif
  elseif a:event == 'stderr'
    for data in filter(a:data,'v:val !~ "^\\s*$"')
        echoerr data
    endfor
  endif
endfunction

function! javacomplete#classpath#gradle#Generate()
  let base = javacomplete#util#GetBase("classpath". g:FILE_SEP)
  let g:JavaComplete_ProjectKey = substitute(g:JavaComplete_GradlePath, '[\\/:;.]', '_', 'g')

  let path = base . g:JavaComplete_ProjectKey
  if filereadable(path)
    if getftime(path) >= getftime(g:JavaComplete_GradlePath)
      return join(readfile(path), '')
    endif
    call javacomplete#util#RemoveFile(javacomplete#util#GetBase('cache'). g:FILE_SEP. 'class_packages_'. g:JavaComplete_ProjectKey. '.dat')
  endif
  call s:GenerateClassPath(path, g:JavaComplete_GradlePath)
  return ''
endfunction

function! s:GenerateClassPath(path, gradle) abort
  let s:temporaryGradleFile = tempname()
  let s:gradleOutput = []
  let s:gradlePath = a:path
  if exists("g:JavaComplete_GradleExecutable")
    let gradle = g:JavaComplete_GradleExecutable
  else
    let gradle = fnamemodify(g:JavaComplete_GradlePath, ':p:h') . (javacomplete#util#IsWindows() ? '\gradlew.bat' : '/gradlew')
    if !executable(gradle)
      let gradle = 'gradle'
    endif
  endif
  call writefile(["allprojects{apply from: '". g:JavaComplete_Home. g:FILE_SEP. "classpath.gradle'}"], s:temporaryGradleFile)
  let cmd = [gradle, '-I', s:temporaryGradleFile, 'classpath']
  call javacomplete#server#BlockStart()
  call javacomplete#util#RunSystem(cmd, 'gradle classpath build process', 'javacomplete#classpath#gradle#BuildClasspathHandler')
endfunction

" vim:set fdm=marker sw=2 nowrap:
