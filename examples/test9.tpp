TP_GROUPMASK = "1,1,1,*,*"
TP_COMMENT = "test prog"

p := P[1..11]

tool := UTOOL[5]
frame := UFRAME[3]

use_utool tool
use_uframe frame

default.group(1).pose -> [0,0,0,90,0,-90]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]
default.group(2).joints -> [90,0]
default.group(3).joints -> [[500,'mm']]

p1.group(1).joints -> [0, 20, 90, 0 ,90 ,180]

#apprach
p2.group(1).pose -> [0,50,0,0,0,0]
p2.group(2).joints -> [0,0]

#start
p3.group(1).xyz -> [0,50,100]
#move circle
p4.group(1).xyz -> [50,0,100]
p4.group(2).joints -> [90,90]

p5.group(1).xyz -> [0,-50,100]
p5.group(2).joints -> [90,180]

p6.group(1).xyz -> [-50,0,100]
p6.group(1).orient -> [0,0,0]
p6.group(2).joints -> [90,-90]

p7..p10 = (p3..p6).reverse

p11 = p1

