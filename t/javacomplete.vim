source autoload/javacomplete.vim

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
call vspec#hint({'sid': 'SID()'})


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
        Expect Call('s:CollectFQNs', 'List', 'kg.ash.foo', '') == ['kg.ash.foo.List','java.lang.List']
        Expect Call('s:CollectFQNs', 'java.util.List', 'kg.ash.foo', '') == ['java.util.List']

        new
        put ='import java.util.List;'
        Expect Call('s:CollectFQNs', 'List', '', '') == ['java.util.List']
        
        new
        put ='import java.util.*;'
        put ='import java.foo.*;'
        Expect Call('s:CollectFQNs', 'List', '', '') == ['List', 'java.lang.List', 'java.util.List', 'java.foo.List']
        Expect Call('s:CollectFQNs', 'List', 'kg.ash.foo', '') == ['kg.ash.foo.List', 'java.lang.List', 'java.util.List', 'java.foo.List']
    end

end
