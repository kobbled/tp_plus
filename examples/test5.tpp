i := R[178]
total := R[192]
type := R[264]
axes := R[223]

foo := PR[21]

TP_GROUPMASK = "1,1,1,*,*"

namespace PRTypes
  POSITION  := 1
  XYZWPR    := 2
  XYZWPREXT := 6
  JOINTPOS  := 9
end

userclear()

# get total number of groups on controller
total = pos::grplen()

#get current position
get_linear_position(foo)

for i in (1 to total)
  type = pos::prtype(&foo, i)
  axes = pos::axescnt(&foo, i)

  case type
    when PRTypes::POSITION
      print('Group ')
      printnr(&i)
      print_line(' is a Cartesian Pose.')
    when PRTypes::XYZWPR
      print('Group ')
      printnr(&i)
      print_line(' is a Cartesian Pose.')
    when PRTypes::XYZWPREXT
      print('Group ')
      printnr(&i)
      print(' is a Cartesian Pose. with ')
      printnr(&axes)
      print(' Extended axes.')
      print_line('')
    when PRTypes::JOINTPOS
      print('Group ')
      printnr(&i)
      print(' is a Joint Pose. with ')
      printnr(&axes)
      print(' axes.')
      print_line('')
  end
end

usershow()
