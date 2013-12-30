class TPPlus::Scanner

option
  ignorecase

macro
  BLANK         [\ \t]+

rule
         BLANK

         \#.*(?=\n?$)  { [:COMMENT, text] }

         true|false     { [:TRUE_FALSE, text] }

         R(?=\[)        { [:NUMREG, text] }
         P(?=\[)        { [:POSITION, text] }
         PR(?=\[)       { [:POSREG, text] }
         VR(?=\[)       { [:VREG, text] }
         SR(?=\[)       { [:SREG, text] }

         F|DO|RO|UO|SO(?=\[) { [:OUTPUT, text] }
         DI|RI|UI|SI(?=\[)   { [:INPUT, text] }

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
         \@             { [:AT_SYM, text] }


         at             { [:AT, text] }
         jump_to        { [:JUMP, text] }
         linear_move|joint_move|circular_move { [:MOVE, text] }
         term           { [:TERM, text] }
         turn_on|turn_off|toggle { [:IO_METHOD, text] }
         to             { [:TO, text] }

         \n+            { [:NEWLINE, text] }
         ;              { [:SEMICOLON, text] }
         \d+\.\d+|\.\d+ { [:REAL, text.to_f] }
         \.             { [:DOT, text] }
         \d+            { [:DIGIT, text.to_i] }

         \s+            # ignore whitespace
         [\w\!\?_]+     { [:WORD, text] }
         .              { [text, text] }
end
