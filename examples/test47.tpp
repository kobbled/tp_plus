local := R[50..70]

EPSILON := 0.001
x := LR[]

if (Mth::abs(x) > EPSILON)
  #do stuff in here
  x = Mth::abs(x)
end

if (Mth::abs(x) > EPSILON) then
  #do stuff in here
  x = Mth::abs(x)
end

while (Mth::abs(x) > EPSILON)
  #do stuff in here
  x = Mth::abs(x)
end