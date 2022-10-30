p := P[1..5]
use_uframe 3
use_utool 2

default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]
default.group(2).joints -> [0]

p1.group(1).pose.polar.z -> [0, 80, 300, 90, 180, 0]
p1.group(2).joints -> [0]
linear_move.to(p1).at(30, 'mm/s').term(-1)

(p2..p5).group(1).xyz.offset.polar.z -> [45, 0 ,0]
#keep tool straight
(p2..p5).group(2).joints.offset -> [-45]
arc_move.to(p2).at(30, 'mm/s').term(100)
arc_move.to(p3).at(30, 'mm/s').term(100)
arc_move.to(p4).at(30, 'mm/s').term(100)
arc_move.to(p5).at(30, 'mm/s').term(-1)