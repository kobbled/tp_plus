require 'test_helper'

class TestParser < Test::Unit::TestCase
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

  def test_minimum_prog
    parse("")
  end

  def blank_prog
    parse("\n\n\n\n\n")
  end

  def test_comment
    parse("# foo")
    assert_node_type CommentNode, last_node
  end

  def test_numreg_definition
    parse("foo := R[1]")
    assert_node_type DefinitionNode, last_node
  end

  def test_assignment
    parse("foo = 1")
    assert_node_type AssignmentNode, last_node
  end

  def test_label_definition
    parse("@foo")
    assert_node_type LabelDefinitionNode, last_node
  end

  def test_jump_to
    parse("@foo\njump_to @foo")
    assert_node_type JumpNode, last_node
  end

  def test_plus_equal
    parse("foo += 1")
    l = last_node
    assert_node_type AssignmentNode, l
    assert_node_type VarNode, l.identifier
    assert_node_type ExpressionNode, l.assignable
    assert_node_type VarNode, l.assignable.left_op
  end

  def test_minus_equal
    parse("foo -= 1")
    l = last_node
    assert_node_type AssignmentNode, l
    assert_node_type VarNode, l.identifier
    assert_node_type ExpressionNode, l.assignable
    assert_node_type VarNode, l.assignable.left_op
  end

  def test_turn_on
    parse("turn_on foo")
    assert_node_type IOMethodNode, last_node
  end

  def test_turn_off
    parse("turn_off foo")
    assert_node_type IOMethodNode, last_node
  end

  def test_toggle
    parse("toggle foo")
    assert_node_type IOMethodNode, last_node
  end

  def test_motion
    parse("linear_move.to(home).at(2000mm/s).term(0)")
    assert_node_type MotionNode, last_node
  end

  def test_simple_if
    parse("if 1==1 \n\n\njump_to @foo\nend")
    assert_node_type ConditionalNode, last_node
  end

  def test_if_with_else
    parse("if 1==1 \n\n\njump_to @foo\n else \n# something\nend")
    assert_node_type ConditionalNode, last_node
  end

  def test_simple_unless
    parse("unless 1==1\njump_to @foo\nend")
    assert_node_type ConditionalNode, last_node
  end

  def test_inline_if
    parse("jump_to @foo if foo < 10")
    assert_node_type InlineConditionalNode, last_node
  end

  def test_inline_if_assignment
    parse("foo = 1 if foo < 10")
    assert_node_type InlineConditionalNode, last_node
  end

  def test_inline_io_method
    parse("turn_on foo if bar < 10")
    assert_node_type InlineConditionalNode, last_node
  end

  def test_prog_call
    parse("foo()")
    assert_node_type CallNode, last_node
  end

  def test_prog_call_with_an_arg
    parse("foo(1)")
    l = last_node
    assert_node_type CallNode, l
    assert_equal 1, l.args.length
  end

  def test_prog_call_with_multiple_args
    parse("foo(1,2,3)")
    l = last_node
    assert_equal 3, l.args.length
  end

  def test_prog_call_with_variable_arg
    parse("foo(bar)")
    assert_node_type CallNode, last_node
  end

  def test_position_definition
    parse("foo := P[1]")
    assert_node_type DefinitionNode, last_node
  end

  def test_uframe_assignment
    parse("uframe_num = 5")
    assert_node_type AssignmentNode, last_node
  end

  def test_utool_assignment
    parse("utool_num = 5")
    assert_node_type AssignmentNode, last_node
  end

  def test_offset
    parse("foo := P[1]\nbar := PR[1]\nlinear_move.to(foo).at(2000mm/s).term(0).offset(bar)")
    assert_node_type MotionNode, last_node
  end

  def test_vr_offset
    parse("foo := P[1]\nbar := VR[1]\nlinear_move.to(foo).at(2000mm/s).term(0).offset(bar)")
    assert_node_type MotionNode, last_node
  end
end
