use_utool 3
use_uframe 2

TP_GROUPMASK = "1,1,*,*,*"

default.group(1).pose -> [0,0,0,90,180,0]
default.group(1).config -> ['F','U','T', 0, 0, 0]
default.group(2).joints -> [0]


.assign RADIUS :< 80
.assign INCREMENTS :< 20
.assign DISTANCE :< 100

.do
  #define points
  :< "p := P[1..#{@INCREMENTS}]"

  #set first point
  :< "joint_move.to(p1).at(15, '%').term(-1)\n"

  inc = @INCREMENTS.to_i
  degree = 0
  for i in 1..inc do
    #get degree
    degree = 360*(i-1)/(inc-1)
    :< "p#{i}.group(1).pose.polar.z -> [#{(-1*degree).to_s}, #{@RADIUS.to_s}, #{@DISTANCE.to_s}, 90, 180, 0]\n"
    :< "p#{i}.group(2).joints -> [#{(degree).to_s}]\n"
    :< "arc_move.to(p#{i}).at(50, 'mm/s').term(#{(i == 1 || i == inc) ? '-1' : '100'}).coord\n"
  end
.end



