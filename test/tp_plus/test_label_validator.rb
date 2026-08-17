require_relative '../test_helper'

class TestLabelValidator < Test::Unit::TestCase
  def test_accepts_forward_label_references
    output = program_with(<<~LS)
       : JMP LBL[128] ;
       : LBL[128:forward_target] ;
    LS

    assert_true TPPlus::LabelValidator.validate!(output, program_name: "FORWARD")
  end

  def test_reports_undefined_labels_and_reference_lines
    output = program_with(<<~LS)
       : JMP LBL[141] ;
       : IF R[1]=1,JMP LBL[141] ;
    LS

    error = assert_raise(TPPlus::LabelValidationError) do
      TPPlus::LabelValidator.validate!(
        output,
        program_name: "TMP_CYL_PAD",
        label_names: { 141 => :non_coord_motion }
      )
    end

    assert_equal "TMP_CYL_PAD", error.program_name
    assert_equal({ 141 => [3, 4] }, error.undefined_labels)
    assert_equal({}, error.duplicate_labels)
    assert_include error.message, "TP+ label validation failed for program TMP_CYL_PAD."
    assert_equal({ 141 => ["non_coord_motion"] }, error.label_names)
    assert_include error.message, "LBL[141] (@non_coord_motion) referenced at generated LS lines 3, 4; no definition was emitted."
    assert_include error.message, "Hint: keep jump_to @name and @name in the same TP+ scope; an inline function cannot target a caller-owned label."
  end

  def test_reports_duplicate_definitions
    output = program_with(<<~LS)
       : LBL[120:first] ;
       : LBL[120] ;
       : JMP LBL[120] ;
    LS

    error = assert_raise(TPPlus::LabelValidationError) do
      TPPlus::LabelValidator.validate!(output, program_name: "DUPLICATE")
    end

    assert_equal({}, error.undefined_labels)
    assert_equal({ 120 => [3, 4] }, error.duplicate_labels)
    assert_include error.message, "LBL[120] defined 2 times at generated LS lines 3, 4."
  end

  def test_ignores_indirect_targets_comments_and_position_data
    output = <<~LS
      /PROG INDIRECT
      /MN
       : JMP LBL[R[1]] ;
       : ! JMP LBL[998] is example text ;
       : MESSAGE[Check LBL[997]] ;
      /POS
      LBL[999]
      /END
    LS

    assert_true TPPlus::LabelValidator.validate!(output, program_name: "INDIRECT")
  end

  def test_validates_output_fragments_without_an_mn_header
    output = <<~LS
       : Skip,LBL[150] ;
       : TIMEOUT,LBL[151] ;
       : LBL[150:skip_target] ;
       : LBL[151] ;
    LS

    assert_true TPPlus::LabelValidator.validate!(output, program_name: "FRAGMENT")
  end

  private

  def program_with(motion_lines)
    <<~LS
      /PROG TEST
      /MN
      #{motion_lines}/END
    LS
  end
end
