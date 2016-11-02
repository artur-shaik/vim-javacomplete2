function! s:__class(class, options)
    let result = "package ". a:options.package .";\n\n"
    let result .= "public class ". a:options.name . " {\n\n"
    for fieldKey in keys(get(a:options, 'fields', {}))
        let field = a:options['fields'][fieldKey]
        let result .= field['mod']. " ". field['type']. " ". field['name']. ";\n"
    endfor
    return result . "\n}"
endfunction
