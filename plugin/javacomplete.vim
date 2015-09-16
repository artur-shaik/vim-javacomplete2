" Java complete plugin file
" Maintainer:	artur shaik <ashaihullin@gmail.com>

command! JCimportsAddMissing call javacomplete#AddMissingImports()
command! JCimportsRemoveUnused call javacomplete#RemoveUnusedImports()
command! JCimportAdd call javacomplete#AddImport()
command! JCimportAddI call javacomplete#AddImport(1)

command! JCserverShowPort call javacomplete#ShowPort()
command! JCserverShowPID call javacomplete#ShowPID()
command! JCserverStart call javacomplete#StartServer()
command! JCserverTerminate call javacomplete#TerminateServer()
command! JCserverCompile call javacomplete#CompileJavavi()

command! JCdebugEnableLogs call javacomplete#EnableLogs()
command! JCdebugDisableLogs call javacomplete#DisableLogs()
command! JCdebugGetLogContent call javacomplete#GetLogContent()

command! JCcacheClear call javacomplete#ClearCache()


autocmd Filetype java JCserverStart
autocmd Filetype java inoremap <buffer>  .  <C-r>=MyFunc('.')<CR>
autocmd Filetype java inoremap <buffer>  A  <C-r>=MyFunc('A')<CR>
autocmd Filetype java inoremap <buffer>  B  <C-r>=MyFunc('B')<CR>
autocmd Filetype java inoremap <buffer>  C  <C-r>=MyFunc('C')<CR>
autocmd Filetype java inoremap <buffer>  D  <C-r>=MyFunc('D')<CR>
autocmd Filetype java inoremap <buffer>  E  <C-r>=MyFunc('E')<CR>
autocmd Filetype java inoremap <buffer>  F  <C-r>=MyFunc('F')<CR>
autocmd Filetype java inoremap <buffer>  G  <C-r>=MyFunc('G')<CR>
autocmd Filetype java inoremap <buffer>  H  <C-r>=MyFunc('H')<CR>
autocmd Filetype java inoremap <buffer>  I  <C-r>=MyFunc('I')<CR>
autocmd Filetype java inoremap <buffer>  J  <C-r>=MyFunc(JG')<CR>
autocmd Filetype java inoremap <buffer>  K  <C-r>=MyFunc('K')<CR>
autocmd Filetype java inoremap <buffer>  L  <C-r>=MyFunc('L')<CR>
autocmd Filetype java inoremap <buffer>  M  <C-r>=MyFunc('M')<CR>
autocmd Filetype java inoremap <buffer>  N  <C-r>=MyFunc('N')<CR>
autocmd Filetype java inoremap <buffer>  O  <C-r>=MyFunc('O')<CR>
autocmd Filetype java inoremap <buffer>  P  <C-r>=MyFunc('P')<CR>
autocmd Filetype java inoremap <buffer>  Q  <C-r>=MyFunc('Q')<CR>
autocmd Filetype java inoremap <buffer>  R  <C-r>=MyFunc('R')<CR>
autocmd Filetype java inoremap <buffer>  S  <C-r>=MyFunc('S')<CR>
autocmd Filetype java inoremap <buffer>  T  <C-r>=MyFunc('T')<CR>
autocmd Filetype java inoremap <buffer>  U  <C-r>=MyFunc('U')<CR>
autocmd Filetype java inoremap <buffer>  V  <C-r>=MyFunc('V')<CR>
autocmd Filetype java inoremap <buffer>  W  <C-r>=MyFunc('W')<CR>
autocmd Filetype java inoremap <buffer>  X  <C-r>=MyFunc('X')<CR>
autocmd Filetype java inoremap <buffer>  Y  <C-r>=MyFunc('Y')<CR>
autocmd Filetype java inoremap <buffer>  Z  <C-r>=MyFunc('Z')<CR>
function! MyFunc(char)
    if(getline(".")=~?'^\s*\/\/')==0
        return a:char."\<c-x>\<c-o>\<c-p>"
    else
        return a:char
    endif
endf
