local := R[70..80]

foo := R[10]
bar := R[11]
biz := R[12]
baz := R[13]

namespace Math
  PI := 3.14159

  def test(ar1, ar2, ar3) : numreg
    return(Math::test2(ar1, ar2)*(ar1+ar2+ar3))
  end

  def test2(ar1, ar2) : numreg
    if ar1 > ar2
      return(0.5)
    end

    return(1)
  end
end

foo = Mth::ln(2)

foo = Mth::test(5+3, bar*biz/2, -1*biz*Math::PI)

foo = Mth::test(bar*biz/2, set_reg(biz), -1*biz*Math::PI)

foo = Mth::test3(bar*Math::PI*set_reg(baz))