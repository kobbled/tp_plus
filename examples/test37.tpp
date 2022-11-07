local := R[70..80]

def func2(val, exp) : numreg
  num := LR[]
  num = Mth::exp(exp * Mth::ln(val))
  return(num)
end

power := R[20]
power = ns1::func2(4, 2)