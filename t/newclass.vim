source plugin/javacomplete.vim
source autoload/javacomplete.vim
source autoload/javacomplete/newclass.vim
source t/javacomplete.vim

call vspec#hint({'sid': 'g:SID("newclass")', 'scope': 'SScope()'})

describe 'javacomplete-test'
    before
        let b:currentPath = reverse(split('/home/foo/project/src/kg/foo/bar/CurrentClass.java', '/')[:-2])
    end

    it 'ParseInput same package class test'
        Expect Call('s:ParseInput', 
                    \ ['NewClass'], 
                    \ b:currentPath, 
                    \ split('kg.foo.bar', '\.')) 
                    \ == 
                    \ {
                    \ 'path' : '', 
                    \ 'class' : 'NewClass', 
                    \ 'package' : 'kg.foo.bar'
                    \ }
    end

    it 'ParseInput root path search test'
        Expect Call('s:ParseInput', 
                    \ ['/', 'foo', 'baz', 'NewClass'], 
                    \ b:currentPath, 
                    \ split('kg.foo.bar', '\.')) 
                    \ == 
                    \ {
                    \ 'path' : '../baz', 
                    \ 'class' : 'NewClass', 
                    \ 'package' : 'kg.foo.baz'
                    \ }
        Expect Call('s:ParseInput', 
                    \ ['/foo', 'baz', 'NewClass'], 
                    \ b:currentPath, 
                    \ split('kg.foo.bar', '\.')) 
                    \ == 
                    \ {
                    \ 'path' : '../baz', 
                    \ 'class' : 'NewClass', 
                    \ 'package' : 'kg.foo.baz'
                    \ }
        Expect Call('s:ParseInput', 
                    \ ['/', 'org', 'foo', 'baz', 'NewClass'], 
                    \ b:currentPath, 
                    \ split('kg.foo.bar', '\.')) 
                    \ == 
                    \ {
                    \ 'path' : '../../../org/foo/baz', 
                    \ 'class' : 'NewClass', 
                    \ 'package' : 'org.foo.baz'
                    \ }
        Expect Call('s:ParseInput', 
                    \ ['/', 'foo', 'baz', 'bar', 'NewClass'], 
                    \ b:currentPath, 
                    \ split('kg.foo.bar', '\.')) 
                    \ == 
                    \ {
                    \ 'path' : '../baz/bar', 
                    \ 'class' : 'NewClass', 
                    \ 'package' : 'kg.foo.baz.bar'
                    \ }
    end

    it 'ParseInput relative path test'
        Expect Call('s:ParseInput', 
                    \ ['foo', 'baz', 'NewClass'], 
                    \ b:currentPath, 
                    \ split('kg.foo.bar', '\.')) 
                    \ == 
                    \ {
                    \ 'path' : 'foo/baz', 
                    \ 'class' : 'NewClass', 
                    \ 'package' : 'kg.foo.bar.foo.baz'
                    \ }
    end

    it 'ParseInput relative path test'
        let currentPath = reverse(split('/home/foo/project/src/kg/foo/bar/baz/bad/bas/CurrentClass.java', '/')[:-2])
        Expect Call('s:ParseInput', 
                    \ ['/bar', 'fee', 'NewClass'], 
                    \ b:currentPath, 
                    \ split('kg.foo.bar.baz.bad.bas', '\.')) 
                    \ == 
                    \ {
                    \ 'path' : '../../../fee', 
                    \ 'class' : 'NewClass', 
                    \ 'package' : 'kg.foo.bar.fee'
                    \ }
    end

end
