require 'test_helper'

class TestInterpreter < Test::Unit::TestCase
  include TPPlus::Nodes

  def setup
    @scanner = TPPlus::Scanner.new
    @parser  = TPPlus::Parser.new @scanner
    @interpreter = @parser.interpreter
  end

  def parse(s)
    @scanner.scan_setup(s)
    @parser.parse
  end

  def last_node
    @last_node ||= @interpreter.nodes.last
  end

  def assert_node_type(t, n)
    assert_equal t, n.class
  end

  def assert_prog(s)
    assert_equal s, @interpreter.eval
  end

  def test_blank_prog
    parse("")
    assert_prog ""
  end

  def test_definition
    parse("foo := R[1]")
    assert_prog ""
  end

  def test_multi_define_fails
    parse("foo := R[1]\nfoo := R[2]")
    assert_raise(RuntimeError) do
      assert_prog ""
    end
  end

  def test_var_usage
    parse("foo := R[1]\nfoo = 1")
    assert_prog "R[1:foo]=1 ;\n"
  end

  def test_basic_addition
    parse("foo := R[1]\nfoo = 1 + 1")
    assert_prog "R[1:foo]=1+1 ;\n"
  end

  def test_basic_addition_with_var
    parse("foo := R[1]\n foo = foo + 1")
    assert_prog "R[1:foo]=R[1:foo]+1 ;\n"
  end

  def test_label_definition
    parse("@foo")
    assert_prog "LBL[100:foo] ;\n"
  end

  def test_duplicate_label_definition
    parse("@foo\n@foo")
    assert_raise RuntimeError do
      assert_prog ""
    end
  end

  def test_jump_to_label
    parse("@foo\njump_to @foo")
    assert_prog "LBL[100:foo] ;\nJMP LBL[100:foo] ;\n"
  end

  def test_nonexistent_label_error
    parse("jump_to @foo")
    assert_raise RuntimeError do
      assert_prog ""
    end
  end

  def test_turn_on
    parse("foo := DO[1]\nturn_on foo")
    assert_prog "DO[1:foo]=ON ;\n"
  end

  def test_turn_off
    parse("foo := DO[1]\nturn_off foo")
    assert_prog "DO[1:foo]=OFF ;\n"
  end

  def test_toggle
    parse("foo := DO[1]\ntoggle foo")
    assert_prog "DO[1:foo]=(!DO[1:foo]) ;\n"
  end

  def test_simple_linear_motion
    parse("foo := PR[1]\nlinear_move.to(foo).at(2000mm/s).term(0)")
    assert_prog "L PR[1:foo] 2000mm/sec CNT0 ;\n"
  end

  def test_simple_if
    parse("foo := R[1]\nif foo==1\nfoo=2\nend")
    assert_prog "IF (R[1:foo]=1),R[1:foo]=(2) ;\n"
  end

  def test_simple_if_else
    parse("foo := R[1]\nif foo==1\nfoo=2\nelse\nfoo=1\nend")
    assert_prog "IF R[1:foo]<>1,JMP LBL[100] ;\nR[1:foo]=2 ;\nJMP LBL[101] ;\nLBL[100] ;\nR[1:foo]=1 ;\nLBL[101] ;\n"
  end

  def test_simple_unless
    parse("foo := R[1]\nunless foo==1\nfoo=2\nend")
    assert_prog "IF (R[1:foo]<>1),R[1:foo]=(2) ;\n"
  end

  def test_simple_unless_else
    parse("foo := R[1]\nunless foo==1\nfoo=2\nelse\nfoo=1\nend")
    assert_prog "IF R[1:foo]=1,JMP LBL[100] ;\nR[1:foo]=2 ;\nJMP LBL[101] ;\nLBL[100] ;\nR[1:foo]=1 ;\nLBL[101] ;\n"
  end

  def test_comment
    parse("# this is a comment")
    assert_prog "! this is a comment ;\n"
  end

  def test_two_comments
    parse("# comment one\n# comment two")
    assert_prog "! comment one ;\n! comment two ;\n"
  end

  def test_inline_comment
    parse("foo := R[1] # comment\nfoo = 1 # another comment")
    assert_prog "! comment ;\nR[1:foo]=1 ;\n! another comment ;\n"
  end

  def test_inline_conditional_if_on_jump
    parse("foo := R[1]\n@bar\njump_to @bar if foo==1\n")
    assert_prog "LBL[100:bar] ;\nIF R[1:foo]=1,JMP LBL[100:bar] ;\n"
  end

  def test_inline_conditional_unless_on_jump
    parse("foo := R[1]\n@bar\njump_to @bar unless foo==1\n")
    assert_prog "LBL[100:bar] ;\nIF R[1:foo]<>1,JMP LBL[100:bar] ;\n"
  end

  def test_inline_assignment
    parse("foo := R[1]\nfoo=2 if foo==1\n")
    assert_prog "IF (R[1:foo]=1),R[1:foo]=(2) ;\n"
  end

  def test_inline_io_method
    parse("foo := DO[1]\nbar := R[1]\nturn_on foo if bar < 10\n")
   assert_prog "IF (R[1:bar]<10),DO[1:foo]=(ON) ;\n" 
  end

  def test_program_call
    parse("foo()")
    assert_prog "CALL FOO ;\n"
  end

  def test_program_call_with_simple_arg
    parse("foo(1)")
    assert_prog "CALL FOO(1) ;\n"
  end

  def test_program_call_with_multiple_simple_args
    parse("foo(1,2,3)")
    assert_prog "CALL FOO(1,2,3) ;\n"
  end

  def test_program_call_with_variable_argument
    parse("foo := R[1]\nbar(foo)")
    assert_prog "CALL BAR(R[1:foo]) ;\n"
  end

  def test_preserve_whitespace
    parse("\n\n")
    assert_prog " ;\n"
  end

  def test_plus_equals
    parse("foo := R[1]\nfoo += 1\n")
    assert_prog "R[1:foo]=R[1:foo]+1 ;\n"
  end

  def test_minus_equals
    parse("foo := R[1]\nfoo -= 1\n")
    assert_prog "R[1:foo]=R[1:foo]-1 ;\n"
  end

  def test_motion_to_a_position
    parse("foo := P[1]\nlinear_move.to(foo).at(2000mm/s).term(0)")
    assert_prog "L P[1:foo] 2000mm/sec CNT0 ;\n"
  end

  def test_fanuc_assignable_uframe
    parse("uframe_num = 5")
    assert_prog "UFRAME_NUM=5 ;\n"
  end

  def test_fanuc_assignable_utool
    parse("foo := R[1]\nutool_num = foo")
    assert_prog "UTOOL_NUM=R[1:foo] ;\n"
  end

  def test_pr_offset
    parse("home := P[1]\nmy_offset := PR[1]\nlinear_move.to(home).at(2000mm/s).term(0).offset(my_offset)")
    assert_prog "L P[1:home] 2000mm/sec CNT0 Offset,PR[1:my_offset] ;\n"
  end

  def test_vr_offset
    parse("home := P[1]\nvision_offset := VR[1]\nlinear_move.to(home).at(2000mm/s).term(0).offset(vision_offset)")
    assert_prog "L P[1:home] 2000mm/sec CNT0 VOFFSET,VR[1:vision_offset] ;\n"
  end

  def test_time_before
    parse("p := P[1]\nlinear_move.to(p).at(2000mm/s).term(0).time_before(0.5, foo())")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TB .50sec,CALL FOO ;\n"
  end

  def test_time_after
    parse("p := P[1]\nlinear_move.to(p).at(2000mm/s).term(0).time_after(0.5, foo())")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TA .50sec,CALL FOO ;\n"
  end

  def test_time_before_with_register_time
    parse("p := P[1]\nt := R[1]\nlinear_move.to(p).at(2000mm/s).term(0).time_before(t, foo())")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TB R[1:t]sec,CALL FOO ;\n"
  end

  def test_time_before_with_io_method
    parse("p := P[1]\nbar := DO[1]\nlinear_move.to(p).at(2000mm/s).term(0).time_before(0.5, turn_on bar)")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TB .50sec,DO[1:bar]=ON ;\n"
  end

end
