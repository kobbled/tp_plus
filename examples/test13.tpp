p := P[1..4]
q := P[5..8]

use_uframe 3
use_utool 2

p1.group(1).pose.polar.z -> [0, 80, 300, 90, 180, 0]
p2.group(1).pose.polar.z -> [90, 80, 300, 90, 180, 0]
p3.group(1).pose.polar.z -> [180, 80, 300, 90, 180, 0]
p4.group(1).pose.polar.z -> [270, 80, 300, 90, 180, 0]

q1.group(1).pose.polar.z.fix -> [0, 80, 300, 180, 0, 0]
q2.group(1).pose.polar.z.fix -> [90, 80, 300, 180, 0, 0]
q3.group(1).pose.polar.z.fix -> [180, 80, 300, 180, 0, 0]
q4.group(1).pose.polar.z.fix -> [270, 80, 300, 180, 0, 0]