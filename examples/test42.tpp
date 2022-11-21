local := R[50..100]

varx := R[10]
varz := R[11]
pr1 := PR[22]

.assign DEBUG :< true

.assign GRP :< 2
.assign STARTX :< 0
.def STARTZ :< 100
.def PITCH :< 6

.def sum(num)

   num = num.to_i
   sum = @STARTX.to_i
   for i in 0..num do
    sum += i
    :< "pr1.group(#{@GRP}) = Pos::setxyz(#{sum}, 0, varz, 0, 0, 0)"
   end
.end

varz = STARTZ

l := LR[]
layers := LR[]
while l < layers
  varz += PITCH
  
  sum(5)

  .if :< (@DEBUG)
    printnr(varz)
  .endif
end