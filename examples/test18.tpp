p := P[1..3]
pr1 := PR[78]

TP_GROUPMASK = "1,*,*,*,*"

use_uframe 2
use_utool 1

default.group(1).pose -> [0,0,200,180,0,90,500]
default.group(1).extunits -> ['mm']
default.group(1).config -> ['N', 'U', 'T', 0, 0, 0]

jump_to @skip
@poses
linear_move.to(p1).at(100, 'mm/s').term(-1)
p2.group(1).pose -> [0,0,200,180,0,90,200]
linear_move.to(p2).at(100, 'mm/s').term(-1)
p3.group(1).pose -> [0,0,200,180,0,90,100]
linear_move.to(p3).at(100, 'mm/s').term(-1)
@skip
#move to pos1
linear_move.to(p1).at(100, 'mm/s').term(-1)
#change rail distance
pr1 = p1
pr1.group(1).e1 = 1000
#move to same pose
linear_move.to(pr1).at(100, 'mm/s').term(-1)