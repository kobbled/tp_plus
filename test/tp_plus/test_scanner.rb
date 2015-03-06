require 'test_helper'

class TestScanner < Test::Unit::TestCase
  def setup
    @scanner = TPPlus::NewScanner.new
  end

  def assert_tok(token)
    assert_token(token, nil)
  end

  def assert_token(token, text)
    if text
      assert_equal [token,text], @scanner.next_token
    else
      assert_equal token, @scanner.next_token[0]
    end
  end

  def test_blank_string
    @scanner.scan_setup ""
    assert_tok :EOF
  end

  def test_ignore_whitespace
    @scanner.scan_setup " "
    assert_tok :EOF
  end

  def test_newline
    @scanner.scan_setup "\n"
    assert_tok :NEWLINE
  end

  def test_no_combine_newlines
    @scanner.scan_setup "\n\n"
    assert_tok :NEWLINE
    assert_tok :NEWLINE
  end

  def test_semicolon
    @scanner.scan_setup ";"
    assert_tok :SEMICOLON
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

  def test_label
    @scanner.scan_setup "@foo"
    assert_token :LABEL, "foo"
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

  def test_timer
    @scanner.scan_setup "TIMER[1]"
    assert_token :TIMER, "TIMER"
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
    assert_tok :EQUAL
  end

  def test_not_equal
    @scanner.scan_setup "<>"
    assert_tok :NOTEQUAL
    @scanner.scan_setup "!="
    assert_tok :NOTEQUAL
  end

  def test_eequal
    @scanner.scan_setup "=="
    assert_tok :EEQUAL
  end

  def test_gte
    @scanner.scan_setup ">="
    assert_tok :GTE
  end

  def test_lte
    @scanner.scan_setup "<="
    assert_tok :LTE
  end

  def test_lt
    @scanner.scan_setup "<"
    assert_tok :LT
  end

  def test_gt
    @scanner.scan_setup ">"
    assert_tok :GT
  end

  def test_plus
    @scanner.scan_setup "+"
    assert_tok :PLUS
  end

  def test_minus
    @scanner.scan_setup "-"
    assert_tok :MINUS
  end

  def test_star
    @scanner.scan_setup "*"
    assert_tok :STAR
  end

  def test_slash
    @scanner.scan_setup "/"
    assert_tok :SLASH
  end

  def test_and
    @scanner.scan_setup "&&"
    assert_tok :AND
  end

  def test_or
    @scanner.scan_setup "||"
    assert_tok :OR
  end

  def test_mod
    @scanner.scan_setup "%"
    assert_tok :MOD
  end

  def test_comment
    @scanner.scan_setup "# foo"
    assert_token :COMMENT, "# foo"
  end

  def test_assign
    @scanner.scan_setup ":="
    assert_tok :ASSIGN
  end

  #def test_at_sym
  #  @scanner.scan_setup "@"
  #  assert_token :AT_SYM, "@"
  #end

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
    assert_tok :DOT
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

   def test_if
     @scanner.scan_setup "if"
     assert_token :IF, "if"
   end

   def test_else
     @scanner.scan_setup "else"
     assert_token :ELSE, "else"
   end

   def test_end
     @scanner.scan_setup "end"
     assert_token :END, "end"
   end

   def test_unless
     @scanner.scan_setup "unless"
     assert_token :UNLESS, "unless"
   end

   def test_carriage_return_newline_as_one
     @scanner.scan_setup "\r\n"
     assert_tok :NEWLINE
   end

   def test_use_uframe
     @scanner.scan_setup "use_uframe"
     assert_token :FANUC_USE, "use_uframe"
   end

   def test_use_utool
     @scanner.scan_setup "use_utool"
     assert_token :FANUC_USE, "use_utool"
   end

   def test_use_payload
     @scanner.scan_setup "use_payload"
     assert_token :FANUC_USE, "use_payload"
   end

   def test_offset
     @scanner.scan_setup "offset"
     assert_token :OFFSET, "offset"
   end

   def test_time_before
     @scanner.scan_setup "time_before"
     assert_token :TIME_SEGMENT, "time_before"
   end

   def test_time_after
     @scanner.scan_setup "time_after"
     assert_token :TIME_SEGMENT, "time_after"
   end

   def test_word_with_end_in_it
     @scanner.scan_setup "end_zone"
     assert_token :WORD, "end_zone"
   end

   def test_scan_wait_for
     @scanner.scan_setup "wait_for"
     assert_token :WAIT_FOR, "wait_for"
   end

   def test_scan_wait_until
     @scanner.scan_setup "wait_until"
     assert_token :WAIT_UNTIL, "wait_until"
   end

   def test_scan_case
     @scanner.scan_setup "case"
     assert_token :CASE, "case"
   end

   def test_scan_when
     @scanner.scan_setup "when"
     assert_token :WHEN, "when"
   end

   def test_scan_argument
     @scanner.scan_setup "AR[1]"
     assert_token :ARG, "AR"
   end

   def test_scan_set_uframe
     @scanner.scan_setup "set_uframe"
     assert_token :FANUC_SET, "set_uframe"
   end

   def test_scan_set_skip_condition
     @scanner.scan_setup "set_skip_condition"
     assert_token :FANUC_SET, "set_skip_condition"
   end

   def test_scan_skip_to
     @scanner.scan_setup "skip_to"
     assert_token :SKIP, "skip_to"
   end

   def test_scans_bang_separate_from_word
     @scanner.scan_setup "!foo"
     assert_tok :BANG
     assert_token :WORD, "foo"
   end

   def test_timeout_to
     @scanner.scan_setup "timeout_to"
     assert_token :TIMEOUT, "timeout_to"
   end

   def test_after
     @scanner.scan_setup "after"
     assert_token :AFTER, "after"
   end

   def test_scanning_single_quoted_string
     @scanner.scan_setup "'string'"
     assert_token :STRING, "string"
   end

   def test_scanning_double_quoted_string
     @scanner.scan_setup '"string"'
     assert_token :STRING, "string"
   end

   def test_scan_namespace
     @scanner.scan_setup "namespace"
     assert_token :NAMESPACE, "namespace"
   end

   def test_scan_eval
     @scanner.scan_setup "eval"
     assert_token :EVAL, "eval"
   end

   def test_scan_for
     @scanner.scan_setup "for"
     assert_token :FOR, "for"
   end

   def test_scan_in
     @scanner.scan_setup "in"
     assert_token :IN, "in"
   end

   def test_scan_indirect
     @scanner.scan_setup "indirect"
     assert_token :INDIRECT, "indirect"
   end

   def test_scan_while
     @scanner.scan_setup "while"
     assert_token :WHILE, "while"
   end

   def test_start
     @scanner.scan_setup "start"
     assert_token :TIMER_METHOD, "start"
   end

   def test_stop
     @scanner.scan_setup "stop"
     assert_token :TIMER_METHOD, "stop"
   end

   def test_reset
     @scanner.scan_setup "reset"
     assert_token :TIMER_METHOD, "reset"
   end

   def test_restart
     @scanner.scan_setup "restart"
     assert_token :TIMER_METHOD, "restart"
   end

   def test_position_data
     @scanner.scan_setup "position_data"
     assert_token :POSITION_DATA, "position_data"
   end

   def test_pulse
     @scanner.scan_setup "pulse"
     assert_token :IO_METHOD, "pulse"
   end

   def test_scan_ualm
     @scanner.scan_setup "UALM[1]"
     assert_token :UALM, "UALM"
   end

   def test_scan_raise
     @scanner.scan_setup "raise"
     assert_token :RAISE, "raise"
   end

   def test_scan_run
     @scanner.scan_setup "run"
     assert_token :RUN, "run"
   end

   def test_tp_ignore_pause
     @scanner.scan_setup "TP_IGNORE_PAUSE"
     assert_token :TP_HEADER, "TP_IGNORE_PAUSE"
   end

   def test_tp_comment
     @scanner.scan_setup "TP_COMMENT"
     assert_token :TP_HEADER, "TP_COMMENT"
   end

   def test_tp_groupmask
     @scanner.scan_setup "TP_GROUPMASK"
     assert_token :TP_HEADER, "TP_GROUPMASK"
   end

   def test_tp_subtype
     @scanner.scan_setup "TP_SUBTYPE"
     assert_token :TP_HEADER, "TP_SUBTYPE"
   end

   def test_tool_offset
     @scanner.scan_setup "tool_offset to toff"
     assert_token :OFFSET, "tool_offset"
     assert_token :TO, "to"
     assert_token :WORD, "toff"
   end

   def test_vision_offset
     @scanner.scan_setup "vision_offset"
     assert_token :OFFSET, "vision_offset"
   end

   def test_pause
     @scanner.scan_setup "pause"
     assert_token :PAUSE, "pause"
   end

   def test_abort
     @scanner.scan_setup "abort"
     assert_token :ABORT, "abort"
   end

   def test_punctuation
     pairs = [
       ['(', :LPAREN],
       [')', :RPAREN],
       ['[', :LBRACK],
       [']', :RBRACK],
       ['{', :LBRACE],
       ['}', :RBRACE],
       [',', :COMMA],
       [':', :COLON]
     ]

     pairs.each do |pair|
       @scanner.scan_setup pair[0]
       assert_tok pair[1]
     end
   end
end
