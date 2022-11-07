namespace ns1
  CONST1 := 1

  inline def func1(num)
    print_nr(num)
    print('HELLO')
  end

  inline def func2() : numreg
    using CONST1, func1

    var1 := R[1]
    var1 = CONST1 + 1

    func1(var1)

    return(var1)
  end
end

var2 := R[2]

var2 = ns1::func2()