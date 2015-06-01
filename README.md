# vim-javacomplete2

Updated version of the original [javacomplete plugin](http://www.vim.org/scripts/script.php?script_id=1785) for vim.

## Demo

![vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2/raw/master/doc/demo.gif)

## Intro

This is vim-javacomplete2, an omni-completion plugin for [Java](http://www.oracle.com/technetwork/java/javase/downloads/index.html) requiring vim 7.

It includes javacomplete.vim, java_parser.vim, javavi (reflecton and source parsing library), javavibridge.py, and the [javaparser](https://github.com/javaparser/javaparser) library.

I have kept java_parser.vim for local (live) continuous parsing, because the javaparser library can't parse unfinished files.

For now the main difference from the original plugin is the existence of a server-like java library, that allows communication over sockets. This speeds up reflection and parsing.

One more issue I had with the original javacomplete plugin is losing my classpath and as a result, completion not working.
So now the javacomplete2 plugin detects the JRE library path, thus bringing standard java completion out of the box - no configuration required!
The plugin will scan child directory tree for `src` directory and add it to the sources path (For this, it is nice to have [vim-rooter](https://github.com/airblade/vim-rooter.git) plugin). 
By default the plugin will look for a maven repository (`~/.m2/repository`).

For the first run the plugin will compile the Javavi library.

## Features

Features:
- Server side java reflection class loader and parsing library;
- Searches class files automatically.

Features (originally existed):
- List members of a class, including (static) fields, (static) methods and ctors;
- List classes or subpackages of a package;
- Provide parameters information of a method, list all overload methods;
- Complete an incomplete word;
- Provide a complete JAVA parser written in Vim script language;
- Use the JVM to obtain most information;
- JSP is supported, Builtin objects such as request, session can be recognized.
 
Features borrowed and ported to vimscript from vim-javacompleteex:
- Complete class name;
- Add import statement for a given class name.

## Requirements

- Vim version 7.0 or above;
- JDK version 7 or above in classpath.

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

### vim-plug
Add to `.vimrc`:
````vimL
Plug 'artur-shaik/vim-javacomplete2'
````

## Configuration

### Required

Add this to your `.vimrc` file:

`autocmd FileType java set omnifunc=javacomplete#Complete`

To enable inserting class imports with F4, add:

`nnoremap <F4> call javacomplete#AddImport()<cr>`

### Optional

`g:JavaComplete_LibsPath` - path to additional jar files. This path will always be appended with '~/.m2/repository' directory. Here you can add, for example, your glassfish libs directory or your project libs. It will be automatically append your JRE home path.

`g:JavaComplete_SourcesPath` - path of additional sources. Don't try to add all sources you have, this will slow down the parsing process. Instead, add your project sources and necessary library sources. If you have compiled classes add them to the previous config (`g:JavaComplete_LibsPath`) instead. By default the plugin will search the `src` directory and add it automatically.

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

Any problems, bugs or suggestions are welcome to send to ashaihullin@gmail.com
