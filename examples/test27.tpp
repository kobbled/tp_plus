local := R[55..60]

namespace ns1
  VAL1 := 'Hello'

  def test2() : numreg
    return(5+ns1::ns2::test3())
  end

  namespace ns2
    VAL2 := true

    def test3() : numreg
      add_val := LR[]

      return(10+add_val)
    end
  end
end

def test()
  using ns1
  foo := R[1]
  foostr := SR[2]

  foostr = Str::set(ns1::VAL1)
  foo = ns1::test2()
end

test()