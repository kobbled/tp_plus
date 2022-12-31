local := R[10..15]

namespace ns1
  VAL1 := 1
  VAL2 := 2

  inline def func2() : numreg
    return(VAL1 + VAL2)
  end

  inline def func1(num) : numreg
    add := LR[]
    add = func2()
    return(add + num)
  end
end

foo := R[1]
bar := R[2]

foo = 10

bar = ns1::func1(foo)