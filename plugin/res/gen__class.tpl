function! s:__class(class, options)
   let result = "package ". a:options.package .";\n\n"
   let result .= "public class ". a:options.name . " {\n\n"
   return result . "}"
endfunction
