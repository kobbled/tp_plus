use_utool 3
use_uframe 2

TP_GROUPMASK = "1,1,*,*,*"

default.group(1).pose -> [0,0,0,90,180,0]
default.group(1).config -> ['F','U','T', 0, 0, 0]
default.group(2).joints -> [0]

p := P[1..21]
p1.group(1).pose.polar.z -> [0, 80, 100, 90, 180, 0]
p1.group(2).joints -> [0]

(p2..p21).group(1).xyz.offset.polar.z -> [-18, 0 ,0]
(p2..p21).group(2).joints.offset -> [18]

joint_move.to(p1).at(15, '%').term(-1)
arc_move.to(p1).at(50, 'mm/s').term(-1).coord
arc_move.to(p2).at(50, 'mm/s').term(100).coord
arc_move.to(p3).at(50, 'mm/s').term(100).coord
arc_move.to(p4).at(50, 'mm/s').term(100).coord
arc_move.to(p5).at(50, 'mm/s').term(100).coord
arc_move.to(p6).at(50, 'mm/s').term(100).coord
arc_move.to(p7).at(50, 'mm/s').term(100).coord
arc_move.to(p8).at(50, 'mm/s').term(100).coord
arc_move.to(p9).at(50, 'mm/s').term(100).coord
arc_move.to(p10).at(50, 'mm/s').term(100).coord
arc_move.to(p11).at(50, 'mm/s').term(100).coord
arc_move.to(p12).at(50, 'mm/s').term(100).coord
arc_move.to(p13).at(50, 'mm/s').term(100).coord
arc_move.to(p14).at(50, 'mm/s').term(100).coord
arc_move.to(p15).at(50, 'mm/s').term(100).coord
arc_move.to(p16).at(50, 'mm/s').term(100).coord
arc_move.to(p17).at(50, 'mm/s').term(100).coord
arc_move.to(p18).at(50, 'mm/s').term(100).coord
arc_move.to(p19).at(50, 'mm/s').term(100).coord
arc_move.to(p20).at(50, 'mm/s').term(100).coord
arc_move.to(p21).at(50, 'mm/s').term(-1).coord
