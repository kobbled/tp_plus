p1 := P[1]
pr1 := PR[1]

.assign TOF_TYPE :< "static"

.doR
  if (@TOF_TYPE == "static")
      # rtcp type motion when workpiece approaching tof
      puts "I am in the static if statement of the TOF_APPR_TYPE definition"
      :< '.def TOF_APPR_TYPE :< "tool_offset"'
      puts "I passed the previous line"
  else
      puts "I am in else statement of the TOF_APPR_TYPE definition"
  end
.end

linear_move.to(p1).at(5, 'mm/s').term(-1).TOF_APPR_TYPE (pr1)