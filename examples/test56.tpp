local := R[55..60]
local := F[10..20]
shared := R[40..50]
shared := F[1..10]

# > [!important]
# > Shared variables must be defined before any namespace, function, or import
# > As they must defined before the namespace, or function is evaluated.
shr_f1 := SF[]
shr_r1 := SHR[]

namespace ns1
  inline def test2() : numreg
    if shr_f1
      return(5+ns1::ns2::test3())
    else
      return((ns1::ns2::test3()))
    end
  end

  namespace ns2
    def test3() : numreg
      add_val := LR[]

      add_val = 10
      return(shr_r1+add_val)
    end
  end
end

foo := R[1]
foostr := SR[2]

foostr = Str::set("Hello")
foo = ns1::test2()
