<!-- TOC -->

- [TP+ Examples](#tp-examples)
  - [IO](#io)
  - [Loops](#loops)
    - [for loop](#for-loop)
      - [Print a pyramid](#print-a-pyramid)
      - [Nested Select Statement in For Loop](#nested-select-statement-in-for-loop)
    - [while loop](#while-loop)
    - [looping with a jump label](#looping-with-a-jump-label)
  - [Conditionals](#conditionals)
    - [If-Then Block](#if-then-block)
  - [Select](#select)
  - [Namespaces](#namespaces)
    - [structs](#structs)
    - [states](#states)
  - [Functions](#functions)
    - [Call A Function with Return](#call-a-function-with-return)
    - [Multiple Functions with multiple return statements](#multiple-functions-with-multiple-return-statements)
    - [namespace collections](#namespace-collections)
    - [functions with positions](#functions-with-positions)
    - [functions with posreg returns](#functions-with-posreg-returns)
  - [Motion](#motion)
  - [Positions](#positions)
    - [Inputing Position Data](#inputing-position-data)
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

### for loop

#### Print a pyramid

TP+
```ruby
i := R[178]
j := R[180]

COLUMNS := 6

userclear()
usershow()

for i in (COLUMNS downto 1)
  for j in (1 to i)
    print('* ')
  end
  print_line('')
end
```

LS
```fanuc
/PROG TEST
/ATTR
COMMENT = "TEST";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,*,*,*,*;
/APPL
/MN
 :  ;
 :  ;
 : CALL USERCLEAR ;
 : CALL USERSHOW ;
 :  ;
 : FOR R[178:i]=6 DOWNTO 1 ;
 : FOR R[180:j]=1 TO R[178:i] ;
 : CALL PRINT('* ') ;
 : ENDFOR ;
 : CALL PRINT_LINE('') ;
 : ENDFOR ;
 :  ;
 :  ;
/END
```


#### Nested Select Statement in For Loop

**..note::** contains Ka_Boost Methods

TP+
```ruby
i := R[178]
total := R[192]
type := R[264]
axes := R[223]

foo := PR[21]

TP_GROUPMASK = "1,1,1,*,*"

namespace prTypes
  POSITION  := 1
  XYZWPR    := 2
  XYZWPREXT := 6
  JOINTPOS  := 9
end

userclear()

# get total number of groups on controller
total = pos::grplen()

#get current position
get_linear_position(foo)

for i in (1 to total)
  type = pos::prtype(&foo, i)
  axes = pos::axescnt(&foo, i)

  case type
    when prTypes::POSITION
      print('Group ')
      printnr(&i)
      print_line(' is a Cartesian Pose.')
    when prTypes::XYZWPR
      print('Group ')
      printnr(&i)
      print_line(' is a Cartesian Pose.')
    when prTypes::XYZWPREXT
      print('Group ')
      printnr(&i)
      print(' is a Cartesian Pose. with ')
      printnr(&axes)
      print(' Extended axes.')
      print_line('')
    when prTypes::JOINTPOS
      print('Group ')
      printnr(&i)
      print(' is a Joint Pose. with ')
      printnr(&axes)
      print(' axes.')
      print_line('')
  end
end

usershow()
```

LS
```fanuc
/PROG TEST
/ATTR
COMMENT = "TEST";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,1,1,*,*;
/APPL
/MN
 :  ;
 :  ;
 :  ;
 :  ;
 : CALL USERCLEAR ;
 :  ;
 : ! get total number of groups on ;
 : ! controller ;
 : CALL POS_GRPLEN(192) ;
 :  ;
 : ! get current position ;
 : PR[21:foo]=LPOS ;
 :  ;
 : FOR R[178:i]=1 TO R[192:total] ;
 : CALL POS_PRTYPE(21,R[178:i],264) ;
 : CALL POS_AXESCNT(21,R[178:i],223) ;
 :  ;
 : SELECT R[264:type]=1,JMP LBL[100] ;
 :        =2,JMP LBL[101] ;
 :        =6,JMP LBL[102] ;
 :        =9,JMP LBL[103] ;
 :  ;
 : LBL[100:caselbl1] ;
 : CALL PRINT('Group ') ;
 : CALL PRINTNR(178) ;
 : CALL PRINT_LINE(' is a Cartesian Pose.') ;
 : JMP LBL[104] ;
 : LBL[101:caselbl2] ;
 : CALL PRINT('Group ') ;
 : CALL PRINTNR(178) ;
 : CALL PRINT_LINE(' is a Cartesian Pose.') ;
 : JMP LBL[104] ;
 : LBL[102:caselbl3] ;
 : CALL PRINT('Group ') ;
 : CALL PRINTNR(178) ;
 : CALL PRINT(' is a Cartesian Pose. with ') ;
 : CALL PRINTNR(223) ;
 : CALL PRINT(' Extended axes.') ;
 : CALL PRINT_LINE('') ;
 : JMP LBL[104] ;
 : LBL[103:caselbl4] ;
 : CALL PRINT('Group ') ;
 : CALL PRINTNR(178) ;
 : CALL PRINT(' is a Joint Pose. with ') ;
 : CALL PRINTNR(223) ;
 : CALL PRINT(' axes.') ;
 : CALL PRINT_LINE('') ;
 : JMP LBL[104] ;
 : LBL[104:endcase] ;
 : ENDFOR ;
 :  ;
 : CALL USERSHOW ;
 :  ;
 :  ;
/END

```
### while loop

**..note::** Contains KaBoost Routines

TP+
```ruby
number := R[56]
sum    := R[143]

userclear()
usershow()

number = userReadInt('enter an Integer')
sum = 0

while number > 0
  sum += number
  number = userReadInt('enter next Integer. 0 to exit.')
end

print('The total sum is:')
printnr(&sum)

```

LS
```fanuc
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
/APPL
/MN
 :  ;
 : CALL USERCLEAR ;
 : CALL USERSHOW ;
 :  ;
 : CALL USERREADINT('enter an Integer',56) ;
 : R[143:sum]=0 ;
 :  ;
 : LBL[100] ;
 : IF R[56:number]<=0,JMP LBL[101] ;
 : R[143:sum]=R[143:sum]+R[56:number] ;
 : CALL USERREADINT('enter next Integer. 0 to exit.',56) ;
 : JMP LBL[100] ;
 : LBL[101] ;
 :  ;
 : CALL PRINT('The total sum is:') ;
 : CALL PRINTNR(143) ;
 :  ;
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

### structs

TP+
```ruby
namespace Foo
  bar := R[1]
  deligate := DI[1]
end

namespace struct1
  CONST1 := 5
end

namespace struct2
  CONST1 := 2
end

if Foo::deligate then
  Foo::bar = struct1::CONST1
else
  Foo::bar = struct2::CONST1
end
```

LS
```fanuc
/PROG TEST
/ATTR
COMMENT = "TEST";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 : IF (DI[1:Foo deligate]) THEN ;
 : R[1:Foo bar]=5 ;
 : ELSE ;
 : R[1:Foo bar]=2 ;
 : ENDIF ;
/END
```


### states

TP+
```ruby
namespace Infeed
  part_present? := DI[2]
  part_scanning? := DI[3]
  part_welding? := DI[4]
  is_weldable?  := F[2]
end

namespace Alarms
  gripper        := UALM[1]
  part_presence  := UALM[2]
  cannot_weld   := UALM[3]
end

namespace Perch
  pickup        := PR[1]
  scan          := PR[2]
  weld          := PR[3]
end

state := R[1]
loop := F[3]

turn_on(loop)

namespace states
  PICKUP    := 1
  SCAN      := 2
  WELD      := 3
  DROPOFF   := 4
end

while loop
  case state
  when states::PICKUP
    pickup_part()
    if !Infeed::part_present? then
      raise Alarms::part_presence
      turn_off(loop)
    else
      state = states::SCAN
      linear_move.to(Perch::scan).at(2000, 'mm/s').term(-1)
    end
  when states::SCAN
    scan_part()
    if !Infeed::part_scanning? && Infeed::is_weldable? then
      state = states::WELD
      linear_move.to(Perch::weld).at(2000, 'mm/s').term(-1)
    elsif !Infeed::part_scanning? && !Infeed::is_weldable? then
      raise Alarms::cannot_weld
      turn_off(loop)
    end
  when states::WELD
    weld_part()
    if !Infeed::part_welding? then
      state = states::DROPOFF
      linear_move.to(Perch::pickup).at(2000, 'mm/s').term(-1)
    end
  when states::DROPOFF
    drop_off_part()
    if !Infeed::part_present? then
      #increment counter
      next_part()
      state = states::PICKUP
      linear_move.to(Perch::pickup).at(2000, 'mm/s').term(-1)
    else
      raise Alarms::gripper
      turn_off(loop)
    end
  end
end
```

LS
```fanuc
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
 :  ;
 :  ;
 :  ;
 : F[3:loop]=(ON) ;
 :  ;
 :  ;
 : LBL[104] ;
 : IF (!F[3:loop]),JMP LBL[105] ;
 : SELECT R[1:state]=1,JMP LBL[100] ;
 :        =2,JMP LBL[101] ;
 :        =3,JMP LBL[102] ;
 :        =4,JMP LBL[103] ;
 :  ;
 : LBL[100:caselbl1] ;
 : CALL PICKUP_PART ;
 : IF (!DI[2:Infeed part_present?]) THEN ;
 : UALM[2] ;
 : F[3:loop]=(OFF) ;
 : ELSE ;
 : R[1:state]=2 ;
 : L PR[2:Perch scan] 2000mm/sec FINE ;
 : ENDIF ;
 : JMP LBL[106] ;
 : LBL[101:caselbl2] ;
 : CALL SCAN_PART ;
 : IF (!DI[3:Infeed part_scanning?] AND F[2:Infeed is_weldable?]) THEN ;
 : R[1:state]=3 ;
 : L PR[3:Perch weld] 2000mm/sec FINE ;
 : ELSE ;
 : IF (!DI[3:Infeed part_scanning?] AND !F[2:Infeed is_weldable?]) THEN ;
 : UALM[3] ;
 : F[3:loop]=(OFF) ;
 : ENDIF ;
 : ENDIF ;
 :  ;
 : JMP LBL[106] ;
 : LBL[102:caselbl3] ;
 : CALL WELD_PART ;
 : IF (!DI[4:Infeed part_welding?]) THEN ;
 : R[1:state]=4 ;
 : L PR[1:Perch pickup] 2000mm/sec FINE ;
 : ENDIF ;
 : JMP LBL[106] ;
 : LBL[103:caselbl4] ;
 : CALL DROP_OFF_PART ;
 : IF (!DI[2:Infeed part_present?]) THEN ;
 : ! increment counter ;
 : CALL NEXT_PART ;
 : R[1:state]=1 ;
 : L PR[1:Perch pickup] 2000mm/sec FINE ;
 : ELSE ;
 : UALM[1] ;
 : F[3:loop]=(OFF) ;
 : ENDIF ;
 : JMP LBL[106] ;
 : LBL[106:endcase] ;
 : JMP LBL[104] ;
 : LBL[105] ;
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

###  namespace collections

TP+
```ruby
namespace Math
  M_PI := 3.14159

  def arclength(angle, radius) : numreg 
    return(angle*radius*M_PI/180)
  end

  def arcangle(length, radius) : numreg
    return(length/radius*180/M_PI)
  end
end

radius := R[1]
angle  := R[2]
length := R[3]

radius = 100
angle = 90

length = Math::arclength(angle, radius)
angle = Math::arcangle(length, radius)
```

LS
```fanuc
/PROG MATH_ARCANGLE
/ATTR
COMMENT = "MATH_ARCANGLE";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : R[AR[3]]=(AR[1]/AR[2]*180/3.14159) ;
 : END ;
/END

/PROG MATH_ARCLENGTH
/ATTR
COMMENT = "MATH_ARCLENGTH";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : R[AR[3]]=(AR[1]*AR[2]*3.14159/180) ;
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
 :  ;
 :  ;
 : R[1:radius]=100 ;
 : R[2:angle]=90 ;
 :  ;
 : CALL MATH_ARCLENGTH(R[2:angle],R[1:radius],3) ;
 : CALL MATH_ARCANGLE(R[3:length],R[1:radius],2) ;
/END
```

### functions with positions

TP+
```ruby
namespace Pose

  def goHome()
    TP_GROUPMASK = "1,*,*,*,*"
    pHome := P[1]
    joint_move.to(pHome).at(10, '%').term(-1)

    position_data
    {
      'positions' : [
        {
          'id' : 1,
          'comment' : 'Home Position',
          'mask' :  [{
            'group' : 1,
            'uframe' : 0,
            'utool' : 1,
            'components' : {
                'J1' : 127.834,
                'J2' : 24.311,
                'J3' : -29.462,
                'J4' : -110.295,
                'J5' : 121.424,
                'J6' : 54.899
                }
            }]
        }
      ]
    }
    end
  end
end
```

LS
```fanuc
/PROG POSE_GOHOME
/ATTR
COMMENT = "POSE_GOHOME";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 : J P[1:pHome] 10% FINE ;
 :  ;
/POS
P[1:"Home Position"]{
   GP1:
  UF : 0, UT : 1, 
  J1 = 127.834 deg, 
  J2 = 24.311 deg, 
  J3 = -29.462 deg, 
  J4 = -110.295 deg, 
  J5 = 121.424 deg, 
  J6 = 54.899 deg
};
/END
```

### functions with posreg returns
**..note::** Includes Ka-Boost Methods

TP+
```ruby
pr1 := PR[20]

#set robot pose
pr1.group(1) = Pos::setxyz(500, 500, 0, 90, 0, 180)
pr1.group(1) = Pos::setcfg('F U T, 0, 0, 0')
#set rotary pose
pr1.group(2) = Pos::setjnt2(90, 0)

#no group
pr1 = Pos::move()

```

LS
```fanuc
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
/APPL
/MN
 :  ;
 : ! set robot pose ;
 : CALL POS_SETXYZ(500,500,0,90,0,180,20,1) ;
 : CALL POS_SETCFG('F U T, 0, 0, 0',20,1) ;
 : ! set rotary pose ;
 : CALL POS_SETJNT2(90,0,20,2) ;
 :  ;
 : ! no group ;
 : CALL POS_MOVE(20) ;
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

### Inputing Position Data

**NOTE** : `uframe`, and `utool` must be added in for each group

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

