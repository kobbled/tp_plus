
Auto_Mode_Sel := DO[111]

namespace Laser
  using Auto_Mode_Sel

  enableio  := DO[19]
  start_     := DO[21]
  reset_     := DO[18]
  time      := TIMER[3]

  def enable()
    #close laser gate
    start_ = off
    #reset laser
    reset_ = on
    wait_for(0.5,'s')
    reset_ = off
    #reset time
    reset time
    #enable laser
    enableio = on
    wait_for(1.0,'s')

    #force override to 100% in auto mode
    if Auto_Mode_Sel
      use_override 100
    end

    #enable conditions
    wait_until(enableio).timeout_to(@alarm).after(10, 's')
    wait_until(!start_).timeout_to(@alarm).after(10, 's')
    
    return
    @alarm
    warning('Laser enable sequence failed. Must clear laser faults.')
  end
end

Laser::enable()