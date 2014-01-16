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

  def test_time_before
    parse("p := P[1]\nlinear_move.to(p).at(2000mm/s).term(0).time_before(0.1, foo())")
    assert_node_type MotionNode, last_node
  end

  def test_use_uframe
    parse("use_uframe 5")
    assert_node_type UseNode, last_node
  end

  def test_indirect_uframe
    parse("foo := R[1]\nuse_uframe foo")
    assert_node_type UseNode, last_node
  end

  def test_use_utool
    parse("use_utool 5")
    assert_node_type UseNode, last_node
  end

  def test_indirect_utool
    parse("foo := R[1]\nuse_utool foo")
    assert_node_type UseNode, last_node
  end

  def test_use_payload
    parse("use_payload 1")
    assert_node_type UseNode, last_node
  end

  def test_indirect_payload
    parse("foo := R[1]\nuse_payload foo")
    assert_node_type UseNode, last_node
  end

  def test_can_name_a_label_end
    parse("@end")
    assert_node_type LabelDefinitionNode, last_node
  end

  def test_wait_for_with_units
    parse("wait_for 5s")
    assert_node_type WaitForNode, last_node
  end

  def test_scan_wait_until
    parse("wait_until 1==0")
    assert_node_type WaitUntilNode, last_node
  end

  def test_scans_assignment_with_negative_number
    parse("foo := R[1]\nfoo = -1")
    assert_node_type AssignmentNode, last_node
  end

  def test_scans_simplest_case_statement
    parse("foo := R[1]\ncase foo\nwhen 1\njump_to @asdf\nend\n@asdf")
    assert_node_type CaseNode, @interpreter.nodes[@interpreter.nodes.length-3]
  end

  def test_scans_case_with_else
    parse("foo := R[1]\ncase foo\nwhen 1\njump_to @asdf\nelse\njump_to @ghjk\nend\n@asdf\n@ghjk")
    assert_node_type CaseNode, @interpreter.nodes[@interpreter.nodes.length-5]
  end

  def test_scans_two_cases
    parse("foo := R[1]\ncase foo\nwhen 1\njump_to @asdf\nwhen 2\njump_to @ghjk\nend\n@asdf\n@ghjk")
    assert_node_type CaseNode, @interpreter.nodes[@interpreter.nodes.length-5]
  end

  def test_case_can_use_a_var_as_a_condition
    parse("foo := R[1]\nbar := R[2]\ncase foo\nwhen bar\njump_to @asdf\nend\n@asdf")
    assert_node_type CaseNode, @interpreter.nodes[@interpreter.nodes.length-3]
  end

  def test_case_can_call_a_prog_as_an_action
    parse("foo := R[1]\ncase foo\nwhen 1\nmy_program()\nend\n@asdf")
    assert_node_type CaseNode, @interpreter.nodes[@interpreter.nodes.length-3]
  end

  def test_can_define_input
    parse("foo := UI[1]")
    assert_node_type DefinitionNode, last_node
  end

  def test_can_inline_conditional_just_io_value
    parse("foo := UI[5]\n@top\njump_to @top if foo")
    assert_node_type InlineConditionalNode, last_node
  end

  def test_inline_program_call
    parse("foo := UI[5]\nbar() unless foo")
    assert_node_type InlineConditionalNode, last_node
  end

  def test_constant_definition
    parse("FOO := 5\nfoo := R[1]\nfoo = FOO")
    assert_node_type DefinitionNode, @interpreter.nodes.first
  end

  def test_defining_arg_as_var
    parse("arg_1 := AR[1]")
    assert_node_type DefinitionNode, last_node
  end

  def test_fanuc_set_uframe_with_pr
    parse("foo := PR[1]\nset_uframe 5, foo")
    assert_node_type SetNode, last_node
  end

  def test_set_skip_condition
    parse("foo := RI[1]\nset_skip_condition foo.on?")
    assert_node_type SetNode, last_node
  end

  def test_skip_to
    parse("p := P[1]\n@somewhere\nlinear_move.to(p).at(2000mm/s).term(0).skip_to(@somewhere)")
    assert_node_type MotionNode, last_node
  end

  def test_skip_to_with_pr
    parse("p := P[1]\nlpos := PR[1]\n@somewhere\nlinear_move.to(p).at(2000mm/s).term(0).skip_to(@somewhere, lpos)")
    assert_node_type MotionNode, last_node
  end
end
