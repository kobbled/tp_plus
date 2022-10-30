number    := R[56]
Dummy_1   := R[225]
Dummy_2   := R[226]

i := R[46]
j := R[48]
k := R[50]

userclear()
usershow()

number = userReadInt('enter length of ascii tree.')

Dummy_1 = number - 1
for i in (0 to Dummy_1)
  Dummy_2 = Dummy_1 - i
  for j in (0 to Dummy_2)
    print(' ')
  end
  
  for k in (0 to i)
    print('* ')
  end
  print_line('')
end
