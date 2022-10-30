import tool2

namespace Sense
  using tool

  measure := R[15]
  ulrm    := UALM[1]

  def read()
    using  measure, tool

    while 0
      measure = tool::read_pin
      wait_for(250,'ms')
    end
  end

  def findZero()
    using measure, ulrm, tool

    lpos := PR[1]
    ofst := PR[2]

    use_utool tool::frame

    #measure current pose
    get_linear_position(lpos)
    
    run Sense::read()

    #determine serch vector
    Pos::clrpr(&ofst)
    if measure > 0
      ofst.z = -1*tool::SEARCH_DIST
    else
      ofst.z = 1*tool::SEARCH_DIST
    end
    #get tool offset pose
    ofst = Pos::mult(&lpos, &ofst)

    #search until 
    set_skip_condition tool::interupt_pin
    linear_move.to(ofst).at(tool::SEARCH_SPEED, 'mm/s').term(-1).skip_to(@not_zerod)

    return
    @not_zerod
      raise ulrm
  end
end