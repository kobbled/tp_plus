def test(d) : numreg
  cond1 := F[1]
  q := R[5..6]

  if cond1 == on
    q1 = LN[d]
    q2 = (4.53+(3.13*q1))
    
    if (q2 < 0.25) && (q2 > -0.25)
      return(0)
    else
      return(q2)
    end
  end
end