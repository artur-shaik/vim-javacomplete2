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
