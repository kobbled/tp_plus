class TPPlus::Scanner

option
  ignorecase

macro
  blank     [\ \t]+
  nl        \n|\r\n|\r|\f
  w         [\s]*
  nw        (?=[\W]+|\A|\z|@)
  nonascii  [^\0-\177]
  num       -?([0-9]+|[0-9]*\.[0-9]+)
  unicode   \\[0-9A-Fa-f]{1,6}(\r\n|[\s])?

  escape    {unicode}|\\[^\n\r\f0-9A-Fa-f]
  nmchar    [_A-Za-z0-9-]|{nonascii}|{escape}
  nmstart   [_A-Za-z]|{nonascii}|{escape}
  ident     [-@]?({nmstart})({nmchar})*
  name      ({nmchar})+
  string1   "([^\n\r\f"]|{nl}|{nonascii}|{escape})*"
  string2   '([^\n\r\f']|{nl}|{nonascii}|{escape})*'
  string    {string1}|{string2}


rule
         \#.*(?=\n?$)  { [:COMMENT, text] }

         {nw}(true|false){nw}     { [:TRUE_FALSE, text] }

         R(?=\[)        { [:NUMREG, text] }
         P(?=\[)        { [:POSITION, text] }
         PR(?=\[)       { [:POSREG, text] }
         VR(?=\[)       { [:VREG, text] }
         SR(?=\[)       { [:SREG, text] }

         F(?=\[)        { [:OUTPUT, text] }
         DO(?=\[)       { [:OUTPUT, text] }
         RO(?=\[)       { [:OUTPUT, text] }
         UO(?=\[)       { [:OUTPUT, text] }
         SO(?=\[)       { [:OUTPUT, text] }

         DI(?=\[)       { [:INPUT, text] }
         RI(?=\[)       { [:INPUT, text] }
         UI(?=\[)       { [:INPUT, text] }
         SI(?=\[)       { [:INPUT, text] }

         \=\=           { [:EEQUAL, text] }
         \=             { [:EQUAL, text] }
         \:\=           { [:ASSIGN, text] }
         \<\>|\!\=      { [:NOTEQUAL, text] }
         \>\=           { [:GTE, text] }
         \<\=           { [:LTE, text] }
         \<             { [:LT, text] }
         \>             { [:GT, text] }
         \+             { [:PLUS, text] }
         \-             { [:MINUS, text] }
         \*             { [:STAR, text] }
         \/             { [:SLASH, text] }
         DIV            { [:DIV, text] }
         &&             { [:AND, text] }
         \|\|           { [:OR, text] }
         \%             { [:MOD, text] }

         \@             { @state = :label; [:AT_SYM, text] }
  :label [\w_0-9]+{nw}      { @state = nil; [:WORD, text] }


         {nw}use_payload{nw}    { [:FANUC_USE, text] }
         {nw}use_uframe{nw}     { [:FANUC_USE, text] }
         {nw}use_utool{nw}      { [:FANUC_USE, text] }


         {nw}at{nw}     { [:AT, text] }
         {nw}case{nw}   { [:CASE, text] }
         {nw}else{nw}   { [:ELSE, text] }
         {nw}end{nw}    { [:END, text] }
         {nw}if{nw}     { [:IF, text] }
         {nw}jump_to{nw}  { [:JUMP, text] }
         {nw}linear_move|joint_move|circular_move{nw} { [:MOVE, text] }
         {nw}max_speed{nw}      { [:MAX_SPEED, text] }
         {nw}offset{nw} { [:OFFSET, text] }
         {nw}term{nw}   { [:TERM, text] }
         {nw}time_before|time_after{nw}  { [:TIME_SEGMENT, text] }
         {nw}turn_on|turn_off|toggle{nw} { [:IO_METHOD, text] }
         {nw}to{nw}     { [:TO, text] }
         {nw}unless{nw} { [:UNLESS, text] }
         {nw}wait_for{nw} { [:WAIT_FOR, text] }
         {nw}wait_until{nw} { [:WAIT_UNTIL, text] }
         {nw}when{nw}   { [:WHEN, text] }

         \r?\n          { [:NEWLINE, text] }
         ;              { [:SEMICOLON, text] }
         \d+\.\d+|\.\d+ { [:REAL, text.to_f] }
         \.             { [:DOT, text] }
         \d+            { [:DIGIT, text.to_i] }
         mm\/s          { [:UNITS, text] }

         \s+            # ignore whitespace
         [\w\!\?_]+     { [:WORD, text] }
         .              { [text, text] }
end
