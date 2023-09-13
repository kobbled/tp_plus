f := F[1..10]
local := R[1..20]

namespace ns1
  inline def func2(amt) : numreg
    roti := LR[]
    i := LR[]
    d1 := LR[]
    d2 := LR[]

    roti = Mth::abs(amt)
    if (roti < 180)
        d1 = 1
    else
        d1 = 2
    end

    # rotation motion
    for i in (1 to d1)
        # motion part
        roti = amt / d1
    end

    return(roti)
  end

  inline def func1(rot)
    i := LR[]
    rot = func2(rot)
  end

end

if f5
  rotDeg := LR[]
  rotDeg = 30.5
  # check motion
  ns1::func1(rotDeg)
end