local := R[50..100]
local := F[30..40]
local := PR[10..30]


namespace ns1
  def func1(ppc, fdist, cdist) : posreg
    TP_GROUPMASK = "1,*,*,*,*"

    var1  := LR[] 
    var2  := LR[]

    pr1 := LPR[]
    shift := LPR[]

    var1 = ppc*fdist
    var2 = ppc*cdist

    RETURN(Pos::setxyz(var1, 0, var2, 0, 0, 0))

  end

  def func2(add1, add2) : numreg
    TP_GROUPMASK = "1,*,*,*,*"

    var3 := LR[]
    MULTIPLIER := 10
    
    var3 = MULTIPLIER

    return(var3*(add1 + add2))
  end

  def func3(dist)
    TP_GROUPMASK = "1,*,*,*,*"

    pos := P[1]

    pos.group(1).pose -> [0, 0, 0, 0, 0 ,0]
    pos.group(1).config -> ['N', 'U', 'T', 0, 0, 0]

    pr1 := LPR[]
    Pos::clrpr(&pr1)

    pr1 = pos

    linear_move.to(pos).at(50, 'mm/s').term(-1)
  end

  def func4(ofst1, ofst2) : posreg
    TP_GROUPMASK = "1,*,*,*,*"

    pr1 := LPR[]
    Pos::clrpr(&pr1)

    pr1 = Pos::setxyz(ofst1, 0, ofst2, 0, 0, 0)
    pr1 = Pos::setcfg('N U T, 0, 0, 0')

    return(pr1)

  end

end

#constents
GRIPPER_DEPTH := 75
PPC := 3   # recorded points per circle


#variables
part_rad         := LR[]
far_dist         := LR[]
close_dist       := LR[]
total_dist       := LR[]

correctTCP  := LF[]

curr_pose := LPR[]
newpose := LPR[]

FAR_DISTANCE := 10
CLOSE_DISTANCE := 10

PART_LEN := 200

part_rad = 100/2

# for approach target calculation
far_dist = PART_LEN - (GRIPPER_DEPTH + FAR_DISTANCE)
close_dist = far_dist - (GRIPPER_DEPTH + CLOSE_DISTANCE)

CLEARANCE := 10               # initial clearance between part and tof with respect to measure frame

correctTCP = on

TP_GROUPMASK = "1,*,*,*,*"

default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['N', 'U', 'T', 0, 0, 0]

use_uframe 1
use_utool 1

total_dist = ns1::func2(far_dist, close_dist)

while correctTCP
  Pos::clrpr(&curr_pose)
  get_linear_position(curr_pose)

  newpose = ns1::func1(PPC, far_dist, close_dist)
end

ns1::func3(CLEARANCE)

