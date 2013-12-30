require 'test_helper'

class TestScanner < Test::Unit::TestCase
  def setup
    @scanner = TPPlus::Scanner.new
  end

  def assert_token(token, text)
    assert_equal [token,text], @scanner.next_token
  end

  def test_blank_string
    @scanner.scan_setup ""
    assert_nil @scanner.next_token
  end

  def test_ignore_whitespace
    @scanner.scan_setup " "
    assert_nil @scanner.next_token
  end

  def test_newline
    @scanner.scan_setup "\n"
    assert_token :NEWLINE, "\n"
  end

  def test_combine_newlines
    @scanner.scan_setup "\n\n"
    assert_token :NEWLINE, "\n\n"
  end

  def test_semicolon
    @scanner.scan_setup ";"
    assert_token :SEMICOLON,";"
  end

  def test_real_with_dot
    @scanner.scan_setup "3.14"
    assert_token :REAL, 3.14
  end

  def test_real_with_no_lead
    @scanner.scan_setup ".10"
    assert_token :REAL, 0.1
  end

  def test_digit
    @scanner.scan_setup "42"
    assert_token :DIGIT, 42
  end

  def test_true
    @scanner.scan_setup "true"
    assert_token :TRUE_FALSE, "true"
  end

  def test_false
    @scanner.scan_setup "false"
    assert_token :TRUE_FALSE, "false"
  end

  def test_numreg
    @scanner.scan_setup "R[42]"
    assert_token :NUMREG, "R"
  end

  def test_posreg
    @scanner.scan_setup "PR[42]"
    assert_token :POSREG, "PR"
  end

  def test_position
    @scanner.scan_setup "P[42]"
    assert_token :POSITION, "P"
  end

  def test_vreg
    @scanner.scan_setup "VR[1]"
    assert_token :VREG, "VR"
  end

  def test_sreg
    @scanner.scan_setup "SR[1]"
    assert_token :SREG, "SR"
  end

  def test_flag
    @scanner.scan_setup "F[1]"
    assert_token :OUTPUT, "F"
  end

  def test_di
    @scanner.scan_setup "DI[1]"
    assert_token :INPUT, "DI"
  end

  def test_do
    @scanner.scan_setup "DO[1]"
    assert_token :OUTPUT, "DO"
  end

  def test_ri
    @scanner.scan_setup "RI[1]"
    assert_token :INPUT, "RI"
  end

  def test_ro
    @scanner.scan_setup "RO[1]"
    assert_token :OUTPUT, "RO"
  end

  def test_ui
    @scanner.scan_setup "UI[1]"
    assert_token :INPUT, "UI"
  end

  def test_uo
    @scanner.scan_setup "UO[1]"
    assert_token :OUTPUT, "UO"
  end

  def test_si
    @scanner.scan_setup "SI[1]"
    assert_token :INPUT, "SI"
  end

  def test_so
    @scanner.scan_setup "SO[1]"
    assert_token :OUTPUT, "SO"
  end

  def test_equal
    @scanner.scan_setup "="
    assert_token :EQUAL, "="
  end

  def test_not_equal
    @scanner.scan_setup "<>"
    assert_token :NOTEQUAL, "<>"
    @scanner.scan_setup "!="
    assert_token :NOTEQUAL, "!="
  end

  def test_eequal
    @scanner.scan_setup "=="
    assert_token :EEQUAL, "=="
  end

  def test_gte
    @scanner.scan_setup ">="
    assert_token :GTE, ">="
  end

  def test_lte
    @scanner.scan_setup "<="
    assert_token :LTE, "<="
  end

  def test_lt
    @scanner.scan_setup "<"
    assert_token :LT, "<"
  end

  def test_gt
    @scanner.scan_setup ">"
    assert_token :GT, ">"
  end

  def test_plus
    @scanner.scan_setup "+"
    assert_token :PLUS, "+"
  end

  def test_minus
    @scanner.scan_setup "-"
    assert_token :MINUS, "-"
  end

  def test_star
    @scanner.scan_setup "*"
    assert_token :STAR, "*"
  end

  def test_slash
    @scanner.scan_setup "/"
    assert_token :SLASH, "/"
  end

  def test_and
    @scanner.scan_setup "&&"
    assert_token :AND, "&&"
  end

  def test_or
    @scanner.scan_setup "||"
    assert_token :OR, "||"
  end

  def test_mod
    @scanner.scan_setup "%"
    assert_token :MOD, "%"
  end

  def test_comment
    @scanner.scan_setup "# foo"
    assert_token :COMMENT, "# foo"
  end

  def test_assign
    @scanner.scan_setup ":="
    assert_token :ASSIGN, ":="
  end

  def test_at_sym
    @scanner.scan_setup "@"
    assert_token :AT_SYM, "@"
  end

  def test_jump_to
    @scanner.scan_setup "jump_to"
    assert_token :JUMP, "jump_to"
  end

  def test_turn_on
    @scanner.scan_setup "turn_on"
    assert_token :IO_METHOD, "turn_on"
  end

  def test_turn_off
    @scanner.scan_setup "turn_off"
    assert_token :IO_METHOD, "turn_off"
  end

  def test_toggle
    @scanner.scan_setup "toggle"
    assert_token :IO_METHOD, "toggle"
  end

  def test_linear_move
    @scanner.scan_setup "linear_move"
    assert_token :MOVE, "linear_move"
  end

  def test_joint_move
    @scanner.scan_setup "joint_move"
    assert_token :MOVE, "joint_move"
  end

  def test_circular_move
    @scanner.scan_setup "circular_move"
    assert_token :MOVE, "circular_move"
  end

  def test_dot
    @scanner.scan_setup "."
    assert_token :DOT, "."
  end

  def test_to
    @scanner.scan_setup "to"
    assert_token :TO, "to"
  end

  def test_at
    @scanner.scan_setup "at"
    assert_token :AT, "at"
  end

   def test_term
     @scanner.scan_setup "term"
     assert_token :TERM, "term"
   end
end
