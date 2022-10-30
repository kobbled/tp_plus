TP_GROUPMASK = "1,*,*,*,*"
TP_COMMENT = "test prog"

p := P[1..6]

tool := UTOOL[5]
frame := UFRAME[3]

use_utool tool
use_uframe frame

#declare a default pose to set all positions to
#if they are not explicitly declared
default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]

#declare joint pose
p1.group(1).joints -> [180, 23.2, 90.5, 0, 60.8, -90.5]
joint_move.to(p1).at(30, '%').term(-1)

#declare position
p2.group(1).pose -> [0,50,100,0,90,0]
p2.group(1).config -> ['F', 'U', 'T', 0, 0, 0]

#independently set position and orientation
p3.group(1).xyz -> [0,30,0]
p3.group(1).orient -> [90,0,0]
p3.group(1).config -> ['F', 'U', 'T', 0, 0, 0]

arc_move.to(p2).at(50, 'mm/s').term(100)
arc_move.to(p3).at(50, 'mm/s').term(100)

#batch declare poses, as well as apply offsets
(p4..p6).group(1).xyz.offset -> [0, 0 ,50]
linear_move.to(p4).at(50, 'mm/s').term(-1)
linear_move.to(p5).at(30, 'mm/s').term(100)
linear_move.to(p6).at(30, 'mm/s').term(-1)
