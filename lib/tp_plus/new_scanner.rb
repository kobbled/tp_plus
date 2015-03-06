module TPPlus
  class NewScanner
    def initialize
      @src = ""
      @lineno = 1
      @ch = " "
      @offset = 0
      @rdOffset = 0

      self.next
    end

    def scan_setup(src)
      @src = src
      @lineno = 1
      @ch = " "
      @offset = 0
      @rdOffset = 0
      self.next
    end

    def next
      if @rdOffset < @src.length
        @offset = @rdOffset
        @ch = @src[@rdOffset]
        if @ch == "\n"
          @lineno += 1
        end
        @rdOffset += 1
      else
        @offset = @src.length
        @ch = -1
      end
    end

    def isDigit?(ch)
      return false if ch == -1

      true if Integer(ch) rescue false
    end

    LETTERS = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
               'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']


    def isLetter?(ch)
      LETTERS.include?(ch) || ch == '_'
    end

    def skipWhitespace
      while @ch == ' ' || @ch == "\t" || @ch == "\r"
        self.next
      end
    end

    def scanIdentifier
      offs = @offset
      while isLetter?(@ch)
        self.next
      end

      return @src[offs,(@offset-offs)]
    end

    def scanReal
      offs = @offset-1
      while self.isDigit?(@ch)
        self.next
      end

      return [:REAL, @src[offs,(@offset-offs)].to_f]
    end

    def scanNumber
      offs = @offset
      while self.isDigit?(@ch)
        self.next
      end
      if @ch == '.'
        self.next
        while self.isDigit?(@ch)
          self.next
        end

        return [:REAL, @src[offs,(@offset-offs)].to_f]
      else
        return [:DIGIT, @src[offs,(@offset-offs)].to_i]
      end
    end

    def scanComment
      offs = @offset-1 # opening # already consumed
      while @ch != "\n" && @ch != -1
        self.next
      end

      return @src[offs,(@offset-offs)]
    end

    def scanString(type)
      offs = @offset
      while @ch != type && @ch != -1
        self.next
      end

      return @src[offs, (@offset-offs)]
    end

    def scanLabel
      offs = @offset
      while self.isLetter?(@ch)
        self.next
      end

      return @src[offs, (@offset-offs)]
    end

    # return token
    def next_token
      self.skipWhitespace

      tok = nil
      lit = ""
      ch = @ch

      if isLetter?(ch)
        lit = self.scanIdentifier
        if @ch == '['
          tok = TPPlus::Token.lookup_data(lit)
        else
          if lit.length > 1
            # keywords are longer than 1 char, avoid lookup otherwise
            tok = TPPlus::Token.lookup(lit)
          else
            tok = :WORD
          end
        end
      elsif isDigit?(ch)
        tok, lit = self.scanNumber
      else
        self.next # always make progress
        case ch
        when -1
          tok = :EOF
        when '='
          if @ch == '='
            tok = :EEQUAL
          else
            tok = :EQUAL
          end
        when ':'
          if @ch == "="
            tok = :ASSIGN
          else
            tok = :COLON
          end
        when "<"
          if @ch == "="
            tok = :LTE
          elsif @ch == ">"
            tok = :NOTEQUAL
          else
            tok = :LT
          end
        when ">"
          if @ch == "="
            tok = :GTE
          else
            tok = :GT
          end
        when "+"
          tok = :PLUS
        when "-"
          tok = :MINUS
        when "*"
          tok = :STAR
        when "/"
          tok = :SLASH
        when "&"
          if @ch == "&"
            tok = :AND
          else
            tok = :ILLEGAL
          end
        when "|"
          if @ch == "|"
            tok = :OR
          else
            tok = :ILLEGAL
          end
        when "%"
          tok = :MOD
        when ";"
          tok = :SEMICOLON
        when "."
          if self.isDigit?(@ch)
            tok, lit = self.scanReal
          else
            tok = :DOT
          end
        when "!"
          if @ch == "="
            tok = :NOTEQUAL
          else
            tok = :BANG
          end
        when "\"", "'"
          tok = :STRING
          lit = self.scanString(ch)
        when "#"
          tok = :COMMENT
          lit = self.scanComment
        when "@"
          tok = :LABEL
          lit = self.scanLabel
        when '('
          tok = :LPAREN
        when ')'
          tok = :RPAREN
        when ','
          tok = :COMMA
        when '['
          tok = :LBRACK
        when ']'
          tok = :RBRACK
        when '{'
          tok = :LBRACE
        when '}'
          tok = :RBRACE
        when "\n"
          tok = :NEWLINE
        else
          tok = :ILLEGAL
          lit = ch
        end
      end

      return [tok, lit]
    end
  end

  class ScanError < StandardError ; end
end
