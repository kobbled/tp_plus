namespace ns1
  using env

  inline def func1(arg1, arg2, arg3)
    TP_GROUPMASK = "1,*,*,*,*"

    pr1 := LPR[]
    pr1 = Pos::setxyz(-1*arg2, 0, -1*arg3, arg1, 0, 0)
    pr1 = Pos::setcfg('F U T, 0, 0, 0')

    #move to the target
    joint_move.to(pr1).at(20, '%').term(-1)
  end

  inline def func2(arg1, arg2, arg3)
    TP_GROUPMASK = "1,*,*,*,*"

    theta := LR[]
    theta = 360/arg1

    circle := LR[]
    for circle in (1 to 2)
      power := LR[]
      power = Mth::pow(-1,circle+2)

      pr2      := LPR[]
      shift    := LPR[]

      pt       := LR[]

      for pt in (0 to arg1)
        if pt == 0 then
            theta = 0
        end
      end
      
      if circle < 1 then
        Pos::clrpr(&shift)
        shift.r = arg3
        pr2 = Pos::mult(&pr2, &shift)

        joint_move.to(pr2).at(20, '%').term(-1)
      end

    end

  end
end