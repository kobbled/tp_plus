class TPPlus::Scanner

option
         ignorecase

macro
         blank                      [\ \t]+
         nl                         \n|\r\n|\r|\f
         w                          [\s]*
         nw                         (?=[\W]+|\A|\z|@)
         nonascii                   [^\0-\177]
         num                        -?([0-9]+|[0-9]*\.[0-9]+)
         unicode                    \\[0-9A-Fa-f]{1,6}(\r\n|[\s])?

         escape                     {unicode}|\\[^\n\r\f0-9A-Fa-f]
         nmchar                     [_A-Za-z0-9-]|{nonascii}|{escape}
         nmstart                    [_A-Za-z]|{nonascii}|{escape}
         ident                      [-@]?({nmstart})({nmchar})*
         name                       ({nmchar})+
         string1                    "([^\n\r\f"]|{nl}|{nonascii}|{escape})*"
         string2                    '([^\n\r\f']|{nl}|{nonascii}|{escape})*'
         string                     {string1}|{string2}


rule
         \#.*(?=\n?$)               { [:COMMENT, text] }

         {nw}(true|false){nw}       { [:TRUE_FALSE, text] }

         R(?=\[)                    { [:NUMREG, text] }
         P(?=\[)                    { [:POSITION, text] }
         PR(?=\[)                   { [:POSREG, text] }
         VR(?=\[)                   { [:VREG, text] }
         SR(?=\[)                   { [:SREG, text] }
         AR(?=\[)                   { [:ARG, text] }

         F(?=\[)                    { [:OUTPUT, text] }
         DO(?=\[)                   { [:OUTPUT, text] }
         RO(?=\[)                   { [:OUTPUT, text] }
         UO(?=\[)                   { [:OUTPUT, text] }
         SO(?=\[)                   { [:OUTPUT, text] }

         DI(?=\[)                   { [:INPUT, text] }
         RI(?=\[)                   { [:INPUT, text] }
         UI(?=\[)                   { [:INPUT, text] }
         SI(?=\[)                   { [:INPUT, text] }

         \=\=                       { [:EEQUAL, text] }
         \=                         { [:EQUAL, text] }
         \:\=                       { [:ASSIGN, text] }
         \<\>|\!\=                  { [:NOTEQUAL, text] }
         \>\=                       { [:GTE, text] }
         \<\=                       { [:LTE, text] }
         \<                         { [:LT, text] }
         \>                         { [:GT, text] }
         \+                         { [:PLUS, text] }
         \-                         { [:MINUS, text] }
         \*                         { [:STAR, text] }
         \/                         { [:SLASH, text] }
         DIV                        { [:DIV, text] }
         &&                         { [:AND, text] }
         \|\|                       { [:OR, text] }
         \%                         { [:MOD, text] }

         \@                         { @state = :label; [:AT_SYM, text] }
  :label [\w_0-9]+{nw}              { @state = nil; [:WORD, text] }


         {nw}set_uframe{nw}         { [:FANUC_SET, text] }
         {nw}set_skip_condition{nw} { [:FANUC_SET, text] }
         {nw}use_payload{nw}        { [:FANUC_USE, text] }
         {nw}use_uframe{nw}         { [:FANUC_USE, text] }
         {nw}use_utool{nw}          { [:FANUC_USE, text] }


         {nw}after{nw}              { [:AFTER, text] }
         {nw}at{nw}                 { [:AT, text] }
         {nw}case{nw}               { [:CASE, text] }
         {nw}circular_move{nw}      { [:MOVE, text] }
         {nw}else{nw}               { [:ELSE, text] }
         {nw}end{nw}                { [:END, text] }
         {nw}eval{nw}               { [:EVAL, text] }
         {nw}if{nw}                 { [:IF, text] }
         {nw}joint_move{nw}         { [:MOVE, text] }
         {nw}jump_to{nw}            { [:JUMP, text] }
         {nw}linear_move{nw}        { [:MOVE, text] }
         {nw}namespace{nw}          { [:NAMESPACE, text] }
         {nw}offset{nw}             { [:OFFSET, text] }
         {nw}position_register{nw}  { [:POSITION_REGISTER, text] }
         {nw}position{nw}           { [:POSITION, text] }
         {nw}skip_to{nw}            { [:SKIP, text] } 
         {nw}term{nw}               { [:TERM, text] }
         {nw}time_after{nw}         { [:TIME_SEGMENT, text] }
         {nw}time_before{nw}        { [:TIME_SEGMENT, text] }
         {nw}timeout_to{nw}         { [:TIMEOUT, text] }
         {nw}toggle{nw}             { [:IO_METHOD, text] }
         {nw}turn_on|turn_off{nw}   { [:IO_METHOD, text] }
         {nw}to{nw}                 { [:TO, text] }
         {nw}unless{nw}             { [:UNLESS, text] }
         {nw}wait_for{nw}           { [:WAIT_FOR, text] }
         {nw}wait_until{nw}         { [:WAIT_UNTIL, text] }
         {nw}when{nw}               { [:WHEN, text] }

         \r?\n                      { [:NEWLINE, text] }
         ;                          { [:SEMICOLON, text] }
         \d+\.\d+|\.\d+             { [:REAL, text.to_f] }
         \.                         { [:DOT, text] }
         \d+                        { [:DIGIT, text.to_i] }
         \!                         { [:BANG, text] }

         \s+                        # ignore whitespace
         [\w\?_]+                   { [:WORD, text] }
         {string}                   { [:STRING, text[1,text.length-2]] }
         .                          { [text, text] }
end
