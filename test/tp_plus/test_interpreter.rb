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
    assert_prog "LBL[100:foo] ;\nJMP LBL[100] ;\n"
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
    parse("foo := PR[1]\nlinear_move.to(foo).at(2000, 'mm/s').term(0)")
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
    assert_prog "LBL[100:bar] ;\nIF R[1:foo]=1,JMP LBL[100] ;\n"
  end

  def test_inline_conditional_unless_on_jump
    parse("foo := R[1]\n@bar\njump_to @bar unless foo==1\n")
    assert_prog "LBL[100:bar] ;\nIF R[1:foo]<>1,JMP LBL[100] ;\n"
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
    parse("foo := P[1]\nlinear_move.to(foo).at(2000, 'mm/s').term(0)")
    assert_prog "L P[1:foo] 2000mm/sec CNT0 ;\n"
  end

  def test_joint_move
    parse("foo := P[1]\njoint_move.to(foo).at(100, '%').term(0)")
    assert_prog "J P[1:foo] 100% CNT0 ;\n"
  end

  def test_joint_move_throws_error_with_bad_units
    parse("foo := P[1]\njoint_move.to(foo).at(2000, 'mm/s').term(0)")
    assert_raise(RuntimeError) do
      assert_prog "J P[1:foo] 100% CNT0 ;\n"
    end
  end

  def test_linear_move_throws_error_with_bad_units
    parse("foo := P[1]\nlinear_move.to(foo).at(100, '%').term(0)")
    assert_raise(RuntimeError) do
      assert_prog "L P[1:foo] 100% CNT0 ;\n"
    end
  end


  def test_pr_offset
    parse("home := P[1]\nmy_offset := PR[1]\nlinear_move.to(home).at(2000, 'mm/s').term(0).offset(my_offset)")
    assert_prog "L P[1:home] 2000mm/sec CNT0 Offset,PR[1:my_offset] ;\n"
  end

  def test_vr_offset
    parse("home := P[1]\nvoff := VR[1]\nlinear_move.to(home).at(2000, 'mm/s').term(0).vision_offset(voff)")
    assert_prog "L P[1:home] 2000mm/sec CNT0 VOFFSET,VR[1:voff] ;\n"
  end

  def test_time_before
    parse("p := P[1]\nlinear_move.to(p).at(2000, 'mm/s').term(0).time_before(0.5, foo())")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TB .50sec,CALL FOO ;\n"
  end

  def test_time_after
    parse("p := P[1]\nlinear_move.to(p).at(2000, 'mm/s').term(0).time_after(0.5, foo())")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TA .50sec,CALL FOO ;\n"
  end

  def test_time_before_with_register_time
    parse("p := P[1]\nt := R[1]\nlinear_move.to(p).at(2000, 'mm/s').term(0).time_before(t, foo())")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TB R[1:t]sec,CALL FOO ;\n"
  end

  def test_time_before_with_io_method
    parse("p := P[1]\nbar := DO[1]\nlinear_move.to(p).at(2000, 'mm/s').term(0).time_before(0.5, turn_on bar)")
    assert_prog "L P[1:p] 2000mm/sec CNT0 TB .50sec,DO[1:bar]=ON ;\n"
  end

  def test_motion_with_indirect_termination
    parse("p := P[1]\ncnt := R[1]\nlinear_move.to(p).at(2000, 'mm/s').term(cnt)")
    assert_prog "L P[1:p] 2000mm/sec CNT R[1:cnt] ;\n"
  end

  def test_motion_with_indirect_speed
    parse("p := P[1]\nspeed := R[1]\nlinear_move.to(p).at(speed, 'mm/s').term(0)")
    assert_prog "L P[1:p] R[1:speed]mm/sec CNT0 ;\n"
  end

  def test_motion_with_max_speed
    parse("p := P[1]\nlinear_move.to(p).at('max_speed').term(0)")
    assert_prog "L P[1:p] max_speed CNT0 ;\n"
  end

  def test_use_uframe
    parse("use_uframe 5")
    assert_prog "UFRAME_NUM=5 ;\n"
  end

  def test_indirect_uframe
    parse("foo := R[1]\nuse_uframe foo")
    assert_prog "UFRAME_NUM=R[1:foo] ;\n"
  end

  def test_use_utool
    parse("use_utool 5")
    assert_prog "UTOOL_NUM=5 ;\n"
  end

  def test_indirect_utool
    parse("foo := R[1]\nuse_utool foo")
    assert_prog "UTOOL_NUM=R[1:foo] ;\n"
  end

  def test_payload
    parse("use_payload 1")
    assert_prog "PAYLOAD[1] ;\n"
  end

  def test_indirect_payload
    parse("foo := R[1]\nuse_payload foo")
    assert_prog "PAYLOAD[R[1:foo]] ;\n"
  end

  def test_nested_conditionals
    parse("foo := R[1]\nif foo==1\nif foo==2\nfoo=3\nelse\nfoo=4\nend\nend")
    assert_prog "IF R[1:foo]<>1,JMP LBL[100] ;\nIF R[1:foo]<>2,JMP LBL[101] ;\nR[1:foo]=3 ;\nJMP LBL[102] ;\nLBL[101] ;\nR[1:foo]=4 ;\nLBL[102] ;\nLBL[100] ;\n"
  end

  def test_inline_unless
    parse("foo := R[1]\n@bar\njump_to @bar unless foo > 1")
    assert_prog "LBL[100:bar] ;\nIF R[1:foo]<=1,JMP LBL[100] ;\n"
  end

  def test_inline_unless_with_two_vars
    parse("foo := R[1]\nbar := R[2]\n@baz\njump_to @baz unless foo > bar")
    assert_prog "LBL[100:baz] ;\nIF R[1:foo]<=R[2:bar],JMP LBL[100] ;\n"
  end

  def test_labels_can_be_defined_after_jumps_to_them
    parse("jump_to @foo\n@foo")
    assert_prog "JMP LBL[100] ;\nLBL[100:foo] ;\n"
  end

  def test_multiple_motion_modifiers
    parse("p := P[1]\no := PR[1]\nlinear_move.to(p).at('max_speed').term(0).offset(o).time_before(0.5,foo())")
    assert_prog "L P[1:p] max_speed CNT0 Offset,PR[1:o] TB .50sec,CALL FOO ;\n"
  end

  def test_motion_modifiers_swallow_terminators_after_dots
    parse("p := P[1]\no := PR[1]\nlinear_move.\nto(p).\nat('max_speed').\nterm(0).\noffset(o).\ntime_before(0.5,foo())")
    assert_prog "L P[1:p] max_speed CNT0 Offset,PR[1:o] TB .50sec,CALL FOO ;\n"
  end

  def test_wait_for_with_seconds
    parse("wait_for(5,'s')")
    assert_prog "WAIT 5.00(sec) ;\n"
  end

  def test_wait_for_with_invalid_units_throws_error
    parse("wait_for(5,'ns')")
    assert_raise(RuntimeError) do
      assert_prog ""
    end
  end

  def test_wait_for_with_milliseconds
    parse("wait_for(100,'ms')")
    assert_prog "WAIT .10(sec) ;\n"
  end

  def test_wait_for_with_indirect_seconds
    parse "foo := R[1]\nwait_for(foo, 's')"
    assert_prog "WAIT R[1:foo] ;\n"
  end

  def test_wait_for_with_indirect_ms
    parse "foo := R[1]\nwait_for(foo, 'ms')"
    assert_raise(RuntimeError) do
      assert_prog ""
    end
  end

  def test_wait_until_with_exp
    parse("wait_until(1==0)")
    assert_prog "WAIT (1=0) ;\n"
  end

  def test_wait_until_with_flag
    parse("foo := F[1]\nwait_until(foo)")
    assert_prog "WAIT (F[1:foo]) ;\n"
  end

  def test_wait_until_with_di
    parse("foo := DI[1]\nwait_until(foo)")
    assert_prog "WAIT (DI[1:foo]) ;\n"
  end

  def test_wait_until_with_boolean
    parse("foo := DI[1]\nbar := DI[2]\nwait_until(foo && bar)")
    assert_prog "WAIT (DI[1:foo] AND DI[2:bar]) ;\n"
  end

  def test_wait_until_with_timeout_to
    parse("wait_until(1==0).timeout_to(@end)\n@end")
    assert_prog "WAIT (1=0) TIMEOUT,LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_wait_until_with_timeout_to_and_after
    parse("wait_until(1==0).timeout_to(@end).after(1, 's')\n@end")
    assert_prog "$WAITTMOUT=(100) ;\nWAIT (1=0) TIMEOUT,LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_wait_until_after_ms
    parse("wait_until(1==0).timeout_to(@end).after(1000, 'ms')\n@end")
    assert_prog "$WAITTMOUT=(100) ;\nWAIT (1=0) TIMEOUT,LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_wait_until_after_indirect
    parse("foo := R[1]\nwait_until(1==0).timeout_to(@end).after(foo, 's')\n@end")
    assert_prog "$WAITTMOUT=(R[1:foo]*100) ;\nWAIT (1=0) TIMEOUT,LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_wait_until_with_constant
    parse("WAIT := 5\nwait_until(1==0).timeout_to(@end).after(WAIT, 's')\n@end")
    assert_prog "$WAITTMOUT=(5*100) ;\nWAIT (1=0) TIMEOUT,LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_pr_components
    parse("foo := PR[1]\nfoo.x=5\nfoo.y=6\nfoo.z=7\nfoo.w=8\nfoo.p=9\nfoo.r=10\n")
    assert_prog "PR[1,1:foo]=5 ;\nPR[1,2:foo]=6 ;\nPR[1,3:foo]=7 ;\nPR[1,4:foo]=8 ;\nPR[1,5:foo]=9 ;\nPR[1,6:foo]=10 ;\n"
  end

  def test_pr_with_invalid_component_raises_error
    parse("foo := PR[1]\nfoo.bar=5\n")
    assert_raise(RuntimeError) do
      assert_prog ""
    end
  end

  def test_simple_case_statement
    parse("foo := R[1]\ncase foo\nwhen 1\njump_to @asdf\nend\n@asdf")
    assert_prog %(SELECT R[1:foo]=1,JMP LBL[100] ;\nLBL[100:asdf] ;\n)
  end

  def test_simple_case_with_else_statement
    parse("foo := R[1]\ncase foo\nwhen 1\njump_to @asdf\nelse\njump_to @ghjk\nend\n@asdf\n@ghjk")
    assert_prog %(SELECT R[1:foo]=1,JMP LBL[100] ;
       ELSE,JMP LBL[101] ;
LBL[100:asdf] ;
LBL[101:ghjk] ;\n)
  end

  def test_case_statement_with_two_whens
    parse("foo := R[1]\ncase foo\nwhen 1\njump_to @asdf\nwhen 2\njump_to @ghjk\nend\n@asdf\n@ghjk")
    assert_prog %(SELECT R[1:foo]=1,JMP LBL[100] ;
       =2,JMP LBL[101] ;
LBL[100:asdf] ;
LBL[101:ghjk] ;\n)
  end

  def test_case_statement_with_three_whens
    parse("foo := R[1]\ncase foo\nwhen 1\nbar()\nwhen 2\nbar()\nwhen 3\nbar()\nend")
    assert_prog %(SELECT R[1:foo]=1,CALL BAR ;
       =2,CALL BAR ;
       =3,CALL BAR ;\n)
  end

  def test_case_statement_with_three_whens_and_else
    parse("foo := R[1]\ncase foo\nwhen 1\nbar()\nwhen 2\nbar()\nwhen 3\nbar()\nelse\nbar()\nend")
    assert_prog %(SELECT R[1:foo]=1,CALL BAR ;
       =2,CALL BAR ;
       =3,CALL BAR ;
       ELSE,CALL BAR ;\n)
  end

  def test_can_use_simple_io_value_as_condition
    parse("foo := UI[5]\n@top\njump_to @top if foo")
    assert_prog "LBL[100:top] ;\nIF (UI[5:foo]),JMP LBL[100] ;\n"
  end

  def test_can_use_simple_io_value_as_condition_with_unless
    parse("foo := UI[5]\n@top\njump_to @top unless foo")
    assert_prog "LBL[100:top] ;\nIF (!UI[5:foo]),JMP LBL[100] ;\n"
  end

  def test_inline_program_call
    parse("foo := UI[5]\nbar() unless foo")
    assert_prog "IF (!UI[5:foo]),CALL BAR ;\n"
  end

  def test_constant_definition
    parse("FOO := 5\nfoo := R[1]\nfoo = FOO")
    assert_prog "R[1:foo]=5 ;\n"
  end

  def test_constant_definition_real
    parse("PI := 3.14159\nfoo:= R[1]\nfoo = PI")
    assert_prog "R[1:foo]=3.14159 ;\n"
  end

  def test_redefining_const_throws_error
    assert_raise(RuntimeError) do
      parse("PI := 3.14\nPI := 5")
      assert_prog ""
    end
  end

  def test_defining_const_without_caps_raises_error
    parse("pi := 3.14")
    assert_raise(RuntimeError) do
      assert_prog ""
    end
  end

  def test_using_argument_var
    parse("foo := AR[1]\n@top\njump_to @top if foo==1")
    assert_prog "LBL[100:top] ;\nIF (AR[1]=1),JMP LBL[100] ;\n"
  end

  def test_use_uframe_with_constant
    parse("FOO := 1\nuse_uframe FOO")
    assert_prog "UFRAME_NUM=1 ;\n"
  end

  def test_fanuc_set_uframe_with_pr
    parse("foo := PR[1]\nset_uframe 5, foo")
    assert_prog "UFRAME[5]=PR[1:foo] ;\n"
  end

  def test_fanuc_set_uframe_with_constant
    parse("foo := PR[1]\nBAR := 5\nset_uframe BAR, foo")
    assert_prog "UFRAME[5]=PR[1:foo] ;\n"
  end

  def test_fanuc_set_uframe_with_reg
    parse("foo := PR[1]\nbar := R[1]\nset_uframe bar, foo")
    assert_prog "UFRAME[R[1:bar]]=PR[1:foo] ;\n"
  end

  def test_set_skip_condition
    parse("foo := RI[1]\nset_skip_condition foo")
    assert_prog "SKIP CONDITION RI[1:foo]=ON ;\n"
  end

  def test_set_skip_condition_with_bang
    parse("foo := RI[1]\nset_skip_condition !foo")
    assert_prog "SKIP CONDITION RI[1:foo]=OFF ;\n"
  end

  def test_skip_to
    parse("p := P[1]\n@somewhere\nlinear_move.to(p).at(2000,'mm/s').term(0).skip_to(@somewhere)")
    assert_prog "LBL[100:somewhere] ;\nL P[1:p] 2000mm/sec CNT0 Skip,LBL[100] ;\n"
  end

  def test_skip_to_with_pr
    parse("p := P[1]\nlpos := PR[1]\n@somewhere\nlinear_move.to(p).at(2000,'mm/s').term(0).skip_to(@somewhere, lpos)")
    assert_prog "LBL[100:somewhere] ;\nL P[1:p] 2000mm/sec CNT0 Skip,LBL[100],PR[1:lpos]=LPOS ;\n"
  end

  def test_label_comment_automatically_adds_a_comment_if_over_16_chars
    parse("@foo_bar_foo_bar_foo")
    assert_prog "LBL[100:foo_bar_foo_bar_] ;\n! foo_bar_foo_bar_foo ;\n"
  end

  def test_automatic_long_comment_wrapping
    parse("# this is a really long comment so it should wrap")
    assert_prog "! this is a really long comment ;\n! so it should wrap ;\n"
  end

  def test_turning_on_a_flag_requires_mixed_logic
    parse("foo := F[1]\nturn_on foo")
    assert_prog "F[1:foo]=(ON) ;\n"
  end

  def test_boolean_assignment
    parse("foo := F[1]\nfoo = 1 && 1")
    assert_prog "F[1:foo]=(1 AND 1) ;\n"
  end

  def test_simple_math
    parse("foo := R[1]\nfoo=1+1")
    assert_prog "R[1:foo]=1+1 ;\n"
  end

  def test_more_complicated_math
    parse("foo := R[1]\nfoo=1+2+3")
    assert_prog "R[1:foo]=(1+2+3) ;\n"
  end

  def test_operator_precedence
    parse "foo := R[1]\nfoo=1+2*3"
    assert_prog "R[1:foo]=(1+2*3) ;\n"
  end

  def test_expression_grouping
    parse "foo := R[1]\nfoo=(1+2)*3"
    assert_prog "R[1:foo]=((1+2)*3) ;\n"
  end

  def test_boolean_expression
    parse "foo := F[1]\nfoo = 1 || 1 && 0"
    assert_prog "F[1:foo]=(1 OR 1 AND 0) ;\n"
  end

  def test_bang
    parse "foo := F[1]\nbar := F[2]\nfoo = !bar"
    assert_prog "F[1:foo]=(!F[2:bar]) ;\n"
  end

  def test_bang_with_grouping
    parse "foo := F[1]\nbar := F[2]\nbaz := F[3]\nfoo = foo || !(bar || baz)"
    assert_prog "F[1:foo]=(F[1:foo] OR !(F[2:bar] OR F[3:baz])) ;\n"
  end

  def test_opposite_flag_in_simple_if
    parse "foo := F[1]\nif foo\n# foo is true\nend"
    assert_prog "IF (!F[1:foo]),JMP LBL[100] ;\n! foo is true ;\nLBL[100] ;\n"
  end

  def test_opposite_flag_in_simple_unless
    parse "foo := F[1]\nunless foo\n# foo is false\nend"
    assert_prog "IF (F[1:foo]),JMP LBL[100] ;\n! foo is false ;\nLBL[100] ;\n"
  end

  def test_inline_if_with_flag
    parse "foo := F[1]\njump_to @end if foo\n@end"
    assert_prog "IF (F[1:foo]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_inline_unless_with_flag
    parse "foo := F[1]\njump_to @end unless foo\n@end"
    assert_prog "IF (!F[1:foo]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_automatic_parens_on_boolean
    parse "foo := F[1]\njump_to @end if foo || foo\n@end"
    assert_prog "IF (F[1:foo] OR F[1:foo]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_no_extra_parens_with_booleans
    parse "foo := F[1]\njump_to @end if foo || foo || foo\n@end"
    assert_prog "IF (F[1:foo] OR F[1:foo] OR F[1:foo]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_assignment_as_bool_result
    parse "foo := F[1]\nbar := R[1]\nfoo = bar == 1"
    assert_prog "F[1:foo]=(R[1:bar]=1) ;\n"
  end

  def test_args_dont_get_comments
    parse "foo := AR[1]\njump_to @end if foo == 1\n@end"
    assert_prog "IF (AR[1]=1),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_indirect_position_assignment
    parse "foo := PR[1]\nfoo = indirect('position',5)"
    assert_prog "PR[1:foo]=P[5] ;\n"
  end

  def test_indirect_indirect_position_assignment
    parse "foo := PR[1]\nbar := R[1]\nfoo = indirect('position',bar)"
    assert_prog "PR[1:foo]=P[R[1:bar]] ;\n"
  end

  def test_indirect_posreg_assignment
    parse "foo := PR[1]\nfoo = indirect('position_register',5)"
    assert_prog "PR[1:foo]=PR[5] ;\n"
  end

  def test_namespace
    parse "namespace Foo\nbar := R[1]\nend\nFoo::bar = 5"
    assert_prog "R[1:Foo bar]=5 ;\n"
  end

  def test_no_namespace_collision
    parse "namespace Foo\nbar := R[1]\nend\nbar := R[2]\nbar = 2\nFoo::bar = 1"
    assert_prog "R[2:bar]=2 ;\nR[1:Foo bar]=1 ;\n"
  end

  def test_namespace_constant_definition
    parse "namespace Math\nPI := 3.14\nend\nfoo := R[1]\nfoo = Math::PI"
    assert_prog "R[1:foo]=3.14 ;\n"
  end

  def test_namespace_swallows_everything
    parse "namespace Foo\n# this is a comment\n#this is another comment\nend"
    assert_prog ""
  end

  def test_nested_namespace
    parse %(namespace Foo
  bar := R[1]
  namespace Bar
    baz := R[2]
  end
end
Foo::bar = 1
Foo::Bar::baz = 2)
    assert_prog "R[1:Foo bar]=1 ;\nR[2:Foo Bar baz]=2 ;\n"
  end

  def test_load_environment
    environment = "foo := R[1]\nbar := R[2]\n#asdf\n#asdf"
    @interpreter.load_environment(environment)
    parse "foo = 5"
    assert_prog "R[1:foo]=5 ;\n"
    assert_equal 1, @interpreter.source_line_count
  end

  def test_load_environment_only_saves_definitions_etc
    environment = "foo := R[1]\nbar := R[2]\n#asdf\n#asdf\nfoo=3"
    @interpreter.load_environment(environment)
    parse "foo = 5"
    assert_prog "R[1:foo]=5 ;\n"
    assert_equal 1, @interpreter.source_line_count
  end


  def test_bad_environment
    assert_raise(RuntimeError) do
      @interpreter.load_environment("asdf")
    end
  end

  def test_inline_conditional_with_namespaced_var
    parse "namespace Foo\nbar := DI[1]\nend\njump_to @end unless Foo::bar\n@end"
    assert_prog "IF (!DI[1:Foo bar]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_namespaced_var_as_condition
    parse "namespace Foo\nbar := DI[1]\nend\nif Foo::bar\n# bar is on\nend"
    assert_prog "IF (!DI[1:Foo bar]),JMP LBL[100] ;\n! bar is on ;\nLBL[100] ;\n"
  end

  def test_reopen_namespace
    parse "namespace Foo\nbar := R[1]\nend\nnamespace Foo\nbaz := R[2]\nend\nFoo::bar = 1\nFoo::baz = 2"
    assert_prog "R[1:Foo bar]=1 ;\nR[2:Foo baz]=2 ;\n"
  end

  def test_eval
    parse %(eval "R[1]=5")
    assert_prog "R[1]=5 ;\n"
  end

  def test_multiline_eval
    parse %(eval "R[1]=5 ;\nR[2]=3")
    assert_prog "R[1]=5 ;\nR[2]=3 ;\n"
  end

  def test_namespaced_position_reg_component
    parse "namespace Fixture\npick_offset := PR[1]\nend\nFixture::pick_offset.x = 10"
    assert_prog "PR[1,1:Fixture pick_offset]=10 ;\n"
  end

  def test_inline_program_call_two
    parse "foo := R[1]\nbar() if foo >= 5"
    assert_prog "IF R[1:foo]>=5,CALL BAR ;\n"
  end

  def test_forlooop
    parse "foo := R[1]\nfor foo in (1 TO 10)\n# bar\nend"
    assert_prog "FOR R[1:foo]=1 TO 10 ;\n! bar ;\nENDFOR ;\n"
  end

  def test_forloop_with_vars
    parse "foo := R[1]\nmin := R[2]\nmax := R[3]\nfor foo in (min to max)\n#bar\nend"
    assert_prog "FOR R[1:foo]=R[2:min] TO R[3:max] ;\n! bar ;\nENDFOR ;\n"
  end

  def test_indirect_flag
    parse "foo := R[1]\nturn_on indirect('flag',foo)"
    assert_prog "F[R[1:foo]]=(ON) ;\n"
  end

  def test_indirect_flag_condition
    parse "foo := R[1]\njump_to @end if indirect('flag',foo)\n@end"
    assert_prog "IF (F[R[1:foo]]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_indirect_flag_condition_not_inline
    parse "foo := R[1]\nif indirect('flag',foo)\n# bar\nend"
    assert_prog "IF (!F[R[1:foo]]),JMP LBL[100] ;\n! bar ;\nLBL[100] ;\n"
  end

  def test_indirect_unless_flag_condition
    parse "foo := R[1]\njump_to @end unless indirect('flag',foo)\n@end"
    assert_prog "IF (!F[R[1:foo]]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_indirect_flag_with_if_bang
    parse "foo := R[1]\njump_to @end if !indirect('flag',foo)\n@end"
    assert_prog "IF (!F[R[1:foo]]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_while_loop
    parse "foo := R[1]\nwhile foo < 10\n# bar\nend"
    assert_prog "LBL[100] ;\nIF R[1:foo]>=10,JMP LBL[101] ;\n! bar ;\nJMP LBL[100] ;\nLBL[101] ;\n"
  end

  def test_while_with_not_flag
    parse "foo := F[1]\nwhile !foo\n#bar\nend"
    assert_prog "LBL[100] ;\nIF (F[1:foo]),JMP LBL[101] ;\n! bar ;\nJMP LBL[100] ;\nLBL[101] ;\n"
  end

  def test_while_with_flag
    parse "foo := F[1]\nwhile foo\n#bar\nend"
    assert_prog "LBL[100] ;\nIF (!F[1:foo]),JMP LBL[101] ;\n! bar ;\nJMP LBL[100] ;\nLBL[101] ;\n"
  end

  def test_timer_start
    parse "foo := TIMER[1]\nstart foo"
    assert_prog "TIMER[1:foo]=START ;\n"
  end

  def test_timer_reset
    parse "foo := TIMER[1]\nreset foo"
    assert_prog "TIMER[1:foo]=RESET ;\n"
  end

  def test_timer_stop
    parse "foo := TIMER[1]\nstop foo"
    assert_prog "TIMER[1:foo]=STOP ;\n"
  end

  def test_timer_restart
    parse "foo := TIMER[1]\nrestart foo"
    assert_prog "TIMER[1:foo]=STOP ;\nTIMER[1:foo]=RESET ;\nTIMER[1:foo]=START ;\n"
  end

  def test_indirect_timer
    parse "foo := R[1]\nfoo = indirect('timer', 3)"
    assert_prog "R[1:foo]=TIMER[3] ;\n"
  end

  def test_indirect_indirect_timer
    parse "foo := R[1]\nfoo = indirect('timer', foo)"
    assert_prog "R[1:foo]=TIMER[R[1:foo]] ;\n"
  end

  def test_start_indirect_timer
    parse "start indirect('timer', 3)"
    assert_prog "TIMER[3]=START ;\n"
  end

  def test_start_indirect_indirect_timer
    parse "foo := R[1]\nstart indirect('timer', foo)"
    assert_prog "TIMER[R[1:foo]]=START ;\n"
  end

  def test_position_data_does_not_output_with_eval
    parse %(position_data
  {
    'positions': [
      {
        'id': 1,
        'comment': "test",
        'group': 1,
        'uframe': 1,
        'utool': 1,
        'config': {
          'flip': true,
          'up': true,
          'top': false,
          'turn_counts': [-1,0,1]
        },
        'components': {
          'x': -50.0,
          'y': 0.0,
          'z': 0.0,
          'w': 0.0,
          'p': 0.0,
          'r': 0.0
        }
      }
    ]
  }
end)

    assert_prog ""
  end

  def test_position_data_populates_interpreter_position_data
    parse %(position_data
  {
    'positions': [
      {
        'id': 1,
        'comment': "test",
        'group': 1,
        'uframe': 1,
        'utool': 1,
        'config': {
          'flip': true,
          'up': true,
          'top': false,
          'turn_counts': [0,0,0]
        },
        'components': {
          'x': 0.0,
          'y': 0.0,
          'z': 0.0,
          'w': 0.0,
          'p': 0.0,
          'r': 0.0
        }
      }
    ]
  }
end)

    assert_prog ""
    assert_equal 1, @interpreter.position_data[:positions].length
  end

  def test_throws_a_fault_if_position_data_invalid
    parse %(position_data
  {
    'positions' : "asdf"
  }
end)
    assert_raise(RuntimeError) do
      @interpreter.eval
    end
  end

  def test_outputs_position_data_correctly
    parse %(position_data
  {
    'positions': [
      {
        'id': 1,
        'comment': "test",
        'group': 1,
        'uframe': 1,
        'utool': 1,
        'config': {
          'flip': true,
          'up': true,
          'top': true,
          'turn_counts': [0,0,0]
        },
        'components': {
          'x': 0.0,
          'y': 0.0,
          'z': 0.0,
          'w': 0.0,
          'p': 0.0,
          'r': 0.0
        }
      }
    ]
  }
end)

    assert_prog ""
    assert_equal %(P[1:"test"]{
   GP1:
  UF : 1, UT : 1,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.0 mm, Y = 0.0 mm, Z = 0.0 mm,
  W = 0.0 deg, P = 0.0 deg, R = 0.0 deg
};\n), @interpreter.pos_section
  end

  def test_outputs_position_data_correctly_with_two_positions
    parse %(position_data
  {
    'positions': [
      {
        'id': 1,
        'comment': "test",
        'group': 1,
        'uframe': 1,
        'utool': 1,
        'config': {
          'flip': true,
          'up': true,
          'top': true,
          'turn_counts': [0,0,0]
        },
        'components': {
          'x': 0.0,
          'y': 0.0,
          'z': 0.0,
          'w': 0.0,
          'p': 0.0,
          'r': 0.0
        }
      },
      {
        'id': 2,
        'comment': "test2",
        'group': 1,
        'uframe': 1,
        'utool': 1,
        'config': {
          'flip': true,
          'up': true,
          'top': true,
          'turn_counts': [0,0,0]
        },
        'components': {
          'x': 0.0,
          'y': 0.0,
          'z': 0.0,
          'w': 0.0,
          'p': 0.0,
          'r': 0.0
        }
      }
    ]
  }
end)

    assert_prog ""
    assert_equal %(P[1:"test"]{
   GP1:
  UF : 1, UT : 1,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.0 mm, Y = 0.0 mm, Z = 0.0 mm,
  W = 0.0 deg, P = 0.0 deg, R = 0.0 deg
};
P[2:"test2"]{
   GP1:
  UF : 1, UT : 1,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.0 mm, Y = 0.0 mm, Z = 0.0 mm,
  W = 0.0 deg, P = 0.0 deg, R = 0.0 deg
};\n), @interpreter.pos_section
  end

  def test_simple_pulse
    parse "foo := DO[1]\npulse foo"
    assert_prog "DO[1:foo]=PULSE ;\n"
  end

  def test_pulse_for_seconds
    parse "foo := DO[1]\npulse(foo,5,'s')"
    assert_prog "DO[1:foo]=PULSE,5.0sec ;\n"
  end

  def test_pulse_for_ms
    parse "foo := DO[1]\npulse(foo,500,'ms')"
    assert_prog "DO[1:foo]=PULSE,0.5sec ;\n"
  end

  def test_indirect_numreg
    parse "foo := R[1]\nindirect('register',foo) = 5"
    assert_prog "R[R[1:foo]]=5 ;\n"
  end

  def test_raise
    parse "my_alarm := UALM[1]\nraise my_alarm"
    assert_prog "UALM[1] ;\n"
  end

  def test_indirect_raise
    parse "raise indirect('user_alarm',1)"
    assert_prog "UALM[1] ;\n"
  end

  def test_indirect_indirect_raise
    parse "foo := R[1]\nraise indirect('user_alarm',foo)"
    assert_prog "UALM[R[1:foo]] ;\n"
  end

  def test_namespaced_pr_component_assignment
    parse "namespace Foo\nbar := PR[1]\nend\nFoo::bar.x = 10"
    assert_prog "PR[1,1:Foo bar]=10 ;\n"
  end

  def test_namespaced_pr_component_plus_equals
    parse "namespace Foo\nbar := PR[1]\nend\nFoo::bar.x += 10"
    assert_prog "PR[1,1:Foo bar]=PR[1,1:Foo bar]+10 ;\n"
  end

  def test_namespaced_pr_component_in_expression
    parse "namespace Foo\nbar := PR[1]\nend\nFoo::bar.x += Foo::bar.x * 10 \n"
    assert_prog "PR[1,1:Foo bar]=(PR[1,1:Foo bar]+PR[1,1:Foo bar]*10) ;\n"
  end

  def test_namespaced_pr_assignment_then_expression
    parse "namespace Foo\nbar := PR[1]\nend\nbaz := P[1]\nFoo::bar = baz\nFoo::bar.x += 5"
    assert_prog "PR[1:Foo bar]=P[1:baz] ;\nPR[1,1:Foo bar]=PR[1,1:Foo bar]+5 ;\n"
  end

  def test_wait_until_does_not_get_inlined
    parse "foo := DO[1]\nunless foo\nwait_until(foo)\nend"
    assert_prog "IF (DO[1:foo]),JMP LBL[100] ;\nWAIT (DO[1:foo]) ;\nLBL[100] ;\n"
  end

  def test_wait_for_does_not_get_inlined
    parse "foo := DO[1]\nunless foo\nwait_for(1,'s')\nend"
    assert_prog "IF (DO[1:foo]),JMP LBL[100] ;\nWAIT 1.00(sec) ;\nLBL[100] ;\n"
  end

  def test_inline_conditional_does_not_get_inlined
    parse "foo := DO[1]\nif foo\nturn_off foo if foo\nend"
    assert_prog "IF (!DO[1:foo]),JMP LBL[100] ;\nIF (DO[1:foo]),DO[1:foo]=(OFF) ;\nLBL[100] ;\n"
  end

  def test_run
    parse "run foo()"
    assert_prog "RUN FOO ;\n"
  end

  def test_tp_ignore_pause
    parse "TP_IGNORE_PAUSE = true"
    assert_prog ""
    assert @interpreter.header_data[:ignore_pause]
  end

  def test_tp_comment
    parse %(TP_COMMENT = "foo")
    assert_prog ""
    assert_equal "foo", @interpreter.header_data[:comment]
  end

  def test_tp_groupmask
    parse %(TP_GROUPMASK = "*,*,*,*,*")
    assert_prog ""
    assert_equal "*,*,*,*,*", @interpreter.header_data[:group_mask]
  end

  def test_mixed_logic_or
    parse %(foo := DI[1]\nbar := DI[2]\nif foo || bar\n# do something\nend)
    assert_prog "IF (!DI[1:foo] AND !DI[2:bar]),JMP LBL[100] ;\n! do something ;\nLBL[100] ;\n"
  end

  def test_flag_assignment_always_gets_parens
    parse %(foo := F[1]\nbar := DI[2]\nfoo = bar)
    assert_prog "F[1:foo]=(DI[2:bar]) ;\n"
  end

  def test_tool_offset
    parse %(p := P[1]\ntoff := PR[1]\nlinear_move.to(p).at(2000,'mm/s').term(0).tool_offset(toff))
    assert_prog "L P[1:p] 2000mm/sec CNT0 Tool_Offset,PR[1:toff] ;\n"
  end

  def test_wait_for_digit
    parse %(wait_for(1,'s'))
    assert_prog "WAIT 1.00(sec) ;\n"
  end

  def test_wait_for_real
    parse %(wait_for(0.5,'s'))
    assert_prog "WAIT .50(sec) ;\n"
  end

  def test_wait_for_real_const
    parse %(FOO := 0.5\nwait_for(FOO,'s'))
    assert_prog "WAIT .50(sec) ;\n"
  end

  def test_negative_numbers_have_parens
    parse %(foo := R[1]\njump_to @end if foo > -1\njump_to @end if foo > -5.3\n@end)
    assert_prog "IF R[1:foo]>(-1),JMP LBL[100] ;\nIF R[1:foo]>(-5.3),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_modulus
    parse %(foo := R[1]\nfoo = 5 % 2)
    assert_prog "R[1:foo]=5 MOD 2 ;\n"
  end

    def test_assignment_to_sop
    parse %(foo := DO[1]\nbar := SO[1]\nfoo = bar)
    assert_prog "DO[1:foo]=(SO[1:bar]) ;\n"
  end

  def test_assignment_to_di
    parse %(foo := DO[1]\nbar := DI[1]\nfoo = bar)
    assert_prog "DO[1:foo]=(DI[1:bar]) ;\n"
  end

  def test_string_register_definition
    parse %(foo := SR[1]\nbar := SR[2]\nfoo = bar)
    assert_prog "SR[1:foo]=SR[2:bar] ;\n"
  end

  def test_string_argument
    parse %(foo('bar'))
    assert_prog "CALL FOO('bar') ;\n"
  end
end
