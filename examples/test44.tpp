namespace Sense
  measure := R[10]
  sensor_signal := DO[10]
  sensor_zero := DO[11]

  def zero(dist, outpose)
    TP_GROUPMASK = "1,*,*,*,*"

    start_pose := PR[8]
    Tool_Offset := PR[25]

    get_linear_position(start_pose)

    if !sensor_signal
      message("Sensor is out of range. Manually move in and continue.")
      pause
    end

    @zero
      Pos::clrpr(&Tool_Offset)
      if measure > 0
        Tool_Offset.z = -1*dist
      else
        Tool_Offset.z = 1*dist
      end

      set_skip_condition sensor_zero
      linear_move.to(indirect('PR', start_pose)).at(3, 'mm/s').term(-1).
          tool_offset(Tool_Offset).
          skip_to(@failed)
      
      get_linear_position(indirect('PR', outpose))

      return
    @failed
      message("Sensor zeroing failed. Manually move in range, and retry.")
      pause
      jump_to @zero
  end

  def none(dist, outpose)
    TP_GROUPMASK = "1,*,*,*,*"

    start_pose := PR[8]
    Tool_Offset := PR[25]

    get_linear_position(start_pose)

    if !sensor_signal
      message("Sensor is out of range. Manually move in and continue.")
      pause
    end

    @zero
      Pos::clrpr(&Tool_Offset)
      Tool_Offset.z += dist

      set_skip_condition !sensor_signal
      linear_move.to(indirect('PR', start_pose)).at(3, 'mm/s').term(-1).
          tool_offset(Tool_Offset).
          skip_to(@failed)
      
      get_linear_position(indirect('PR', outpose))

      return
    @failed
      message("Sensor zeroing failed. Manually move in range, and retry.")
      pause
      jump_to @zero
  end
end

pr1 := PR[5]
Sense::zero(10, &pr1)