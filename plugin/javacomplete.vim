" Java complete plugin file
" Maintainer:	artur shaik <ashaihullin@gmail.com>
" this file comtains command,custom g:var init and maps

let s:save_cpo = &cpo
set cpo&vim

if exists('g:JavaComplete_PluginLoaded')
    finish
endif


command! JCimportsAddMissing call javacomplete#imports#AddMissing()
command! JCimportsRemoveUnused call javacomplete#imports#RemoveUnused()
command! JCimportAddSmart call javacomplete#imports#Add(1)
command! JCimportAdd call javacomplete#imports#Add()

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
nnoremap <Plug>(JavaComplete-Imports-AddSmart) :call javacomplete#imports#Add(1)<cr>
inoremap <Plug>(JavaComplete-Imports-Add) <c-r>=<SID>nop(javacomplete#imports#Add())<cr>
inoremap <Plug>(JavaComplete-Imports-AddSmart) <c-r>=<SID>nop(javacomplete#imports#Add(1))<cr>



let g:JavaComplete_PluginLoaded = 1
let &cpo = s:save_cpo
unlet s:save_cpo
" vim:set fdm=marker sw=2 nowrap:
