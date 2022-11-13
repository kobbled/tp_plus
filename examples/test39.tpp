namespace ns1
  CONST1 := 10
  var1 := R[12]

  def func1()
   var1 = CONST1
  end
end

namespace ns2
  using ns1

  CONST1 := 22
  var1 := R[45]

  def func1()
   ns1::func1()
   var1 = CONST1
  end
end

ns1::func1()
ns2::func1()