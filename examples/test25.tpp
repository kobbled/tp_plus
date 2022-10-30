local := R[50..70]

sum := LR[]

def ratio(ar1) :numreg
    divisor := LR[]

    if (ar1 % 2 == 0)
      divisor = 2
    else
      divisor = 1
    end

    return(ar1/divisor)
end

def addin() : numreg
    foo := LR[]
    bar := LR[]

    bar = multiple(bar)
    return(foo + bar)
end

def multiple(ar1) : numreg
    multiplier := LR[]

    multiplier = 10
    return(ar1*multiplier)
end

sum = addin()
sum = ratio()
