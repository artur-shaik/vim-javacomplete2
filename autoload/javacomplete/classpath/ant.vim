let s:antXmlTemplate = [
      \ '  <target name="vjc-test-conditions">',
      \ '      <condition property="vjc-netbeans-condition">',
      \ '          <isset property="javac.classpath" />',
      \ '      </condition>',
      \ '      <condition property="vjc-project-condition">',
      \ '          <isreference refid="project.classpath"/>',
      \ '      </condition>',
      \ '      <condition property="vjc-classpath-condition">',
      \ '          <isreference refid="classpath"/>',
      \ '      </condition>',
      \ '  </target>',
      \ '  <target name="vjc-netbeans-classpath" depends="vjc-test-conditions" if="vjc-netbeans-condition">',
      \ '      <property name="javavi.classpath" value="${javac.classpath}" />',
      \ '  </target>',
      \ '  <target name="vjc-project-classpath" depends="vjc-test-conditions" if="vjc-project-condition">',
      \ '      <property name="javavi.classpath" refid="project.classpath"/>',
      \ '  </target>',
      \ '  <target name="vjc-classpath" depends="vjc-test-conditions" if="vjc-classpath-condition">',
      \ '      <property name="javavi.classpath" refid="project.classpath"/>',
      \ '  </target>',
      \ '  <target name="vjc-printclasspath" depends="vjc-project-classpath,vjc-netbeans-classpath,vjc-classpath">',
      \ '      <echo message="${javavi.classpath}"/>',
      \ '  </target>']

function! s:Log(log)
  let log = type(a:log) == type("") ? a:log : string(a:log)
  call javacomplete#logger#Log("[classpath.ant] ". log)
endfunction

function! javacomplete#classpath#ant#IfAnt()
  if executable('ant') && g:JavaComplete_AntPath != ""
    return 1
  endif
  return 0
endfunction

function! javacomplete#classpath#ant#Generate(force) abort
  let g:JavaComplete_ProjectKey = substitute(g:JavaComplete_AntPath, '[\\/:;.]', '_', 'g')
  let path = javacomplete#util#GetBase("classpath". g:FILE_SEP). g:JavaComplete_ProjectKey

  call s:Log(path)
  if filereadable(path)
    if a:force == 0 && getftime(path) >= getftime(g:JavaComplete_AntPath)
      call s:Log("get libs from cache file")
      return join(readfile(path), '')
    endif
    call javacomplete#util#RemoveFile(javacomplete#util#GetBase('cache'). g:FILE_SEP. 'class_packages_'. g:JavaComplete_ProjectKey. '.dat')
  endif

  let hasInitTarget = !empty(system("ant -projecthelp -v | grep '^ init\\>'"))
  let tmpFile = []
  for line in readfile(g:JavaComplete_AntPath)
    if stridx(line, '</project>') >= 0
      if hasInitTarget
        let xmlTemplate = s:antXmlTemplate
        let xmlTemplate[0] = xmlTemplate[0][:-2]. ' depends="init">'
        call extend(tmpFile, xmlTemplate)
      else
        call extend(tmpFile, s:antXmlTemplate)
      endif
    endif
    call add(tmpFile, line)
  endfor
  let s:temporaryAntFile = "vjc-ant-build.xml"
  call writefile(tmpFile, s:temporaryAntFile)

  let antCmd = ['ant', '-f', s:temporaryAntFile, '-q', 'vjc-printclasspath']
  call delete(s:temporaryAntFile)
  let result = system(join(antCmd, " "))
  for line in split(result, '\n')
    let matches = matchlist(line, '\m^\s\+\[echo\]\s\+\(.*\)')
    if !empty(matches)
      return matches[1]
    endif
  endfor
  return '.'
endfunction

" vim:set fdm=marker sw=2 nowrap:
