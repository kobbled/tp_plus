foo := SR[1]
bar := R[2]

sum := R[20]
j   := R[21]

def linear_sequence(n1, n2) : numreg
  return(n1*n2)
end
indirect('r', 2) = linear_sequence(sum, j)


call indirect('sr', bar)()