# TP+ Examples

TP+
```ruby
```

LS
```fanuc
/PROG example_1
/MN
/END
```

IO
------------

TP+
```Ruby

bar  := DO[1]
baz  := DO[2]

turn_on bar if foo == 5
toggle baz
```

LS
```Fanuc
/PROG example
/MN
  : IF (R[1:foo]=5),DO[1:bar]=(ON) ;
  : DO[2:baz]=(!DO[2:baz]) ;
/END
```

Loops
------------

TP+
```ruby
```

LS
```fanuc
/PROG example_1
/MN
/END
```

### looping with a jump label

TP+
```ruby
    foo  := R[1]

    foo = 1

    @loop
      foo += 1
      jump_to @loop if foo < 10
```


LS
```fanuc
/PROG example_1
/MN
  : R[1:foo] = 1 ;
  :  ;
  : LBL[100:loop] ;
  : R[1:foo]=R[1:foo]+1 ;
  : IF R[1:foo]<10,JMP LBL[100] ;
/END
```

Conditionals
------------

### If-Then Block

TP+
```ruby
foo := R[1]
pin1 := DO[33]
pin2 := DO[34]

# if with no else

if foo == 1 then
 # do something
 turn_on(pin1)
end


#if else block

if $SCR.$NUM_GROUP > 1 then
  #true block
  turn_on(pin1)
else
  #false block
  turn_off(pin1)
end

# else if block

if foo == 1 then
  #true block
  turn_on(pin1)
elsif foo==2 then
  #false block
  turn_on(pin2)
end

# else if - else block

if foo == 1 then
  #true block
  turn_on(pin1)
elsif foo==2 then
  #false block
  turn_on(pin2)
else
  turn_off(pin1)
  turn_off(pin2)
end
```

LS
```fanuc
/PROG example_1
/MN
 :  ;
 : ! if with no else ;
 :  ;
 : IF (R[1:foo]=1) THEN ;
 : ! do something ;
 : DO[33:pin1]=ON ;
 : ENDIF ;
 :  ;
 : ! if else block ;
 :  ;
 : IF ($SCR.$NUM_GROUP>1) THEN ;
 : ! true block ;
 : DO[33:pin1]=ON ;
 : ELSE ;
 : ! false block ;
 : DO[33:pin1]=OFF ;
 : ENDIF ;
 :  ;
 : ! else if block ;
 :  ;
 : IF (R[1:foo]=1) THEN ;
 : ! true block ;
 : DO[33:pin1]=ON ;
 : ELSE ;
 : IF (R[1:foo]=2) THEN ;
 : ! false block ;
 : DO[34:pin2]=ON ;
 : ENDIF ;
 : ENDIF ;
 :  ;
 :  ;
 : ! else if - else block ;
 :  ;
 : IF (R[1:foo]=1) THEN ;
 : ! true block ;
 : DO[33:pin1]=ON ;
 : ELSE ;
 : IF (R[1:foo]=2) THEN ;
 : ! false block ;
 : DO[34:pin2]=ON ;
 : ELSE ;
 : DO[33:pin1]=OFF ;
 : DO[34:pin2]=OFF ;
 : ENDIF ;
 : ENDIF ;
 :  ;
/END
```


Select
---------

TP+
```ruby
foo := R[1]
foo2:= R[2]
foo3 := DO[1]
t    := TIMER[1]

case foo
when 1
  message('foo == 1')
  wait_for(1, 's')
  turn_on foo3
when 2
  PROG1()
  foo2 += 1
else
  stop t
  GO_HOME()
end
```

LS
```fanuc
/PROG example_1
/MN
 :  ;
 : SELECT R[1:foo]=1,JMP LBL[100] ;
 :        =2,JMP LBL[101] ;
 :        ELSE,JMP LBL[102] ;
 :  ;
 : LBL[100:caselbl1] ;
 : MESSAGE[foo == 1] ;
 : WAIT 1.00(sec) ;
 : DO[1:foo3]=ON ;
 : JMP LBL[103] ;
 : LBL[101:caselbl2] ;
 : CALL PROG1 ;
 : R[2:foo2]=R[2:foo2]+1 ;
 : JMP LBL[103] ;
 : LBL[102:caselbl3] ;
 : TIMER[1]=STOP ;
 : CALL GO_HOME ;
 : JMP LBL[103] ;
 : LBL[103:endcase] ;
/END
```

Motion
------------

TP+
```ruby
home := PR[1]
lpos := PR[2]


linear_move.to(home).at(2000, 'mm/s').term(0)
get_linear_position(lpos)
```

LS
```fanuc
/PROG example_1
/MN
  : L PR[1:home] 2000mm/sec CNT0 ;
  : PR[2:lpos]=LPOS ;
/END
```

Positions
----------------

TP+
```ruby
position_data
{
  'positions' : [
    {
      'id' : 1,
      'mask' :  [{
        'group' : 1,
        'uframe' : 5,
        'utool' : 2,
        'config' : {
            'flip' : false,
            'up'   : true,
            'top'  : true,
            'turn_counts' : [0,0,0]
            },
        'components' : {
            'x' : -.590,
            'y' : -29.400,
            'z' : 1304.471,
            'w' : 78.512,
            'p' : 89.786,
            'r' : -11.595
            }
        },
        {
        'group' : 2,
        'uframe' : 5,
        'utool' : 2,
        'components' : {
            'J1' : 0.00
            }
        }]
    }
  ]
}
end
```

LS
```fanuc
/PROG example_1
/POS
P[1:""]{
   GP1:
  UF : 5, UT : 2,  CONFIG : 'N U T, 0, 0, 0',
  X = -0.59 mm, Y = -29.4 mm, Z = 1304.471 mm,
  W = 78.512 deg, P = 89.786 deg, R = -11.595 deg
   GP2:
  UF : 5, UT : 2, 
  J1 = 0.0 deg
};
/END
```


Function parameters
------------

TP+
```ruby
ar1 := AR[1]
ar2 := AR[2]
foo1 := R[3]
foo2 := R[4]

# pass ar1 and foo1 by reference
# pass ar2 and foo2 by value
FUNC01(&ar1, ar2, &foo1, foo2)
```

LS
```fanuc
/PROG example_1
/MN
 :  ;
 : ! pass ar1 and foo1 by reference ;
 : ! pass ar2 and foo2 by value ;
 : CALL FUNC01(1,AR[2],3,R[4:foo2]) ;
/END
```

Arguments
------------

TP+
```ruby
ar1 := AR[1]
ar2 := AR[2]
poo1 := PR[1]

#if AR[1] is a posreg number set y = 5
indirect('pr', ar1).group(1).y=5

#if Ar[1], AR[2] are numreg addresses
indirect('r', ar2) = SIN[indirect('r', ar1)]

# if AR[1] is a posreg number put current position
# into that register
get_linear_position(indirect('PR', ar1))

# if AR[1] is a posreg number goto that posreg
linear_move.to(indirect('pr', ar1)).at(2000, 'mm/s').term(-1)

# if AR[2] is a posreg number use that posreg as the user offset
linear_move.to(poo1).at(100, 'mm/s').term(-1).offset(indirect('pr', ar2))
```

LS
```fanuc
/PROG example_1
/MN
 :  ;
 : ! if AR[1] is a posreg number set ;
 : ! y = 5 ;
 : PR[GP1:AR[1],2]=5 ;
 :  ;
 : ! if Ar[1], AR[2] are numreg ;
 : ! addresses ;
 : R[AR[2]]=SIN[R[AR[1]]] ;
 :  ;
 : ! if AR[1] is a posreg number put ;
 : ! current position ;
 : ! into that register ;
 : PR[AR[1]]=LPOS ;
 :  ;
 : ! if AR[1] is a posreg number ;
 : ! goto that posreg ;
 : L PR[AR[1]] 2000mm/sec FINE ;
 :  ;
 : ! if AR[2] is a posreg number use ;
 : ! that posreg as the user offset ;
 : L PR[1:poo1] 100mm/sec FINE Offset,PR[AR[2]] ;
/END
```

