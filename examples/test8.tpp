namespace ns1
  VAL1 := 1
  VAL2 := 2
end

namespace ns2
  VAL1 := 3.14
  VAL2 := 2.72
end

namespace ns3
  using ns1
  
  VAL1 := 'Hello'

  def test2() : numreg
    return(ns1::VAL1 + 5)
  end
end

def test()
  using ns1, ns2, ns3
  foo := R[1]
  bar := R[2]
  foostr := SR[3]

  foo = ns2::VAL1
  bar = ns2::VAL2

  foostr = Str::set(ns3::VAL1)
  foo = ns3::test2()
end