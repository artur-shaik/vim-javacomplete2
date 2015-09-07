source autoload/javacomplete.vim
source autoload/java_parser.vim

function! SID() abort
  redir => l:scriptnames
  silent scriptnames
  redir END
  for line in split(l:scriptnames, '\n')
    let [l:sid, l:path] = matchlist(line, '^\s*\(\d\+\):\s*\(.*\)$')[1:2]
    if l:path =~# '\<autoload[/\\]javacomplete\.vim$'
      return '<SNR>' . l:sid . '_'
    endif
  endfor
endfunction
call vspec#hint({'sid': 'SID()', 'scope': 'SScope()'})


describe 'javacomplete-test'
    it 'CountDims test'
        Expect Call('s:CountDims', '') == 0
        Expect Call('s:CountDims', 'String[]') == 1
        Expect Call('s:CountDims', 'String[][]') == 2
        Expect Call('s:CountDims', 'String[][][][][]') == 5
        Expect Call('s:CountDims', 'String]') == 1
        Expect Call('s:CountDims', 'String[') == 0
        Expect Call('s:CountDims', 'String[[') == 0
        Expect Call('s:CountDims', 'String]]') == 1
    end

    it 'CollectFQNs test'
        Expect Call('s:CollectFQNs', 'List', 'kg.ash.foo', '') == ['kg.ash.foo.List','java.lang.List', 'java.lang.Object']
        Expect Call('s:CollectFQNs', 'java.util.List', 'kg.ash.foo', '') == ['java.util.List']

        new
        put ='import java.util.List;'
        Expect Call('s:CollectFQNs', 'List', '', '') == ['java.util.List']
        
        new
        put ='import java.util.*;'
        put ='import java.foo.*;'
        Expect Call('s:CollectFQNs', 'List', '', '') == ['List', 'java.lang.List', 'java.util.List', 'java.foo.List', 'java.lang.Object']
        Expect Call('s:CollectFQNs', 'List', 'kg.ash.foo', '') == ['kg.ash.foo.List', 'java.lang.List', 'java.util.List', 'java.foo.List', 'java.lang.Object']
    end

    it 'GetClassNameWithScope test'
        new 
        put ='ArrayLi'
        Expect Call('s:GetClassNameWithScope') == 'ArrayLi'

        new 
        put ='ArrayList '
        Expect Call('s:GetClassNameWithScope') == 'ArrayList'

        new 
        put ='ArrayList l'
        call cursor(0, 10)
        Expect Call('s:GetClassNameWithScope') == 'ArrayList'

        new 
        put ='ArrayList<String> l'
        call cursor(0, 11)
        Expect Call('s:GetClassNameWithScope') == 'String'

        new 
        put ='List l = new ArrayList<String>()'
        call cursor(0, 1)
        Expect Call('s:GetClassNameWithScope') == 'List'
        call cursor(0, 14)
        Expect Call('s:GetClassNameWithScope') == 'ArrayList'
        call cursor(0, 31)
        Expect Call('s:GetClassNameWithScope') == ''
    end

    it 'AddImport test'
        new
        put! ='package kg.ash.foo;'

        call Call('s:AddImport', 'java.util.List')
        Expect getline(3) == 'import java.util.List;'

        call Call('s:AddImport', 'java.util.ArrayList')
        Expect getline(3) == 'import java.util.List;'

        call Call('s:AddImport', 'foo.bar.Baz')
        Expect getline(5) == 'import foo.bar.Baz;'

        call Call('s:AddImport', 'zoo.bar.Baz')
        Expect getline(5) == 'import foo.bar.Baz;'

        new

        call Call('s:AddImport', 'java.util.List')
        Expect getline(2) == 'import java.util.List;'

        call Call('s:AddImport', 'java.util.ArrayList')
        Expect getline(3) == 'import java.util.ArrayList;'

        call Call('s:AddImport', 'foo.bar.Baz')
        Expect getline(4) == 'import foo.bar.Baz;'

        call Call('s:AddImport', 'zoo.bar.Baz')
        Expect getline(4) == 'import foo.bar.Baz;'

    end

    it 'ParseExpr test'
        Expect Call('s:ParseExpr', 'var') == ['var']
        Expect Call('s:ParseExpr', 'var.') == ['var']
        Expect Call('s:ParseExpr', 'var.method().') == ['var', 'method()']
        Expect Call('s:ParseExpr', 'var.vari') == ['var', 'vari']
        Expect Call('s:ParseExpr', 'var.vari.') == ['var', 'vari']
        Expect Call('s:ParseExpr', 'var[].') == ['var[]']
        Expect Call('s:ParseExpr', '(Boolean) var.') == [' var']
        Expect Call('s:ParseExpr', '((Boolean) var).') == ['(Boolean)obj.']
        Expect Call('s:ParseExpr', '((Boolean) var).method()') == ['(Boolean)obj.', 'method()']
        Expect Call('s:ParseExpr', 'System.out::') == ['System', 'out']
        Expect Call('s:ParseExpr', 'System.out:') == ['System', 'out']
    end

    it 'ExtractCleanExpr test'
        Expect Call('s:ExtractCleanExpr', 'var') == 'var'
        Expect Call('s:ExtractCleanExpr', ' var.') == 'var.'
        Expect Call('s:ExtractCleanExpr', 'var [ 0 ].') == 'var[0].'
        Expect Call('s:ExtractCleanExpr', 'Boolean b = ((Boolean) var).method()') == '((Boolean)var).method()'
        Expect Call('s:ExtractCleanExpr', 'List<String>::') == 'List<String>::'
    end

    it 'GetPackageName test'

        Expect Call('s:GetPackageName') == ''

        new 
        put ='package foo.bar.baz'
        Expect Call('s:GetPackageName') == ''

        new 
        put ='package foo.bar.baz;'
        Expect Call('s:GetPackageName') == 'foo.bar.baz'
    end

    it 'Regexps test'
        let reTypeArgument = Ref('s:RE_TYPE_ARGUMENT')
        let reTypeArgumentExtends = Ref('s:RE_TYPE_ARGUMENT_EXTENDS')
        Expect 'Integer[]' =~ reTypeArgument
        Expect 'Integer[]' !~ reTypeArgumentExtends
        Expect '? super Integer[]' =~ reTypeArgument
        Expect '? super Integer[]' =~ reTypeArgumentExtends

        let qualid = Ref('s:RE_QUALID')
        Expect 'java.util.function.ToIntFunction' =~ '^\s*' . qualid . '\s*$'
        Expect Call('s:HasKeyword', 'java.util.function.ToIntFunction') == 0
    end

    it 'CollectTypeArguments test'
        Expect Call('s:CollectTypeArguments', '', '', '') == ''

        Expect Call('s:CollectTypeArguments', 'Integer', '', '') == '<(Integer|java.lang.Integer|java.lang.Object)>'
        Expect Call('s:CollectTypeArguments', 'Integer[]', '', '') == '<(Integer[]|java.lang.Integer[]|java.lang.Object)>'
        Expect Call('s:CollectTypeArguments', '? super Integer[]', '', '') == '<(Integer[]|java.lang.Integer[]|java.lang.Object)>'

        new
        put ='import java.util.List;'
        put ='import java.util.HashMap;'
        Expect Call('s:CollectTypeArguments', 'List<HashMap<String,BigDecimal>>', '', '') == '<java.util.List<HashMap<String,BigDecimal>>>'
        Expect Call('s:CollectTypeArguments', 'HashMap<String,BigDecimal>', '', '') == '<java.util.HashMap<String,BigDecimal>>'
        Expect Call('s:CollectTypeArguments', 'String,BigDecimal', '', '') == '<(String|java.lang.String|java.lang.Object),(BigDecimal|java.lang.BigDecimal|java.lang.Object)>'
        put ='import java.math.BigDecimal;'
        Expect Call('s:CollectTypeArguments', 'String,BigDecimal', '', '') == '<(String|java.lang.String|java.lang.Object),java.math.BigDecimal>'

        Expect Call('s:CollectTypeArguments', 'MyClass', '', '') == '<(MyClass|java.lang.MyClass|java.lang.Object)>'
        Expect Call('s:CollectTypeArguments', 'MyClass', 'foo.bar.baz', '') == '<(foo.bar.baz.MyClass|java.lang.MyClass|java.lang.Object)>'
    end

    it 'Lambdas named argument search test'
        let tree = Call('javacomplete#parse', 't/data/LambdaNamedClass.java')

        let result = Call('s:SearchNameInAST', tree, 't', 453, 1)
        Expect result[0].type.name == 'String'

        let result = Call('s:SearchNameInAST', tree, 'd', 467, 1)
        Expect result[0].type.name == 'BigDecimal'
    end

    it 'Lambdas anonym argument search test'
        let tree = Call('javacomplete#parse', 't/data/LambdaAnonClass.java')

        let result = Call('s:SearchNameInAST', tree, 't', 388, 1)
        Expect result[0].tag == 'LAMBDA'
        Expect result[0].args.tag == 'IDENT'
        Expect result[0].args.name == 't'

        let result = Call('s:SearchNameInAST', tree, 'd', 463, 1)
        Expect result[1].tag == 'LAMBDA'
        Expect result[1].args[0].tag == 'IDENT'
        Expect result[1].args[0].name == 't'
    end

    it 'Lambdas in method return'
        let tree = Call('javacomplete#parse', 't/data/LambdaReturnClass.java')

        let result = Call('s:SearchNameInAST', tree, 'p', 171, 1)
        Expect result[0].tag == 'LAMBDA'
        Expect result[0].args.tag == 'IDENT'
        Expect result[0].args.name == 'p'
    end

    it 'SplitTypeArguments test'
        Expect Call('s:SplitTypeArguments', 'java.util.List<Integer>') == ['java.util.List', 'Integer']
        Expect Call('s:SplitTypeArguments', 'java.util.List<java.lang.Integer>') == ['java.util.List', 'java.lang.Integer']
        Expect Call('s:SplitTypeArguments', 'java.util.HashMap<Integer,String>') == ['java.util.HashMap', 'Integer,String']
        Expect Call('s:SplitTypeArguments', 'java.util.List<? extends java.lang.Integer[]>') == ['java.util.List', '? extends java.lang.Integer[]']
        Expect Call('s:SplitTypeArguments', 'List<? extends java.lang.Integer[]>') == ['List', '? extends java.lang.Integer[]']
        Expect Call('s:SplitTypeArguments', 'java.util.HashMap<? super Integer,? extends String>') == ['java.util.HashMap', '? super Integer,? extends String']
        Expect Call('s:SplitTypeArguments', 'java.util.function.ToIntFunction<? super java.lang.Integer[]>') == ['java.util.function.ToIntFunction', '? super java.lang.Integer[]']
        Expect Call('s:SplitTypeArguments', 'java.lang.Class<?>') == ['java.lang.Class', 0]
    end

    it 'CleanFQN test'
        Expect Call('s:CleanFQN', '') == ''
        Expect Call('s:CleanFQN', 'java.lang.Object') == 'Object'
        Expect Call('s:CleanFQN', 'java.lang.Object java.util.HashMap.get()') == 'Object get()'
        Expect Call('s:CleanFQN', 'public java.math.BigDecimal java.util.HashMap.computeIfAbsent(java.lang.String,java.util.function.Function<? super java.lang.String, ? extends java.math.BigDecimal>)') == 'public BigDecimal computeIfAbsent(String,Function<? super String, ? extends BigDecimal>)'
    end

end
