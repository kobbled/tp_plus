import enum

namespace ns1
  using env, Axis

  inline def add(ar1, ar2) : numreg
    return(ar1 + ar2)
  end

  inline def add_div(ar1, ar2, ar3) : numreg
    return(add(ar1, ar2)/ar3)
  end
end