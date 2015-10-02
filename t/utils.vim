source autoload/javacomplete/util.vim
source t/javacomplete.vim

call vspec#hint({'sid': 'g:SID("util")'})


describe 'javacomplete utils test'
    it 'CountDims test'
        Expect Call('javacomplete#util#CountDims', '') == 0
        Expect Call('javacomplete#util#CountDims', 'String[]') == 1
        Expect Call('javacomplete#util#CountDims', 'String[][]') == 2
        Expect Call('javacomplete#util#CountDims', 'String[][][][][]') == 5
        Expect Call('javacomplete#util#CountDims', 'String]') == 1
        Expect Call('javacomplete#util#CountDims', 'String[') == 0
        Expect Call('javacomplete#util#CountDims', 'String[[') == 0
        Expect Call('javacomplete#util#CountDims', 'String]]') == 1
    end

    it 'GetClassNameWithScope test'
        new 
        put ='ArrayLi'
        Expect Call('javacomplete#util#GetClassNameWithScope') == 'ArrayLi'

        new 
        put ='ArrayList '
        Expect Call('javacomplete#util#GetClassNameWithScope') == 'ArrayList'

        new 
        put ='ArrayList l'
        call cursor(0, 10)
        Expect Call('javacomplete#util#GetClassNameWithScope') == 'ArrayList'

        new 
        put ='ArrayList<String> l'
        call cursor(0, 11)
        Expect Call('javacomplete#util#GetClassNameWithScope') == 'String'

        new 
        put ='List l = new ArrayList<String>()'
        call cursor(0, 1)
        Expect Call('javacomplete#util#GetClassNameWithScope') == 'List'
        call cursor(0, 14)
        Expect Call('javacomplete#util#GetClassNameWithScope') == 'ArrayList'
        call cursor(0, 31)
        Expect Call('javacomplete#util#GetClassNameWithScope') == ''
    end

    it 'CleanFQN test'
        Expect Call('javacomplete#util#CleanFQN', '') == ''
        Expect Call('javacomplete#util#CleanFQN', 'java.lang.Object') == 'Object'
        Expect Call('javacomplete#util#CleanFQN', 'java.lang.Object java.util.HashMap.get()') == 'Object get()'
        Expect Call('javacomplete#util#CleanFQN', 'public java.math.BigDecimal java.util.HashMap.computeIfAbsent(java.lang.String,java.util.function.Function<? super java.lang.String, ? extends java.math.BigDecimal>)') == 'public BigDecimal computeIfAbsent(String,Function<? super String, ? extends BigDecimal>)'
    end

    it 'Prune test'
        Expect Call('javacomplete#util#Prune', ' 	sb. /* block comment*/ append( "stringliteral" ) // comment ') == 'sb.   append( "" ) '
        Expect Call('javacomplete#util#Prune', ' 	list.stream(\n\t\ts -> {System.out.println(s)}).') == 'list.stream(\n\t\ts -> {System.out.println(s)}). '
    end
end
