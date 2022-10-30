def goHome()
  TP_GROUPMASK = "1,*,*,*,*"
  TP_COMMENT = "home"

  p := P[1]

  use_utool 1
  use_uframe 0

  p.joints -> [0, 20, 90, 0 ,90 ,180]
  joint_move.to(p).at(30, '%').term(-1)

end