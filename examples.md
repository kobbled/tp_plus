<!-- TOC -->

- [TP+ Examples](#tp-examples)
  - [IO](#io)
  - [Loops](#loops)
    - [looping with a jump label](#looping-with-a-jump-label)
  - [Conditionals](#conditionals)
    - [If-Then Block](#if-then-block)
  - [Select](#select)
  - [Namespaces](#namespaces)
  - [Functions](#functions)
    - [Call A Function with Return](#call-a-function-with-return)
    - [Multiple Functions with multiple return statements](#multiple-functions-with-multiple-return-statements)
  - [Motion](#motion)
  - [Positions](#positions)
  - [Function parameters](#function-parameters)
  - [Arguments](#arguments)

<!-- /TOC -->

# TP+ Examples

**IN DEVELOPMENT** : If you any examples to contribute post them to issues.

TP+
```ruby
```

LS
```fanuc
/PROG example_1
/MN
/END
```

##  IO

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

##  Loops

TP+
```ruby
```

LS
```fanuc
/PROG example_1
/MN
/END
```

###  looping with a jump label

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

##  Conditionals

###  If-Then Block

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


##  Select

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
## Namespaces

TP+
```ruby
```

LS
```fanuc
/PROG example_1
/MN
/END
```

##  Functions

**NOTE::** Currently in development

###  Call A Function with Return
TP+
```ruby
pose := PR[1]

def set_pose(x,y,z,w,p,r) : posreg
  dummy := PR[50]

  clpr(&dummy, 0)
  dummy.x = x
  dummy.y = y
  dummy.z = z
  dummy.w = w
  dummy.p = p
  dummy.r = r

  return (dummy)
end


pose = set_pose(100,0,50,90,0,-90)
```

LS
```fanuc
/PROG SET_POSE
/ATTR
COMMENT = "SET_POSE";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = *,*,*,*,*;
/MN
 :  ;
 : CALL CLPR(50,0) ;
 : PR[50,1:dummy]=AR[1] ;
 : PR[50,2:dummy]=AR[2] ;
 : PR[50,3:dummy]=AR[3] ;
 : PR[50,4:dummy]=AR[4] ;
 : PR[50,5:dummy]=AR[5] ;
 : PR[50,6:dummy]=AR[6] ;
 :  ;
 : PR[AR[7]]=PR[50:dummy] ;
/END

/PROG MAIN
/ATTR
COMMENT = "MAIN";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 :  ;
 : CALL SET_POSE(100,0,50,90,0,(-90),1) ;
 :  ;
/END
```

###  Multiple Functions with multiple return statements
TP+
```ruby
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
```

LS
```fanuc
/PROG DIVIDE_SEQUENCE
/ATTR
COMMENT = "DIVIDE_SEQUENCE";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : IF (AR[2]<1) THEN ;
 : R[AR[3]]=AR[1] ;
 : END ;
 : ENDIF ;
 :  ;
 : R[AR[3]]=AR[1]/AR[2] ;
 : END ;
/END

/PROG LINEAR_SEQUENCE
/ATTR
COMMENT = "LINEAR_SEQUENCE";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : R[AR[3]]=(AR[1]*AR[2]+100) ;
 : END ;
/END

/PROG MAIN
/ATTR
COMMENT = "MAIN";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 :  ;
 : R[3:i]=0 ;
 : LBL[100] ;
 : IF R[3:i]>=30,JMP LBL[101] ;
 : ! inital seed ;
 : R[1:sum]=1 ;
 : R[4:j]=0 ;
 : LBL[102] ;
 : IF (R[4:j]>=20),JMP LBL[103] ;
 : CALL DIVIDE_SEQUENCE(R[1:sum],R[4:j],1) ;
 : CALL LINEAR_SEQUENCE(R[1:sum],R[3:i],1) ;
 :  ;
 : R[4:j]=R[4:j]+1 ;
 : JMP LBL[102] ;
 : LBL[103] ;
 : R[3:i]=R[3:i]+5 ;
 : JMP LBL[100] ;
 : LBL[101] ;
 :  ;
 :  ;
/END

```


##  Motion

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

##  Positions

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


##  Function parameters

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

##  Arguments

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

