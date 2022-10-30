namespace touchPose
  strt := PR[1]
  search_dist := PR[2]
  found := PR[3]
end

namespace sensor
  signal := DI[1]
  val    := AI[1]
  zerod  := DI[2]

  POLLING_RATE := 0.5
  SAMPLING_TIME := 0.3

  def sample(pin, time) : numreg
    using POLLING_RATE, SAMPLING_TIME
    
    t := R[150]
    sum := R[151]
    inc := R[152]
    
    t = 0
    sum = 0
    inc = 0
    while t < time
      sum += indirect('ai', pin)
      
      wait_for(POLLING_RATE, 's')
      inc += 1
      t += POLLING_RATE
    end

    return(sum/inc)
  end
end

sensor_reading := R[1]
i    := R[150]

FINE := -1

#get start position
get_linear_position(touchPose::strt)

#clear found pose
pos::clrpr(&touchPose::found)

if !sensor::signal
    warning('Sensor is not starting on a surface. Check sensor measurement.')
end

#skip condition when sensor read 0. Setup as a digital pin from sensor.
set_skip_condition sensor::zerod

i = 0
@find_zero
  i += 1

  #offset value. Assuming tool frame is pointing into the surface.
  case i
    when 1
      #initially move down 100mm.
      pos::clrpr(&touchPose::search_dist)
      touchPose::search_dist.z = 100
      
      #search for touch if not found go back to start of loop
      #On next iteration move from previous position
      linear_move.to(touchPose::strt).at(20, 'mm/s').term(FINE).
          tool_offset(touchPose::search_dist).
          skip_to(@find_zero)

      #if found jump label
      jump_to @found_zero
    when 2
      #next try moving up 100mm
      pos::clrpr(&touchPose::search_dist)
      touchPose::search_dist.z = -100

      #search for touch if not found go back to start of loop
      #On next iteration move from lpos
      linear_move.to(touchPose::strt).at(20, 'mm/s').term(FINE).
          tool_offset(touchPose::search_dist).
          skip_to(@find_zero, touchPose::strt)
      
      jump_to @found_zero
    when 3
      #next try moving down 500mm
      pos::clrpr(&touchPose::search_dist)
      touchPose::search_dist.z = 500

      #search for touch if not found go back to start of loop
      #save lpos position
      linear_move.to(touchPose::strt).at(50, 'mm/s').term(FINE).
          tool_offset(touchPose::search_dist).
          skip_to(@find_zero, touchPose::strt)
      
      jump_to @found_zero
    else
      # raise warning
      warning('Could not find surface after 4 iterations!')
  end

jump_to @end

@found_zero
  get_linear_position(touchPose::found)

  #sample sensor
  wait_for(100, "ms") # make sure robot isnt moving
  sensor_reading = sensor::sample(&sensor::val, sensor::SAMPLING_TIME)

jump_to @end

@end