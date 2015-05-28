# vim-javacomplete2

Refreshed javacomplete plugin for vim.

## Demo

![vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2/raw/master/doc/demo.gif)

## Intro

This is vim-javacomplete2, an omni-completion script of JAVA language for vim 7.  This plugin updates old one: http://www.vim.org/scripts/script.php?script_id=1785.

It includes javacomplete.vim, java_parser.vim, javavi (reflecton and source parsing library), javavibridge.py, [javaparser](https://github.com/javaparser/javaparser) library.

I have kept java_parser.vim for local continious parsing, because javaparser library can't parse unfinished files.

For now main difference from original plugin is existence of server-like java library, that allows to communicate with it through socket.
This speed up reflection and source parsing.

One more issue I had with original javacomplete plugin is loosing my classpath and as result not working completion.
Now plugin detect jre library path, and you will have standart java completion out of the box, without configuration.
Plugin will scan child directory tree for `src` named directory and add it to sources path (For this, nice to have [vim-rooter](https://github.com/airblade/vim-rooter.git) plugin). 
And by default plugin will look at maven repository (`~/.m2/repository`).

At most first run, plugin will compile Javavi library.

## Features

Features:
- Server side java reflection class loader and parsing library;
- Search class files automatically.

Features (originally existed):
- List members of a class, including (static) fields, (static) methods and ctors;
- List classes or subpackages of a package;
- Provide parameters information of a method, list all overload methods;
- Complete an incomplete word;
- Provide a complete JAVA parser written in Vim script language;
- Use the JVM to obtain most information;
- JSP is supported, Builtin objects such as request, session can be recognized.
 
Features was borrowed and ported to vimscript from vim-javacompleteex:
- Complete class name;
- Add import statement for a given class name.

## Requirements

- Vim version 7.0 and above;
- JDK version 7 and above in classpath.

## Installation

This assumes you are using [Vundle](https://github.com/gmarik/Vundle.vim). Adapt
for your plugin manager of choice. Put this into your `.vimrc`.

    " Java completion plugin.
    Plugin 'artur-shaik/vim-javacomplete2'

## Configuration

### Required

Add this to your vimrc file:

`autocmd FileType java set omnifunc=javacomplete#Complete`

To insert class import with F4, add this:

`nnoremap <F4> call javacomplete#AddImport()<cr>`

### Optional

`g:JavaComplete_LibsPath` - path of you jar files. This path will always appended with '~/.m2/repository' directory. Here you can add your glassfish libs directory or your project libs. It will be automatically appended with you jre home path.

`g:JavaComplete_SourcesPath` - path of your sources. Don't try to add all sources you have, this will slow down parsing process. Add you project sources and necessery library sources. If you have compiled classes add them to previous config instead. By default plugin will search `src` directory and add it automatically.

## Commands

manually run server:

    javacomplete#StartServer()

manually stop server:

    javacomplete#TerminateServer()

insert class import:

    javacomplete#AddImport()

show port used for javavi server:

    javacomplete#ShowPort()

show javavi server process id:

    javacomplete#ShowPID()

manually run server compilation:

    javacomplete#CompileJavavi()

## Limitations:

- First run can be slow;
- The embedded parser works a bit slower than expected.

## Todo

- Add javadoc;
- Give a hint for class name conflict in different packages;
- Support parameter information for template;
- Make it faster and more robust;
- Lambda support;
- Cross session cache;
- Most used (classes, methods, vars) at first place (smart suggestions);
- FXML support;
- Check for jsp support;
- Refactoring support?;
- Class creation helpers;
- Generics;
- Clean old unused code;
- etc...

## Thanks

- Cheng Fang author of original javacomplete plugin;
- Zhang Li author of vim-javacompleteex plugin;
- http://github.com/javaparser/javaparser library.

Originally thanked:

- Bram Moolenaar and all Vim contributors for Vim;
- The insenvim project;
- The javac and gjc sources;
- Martin Stubenschrott	author of IComplete;
- Vissale NEANG		author of OmniCppComplete;
- David Fishburn		author of SQLComplete and others;
- Nico Weber		testing on the Mac;
- Thomas Link		testing on cygwin+bash;
- Zhixing Yu;
- Rodrigo Rosenfeld Rosas;
- Alexandru Mo?oi.

## FeedBack

Any problem, bug or suggest are welcome to send to ashaihullin@gmail.com
