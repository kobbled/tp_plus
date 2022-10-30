p := P[1..5]
p_new := P[100]

use_uframe 3
use_utool 2

default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['N', 'U', 'T', 0, 0, 0]
default.group(2).joints -> [90, 0]

p1.group(1).pose -> [0, 80, 300, 90, 180, 0]

p2.group(1).orient.offset -> [0, 10, 10]
p2.group(2).joints.offset -> [0, 10]

p3.group(1).orient.offset -> [0, 10, 10]
p3.group(2).joints.offset -> [0, 10]

p4.group(1).orient.offset -> [0, 10, 10]
p4.group(2).joints.offset -> [0, 10]

p5.group(1).orient.offset -> [0, 10, 10]
p5.group(2).joints.offset -> [0, 10]

p_new = p1
