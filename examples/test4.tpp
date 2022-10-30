pr1 := PR[20]

#set robot pose
pr1.group(1) = Pos::setxyz(500, 500, 0, 90, 0, 180)
pr1.group(1) = Pos::setcfg('F U T, 0, 0, 0')
#set rotary pose
pr1.group(2) = Pos::setjnt2(90, 0)
pr1.group(2) = Pos::setjnt(90)

#no group
pr1 = Pos::move()
