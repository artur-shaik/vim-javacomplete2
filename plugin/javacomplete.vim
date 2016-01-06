" Java complete plugin file
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" this file comtains command,custom g:var init and maps

let s:save_cpo = &cpo
set cpo&vim

if exists('g:JavaComplete_plugin_loaded')
    finish
endif
let g:JavaComplete_plugin_loaded = 1

let g:JavaComplete_IS_WINDOWS = javacomplete#util#IsWindows()

if g:JavaComplete_IS_WINDOWS
  let g:PATH_SEP    = ';'
  let g:FILE_SEP    = '\'
else
  let g:PATH_SEP    = ':'
  let g:FILE_SEP    = '/'
endif

let g:JavaComplete_BaseDir =
      \ get(g:,'JavaComplete_BaseDir',expand('~'. g:FILE_SEP. '.javacomplete2'))

let g:JavaComplete_Import_Default =
      \ get(g:,'JavaComplete_Import_Default',0)

command! JCimportsAddMissing call javacomplete#imports#AddMissing()
command! JCimportsRemoveUnused call javacomplete#imports#RemoveUnused()
command! JCimportAdd call javacomplete#imports#Add()
command! JCimportAddI call javacomplete#imports#Add(1)

command! JCserverShowPort call javacomplete#server#ShowPort()
command! JCserverShowPID call javacomplete#server#ShowPID()
command! JCserverStart call javacomplete#server#Start()
command! JCserverTerminate call javacomplete#server#Terminate()
command! JCserverCompile call javacomplete#server#Compile()

command! JCdebugEnableLogs call javacomplete#logger#Enable()
command! JCdebugDisableLogs call javacomplete#logger#Disable()
command! JCdebugGetLogContent call javacomplete#logger#GetContent()

command! JCcacheClear call javacomplete#ClearCache()

command! JCstart call javacomplete#Start()

autocmd Filetype java,jsp JCstart

function! s:nop(s)
  return ''
endfunction

nnoremap <Plug>(JavaComplete-Imports-AddMissing) :call javacomplete#imports#AddMissing()<cr>
inoremap <Plug>(JavaComplete-Imports-AddMissing) <c-r>=<SID>nop(javacomplete#imports#AddMissing())<cr>
nnoremap <Plug>(JavaComplete-Imports-RemoveUnused) :call javacomplete#imports#RemoveUnused()<cr>
inoremap <Plug>(JavaComplete-Imports-RemoveUnused) <c-r>=<SID>nop(javacomplete#imports#RemoveUnused())<cr>
nnoremap <Plug>(JavaComplete-Imports-Add) :call javacomplete#imports#Add()<cr>
inoremap <Plug>(JavaComplete-Imports-Add) <c-r>=<SID>nop(javacomplete#imports#Add())<cr>



let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fdm=marker sw=2 nowrap:
