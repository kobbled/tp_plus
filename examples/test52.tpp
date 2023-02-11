p1 := P[1]
pr1 := PR[1]

.assign TOF_TYPE :< "dynamic"

.doR
  if (@TOF_TYPE == "static")
    # rtcp type motion when workpiece approaching tof
    puts "Using tool offset"
    :< '.def TOF_APPR_TYPE :< "tool_offset"'
  elsif (@TOF_TYPE == "dynamic")
    puts "Using frame offset"
    :< '.def TOF_APPR_TYPE :< "offset"'
  end
.end

linear_move.to(p1).at(5, 'mm/s').term(-1).TOF_APPR_TYPE (pr1)