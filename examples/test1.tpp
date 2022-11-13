p := P[1]
r := R[1]
grp := GO[2]

use_uframe 0
use_utool 1

p.joints -> [0,0,0,0,0,0]

linear_move.to(p).at(100, 'mm/s').term(0).distance_before(r, grp=10)
