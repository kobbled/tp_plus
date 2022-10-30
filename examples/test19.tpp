p := P[1..3]
TP_GROUPMASK = "1,*,*,*,*"

use_uframe 2
use_utool 1

default.group(1).joints -> [-86,12,-18,-92,-85,63,[200,'mm']]

#move to pos1
joint_move.to(p1).at(5, '%').term(-1)
p2.group(1).joints -> [-86,12,-18,-92,-85,63,[500,'mm']]
joint_move.to(p2).at(5, '%').term(-1)
p3.group(1).joints -> [-86,12,-18,-92,-85,63,[1000,'mm']]
joint_move.to(p3).at(5, '%').term(-1)