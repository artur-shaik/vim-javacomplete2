" Java complete plugin file
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" this file comtains command,custom g:var init and maps

""
" @section Introduction, intro
" @library
" @order intro features requirements download install usage
" This is javacomplete, an omni-completion script of JAVA language
" for vim 7 and above. It includes javacomplete.vim, java_parser.vim,
" javavi library, javaparser library and javacomplete.txt.


""
" @section Features, features
" 1. List members of a class, including (static) fields, (static) methods and ctors;
" 2. List classes or subpackages of a package;
" 3. Provide parameters information of a method, list all overload methods;
" 4. Complete an incomplete word;
" 5. Provide a complete JAVA parser written in Vim script language;
" 6. Use the JVM to obtain most information;
" 7. Use the embedded parser to obtain the class information from source files;
" 8. JSP is supported, Builtin objects such as request, session can be recognized;
" 9. The classes and jar files in the WEB-INF will be appended automatically to the classpath;
" 10. Server side java reflection class loader and parsing library;
" 11. Search class files automatically;
" 12. Complete class name;
" 13. Add import statement for a given class name;
" 14. Complete methods declaration after '@Override';
" 15. Support for maven, gradle and Eclipse's '.classpath';
" 16. Cross-session cache;
" 17. Auto insert methods that need to be implemented;
" 18. `toString`, `equals`, `hashCode`, Accessors generation.


""
" @section Requirements, requirements
"
" 1. Vim version 7.4 and above with python support;
" 2. JDK8.
"

""
" @section Download, download
" You can download the lastest version from this url:
	" https://github.com/artur-shaik/vim-javacomplete2

""
" @section Install, install
" 1. This assumes you are using `Vundle`. Adapt for your plugin manager of choice. Put this into your `.vimrc`.
" 
"     " Java completion plugin.
"     Plugin 'artur-shaik/vim-javacomplete2'
" 
" 2. Set 'omnifunc' option. e.g.
" >
"   autocmd Filetype java setlocal omnifunc=javacomplete#Complete
" <
" 3. Map keys you prefer:
" For smart (trying to guess import option) insert class import with <F4>:
" >
"     nmap <F4> <Plug>(JavaComplete-Imports-AddSmart)
"     imap <F4> <Plug>(JavaComplete-Imports-AddSmart)
" <
" For usual (will ask for import option) insert class import with <F5>:
" 
"     nmap <F5> <Plug>(JavaComplete-Imports-Add)
"     imap <F5> <Plug>(JavaComplete-Imports-Add)
" 
" For add all missing imports with <F6>:
" 
"     nmap <F6> <Plug>(JavaComplete-Imports-AddMissing)
"     imap <F6> <Plug>(JavaComplete-Imports-AddMissing)
" 
" For remove all missing imports with <F7>:
" 
"     nmap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
"     imap <F7> <Plug>(JavaComplete-Imports-RemoveUnused)
" 
" For sorting all imports with <F8>:
" 
"     nmap <F8> <Plug>(JavaComplete-Imports-SortImports)
"     imap <F8> <Plug>(JavaComplete-Imports-SortImports)
" 
" 
" Default mappings:
" 
"     nmap <leader>jI <Plug>(JavaComplete-Imports-AddMissing)
"     nmap <leader>jR <Plug>(JavaComplete-Imports-RemoveUnused)
"     nmap <leader>ji <Plug>(JavaComplete-Imports-AddSmart)
"     nmap <leader>jii <Plug>(JavaComplete-Imports-Add)
"     nmap <Leader>jis <Plug>(JavaComplete-Imports-SortImports)
" 
"     imap <C-j>I <Plug>(JavaComplete-Imports-AddMissing)
"     imap <C-j>R <Plug>(JavaComplete-Imports-RemoveUnused)
"     imap <C-j>i <Plug>(JavaComplete-Imports-AddSmart)
"     imap <C-j>ii <Plug>(JavaComplete-Imports-Add)
" 
"     nmap <leader>jM <Plug>(JavaComplete-Generate-AbstractMethods)
" 
"     imap <C-j>jM <Plug>(JavaComplete-Generate-AbstractMethods)
" 
"     nmap <leader>jA <Plug>(JavaComplete-Generate-Accessors)
"     nmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
"     nmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
"     nmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
"     nmap <leader>jts <Plug>(JavaComplete-Generate-ToString)
"     nmap <leader>jeq <Plug>(JavaComplete-Generate-EqualsAndHashCode)
"     nmap <leader>jc <Plug>(JavaComplete-Generate-Constructor)
"     nmap <leader>jcc <Plug>(JavaComplete-Generate-DefaultConstructor)
" 
"     imap <C-j>s <Plug>(JavaComplete-Generate-AccessorSetter)
"     imap <C-j>g <Plug>(JavaComplete-Generate-AccessorGetter)
"     imap <C-j>a <Plug>(JavaComplete-Generate-AccessorSetterGetter)
" 
"     vmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
"     vmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
"     vmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
" 
" 
" 4. Javavi library will be automatcally compiled when you
" use first time. 
" If no libs/javavi/target is generated, check that you have the write permission
" and jdk installed.


let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:JavaComplete_PluginLoaded')
  finish
endif
let g:JavaComplete_PluginLoaded = 1

let g:JavaComplete_IsWindows = javacomplete#util#IsWindows()

if g:JavaComplete_IsWindows
  let g:PATH_SEP    = ';'
  let g:FILE_SEP    = '\'
else
  let g:PATH_SEP    = ':'
  let g:FILE_SEP    = '/'
endif

let g:JavaComplete_BaseDir =
      \ get(g:, 'JavaComplete_BaseDir', expand('~'. g:FILE_SEP. '.cache'))

let g:JavaComplete_ImportDefault =
      \ get(g:, 'JavaComplete_ImportDefault', 0)

let g:JavaComplete_ShowExternalCommandsOutput =
      \ get(g:, 'JavaComplete_ShowExternalCommandsOutput', 0)

let g:JavaComplete_ClasspathGenerationOrder =
      \ get(g:, 'JavaComplete_ClasspathGenerationOrder', ['Maven', 'Eclipse', 'Gradle', 'Ant'])

let g:JavaComplete_ImportSortType =
      \ get(g:, 'JavaComplete_ImportSortType', 'jarName')

let g:JavaComplete_ImportOrder =
      \ get(g:, 'JavaComplete_ImportOrder', ['java.', 'javax.', 'com.', 'org.', 'net.'])

let g:JavaComplete_StaticImportsAtTop =
      \ get(g:, 'JavaComplete_StaticImportsAtTop', 0)

let g:JavaComplete_RegularClasses =
      \ get(g:, 'JavaComplete_RegularClasses', ['java.lang.String', 'java.lang.Object', 'java.lang.Exception', 'java.lang.StringBuilder', 'java.lang.Override', 'java.lang.UnsupportedOperationException', 'java.math.BigDecimal', 'java.lang.Byte', 'java.lang.Short', 'java.lang.Integer', 'java.lang.Long', 'java.lang.Float', 'java.lang.Double', 'java.lang.Character', 'java.lang.Boolean'])

let g:JavaComplete_AutoStartServer = 
      \ get(g:, 'JavaComplete_AutoStartServer', 1)

let g:JavaComplete_CompletionResultSort =
      \ get(g:, 'JavaComplete_CompletionResultSort', 0)

""
" @section Commands, commands
" @parentsection usage
" All these commands are supported when encoding with java project.

""
" add all missing 'imports'
command! JCimportsAddMissing call javacomplete#imports#AddMissing()
command! JCDisable call javacomplete#Disable()
command! JCEnable call javacomplete#Enable()
""
" remove all unsused 'imports'
command! JCimportsRemoveUnused call javacomplete#imports#RemoveUnused()
""
" add 'import' for classname that is under cursor, or before it
command! JCimportAdd call javacomplete#imports#Add()
""
" add 'import' for classname trying to guess variant without ask user to choose an option (it will ask on false guessing)
command! JCimportAddSmart call javacomplete#imports#Add(1)
""
" sort all 'imports'
command! JCimportsSort call javacomplete#imports#SortImports()

command! JCGetSymbolType call javacomplete#imports#getType()

    " JCclassNew - open prompt to enter class creation command;
    " JCclassInFile - open prompt to choose template that will be used for creation class boilerplate in current empty file;
"
    " JCserverShowPort - show port, through which vim plugin communicates with server;
    " JCserverShowPID - show server process identificator;
    " JCserverStart - start server manually;
    " JCserverTerminate - stop server manually;
    " JCserverCompile - compile server manually;
"
    " JCdebugEnableLogs - enable logs;
    " JCdebugDisableLogs - disable logs;
    " JCdebugGetLogContent - get debug logs;
"
    " JCcacheClear - clear cache manually.
command! JCserverShowPort call javacomplete#server#ShowPort()
command! JCserverShowPID call javacomplete#server#ShowPID()
command! JCserverStart call javacomplete#server#Start()
command! JCserverTerminate call javacomplete#server#Terminate()
command! JCserverCompile call javacomplete#server#Compile()
command! JCserverLog call javacomplete#server#GetLogContent()
command! JCserverEnableDebug call javacomplete#server#EnableDebug()
command! JCserverEnableTraceDebug call javacomplete#server#EnableTraceDebug()

command! JCdebugEnableLogs call javacomplete#logger#Enable()
command! JCdebugDisableLogs call javacomplete#logger#Disable()
command! JCdebugGetLogContent call javacomplete#logger#GetContent()

command! JCcacheClear call javacomplete#ClearCache()

command! JCstart call javacomplete#Start()

""
" generate methods that need to be implemented
command! JCgenerateAbstractMethods call javacomplete#generators#AbstractDeclaration()
""
" generate getters and setters for all fields;
command! JCgenerateAccessors call javacomplete#generators#Accessors()
" "
" generate setter for field under cursor;
command! JCgenerateAccessorSetter call javacomplete#generators#Accessor('s')
" "
" generate getter for field under cursor;
command! JCgenerateAccessorGetter call javacomplete#generators#Accessor('g')
""
" generate getter and setter for field under cursor;
command! JCgenerateAccessorSetterGetter call javacomplete#generators#Accessor('sg')
" "
" generate 'toString' method;
command! JCgenerateToString call javacomplete#generators#GenerateToString()
" "
" generate 'equals' and 'hashCode' methods;
command! JCgenerateEqualsAndHashCode call javacomplete#generators#GenerateEqualsAndHashCode()
" "
" generate constructor with chosen fields;
command! JCgenerateConstructor call javacomplete#generators#GenerateConstructor(0)
" "
" generate default constructor;
command! JCgenerateConstructorDefault call javacomplete#generators#GenerateConstructor(1)

command! JCclasspathGenerate call javacomplete#classpath#classpath#RebuildClassPath()

command! JCclassNew call javacomplete#newclass#CreateClass()
command! JCclassInFile call javacomplete#newclass#CreateInFile()

if g:JavaComplete_AutoStartServer
  augroup vim_javacomplete2
    autocmd!
    autocmd Filetype java,jsp JCstart
  augroup END
endif

function! s:nop(s)
  return ''
endfunction

nnoremap <silent> <Plug>(JavaComplete-Imports-AddMissing) :call javacomplete#imports#AddMissing()<cr>
inoremap <silent> <Plug>(JavaComplete-Imports-AddMissing) <c-r>=<SID>nop(javacomplete#imports#AddMissing())<cr>
nnoremap <silent> <Plug>(JavaComplete-Imports-RemoveUnused) :call javacomplete#imports#RemoveUnused()<cr>
inoremap <silent> <Plug>(JavaComplete-Imports-RemoveUnused) <c-r>=<SID>nop(javacomplete#imports#RemoveUnused())<cr>
nnoremap <silent> <Plug>(JavaComplete-Imports-Add) :call javacomplete#imports#Add()<cr>
inoremap <silent> <Plug>(JavaComplete-Imports-Add) <c-r>=<SID>nop(javacomplete#imports#Add())<cr>
nnoremap <silent> <Plug>(JavaComplete-Imports-AddSmart) :call javacomplete#imports#Add(1)<cr>
inoremap <silent> <Plug>(JavaComplete-Imports-AddSmart) <c-r>=<SID>nop(javacomplete#imports#Add(1))<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-AbstractMethods) :call javacomplete#generators#AbstractDeclaration()<cr>
inoremap <silent> <Plug>(JavaComplete-Generate-AbstractMethods) <c-r>=<SID>nop(javacomplete#generators#AbstractDeclaration())<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-Accessors) :call javacomplete#generators#Accessors()<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-AccessorSetter) :call javacomplete#generators#Accessor('s')<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-AccessorGetter) :call javacomplete#generators#Accessor('g')<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-AccessorSetterGetter) :call javacomplete#generators#Accessor('sg')<cr>
inoremap <silent> <Plug>(JavaComplete-Generate-AccessorSetter) <c-r>=<SID>nop(javacomplete#generators#Accessor('s'))<cr>
inoremap <silent> <Plug>(JavaComplete-Generate-AccessorGetter) <c-r>=<SID>nop(javacomplete#generators#Accessor('g'))<cr>
inoremap <silent> <Plug>(JavaComplete-Generate-AccessorSetterGetter) <c-r>=<SID>nop(javacomplete#generators#Accessor('sg'))<cr>
vnoremap <silent> <Plug>(JavaComplete-Generate-AccessorSetter) :call javacomplete#generators#Accessor('s')<cr>
vnoremap <silent> <Plug>(JavaComplete-Generate-AccessorGetter) :call javacomplete#generators#Accessor('g')<cr>
vnoremap <silent> <Plug>(JavaComplete-Generate-AccessorSetterGetter) :call javacomplete#generators#Accessor('sg')<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-ToString) :call javacomplete#generators#GenerateToString()<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-EqualsAndHashCode) :call javacomplete#generators#GenerateEqualsAndHashCode()<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-Constructor) :call javacomplete#generators#GenerateConstructor(0)<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-DefaultConstructor) :call javacomplete#generators#GenerateConstructor(1)<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-NewClass) :call javacomplete#newclass#CreateClass()<cr>
nnoremap <silent> <Plug>(JavaComplete-Generate-ClassInFile) :call javacomplete#newclass#CreateInFile()<cr>
nnoremap <silent> <Plug>(JavaComplete-Imports-SortImports) :call javacomplete#imports#SortImports()<cr>
inoremap <silent> <Plug>(JavaComplete-Imports-SortImports) <c-r>=<SID>nop(javacomplete#imports#SortImports())<cr>

let &cpoptions = s:save_cpo
unlet s:save_cpo
augroup vim_javacomplete2
  autocmd User CmSetup call cm#sources#java#register()
augroup END
" vim:set fdm=marker sw=2 nowrap:
