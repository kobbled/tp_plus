local := R[70..80]

namespace ns1
  var1 := R[1]
  var2 := R[2]

  CONST1 := 2.5
  CONST2 := 10
end

namespace ns1
  def func1(num)
    print_nr((CONST2*num)/CONST1)
    print('HELLO')
  end

  def func2(val, exp) : numreg
    var1 = val
    var2 = exp

    num := LR[]
    num = Mth::exp(exp * Mth::ln(val))

    return(num)
  end
end

power := R[10]
power = ns1::func2(4, 2)