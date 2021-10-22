require_relative '../test_helper'

class TestInterpreter < Test::Unit::TestCase
  include TPPlus::Nodes

  def setup
    $global_options = {}
    
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

  def test_label_with_number_definition
    parse("@foo2")
    assert_prog "LBL[100:foo2] ;\n"
  end

  def test_label_in_while_loop
    parse("i   := R[1]
    inc := R[2]
    i = 0
    inc = 10
    while i < inc
        @finlbl1
        i += 1
    end
    jump_to @finlbl1")
    
    assert_prog "R[1:i]=0 ;\n" +
    "R[2:inc]=10 ;\n" +
    "LBL[101] ;\n" +
    "IF R[1:i]>=R[2:inc],JMP LBL[102] ;\n" +
    "LBL[100:finlbl1] ;\n" +
    "R[1:i]=R[1:i]+1 ;\n" +
    "JMP LBL[101] ;\n" +
    "LBL[102] ;\n" +
    "JMP LBL[100] ;\n"

  end

  def test_label_in_nested_loop
    parse("i   := R[1]
    inc := R[2]
    j   := R[3]
    inc2 := R[4]
    i = 0
    j = 0
    inc = 10
    inc2 = 20
    while i < inc
        @finlbl1
        while j < inc2
          @finlbl2
          j += 1
        end
        i += 1
    end
    jump_to @finlbl1
    jump_to @finlbl2")
    
    assert_prog "R[1:i]=0 ;\n" +
    "R[3:j]=0 ;\n" +
    "R[2:inc]=10 ;\n" +
    "R[4:inc2]=20 ;\n" +
    "LBL[102] ;\n" +
    "IF R[1:i]>=R[2:inc],JMP LBL[103] ;\n" +
    "LBL[100:finlbl1] ;\n" +
    "LBL[104] ;\n" +
    "IF R[3:j]>=R[4:inc2],JMP LBL[105] ;\n" +
    "LBL[101:finlbl2] ;\n" +
    "R[3:j]=R[3:j]+1 ;\n" +
    "JMP LBL[104] ;\n" +
    "LBL[105] ;\n" +
    "R[1:i]=R[1:i]+1 ;\n" +
    "JMP LBL[102] ;\n" +
    "LBL[103] ;\n" +
    "JMP LBL[100] ;\n" +
    "JMP LBL[101] ;\n"

  end

  def test_label_in_for_loop
    parse("i   := R[1]
    inc := R[2]
    i = 0
    inc = 10
    for i in (1 to 10)
        @finlbl1
    end
    jump_to @finlbl1")
    
    assert_prog "R[1:i]=0 ;\n" +
    "R[2:inc]=10 ;\n" +
    "FOR R[1:i]=1 TO 10 ;\n" +
    "LBL[100:finlbl1] ;\n" +
    "ENDFOR ;\n" +
    "JMP LBL[100] ;\n"

  end

  def test_label_in_for_loop_decrement
    parse("i   := R[1]
    for i in (10 downto 1)
        @finlbl1
    end")
    
    assert_prog "FOR R[1:i]=10 DOWNTO 1 ;\n" + 
    "LBL[100:finlbl1] ;\n" + 
    "ENDFOR ;\n"

  end
  # ------

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

  def test_message
    parse("message('This is a test message!')")
    assert_prog "MESSAGE[This is a test message!] ;\n"
  end

  def test_warning
    parse %(foo := R[1]

      if foo == 1
          message('foo == 1')
          warning('This is a warning')
      else
          message('foo != 1')
      end
      
      warning('This is another warning')
    )

    assert_prog %( ;
IF R[1:foo]<>1,JMP LBL[102] ;
MESSAGE[foo == 1] ;
JMP LBL[100] ;
JMP LBL[103] ;
LBL[102] ;
MESSAGE[foo != 1] ;
LBL[103] ;
 ;
JMP LBL[101] ;\n)

    assert_equal %(;
! ******** ;
! WARNINGS ;
! ******** ;
 ;
JMP LBL[104] ;
LBL[100:warning1] ;
CALL USERCLR ;
MESSAGE[This is a warning] ;
WAIT UI[5]=ON ;
WAIT UI[5]=OFF ;
LBL[104] ;
 ;
JMP LBL[105] ;
LBL[101:warning2] ;
CALL USERCLR ;
MESSAGE[This is another warning] ;
WAIT UI[5]=ON ;
WAIT UI[5]=OFF ;
LBL[105] ;\n), @interpreter.list_warnings
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

  #@kobbled adds
  def test_motion_with_seconds_motion_type
    parse("p := P[1]\nspeed := R[1]\nlinear_move.to(p).at(speed, 's').term(0)")
    assert_prog "L P[1:p] R[1:speed]sec CNT0 ;\n"
  end
  # ---------

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

  def test_use_uframe_frame
    parse("foo := UFRAME[1]\nuse_uframe foo")
    assert_prog "UFRAME_NUM=1 ;\n"
  end

  def test_use_utool_tool
    parse("foo := UTOOL[2]\nuse_utool foo")
    assert_prog "UTOOL_NUM=2 ;\n"
  end

  def test_payload
    parse("use_payload 1")
    assert_prog "PAYLOAD[1] ;\n"
  end

  def test_indirect_payload
    parse("foo := R[1]\nuse_payload foo")
    assert_prog "PAYLOAD[R[1:foo]] ;\n"
  end

  def test_group_payload
    parse("foo := R[1]\nuse_payload(1,group(1))\nuse_payload(foo,group(2))")
    assert_prog "PAYLOAD[GP1:1] ;\n" + "PAYLOAD[GP2:R[1:foo]] ;\n"
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

  def test_motion_min_rotation
    parse %(foo := PR[1]
      foo2 := PR[2]
      TERM := -1
      joint_move.to(foo).at(100, '%').term(TERM).minimal_rotation
      linear_move.to(foo2).at(400, 'mm/s').term(TERM).acc(100).
              wrist_joint.
              mrot
      )
    assert_prog "J PR[1:foo] 100% FINE MROT ;\nL PR[2:foo2] 400mm/sec FINE ACC100 Wjnt MROT ;\n"
  end

  def test_remote_TCP_motion
    parse %(foo := PR[1]
      foo2 := PR[2]
      TERM := -1
      joint_move.to(foo).at(40, '%').term(TERM)
      linear_move.to(foo2).at(400, 'mm/s').term(100).acc(100).rtcp
      )
    assert_prog "J PR[1:foo] 40% FINE ;\n" + "L PR[2:foo2] 400mm/sec CNT100 ACC100 RTCP ;\n"
  end

  def test_corner_distance
    parse %(foo := PR[1]
      foo2 := PR[2]
      foo3 := PR[3]
      TERM := -1
      linear_move.to(foo).at(400, 'mm/s').term(TERM).acc(100)
      linear_move.to(foo2).at(400, 'mm/s').term(100).acc(100).cd(50)
      linear_move.to(foo3).at(400, 'mm/s').term(TERM)
      )
    assert_prog "L PR[1:foo] 400mm/sec FINE ACC100 ;\n" +
    "L PR[2:foo2] 400mm/sec CNT100 ACC100 CD50 ;\n" +
    "L PR[3:foo3] 400mm/sec FINE ;\n"
  end

  def test_corner_region_termination
    parse %(foo := PR[1]
      linear_move.to(foo).at(100, 'mm/s').corner_region(30)
      linear_move.to(foo).at(100, 'mm/s').corner_region(5,10)
      )
    assert_prog "L PR[1:foo] 100mm/sec CR30 ;\n" + 
    "L PR[1:foo] 100mm/sec CR5,10 ;\n"
  end

  def test_extended_velocity
    parse %(foo := PR[1]
      foo2 := PR[2]
      TERM := -1
      joint_move.to(foo).at(40, '%').term(TERM).simultaneous_ev(50)
      joint_move.to(foo2).at(40, '%').term(TERM).independent_ev(50)
      )
    assert_prog "J PR[1:foo] 40% FINE EV50% ;\n" + "J PR[2:foo2] 40% FINE Ind.EV50% ;\n"
  end

  def test_process_speed
    parse %(foo := PR[1]
      TERM := -1
      linear_move.to(foo).at(100, 'mm/s').term(TERM).process_speed(110)
      )
    assert_prog "L PR[1:foo] 100mm/sec FINE PSPD110 ;\n"
  end

  def test_continuous_rotation_speed
    parse %(foo := PR[1]
      TERM := -1
      linear_move.to(foo).at(100, 'mm/s').term(TERM).continuous_rotation_speed(0)
      )
    assert_prog "L PR[1:foo] 100mm/sec FINE CTV0 ;\n"
  end

  def test_linear_distance
    parse %(foo := PR[1]
      foo2 := PR[2]
      TERM := -1
      linear_move.to(foo).at(400, 'mm/s').term(TERM).approach_ld(100)
      linear_move.to(foo2).at(400, 'mm/s').term(100).retract_ld(100)
      )
    assert_prog "L PR[1:foo] 400mm/sec FINE AP_LD100 ;\n" +
    "L PR[2:foo2] 400mm/sec CNT100 RT_LD100 ;\n"
  end

  def test_linear_distance_register
    parse %(foo := PR[1]
      foo2 := PR[2]
      TERM := -1
      reg1 := R[1]
      arreg := AR[1]
      linear_move.to(foo).at(400, 'mm/s').term(TERM).approach_ld(reg1)
      linear_move.to(foo2).at(400, 'mm/s').term(100).retract_ld(arreg)
      )
    assert_prog "L PR[1:foo] 400mm/sec FINE AP_LDR[1:reg1] ;\n" +
    "L PR[2:foo2] 400mm/sec CNT100 RT_LDAR[1] ;\n"
  end

  # ..warning:: Remove for now
  # def test_motion_min_rotation_error
  #   parse %(foo := PR[1]
  #     TERM := -1
  #     linear_move.to(foo).at(400, 'mm/s').term(TERM).acc(100).mrot
  #     )
  #   assert_raise_message("Runtime error on line 3:\nWrist Joint modifier is needed if minimal rotation is specified for a linear move.") do
  #     assert_prog ""
  #   end
  # end

  def test_motion_path
    parse %(foo := PR[1]
      TERM := 100
      linear_move.to(foo).term(TERM).at(400, 'mm/s').pth
    )
    assert_prog "L PR[1:foo] 400mm/sec CNT100 PTH ;\n"
  end

  def test_motion_break
    parse %(edge_start := P[1]
      corner_start := P[2]
      corner_end := P[3]
      di          := DI[1]
      TERM := -1
      joint_move.to(edge_start).at(50, '%').term(TERM)
      linear_move.to(corner_start).at(500, 'mm/s').term(100).break
      thread_prog()
      wait_until(di)
      linear_move.to(corner_end).at(500, 'mm/s').term(0)
    )
    assert_prog "J P[1:edge_start] 50% FINE ;\nL P[2:corner_start] 500mm/sec CNT100 BREAK ;\nCALL THREAD_PROG ;\nWAIT (DI[1:di]) ;\nL P[3:corner_end] 500mm/sec CNT0 ;\n"
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
    assert_raise_message("Runtime error on line 2:\nIndirect values can only use seconds ('s') as the units argument") do
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

  #def test_pr_with_invalid_component_raises_error
  #  parse("foo := PR[1]\nfoo.bar=5\n")
  #  assert_raise(RuntimeError) do
  #  assert_prog ""
  #  end
  #end

  def test_case_statement_with_blocks
    parse %(foo := R[1]
            foo2:= R[2]
            foo3 := DO[1]
            t    := TIMER[1]
      
      case foo
          when 1
              message('foo == 1')
              wait_for(1, 's')
              turn_on foo3
          when 2
              PROG1()
              foo2 += 1
          else
             stop t
      end)
    assert_prog %( ;
SELECT R[1:foo]=1,JMP LBL[100] ;
       =2,JMP LBL[101] ;
       ELSE,JMP LBL[102] ;
JMP LBL[103] ;
LBL[100:caselbl1] ;
MESSAGE[foo == 1] ;
WAIT 1.00(sec) ;
DO[1:foo3]=ON ;
JMP LBL[103] ;
LBL[101:caselbl2] ;
CALL PROG1 ;
R[2:foo2]=R[2:foo2]+1 ;
JMP LBL[103] ;
LBL[102:caselbl3] ;
TIMER[1]=STOP ;
JMP LBL[103] ;
LBL[103:endcase] ;\n)
  end

  def test_case_statement_with_three_whens
    parse("foo := R[1]\ncase foo\nwhen 1\nbar()\nwhen 2\nbar()\nwhen 3\nbar()\nend")
    assert_prog %(SELECT R[1:foo]=1,JMP LBL[100] ;
       =2,JMP LBL[101] ;
       =3,JMP LBL[102] ;
JMP LBL[103] ;
LBL[100:caselbl1] ;
CALL BAR ;
JMP LBL[103] ;
LBL[101:caselbl2] ;
CALL BAR ;
JMP LBL[103] ;
LBL[102:caselbl3] ;
CALL BAR ;
JMP LBL[103] ;
LBL[103:endcase] ;\n)
  end

  def test_case_statement_with_three_whens_and_else
    parse("foo := R[1]\ncase foo\nwhen 1\nbar()\nwhen 2\nbar()\nwhen 3\nbar()\nelse\nbar()\nend")
    assert_prog %(SELECT R[1:foo]=1,JMP LBL[100] ;
       =2,JMP LBL[101] ;
       =3,JMP LBL[102] ;
       ELSE,JMP LBL[103] ;
JMP LBL[104] ;
LBL[100:caselbl1] ;
CALL BAR ;
JMP LBL[104] ;
LBL[101:caselbl2] ;
CALL BAR ;
JMP LBL[104] ;
LBL[102:caselbl3] ;
CALL BAR ;
JMP LBL[104] ;
LBL[103:caselbl4] ;
CALL BAR ;
JMP LBL[104] ;
LBL[104:endcase] ;\n)
  end

  def test_case_blocks_with_else
    parse("foo := R[1]
      bar := R[2]
      
      case foo
      when 1
          bar = 12345
          execBar(bar)
      when 2
          bar = 54321
          execBar(bar)
      else
        if bar <= 0 then
          errorBar()
        end
      end")

      assert_prog " ;\n" +
      "SELECT R[1:foo]=1,JMP LBL[100] ;\n" +
      "       =2,JMP LBL[101] ;\n" +
      "       ELSE,JMP LBL[102] ;\n" +
      "JMP LBL[103] ;\n" +
      "LBL[100:caselbl1] ;\n" +
      "R[2:bar]=12345 ;\n" +
      "CALL EXECBAR(R[2:bar]) ;\n" +
      "JMP LBL[103] ;\n" +
      "LBL[101:caselbl2] ;\n" +
      "R[2:bar]=54321 ;\n" +
      "CALL EXECBAR(R[2:bar]) ;\n" +
      "JMP LBL[103] ;\n" +
      "LBL[102:caselbl3] ;\n" +
      "IF (R[2:bar]<=0) THEN ;\n" +
      "CALL ERRORBAR ;\n" +
      "ENDIF ;\n" +
      "JMP LBL[103] ;\n" +
      "LBL[103:endcase] ;\n"
  end

  def test_case_blocks_without_else
    parse("foo := R[1]
      bar := R[2]
      
      case foo
      when 1
          bar = 12345
          execBar(bar)
      when 2
          bar = 54321
          execBar(bar)
      end")

      assert_prog " ;\n" +
      "SELECT R[1:foo]=1,JMP LBL[100] ;\n" +
      "       =2,JMP LBL[101] ;\n" +
      "JMP LBL[102] ;\n" +
      "LBL[100:caselbl1] ;\n" +
      "R[2:bar]=12345 ;\n" +
      "CALL EXECBAR(R[2:bar]) ;\n" +
      "JMP LBL[102] ;\n" +
      "LBL[101:caselbl2] ;\n" +
      "R[2:bar]=54321 ;\n" +
      "CALL EXECBAR(R[2:bar]) ;\n" +
      "JMP LBL[102] ;\n" +
      "LBL[102:endcase] ;\n"
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

  def test_set_uframe_with_pr
    parse("foo := PR[1]\nindirect('uframe',5)=foo")
    assert_prog "UFRAME[5]=PR[1:foo] ;\n"
  end

  def test_set_uframe_with_constant
    parse("foo := PR[1]\nBAR := 5\nindirect('uframe',BAR)=foo")
    assert_prog "UFRAME[5]=PR[1:foo] ;\n"
  end

  def test_fanuc_set_uframe_with_reg
    parse("foo := PR[1]\nbar := R[1]\nindirect('uframe',bar)=foo")
    assert_prog "UFRAME[R[1:bar]]=PR[1:foo] ;\n"
  end

  def test_fanuc_set_uframe
    parse("foo := PR[1]\nbar := UFRAME[2]\nbar=foo")
    assert_prog "UFRAME[2]=PR[1:foo] ;\n"
  end


  def test_fanuc_set_utool_with_reg
    parse("foo := PR[1]\nbar := R[1]\nindirect('utool',bar)=foo")
    assert_prog "UTOOL[R[1:bar]]=PR[1:foo] ;\n"
  end

  def test_fanuc_set_utool
    parse("foo := PR[1]\nbar := UTOOL[2]\nbar=foo")
    assert_prog "UTOOL[2]=PR[1:foo] ;\n"
  end

  def test_set_skip_condition
    parse("foo := DI[1]\nset_skip_condition foo")
    assert_prog "SKIP CONDITION DI[1:foo]=ON ;\n"
  end

  def test_set_skip_condition_with_bang
    parse("foo := RI[1]\nset_skip_condition !foo")
    assert_prog "SKIP CONDITION RI[1:foo]=OFF ;\n"
  end

  def test_set_skip_condition_indirect
    parse("foo := AR[1]\nset_skip_condition indirect('DI', foo)")
    assert_prog "SKIP CONDITION DI[AR[1]]=ON ;\n"
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

  # issue #15 https://github.com/onerobotics/tp_plus/issues/15
  def test_assign_output_to_ro
    parse "foo := DO[1]\nbar := RO[1]\nfoo = bar"
    assert_prog "DO[1:foo]=(RO[1:bar]) ;\n"
  end

  def test_assign_output_to_numreg_requires_no_parens
    parse "foo := DO[1]\nbar := R[1]\nfoo = bar"
    assert_prog "DO[1:foo]=R[1:bar] ;\n"
  end

  # issue #16 https://github.com/onerobotics/tp_plus/issues/16
  def test_negative_assignment
    parse "foo := R[1]\nfoo = -foo"
    assert_prog "R[1:foo]=R[1:foo]*(-1) ;\n"
  end

  def test_bang_with_grouping
    parse "foo := F[1]\nbar := F[2]\nbaz := F[3]\nfoo = foo || !(bar || baz)"
    assert_prog "F[1:foo]=(F[1:foo] OR !(F[2:bar] OR F[3:baz])) ;\n"
  end

  def test_opposite_flag_in_simple_if
    parse "foo := F[1]\nif foo\n# foo is true\nend"
    assert_prog "IF (!F[1:foo]),JMP LBL[100] ;\n! foo is true ;\nLBL[100] ;\n"
  end

  def test_opposite_with_boolean_and
    parse "foo := F[1]\nbar := F[2]\nbaz := F[3]\nif foo && bar && baz\n#foo, bar and baz are true\nend"
    assert_prog "IF (!F[1:foo] OR !F[2:bar] OR !F[3:baz]),JMP LBL[100] ;\n! foo, bar and baz are true ;\nLBL[100] ;\n"
  end

  def test_opposite_with_boolean_or
    parse "foo := F[1]\nbar := F[2]\nbaz := F[3]\nif foo || bar || baz\n#foo or bar or baz is true\nend"
    assert_prog "IF (!F[1:foo] AND !F[2:bar] AND !F[3:baz]),JMP LBL[100] ;\n! foo or bar or baz is true ;\nLBL[100] ;\n"
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
    parse "foo := PR[1]\nfoo = indirect('p',5)"
    assert_prog "PR[1:foo]=P[5] ;\n"
  end

  # Issue #11
  def test_indirect_gi
    parse "foo := R[1]\nbar := R[2]\nfoo = indirect('gi', bar)"
    assert_prog "R[1:foo]=GI[R[2:bar]] ;\n"
  end

  def test_indirect_indirect_position_assignment
    parse "foo := PR[1]\nbar := R[1]\nfoo = indirect('p',bar)"
    assert_prog "PR[1:foo]=P[R[1:bar]] ;\n"
  end

  def test_indirect_posreg_assignment
    parse "foo := PR[1]\nfoo = indirect('pr',5)"
    assert_prog "PR[1:foo]=PR[5] ;\n"
  end

  def test_add_posregs
    parse "a := PR[1]\nb := PR[2]\nc := PR[3]\nd := PR[4]\na=b+c+d"
    assert_prog "PR[1:a]=PR[2:b]+PR[3:c]+PR[4:d] ;\n"
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
    assert_raise(TPPlus::Parser::ParseError) do
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
    assert_raise(RuntimeError) do
      @interpreter.eval
    end
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
    parse "foo := R[1]\nfor foo in (1 to 10)\n# bar\nend"
    assert_prog "FOR R[1:foo]=1 TO 10 ;\n! bar ;\nENDFOR ;\n"
  end

  def test_forloop_with_vars
    parse "foo := R[1]\nmin := R[2]\nmax := R[3]\nfor foo in (min to max)\n#bar\nend"
    assert_prog "FOR R[1:foo]=R[2:min] TO R[3:max] ;\n! bar ;\nENDFOR ;\n"
  end

  def test_indirect_flag
    parse "foo := R[1]\nturn_on indirect('f',foo)"
    assert_prog "F[R[1:foo]]=(ON) ;\n"
  end

  def test_indirect_flag_condition
    parse "foo := R[1]\njump_to @end if indirect('f',foo)\n@end"
    assert_prog "IF (F[R[1:foo]]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_indirect_flag_condition_not_inline
    parse "foo := R[1]\nif indirect('f',foo)\n# bar\nend"
    assert_prog "IF (!F[R[1:foo]]),JMP LBL[100] ;\n! bar ;\nLBL[100] ;\n"
  end

  def test_indirect_unless_flag_condition
    parse "foo := R[1]\njump_to @end unless indirect('f',foo)\n@end"
    assert_prog "IF (!F[R[1:foo]]),JMP LBL[100] ;\nLBL[100:end] ;\n"
  end

  def test_indirect_flag_with_if_bang
    parse "foo := R[1]\njump_to @end if !indirect('f',foo)\n@end"
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
    assert_prog "TIMER[1]=START ;\n"
  end

  def test_timer_reset
    parse "foo := TIMER[1]\nreset foo"
    assert_prog "TIMER[1]=RESET ;\n"
  end

  def test_timer_stop
    parse "foo := TIMER[1]\nstop foo"
    assert_prog "TIMER[1]=STOP ;\n"
  end

  def test_timer_restart
    parse "foo := TIMER[1]\nrestart foo"
    assert_prog "TIMER[1]=STOP ;\nTIMER[1]=RESET ;\nTIMER[1]=START ;\n"
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
        'mask' : [{
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
        }]
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
        'mask': [{
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
        }]
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
        'mask' : [{
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
        }]
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
        'mask': [{
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
        }]
      },
      {
        'id': 2,
        'comment': "test2",
        'mask': [{
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
        }]
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

  def test_joint_position_outputs
    parse %(position_data
  {
    'positions': [
      {
        'id': 1,
        'comment': "test",
        'mask': [{
          'group': 1,
          'uframe': 0,
          'utool': 1,
          'components': {
            'J1': 180.0,
            'J2': 90.0,
            'J3': 60.0,
            'J4': -90.0,
            'J5': 0.0,
            'J6': 180.0
          }
        }]
      }
    ]
  }
end)

    assert_prog ""
    assert_equal %(P[1:"test"]{
   GP1:
  UF : 0, UT : 1, 
  J1 = 180.0 deg, 
  J2 = 90.0 deg, 
  J3 = 60.0 deg, 
  J4 = -90.0 deg, 
  J5 = 0.0 deg, 
  J6 = 180.0 deg
};\n), @interpreter.pos_section
  end

  def test_independent_group_position_rot
    parse %(position_data
  {
    'positions': [
      {
        'id': 1,
        'comment': "test",
        'mask': [{
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
            'x' : -576.703,
            'y' : 652.415,
            'z' : 10751.806,
            'w' : 76.235,
            'p' : 9.185,
            'r' : 27.809
          }
        },
        {
          'group' : 2,
          'uframe': 1,
          'utool': 1,
          'components' : {
              'J1' : 90.0,
              'J2' : 180.0
              }
        }]
      }
    ]
  }
end)

    assert_prog ""
    assert_equal %(P[1:"test"]{
   GP1:
  UF : 1, UT : 1,  CONFIG : 'F U T, 0, 0, 0',
  X = -576.703 mm, Y = 652.415 mm, Z = 10751.806 mm,
  W = 76.235 deg, P = 9.185 deg, R = 27.809 deg
   GP2:
  UF : 1, UT : 1, 
  J1 = 90.0 deg, 
  J2 = 180.0 deg
};\n), @interpreter.pos_section
  end

  def test_independent_group_pos_linear
    parse %(position_data
  {
    'positions': [
      {
        'id' : 1,
        'comment' : "test",
        'mask' :  [{
          'group' : 1,
          'uframe' : 8,
          'utool' : 5,
          'config' : {
              'flip' : true,
              'up'   : true,
              'top'  : true,
              'turn_counts' : [0,0,0]
              },
          'components' : {
              'x' : 0.0,
              'y' : 0.0,
              'z' : 0.0,
              'w' : 90.0,
              'p' : 90.0,
              'r' : 0.0
              }
          },
          {
          'group' : 2,
          'uframe' : 8,
          'utool' : 5,
          'components' : {
              'J1' : [11500.0, 'mm']
              }
          }]
      }
    ]
  }
end)

    assert_prog ""
    assert_equal %(P[1:"test"]{
   GP1:
  UF : 8, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.0 mm, Y = 0.0 mm, Z = 0.0 mm,
  W = 90.0 deg, P = 90.0 deg, R = 0.0 deg
   GP2:
  UF : 8, UT : 5, 
  J1 = 11500.0 mm
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
    parse "foo := R[1]\nindirect('r',foo) = 5"
    assert_prog "R[R[1:foo]]=5 ;\n"
  end

  def test_raise
    parse "my_alarm := UALM[1]\nraise my_alarm"
    assert_prog "UALM[1] ;\n"
  end

  def test_indirect_raise
    parse "raise indirect('ualm',1)"
    assert_prog "UALM[1] ;\n"
  end

  def test_indirect_indirect_raise
    parse "foo := R[1]\nraise indirect('ualm',foo)"
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

  def test_call_sr
    parse "name := SR[1]\narg1 := AR[1]\ncall name(arg1)"
    assert_prog "CALL SR[1:name](AR[1]) ;\n"
  end

  def test_tp_ignore_pause
    parse "TP_IGNORE_PAUSE = true"
    assert_prog ""
    assert @interpreter.header_data[:ignore_pause]
  end

  def test_tp_subtype
    parse "TP_SUBTYPE = 'macro'"
    assert_prog ""
    assert_equal :macro, @interpreter.header_data[:subtype]
  end

  def test_tp_comment
    parse %(TP_COMMENT = "foo")
    assert_prog ""
    assert_equal "foo", @interpreter.header_data[:comment]
  end

  def test_tp_message
    parse %(message('This is a Message! It can be over the character limit!'))
    assert_prog "MESSAGE[This is a Message! It can] ;\nMESSAGE[be over the character] ;\nMESSAGE[limit!] ;\n"
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

  def test_modulus_in_if
    parse %(foo := R[1]\nis := R[2]\n is = 2\n if is % 0 == 0 \n foo = 5 \n end)
    assert_prog "R[2:is]=2 ;\nIF (R[2:is] MOD 0=0),R[1:foo]=(5) ;\n"
  end

  def test_modulus_in_if_logic
    parse %(foo := R[1]\ni := R[2]\n i = 2\n if i % 0 == 0 \n foo = 5\nGO_TO1() \n end)
    assert_prog "R[2:i]=2 ;\nIF (R[2:i] MOD 0<>0),JMP LBL[100] ;\nR[1:foo]=5 ;\nCALL GO_TO1 ;\nLBL[100] ;\n"
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

  def test_pause
    parse %(pause)
    assert_prog "PAUSE ;\n"
  end

  def test_abort
    parse %(abort)
    assert_prog "ABORT ;\n"
  end

  def test_div
    parse %(foo := R[1]\nfoo = 1 DIV 5)
    assert_prog "R[1:foo]=1 DIV 5 ;\n"
  end

  def test_div_overload
    parse %(foo := R[1]\nfoo = 1 // 5)
    assert_prog "R[1:foo]=1 DIV 5 ;\n"
  end

  def test_conditional_equals
    parse("foo := R[1]\nfoo2 := R[2]\nif foo == foo2\nfoo = 1\nfoo2 = 2\nend")
    assert_prog "IF R[1:foo]<>R[2:foo2],JMP LBL[100] ;\nR[1:foo]=1 ;\nR[2:foo2]=2 ;\nLBL[100] ;\n"
  end

  def test_if_statement_multiple_arguments
    parse("foo := R[1]\nfoo2 := R[2]\nif foo == 1 && foo2 == 2\nfoo = 1\nfoo2 = 2\nend")
    assert_prog "IF (R[1:foo]<>1 OR R[2:foo2]<>2),JMP LBL[100] ;\nR[1:foo]=1 ;\nR[2:foo2]=2 ;\nLBL[100] ;\n"
  end

  def test_parse_error_on_invalid_term
    assert_raise do
      parse("foo := PR[1]\nlinear_move.to(foo).at(2000, 'mm/s').term(-2)")
    end
  end

  def test_acc_zero
    parse("foo := PR[1]\nlinear_move.to(foo).at(2000, 'mm/s').term(0).acc(0)")
    assert_prog "L PR[1:foo] 2000mm/sec CNT0 ACC0 ;\n"
  end

  def test_acc_150
    parse("foo := PR[1]\nlinear_move.to(foo).at(2000, 'mm/s').term(0).acc(150)")
    assert_prog "L PR[1:foo] 2000mm/sec CNT0 ACC150 ;\n"
  end

  def test_acc_with_constant
    parse("foo := PR[1]\nBAR := 50\nlinear_move.to(foo).at(2000, 'mm/s').term(0).acc(BAR)")
    assert_prog "L PR[1:foo] 2000mm/sec CNT0 ACC50 ;\n"
  end

  def test_acc_with_var
    parse("foo := PR[1]\nbar := R[1]\nlinear_move.to(foo).at(2000, 'mm/s').term(0).acc(bar)")
    assert_prog "L PR[1:foo] 2000mm/sec CNT0 ACC R[1:bar] ;\n"
  end

  def test_term_fine_with_constant
    parse("foo := PR[1]\nTERM := -1\nlinear_move.to(foo).at(2000, 'mm/s').term(TERM)")
    assert_prog "L PR[1:foo] 2000mm/sec FINE ;\n"
  end

  def test_term_cnt_with_constant
    parse("foo := PR[1]\nTERM := 100\nlinear_move.to(foo).at(2000, 'mm/s').term(TERM)")
    assert_prog "L PR[1:foo] 2000mm/sec CNT100 ;\n"
  end

  def test_pr_components_groups
    parse("foo := PR[1]\nfoo.group(1).y=5\n")
    assert_prog "PR[GP1:1,2:foo]=5 ;\n"
  end

  def test_position_data_with_mask
    parse %(position_data
{
  'positions' : [
    {
      'id' : 1,
      'mask' :  [{
        'group' : 1,
        'uframe' : 5,
        'utool' : 2,
        'config' : {
            'flip' : false,
            'up'   : true,
            'top'  : true,
            'turn_counts' : [0,0,0]
            },
        'components' : {
            'x' : -.590,
            'y' : -29.400,
            'z' : 1304.471,
            'w' : 78.512,
            'p' : 89.786,
            'r' : -11.595
            }
        },
        {
        'group' : 2,
        'uframe' : 5,
        'utool' : 2,
        'components' : {
            'J1' : 0.00
            }
        }]
    }
  ]
}
end)
    assert_prog ""
    #output = @interpreter.pos_section
    #output = output
    assert_equal 1, @interpreter.position_data[:positions].length
  end

  def test_conditional_equals_minus_one
    parse("foo := R[1]\nfoo2 := R[2]\nif foo == (foo2-1)\nfoo = 1\nfoo2 = 2\nend")
    assert_prog "IF (R[1:foo]<>(R[2:foo2]-1)),JMP LBL[100] ;\nR[1:foo]=1 ;\nR[2:foo2]=2 ;\nLBL[100] ;\n"
  end

  def test_conditional_equals_minus_and
    parse("foo := R[1]\nfoo2 := R[2]\nif foo >= (foo2-1) && foo <= (foo2+1) \nfoo = 1\nfoo2 = 2\nend")
    assert_prog "IF (R[1:foo]<(R[2:foo2]-1) OR R[1:foo]>(R[2:foo2]+1)),JMP LBL[100] ;\nR[1:foo]=1 ;\nR[2:foo2]=2 ;\nLBL[100] ;\n"
  end

  def test_inline_conditional_equals_minus_and
    parse("foo := R[1]\nfoo2 := R[2]\nif foo >= (foo2-1) && foo <= (foo2+1) \nfoo2 = 2\nend")
    assert_prog "IF (R[1:foo]>=(R[2:foo2]-1) AND R[1:foo]<=(R[2:foo2]+1)),R[2:foo2]=(2) ;\n"
  end

  def test_address
    parse("a := AR[1]
b := DI[2]
c := R[3]
d := P[4]
e := PR[5]
f := SR[6]
g := TIMER[7]
h := UALM[8]
i := VR[9]
TEST(&a,&b,&c,&d,&e,&f,&g,&h,&i)")
    assert_prog "CALL TEST(1,2,3,4,5,6,7,8,9) ;\n"
  end

  def test_address_assignment
    parse("foo := R[1]
foo = &foo")
    assert_prog "R[1:foo]=1 ;\n"
  end

  def test_namespaced_address_assignment
    parse(" namespace a 
foo := R[5]
end
foo := R[1]
foo = &a::foo")
    assert_prog "R[1:foo]=5 ;\n"
  end

  def test_invalid_address_throws_error
    parse("foo := R[1]\nfoo = &bar")
    assert_raise(RuntimeError) do
      assert_prog ""
    end
  end

  def test_lpos
    parse "foo := PR[1]\nget_linear_position(foo)"
    assert_prog "PR[1:foo]=LPOS ;\n"
  end

  def test_jpos
    parse "foo := PR[1]\nget_joint_position(foo)"
    assert_prog "PR[1:foo]=JPOS ;\n"
  end

  def test_lpos_indirect
    parse "foo := AR[1]\nget_linear_position(indirect('PR', foo))"
    assert_prog "PR[AR[1]]=LPOS ;\n"
  end

  def test_jpos_indirect
    parse "get_joint_position(indirect('PR', 3))"
    assert_prog "PR[3]=JPOS ;\n"
  end

  def test_return
    parse "return"
    assert_prog "END ;\n"
  end

  def test_motion_indirect_offset
    parse("p := P[1]\no := PR[1]\nfoo := AR[1]\nlinear_move.to(p).at(100, 'mm/s').term(0).offset(indirect('pr', foo))")
    assert_prog "L P[1:p] 100mm/sec CNT0 Offset,PR[AR[1]] ;\n"
  end

  def test_indirect_motion_to_a_position
    parse("foo := AR[1]\nlinear_move.to(indirect('pr', foo)).at(2000, 'mm/s').term(0)")
    assert_prog "L PR[AR[1]] 2000mm/sec CNT0 ;\n"
  end

  def test_pr_components_indirect
    parse("arg := AR[1]\nindirect('pr', arg).group(1).y=5\n")
    assert_prog "PR[GP1:AR[1],2]=5 ;\n"
  end

  def test_motion_circular
    parse("foo := PR[1]\nfoo2 := PR[2]\nTERM := 100\ncircular_move.mid(foo).to(foo2).at(2000, 'mm/s').term(TERM).coord")
    assert_prog "C PR[1:foo] \n" + "  PR[2:foo2] 2000mm/sec CNT100 COORD ;\n"
  end

  def test_motion_arc
    parse("p1 := P[1]
    p2 := P[2]
    p3 := P[3]
    p4 := P[4]
    p5 := P[5]
    p6 := P[6]
    
    FINE := -1
    
    
    joint_move.to(p1).at(100, '%').term(FINE)
    arc_move.to(p2).at(200, 'mm/s').term(FINE)
    arc_move.to(p3).at(200, 'mm/s').term(100)
    arc_move.to(p4).at(200, 'mm/s').term(100)
    arc_move.to(p5).at(200, 'mm/s').term(FINE)
    linear_move.to(p6).at(200, 'mm/s').term(FINE)
    linear_move.to(p6).at(200, 'mm/s').term(-1)")
    
    assert_prog " ;\n" +
    " ;\n" +
    "J P[1:p1] 100% FINE ;\n" +
    "A P[2:p2] 200mm/sec FINE ;\n" +
    "A P[3:p3] 200mm/sec CNT100 ;\n" +
    "A P[4:p4] 200mm/sec CNT100 ;\n" +
    "A P[5:p5] 200mm/sec FINE ;\n" +
    "L P[6:p6] 200mm/sec FINE ;\n" +
    "L P[6:p6] 200mm/sec FINE ;\n"
  end

  def test_analogin
    parse("foo := AI[1]\nfoo = 20")
    assert_prog "AI[1:foo]=(20) ;\n"
  end

  def test_analogout
    parse("foo := AO[1]\nfoo = 20")
    assert_prog "AO[1:foo]=20 ;\n"
  end

  def test_system_vars
    parse("$PRIORITY = 128")
    assert_prog "$PRIORITY=128 ;\n"
  end

  def test_system_vars_nested
    parse("test_pr := PR[1]\n$CD_PAIR[1].$LEADER_FRM = test_pr")
    assert_prog "$CD_PAIR[1].$LEADER_FRM=PR[1:test_pr] ;\n"
  end

  def test_system_vars_nested_rval
    parse("test_pr := PR[1]\ntest_pr = $CD_PAIR[1].$LEADER_FRM")
    assert_prog "PR[1:test_pr]=$CD_PAIR[1].$LEADER_FRM ;\n"
  end

  def test_system_vars_nested_arrays
    parse("$MRR_GRP[2].$MASTER_POS[1] = 0")
    assert_prog "$MRR_GRP[2].$MASTER_POS[1]=0 ;\n"
  end

  def test_system_var_in_expression
    parse("if $SCR.$NUM_GROUP > 1 then
      #true block
      else
      #false block
      end")
    assert_prog "IF ($SCR.$NUM_GROUP>1) THEN ;\n" +
    "! true block ;\n" +
    "ELSE ;\n" +
    "! false block ;\n" +
    "ENDIF ;\n"
  end

  def test_system_var_in_expression_rval
    parse("foo := R[1]

      foo = $SCR.$NUM_GROUP
      
      if foo > $SCR.$NUM_GROUP then
      #true block
      else
      #false block
      end")
    assert_prog " ;\n" +
    "R[1:foo]=$SCR.$NUM_GROUP ;\n" +
    " ;\n" +
    "IF (R[1:foo]>$SCR.$NUM_GROUP) THEN ;\n" +
    "! true block ;\n" +
    "ELSE ;\n" +
    "! false block ;\n" +
    "ENDIF ;\n"
  end

  # issue #18 https://github.com/onerobotics/tp_plus/issues/18
  def test_mixed_logic_with_multiple_conditions_and_not_operator
    parse "foo := RI[1]\nbar := RI[2]\nif !foo && !bar\n# true\nend"
    assert_prog "IF (RI[1:foo] OR RI[2:bar]),JMP LBL[100] ;\n! true ;\nLBL[100] ;\n"
  end

  def test_operations
    parse("foo := R[1]\nfoo2 := R[2]\nfoo2 = foo*SIN[foo]")
    assert_prog "R[2:foo2]=R[1:foo]*SIN[R[1:foo]] ;\n"
  end

  def test_operations2
    parse("foo := R[1]\nfoo2 := AR[1]\nif COS[foo] || SQRT[foo2]\n# true\nend")
    assert_prog "IF (COS[R[1:foo]] AND SQRT[AR[1]]),JMP LBL[100] ;\n" +
    "! true ;\n" +
    "LBL[100] ;\n"
  end

  def test_inverse_trig
    parse("foo := R[1]\nfoo2 := R[2]\nfoo2 = ATAN2[foo,foo2]")
    assert_prog "R[2:foo2]=ATAN2[R[1:foo],R[2:foo2]] ;\n"
  end

  def test_operations_cannot_use_numbers
    parse("foo := R[1]\nfoo2 := AR[1]\nif ABS[-10] || SQRT[64]\n# true\nend")
    assert_raise(RuntimeError) do
      assert_prog ""
    end
  end

  def test_conditional_block
    parse("Dummy1 := R[225]
      Dummy2 := R[226]
      pin1 := DO[33]
      pin2 := DO[34]
      pin3 := DO[35]
      
      Dummy1 = 0
      Dummy2 = 0
      
      if ATAN2[Dummy1, Dummy2] == 0 then
        turn_on(pin1)
        turn_off(pin2)
        turn_off(pin3)
      elsif ATAN2[Dummy1, Dummy2] == 90 then
        turn_off(pin1)
        turn_on(pin2)
        turn_off(pin3)
      elsif ATAN2[Dummy1, Dummy2] == -90 then
        turn_off(pin1)
        turn_off(pin2)
        turn_on(pin3)
      else
        turn_off(pin1)
        turn_off(pin2)
        turn_off(pin3)
      end")
    
    assert_prog " ;\n" +
    "R[225:Dummy1]=0 ;\n" +
    "R[226:Dummy2]=0 ;\n" +
    " ;\n" +
    "IF (ATAN2[R[225:Dummy1],R[226:Dummy2]]=0) THEN ;\n" +
    "DO[33:pin1]=ON ;\n" +
    "DO[34:pin2]=OFF ;\n" +
    "DO[35:pin3]=OFF ;\n" +
    "ELSE ;\n" +
    "IF (ATAN2[R[225:Dummy1],R[226:Dummy2]]=90) THEN ;\n" +
    "DO[33:pin1]=OFF ;\n" +
    "DO[34:pin2]=ON ;\n" +
    "DO[35:pin3]=OFF ;\n" +
    "ELSE ;\n" +
    "IF (ATAN2[R[225:Dummy1],R[226:Dummy2]]=(-90)) THEN ;\n" +
    "DO[33:pin1]=OFF ;\n" +
    "DO[34:pin2]=OFF ;\n" +
    "DO[35:pin3]=ON ;\n" +
    "ELSE ;\n" +
    "DO[33:pin1]=OFF ;\n" +
    "DO[34:pin2]=OFF ;\n" +
    "DO[35:pin3]=OFF ;\n" +
    "ENDIF ;\n" +
    "ENDIF ;\n" +
    "ENDIF ;\n" +
    " ;\n"
  end

  def test_conditional_block_no_else
    parse("foo := R[1]
      pin1 := DO[33]

      if foo == 1 then
       # do something
       turn_on(pin1)
      end")

    assert_prog " ;\n" +
    "IF (R[1:foo]=1) THEN ;\n" +
    "! do something ;\n" +
    "DO[33:pin1]=ON ;\n" +
    "ENDIF ;\n"
  end

  def test_conditional_block_with_else
    parse("foo := R[1]
      pin1 := DO[33]

      if foo == 1 then
       # do something
       turn_on(pin1)
      else
        # do something else
        turn_off(pin1)
      end")

    assert_prog " ;\n" +
    "IF (R[1:foo]=1) THEN ;\n" +
    "! do something ;\n" +
    "DO[33:pin1]=ON ;\n" +
    "ELSE ;\n" +
    "! do something else ;\n" +
    "DO[33:pin1]=OFF ;\n" +
    "ENDIF ;\n"
  end

  def test_override
    parse("foo := R[1]
      use_override 50
      use_override foo")
    assert_prog "OVERRIDE=50% ;\n" + "OVERRIDE=R[1:foo] ;\n"
  end

  def test_collision_guard
    parse("foo := R[1]
      colguard_on 
      adjust_colguard
      adjust_colguard 80
      colguard_off ")
    assert_prog "COL DETECT ON ;\n" +
    "COL GUARD ADJUST ;\n" +
    "COL GUARD ADJUST 80 ;\n" +
    "COL DETECT OFF ;\n"
  end

  def test_tool_application_header
    parse("PAINT_PROCESS = {
      DEFAULT_USER_FRAME : 1,
      DEFAULT_TOOL_FRAME : 1,
      START_DELAY        : 0,
      TRACKING_PROCESS   : no
    }")

    assert_prog ""

    output = "/APPL\n"
    @interpreter.header_appl_data.each do |n|
      output += n.write(@interpreter)
    end

    assert_equal %(/APPL
PAINT_PROCESS ;
  DEFAULT_USER_FRAME : 1 ;
  DEFAULT_TOOL_FRAME : 1 ;
  START_DELAY : 0 ;
  TRACKING_PROCESS : no ;
), output
  end

  def test_tool_application_header2
    parse("LINE_TRACK = {
      LINE_TRACK_SCHEDULE_NUMBER : 0,
      LINE_TRACK_BOUNDARY_NUMBER : 0,
      CONTINUE_TRACK_AT_PROG_END : FALSE
    }")

    assert_prog ""

    output = "/APPL\n"
    @interpreter.header_appl_data.each do |n|
      output += n.write(@interpreter)
    end

    assert_equal %(/APPL
LINE_TRACK ;
  LINE_TRACK_SCHEDULE_NUMBER : 0 ;
  LINE_TRACK_BOUNDARY_NUMBER : 0 ;
  CONTINUE_TRACK_AT_PROG_END : FALSE ;
), output
  end

  def test_function_with_return
    $global_options[:function_print] = true
    parse("foo := R[1]
      def set_reg(x) : numreg    
        return (x)
      end
      foo=set_reg(100)")
      assert_prog "CALL SET_REG(100,1) ;\n"

      options = {}
      options[:output] = false
      assert_equal %(: ! ------- ;
: ! set_reg ;
: ! ------- ;
 : R[AR[2]]=AR[1] ;
 : END ;
: ! end of set_reg ;
: ! ------- ;
), @interpreter.output_functions(options)
  end


  def test_function_with_case_statement
    $global_options[:function_print] = true
    parse("foo := R[1]
      bar := R[2]
      
      def test()
        using foo, bar
        case foo
        when 1
          bar = 12345
          execBar(bar)
        when 2
          bar = 54321
          execBar(bar)
        else
          errorBar() if bar <= 0
        end
      end")
      assert_prog " ;\n"

      options = {}
      options[:output] = false
      assert_equal %(: ! ------- ;
: ! test ;
: ! ------- ;
 :  ;
 : SELECT R[1:foo]=1,JMP LBL[100] ;
 :        =2,JMP LBL[101] ;
 :        ELSE,JMP LBL[102] ;
 : JMP LBL[103] ;
 : LBL[100:caselbl1] ;
 : R[2:bar]=12345 ;
 : CALL EXECBAR(R[2:bar]) ;
 : JMP LBL[103] ;
 : LBL[101:caselbl2] ;
 : R[2:bar]=54321 ;
 : CALL EXECBAR(R[2:bar]) ;
 : JMP LBL[103] ;
 : LBL[102:caselbl3] ;
 : IF R[2:bar]<=0,CALL ERRORBAR ;
 : JMP LBL[103] ;
 : LBL[103:endcase] ;
: ! end of test ;
: ! ------- ;
), @interpreter.output_functions(options)
  end

  def test_namespace_scoping
    $global_options[:function_print] = true
    parse("namespace ns1
      VAL1 := 1
      VAL2 := 2
    end
    
    namespace ns2
      VAL1 := 3.14
      VAL2 := 2.72
    end
    
    namespace ns3
      using ns1, ns2
    
      def test()
        using ns1
    
        bar := R[15]
        bar = ns1::VAL2
      end
    
      def test2()
        using ns2
    
        foo := R[20]
        foo = ns2::VAL1
        
      end
    end
    
    foo := R[1]
    foo = ns1::VAL1
    
    bar := R[2]
    foo = ns2::VAL2")
      assert_prog " ;\n" + " ;\n" + " ;\n" + "R[1:foo]=1 ;\n" + " ;\n" + "R[1:foo]=2.72 ;\n"
      options = {}
      options[:output] = false
      assert_equal %(: ! ------- ;
: ! ns3_test ;
: ! ------- ;
 :  ;
 :  ;
 : R[15:bar]=2 ;
: ! end of ns3_test ;
: ! ------- ;
: ! ------- ;
: ! ns3_test2 ;
: ! ------- ;
 :  ;
 :  ;
 : R[20:foo]=3.14 ;
 :  ;
: ! end of ns3_test2 ;
: ! ------- ;
), @interpreter.output_functions(options)
  end

  def test_namespace_scoping_function
    $global_options[:function_print] = true
    parse("namespace ns1
      VAL1 := 'Hello'
    
      def test2() : numreg
        return(5)
      end
    end
    
    def test()
      using ns1
      foo := R[1]
      foostr := SR[2]
    
      foostr = Str::set(ns1::VAL1)
      foo = ns3::test2()
    end")
      assert_prog " ;\n"
      options = {}
      options[:output] = false
      assert_equal %(: ! ------- ;
: ! test ;
: ! ------- ;
 :  ;
 :  ;
 : CALL STR_SET('Hello',2) ;
 : CALL NS3_TEST2(1) ;
: ! end of test ;
: ! ------- ;
: ! ------- ;
: ! ns1_test2 ;
: ! ------- ;
 : R[AR[1]]=5 ;
 : END ;
: ! end of ns1_test2 ;
: ! ------- ;
), @interpreter.output_functions(options)
  end


  def test_scoping_constants
    $global_options[:function_print] = true
    parse("CONST1 := 1
      CONST2 := 0.5
      
      def test()
        using CONST1, CONST2
      
        foo := R[1]
      
        foo = CONST1
        foo = CONST2
      end")
      assert_prog " ;\n"
      options = {}
      options[:output] = false
      assert_equal %(: ! ------- ;
: ! test ;
: ! ------- ;
 :  ;
 :  ;
 :  ;
 : R[1:foo]=1 ;
 : R[1:foo]=0.5 ;
: ! end of test ;
: ! ------- ;
), @interpreter.output_functions(options)
  end

  def test_scoping_posreg
    $global_options[:function_print] = true
    parse("pfoo := PR[5]

      def test()
        using pfoo
        
        test::posreg(&pfoo)
      end")
      assert_prog " ;\n"
      options = {}
      options[:output] = false
      assert_equal %(: ! ------- ;
: ! test ;
: ! ------- ;
 :  ;
 :  ;
 : CALL TEST_POSREG(5) ;
: ! end of test ;
: ! ------- ;
), @interpreter.output_functions(options)
  end

end
