# vim-javacomplete2

Updated version of the original [javacomplete plugin](http://www.vim.org/scripts/script.php?script_id=1785) for vim.

## Demo

![vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2/raw/master/doc/demo.gif)

Generics demo

![vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2/raw/master/doc/generics_demo.gif)

## Intro

This is vim-javacomplete2, an omni-completion plugin for [Java](http://www.oracle.com/technetwork/java/javase/downloads/index.html) requiring vim 7.

It includes javacomplete.vim, java_parser.vim, javavi (reflecton and source parsing library), javavibridge.py, and the [javaparser](https://github.com/javaparser/javaparser) library.

I have kept java_parser.vim for local (live) continuous parsing, because the javaparser library can't parse unfinished files.

For now the main difference from the original plugin is the existence of a server-like java library, that allows communication over sockets. This speeds up reflection and parsing.

One more issue I had with the original javacomplete plugin is losing my classpath and as a result, completion not working.
So now the javacomplete2 plugin detects the JRE library path, thus bringing standard java completion out of the box - no configuration required!
The plugin will scan child directory tree for `src` directory and add it to the sources path (For this, it is nice to have [vim-rooter](https://github.com/airblade/vim-rooter.git) plugin). 

For the first run the plugin will compile the Javavi library.

## Features

Features:
- Server side java reflection class loader and parsing library;
- Searches class files automatically, using `maven`, `gradle` or Eclipse's `.classpath` file to append completion classpath;
- Generics;
- Lambdas;
- Annotations completion;
- Nested classes;
- Adding imports automatically, includes `static` imports and imports of nested classes;
- Complete methods declaration after '@Override';
- Jsp support, without taglibs.

Features (originally existed):
- List members of a class, including (static) fields, (static) methods and ctors;
- List classes or subpackages of a package;
- Provide parameters information of a method, list all overload methods;
- Complete an incomplete word;
- Provide a complete JAVA parser written in Vim script language;
- Use the JVM to obtain most information.
 
Features borrowed and ported to vimscript from vim-javacompleteex:
- Complete class name;
- Add import statement for a given class name.

## Requirements

- Vim version 7.4 or above with python support;
- JDK8.

## Installation

### pathogen
Run:

````Shell
cd ~/.vim/bundle
git clone https://github.com/artur-shaik/vim-javacomplete2.git
````

### Vundle
Add to `.vimrc`:

````vimL
Plugin 'artur-shaik/vim-javacomplete2'
````

### NeoBundle
Add to `.vimrc`:

````vimL
NeoBundle 'artur-shaik/vim-javacomplete2'
````

### vim-plug
Add to `.vimrc`:
````vimL
Plug 'artur-shaik/vim-javacomplete2'
````

## Configuration

### Required

Add this to your `.vimrc` file:

`autocmd FileType java setlocal omnifunc=javacomplete#Complete`

To enable inserting class imports with F4, add:

`nmap <F4> <Plug>(JavaComplete-Imports-Add)`

`imap <F4> <Plug>(JavaComplete-Imports-Add)`

To add all missing imports with F5:

`nmap <F5> <Plug>(JavaComplete-Imports-AddMissing)`

`imap <F5> <Plug>(JavaComplete-Imports-AddMissing)`

To remove all missing imports with F6:

`nmap <F6> <Plug>(JavaComplete-Imports-RemoveUnused)`

`imap <F6> <Plug>(JavaComplete-Imports-RemoveUnused)`

### Optional

`g:JavaComplete_LibsPath` - path to additional jar files. This path appends with you libraries specified in `pom.xml`. Here you can add, for example, your glassfish libs directory or your project libs. It will be automatically append your JRE home path.

`g:JavaComplete_SourcesPath` - path of additional sources. Don't try to add all sources you have, this will slow down the parsing process. Instead, add your project sources and necessary library sources. If you have compiled classes add them to the previous config (`g:JavaComplete_LibsPath`) instead. By default the plugin will search the `src` directory and add it automatically.

`let g:JavaComplete_MavenRepositoryDisable = 1` - don't append classpath with libraries specified in `pom.xml` of your project. By default is `0`.

`let g:JavaComplete_UseFQN = 1` - use full qualified name in completions description. By default is `0`.

`let g:JavaComplete_PomPath = /path/to/pom.xml` - set path to `pom.xml` explicitly. It will be set automatically, if `pom.xml` is in underlying path.

`let g:JavaComplete_ClosingBrace = 1` - add close brace automatically, when complete method declaration. Disable if it conflicts with another plugins.

`let g:JavaComplete_JavaviLogfileDirectory = ''` - directory, where to write server logs.

`let g:JavaComplete_JavaviDebug = 1` - enables server side logging.

## Commands

`JCimportsAddMissing` - add all missing 'imports';

`JCimportsRemoveUnused` - remove all unsused 'imports';

`JCimportAdd` - add 'import' for classname that is under cursor, or before it;

`JCimportAddI` - the same, but enable insert mode after 'import' was added;


`JCserverShowPort` - show port, through which vim plugin communicates with server;

`JCserverShowPID` - show server process identificator;

`JCserverStart` - start server manually;

`JCserverTerminate` - stop server manually;

`JCserverCompile` - compile server manually;


`JCdebugEnableLogs` - enable logs;

`JCdebugDisableLogs` - disable logs;

`JCdebugGetLogContent` - get debug logs;


`JCcacheClear` - clear cache manually.

## Limitations:

- First run can be slow;
- The embedded parser works a bit slower than expected.

## Todo

- Add javadoc;
- ~~Lambda support~~;
- Cross session cache;
- Most used (classes, methods, vars) at first place (smart suggestions);
- FXML support;
- ~~Check for jsp support~~;
- Refactoring support?;
- Class creation helpers;
- ~~Generics~~;
- etc...

## Thanks

- Cheng Fang author of original javacomplete plugin;
- Zhang Li author of vim-javacompleteex plugin;
- http://github.com/javaparser/javaparser library.

## FeedBack

Any problems, bugs or suggestions are welcome to send to ashaihullin@gmail.com
