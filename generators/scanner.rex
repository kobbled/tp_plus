class TPPlus::Scanner

macro
  BLANK         [\ \t]+

rule
         BLANK

         ON             { [:ON_OFF, text] }
         OFF            { [:ON_OFF, text] }
         TRUE           { [:TRUE_FALSE, text] }
         FALSE          { [:TRUE_FALSE, text] }

         R(?=\[)        { [:NUMREG, text] }
         P(?=\[)        { [:POSITION, text] }
         PR(?=\[)       { [:POSREG, text] }
         VR(?=\[)       { [:VREG, text] }

         F(?=\[)        { [:OUTPUT, text] }
         DI(?=\[)       { [:INPUT, text] }
         DO(?=\[)       { [:OUTPUT, text] }
         RI(?=\[)       { [:INPUT, text] }
         RO(?=\[)       { [:OUTPUT, text] }
         UI(?=\[)       { [:INPUT, text] }

         \=             { [:EQUAL, text] }
         \<\>           { [:NOTEQUAL, text] }
         \>\=           { [:GTE, text] }
         \<\=           { [:LTE, text] }
         \<             { [:LT, text] }
         \>             { [:GT, text] }
         \+             { [:PLUS, text] }
         \-             { [:MINUS, text] }
         \*             { [:STAR, text] }
         \/             { [:SLASH, text] }
         DIV            { [:DIV, text] }
         AND            { [:AND, text] }
         OR             { [:OR, text] }


         # has to be below modified
         MOD            { [:MOD, text] }

         #\n             { [:NEWLINE, text] }
         ;              { [:SEMICOLON, text] }
         \d+\.\d+       { [:REAL, text.to_f] }
         \.\d+          { [:REAL, text.to_f] }
         \d+            { [:DIGIT, text.to_i] }

         \s+            # ignore whitespace
         [\w\!\?_]+     { [:WORD, text] }
         .              { [text, text] }
end
