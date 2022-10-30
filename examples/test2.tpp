sum := R[1]
prop := R[2]
i := R[3]
j := R[4]

SEED := 1
INCREMENTS := 5
AMPLITUDE := 100
MAX_PROPIGATION := 30
WAVE_DISTANCE := 20

def linear_sequence(n1, n2) : numreg
  using AMPLITUDE
  return(n1*n2 + AMPLITUDE)
end

def divide_sequence(n1, n2) : numreg
  if n2 < 1 then
    return(n1)
  end

  return(n1/n2)
end

i=0
while i < MAX_PROPIGATION
  # inital seed
  sum = SEED
  j = 0
  while (j < WAVE_DISTANCE)
    sum = divide_sequence(sum, j)
    sum = linear_sequence(sum, i)

    j += 1
  end
  i += INCREMENTS
end