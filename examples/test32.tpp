
def process()
  using env

  TP_GROUPMASK = "1,*,1,*,*"

  use_utool Tool1::frame
  use_uframe Positioner::frame

  #move home
  linear_move.to(Positioner::home).at(100, 'mm/s').term(-1)

  Lam::set_parameters(&Lam::power, &Lam::flowrate, &Lam::speed)
  Lam::enable = on

  while l < layers

    #pause after each layer
    if (layers > 1)
      Lam::enable = off
      #move home
      linear_move.to(Positioner::home).at(100, 'mm/s').term(-1)
      pause
      Lam::enable = on
    end
    
    #run through path
    Lam::strt = on
    while j < passes
      call program_name()
    end
    Lam::strt = off
  end

  Lam::enable = off

  #move home
  linear_move.to(Positioner::home).at(100, 'mm/s').term(-1)
end