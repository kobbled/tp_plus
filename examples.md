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
    - [Evaluating IO](#evaluating-io)
    - [Using Constants](#using-constants)
  - [Select](#select)
  - [Inline Statments](#inline-statments)
  - [Namespaces](#namespaces)
    - [Namespace scoping](#namespace-scoping)
    - [structs](#structs)
    - [states](#states)
  - [Functions](#functions)
    - [Call A Function with Return](#call-a-function-with-return)
    - [Multiple Functions with multiple return statements](#multiple-functions-with-multiple-return-statements)
    - [namespace collections](#namespace-collections)
    - [functions with positions](#functions-with-positions)
    - [functions with posreg returns](#functions-with-posreg-returns)
  - [Imports](#imports)
  - [Local variables](#local-variables)
    - [Expressions in Arguements](#expressions-in-arguements)
  - [Frames](#frames)
  - [Motion](#motion)
    - [basic options](#basic-options)
    - [Touch sensing with robot](#touch-sensing-with-robot)
  - [Positions](#positions)
    - [Setting positions](#setting-positions)
    - [Position Assignment](#position-assignment)
    - [Coordinate Systems](#coordinate-systems)
    - [Assigning posregs](#assigning-posregs)
  - [Function parameters](#function-parameters)
  - [Math](#math)
    - [Functions](#functions)
    - [Matrix Math](#matrix-math)
  - [Arguments](#arguments)
  - [String Manipulation](#string-manipulation)
  - [Timers](#timers)
  - [wait statments](#wait-statments)
  - [Preprocessor](#preprocessor)
    - [Define Macros](#define-macros)
    - [Conditional Inclusion](#conditional-inclusion)
    - [File inclusion](#file-inclusion)
    - [Code Execution](#code-execution)
  - [Environment Files](#environment-files)
  - [Misc Statments](#misc-statments)
    - [MNU Access](#mnu-access)
    - [collision guard](#collision-guard)
    - [tool application headers](#tool-application-headers)

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

bar = on if foo == 5
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

namespace PRTypes
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
    when PRTypes::POSITION
      print('Group ')
      printnr(&i)
      print_line(' is a Cartesian Pose.')
    when PRTypes::XYZWPR
      print('Group ')
      printnr(&i)
      print_line(' is a Cartesian Pose.')
    when PRTypes::XYZWPREXT
      print('Group ')
      printnr(&i)
      print(' is a Cartesian Pose. with ')
      printnr(&axes)
      print(' Extended axes.')
      print_line('')
    when PRTypes::JOINTPOS
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
 pin1 = on
end


#if else block

if $SCR.$NUM_GROUP > 1 then
  #true block
  pin1 = on
else
  #false block
  pin1 = off
end

# else if block

if foo == 1 then
  #true block
  pin1 = on
elsif foo==2 then
  #false block
  pin2 = off
end

# else if - else block

if foo == 1 then
  #true block
  pin1 = on
elsif foo==2 then
  #false block
  pin2 = on
else
  pin1 = off
  pin2 = off
end
```

###  Evaluating IO

Can use evaluators `true`, `false`, `on`, and `off`

TP+
```ruby
foo := DI[1]
bar := F[2]

if (foo == on) && (bar == off) then
  print('hello')
end

foo2 := UO[3]

if foo2 == true then
  print('Program is running')
end

if foo2 == false then
  print('Program is not running')
end
```

LS
```fanuc
/PROG main
/MN
 : IF ((DI[1:foo]=ON) AND (F[2:bar]=OFF)) THEN ;
 : CALL PRINT('hello') ;
 : ENDIF ;
 :  ;
 : IF (UO[3:foo2]=ON) THEN ;
 : CALL PRINT('Program is running') ;
 : ENDIF ;
 :  ;
 : IF (UO[3:foo2]=OFF) THEN ;
 : CALL PRINT('Program is not running') ;
 : ENDIF ;
/END
```

###  Using Constants

Constants can be used in expressions:

TP+
```ruby
CONST1 := true

if CONST1 == false
  print('hello')
end
```

will evaluate to:

LS
```fanuc
/PROG main
/MN
 : IF ON=OFF,CALL PRINT('hello') ;
/END
```

which is legal syntax

An infinite while loop can be constructed like so:

TP+
```ruby
while true == true
  print('hello')
  wait_for(1, 's')
end
```

LS
```fanuc
/PROG main
/MN
 : LBL[100] ;
 : IF ON<>ON,JMP LBL[101] ;
 : CALL PRINT('hello') ;
 : WAIT 1.00(sec) ;
 : JMP LBL[100] ;
 : LBL[101] ;
/END
```



##  Select

TP+
```ruby
foo := R[1]
foo2 := R[2]
foo3 := DO[1]
t    := TIMER[1]

case foo
when 1
  message('foo == 1')
  wait_for(1, 's')
  foo3 = on
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

## Inline Statments

TP+
```ruby
foo := R[1]
bar := R[2]
flg := F[1]
@lbl 

jump_to @lbl if foo==1
jump_to @lbl unless foo==1
jump_to @lbl unless flg

foo=2 if foo==1
foo = on if bar < 10

prog() if foo >= 5
prog() unless foo

bar = 2 if foo >= (bar-1) && foo <= (bar+1) 

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
 : LBL[100:lbl] ;
 :  ;
 : IF R[1:foo]=1,JMP LBL[100] ;
 : IF R[1:foo]<>1,JMP LBL[100] ;
 : IF (!F[1:flg]),JMP LBL[100] ;
 :  ;
 : IF (R[1:foo]=1),R[1:foo]=(2) ;
 : IF (R[2:bar]<10),R[1:foo]=(ON) ;
 :  ;
 : IF R[1:foo]>=5,CALL PROG ;
 : IF (!R[1:foo]),CALL PROG ;
 :  ;
 : IF (R[1:foo]>=(R[2:bar]-1) AND R[1:foo]<=(R[2:bar]+1)),R[2:bar]=(2) ;
/END
```

## Namespaces

### Namespace scoping

namespaces, variables, constants, and functions must be scoped into
functions and namespaces with the "using" keyword, and the name of the
identifier.

TP+
```ruby
namespace ns1
  VAL1 := 1
  VAL2 := 2
end

namespace ns2
  VAL1 := 3.14
  VAL2 := 2.72
end

namespace ns3
  using ns1
  
  VAL1 := 'Hello'

  def test2() : numreg
    return(ns1::VAL1 + 5)
  end
end

def test()
  using ns1, ns2, ns3
  foo := R[1]
  bar := R[2]
  foostr := SR[3]

  foo = ns2::VAL1
  bar = ns2::VAL2

  foostr = Str::set(ns3::VAL1)
  foo = ns3::test2()
end
```

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

loop = on

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
      loop = off
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
      loop = off
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
      loop = off
    end
  end
end
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

###  namespace collections

**NOTE::** Currently inlined functions have to have different arguement variable names than register names in order to work. If functions are not inlined the argument name can be the same as the register name being passed into it.

TP+
```ruby
namespace Math
  M_PI := 3.14159

  inline def arclength(ang, rad) : numreg
    return(ang*rad*M_PI/180)
  end

  inline def arcangle(len, rad) : numreg
    return(len/rad*180/M_PI)
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
 : R[1:radius]=100 ;
 : R[2:angle]=90 ;
 :  ;
 : ! inline Math_arclength ;
 :  ;
 : R[3:length]=(R[2:angle]*R[1:radius]*3.14159/180) ;
 : ! end Math_arclength ;
 :  ;
 : ! inline Math_arcangle ;
 :  ;
 : R[2:angle]=(R[3:length]/R[1:radius]*180/3.14159) ;
 : ! end Math_arcangle ;
 :  ;
/END
```

### functions with positions

TP+
```ruby
namespace Pose

  def goHome()
    pHome := P[1]

    use_uframe 0
    use_utool 1

    pHome.joints -> [127.834, 24.311, -29.462, -110.295, 121.424, 54.899]

    joint_move.to(pHome).at(10, '%').term(-1)
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
## Imports

**WARNING** New feature is without unit tesst coverage. There may be issues with usage.

imports outside of current working directory are set with
```bash
tpp test.tpp -o "./ls/test.ls" -i "path/to/include/dir"
```

import names refer to the filenames without the .tpp extension

imports can be chosen to be printed or not with the `compile` keyword infront of the import statement 

**NOTE** : importing the same file in nested files may cause problems as there   are currently no collision guards.

main
```ruby
import tool2
compile import test_import

Sense::findZero()
```

Replacing the import with a different file with the same struct format can be used to quickly swap configurations.

tool1.tpp
```ruby
namespace tool
  frame := UTOOL[1]
  read_pin := AI[1]
  interupt_pin := DI[8]
  SEARCH_DIST := 10
  SEARCH_SPEED := 3
end
```

test_import.tpp
```ruby
namespace Sense
  using tool

  measure := R[1]
  ulrm    := UALM[1]

  def read()
    while 0
      measure = tool::read_pin
      wait_for(250,'ms')
    end
  end

  def findZero()
    lpos := PR[1]
    ofst := PR[2]

    use_utool tool::frame

    #measure current pose
    get_linear_position(lpos)
    
    run Sense::read()

    #determine serch vector
    Pos::clrpr(&ofst)
    if measure > 0
      ofst.z = -1*tool::SEARCH_DIST
    else
      ofst.z = 1*tool::SEARCH_DIST
    end
    #get tool offset pose
    ofst = Pos::mult(&lpos, &ofst)

    #search until 
    set_skip_condition tool::interupt_pin
    linear_move.to(ofst).at(tool::SEARCH_SPEED, 'mm/s').term(-1).skip_to(@not_zerod)

    return
    @not_zerod
      raise ulrm
  end
end
```

## Local variables

> [!DANGER]
> This feature is experimental, it may provide unpredictable results. Use at your own discretion.

> [!TODO]
> Make a karel program to handle a local register stack dynamically during runtime.

You can declare a local stack of variables using:

```ruby
local := R[50..100]
local := PR[5..10]
local := F[50..100]
```

A virtual stack will be created during compilation to track where the function calls occur in the program. Depending on the scope of the function call, local registers will be assigned to an open register. If you run out of register a _Stack Overflow_ error will result.

Local registers can be declared with:

```
numreg := LR[]
posreg := LPR[]
flag   := LF[] 
```

Below is an example of its usage:

```ruby
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
```

which will produce this TP:

```fortran
/PROG TEST
COMMENT = "TEST";
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 : CALL ADDIN(50) ;
 : CALL RATIO(50) ;
/POS
/END
```
```fortran
/PROG ADDIN
COMMENT = "ADDIN";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 :  ;
 : CALL MULTIPLE(R[52:bar],52) ;
 : R[AR[1]]=R[51:foo]+R[52:bar] ;
 : END ;
/END
```
```fortran
/PROG MULTIPLE
COMMENT = "MULTIPLE";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 :  ;
 : R[53:multiplier]=10 ;
 : R[AR[2]]=AR[1]*R[53:multiplier] ;
 : END ;
/END
```
```fortran
/PROG RATIO
COMMENT = "RATIO";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 :  ;
 : IF ((AR[1] MOD 2<>0)),JMP LBL[100] ;
 : R[51:divisor]=2 ;
 : JMP LBL[101] ;
 : LBL[100] ;
 : R[51:divisor]=1 ;
 : LBL[101] ;
 :  ;
 : R[AR[2]]=AR[1]/R[51:divisor] ;
 : END ;
/END
```

> [!WARNING]
> The local variable system is done completely at compile time If the function is not defined in the compilation scope, it will not be captured. 

> [!WARNING]
> The local variable system is done completely at compile time, each function/subroutine should be re-exported to the robot everytime! In the case a where the same subroutine is used in different programs, at different points in the program, different register number may be assigned and conflict with the program scope.

### Expressions in Arguements

Currently the Fanuc TP language does not allow you to put expressions in function arguments. With the use of local variables this is now possible in TP+.

```ruby
local := R[70..80]

foo := R[10]
bar := R[11]
biz := R[12]
baz := R[13]

namespace Math
  PI := 3.14159

  def test(ar1, ar2, ar3) : numreg
    return(Math::test2(ar1, ar2)*(ar1+ar2+ar3))
  end

  def test2(ar1, ar2) : numreg
    if ar1 > ar2
      return(0.5)
    end

    return(1)
  end
end

foo = Mth::ln(2)

foo = Mth::test(5+3, bar*biz/2, -1*biz*Math::PI)

foo = Mth::test(bar*biz/2, set_reg(biz), -1*biz*Math::PI)

foo = Mth::test3(bar*Math::PI*set_reg(baz))
```

will transform into this:

```fortran
/PROG TEST29
COMMENT = "TEST29";
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 : CALL MTH_LN(2,10) ;
 :  ;
 : R[70:dvar2]=5+3 ;
 : R[71:dvar3]=(R[11:bar]*R[12:biz]/2) ;
 : R[72:dvar4]=((-1)*R[12:biz]*3.14159) ;
 : CALL MTH_TEST(R[70:dvar2],R[71:dvar3],R[72:dvar4],10) ;
 :  ;
 : CALL SET_REG(R[12:biz],74) ;
 : R[73:dvar5]=(R[11:bar]*R[12:biz]/2) ;
 : R[75:dvar7]=((-1)*R[12:biz]*3.14159) ;
 : CALL MTH_TEST(R[73:dvar5],R[74:dvar6],R[75:dvar7],10) ;
 :  ;
 : CALL SET_REG(R[13:baz],76) ;
 : R[77:dvar9]=(R[11:bar]*3.14159*R[76:dvar8]) ;
 : CALL MTH_TEST3(R[77:dvar9],10) ;
/POS
/END
```
```fortran
/PROG MATH_TEST
COMMENT = "MATH_TEST";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : CALL MATH_TEST2(AR[1],AR[2],78) ;
 : R[AR[4]]=(R[78:dvar1]*(AR[1]+AR[2]+AR[3])) ;
 : END ;
/END
```
```fortran
/PROG MATH_TEST2
COMMENT = "MATH_TEST2";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : IF (AR[1]<=AR[2]),JMP LBL[100] ;
 : R[AR[3]]=0.5 ;
 : END ;
 : LBL[100] ;
 :  ;
 : R[AR[3]]=1 ;
 : END ;
/END
```

## Frames

TP+
```ruby
frame := UFRAME[1]
tool := UTOOL[2]
temp_frame := PR[5]
offst := PR[6]

use_uframe frame
use_utool tool

#copy frame to posreg
temp_frame = frame

#set offet amount
Pos::clrpr(&offst)
offst.z = 100

#get offset frame
temp_frame = Pos::mult(&temp_frame, &offst)

#set new frame
frame = temp_frame
```

LS
```fanuc
 : UFRAME_NUM=1 ;
 : UTOOL_NUM=2 ;
 :  ;
 : ! copy frame to posreg ;
 : PR[5:temp_frame]=UFRAME[1] ;
 :  ;
 : ! set offet amount ;
 : CALL POS_CLRPR(6,1) ;
 : PR[6,3:offst]=100 ;
 :  ;
 : ! get offset frame ;
 : CALL POS_MULT(5,6,5) ;
 :  ;
 : ! set new frame ;
 : UFRAME[1]=PR[5:temp_frame] ;
```

##  Motion

### basic options

TP+
```ruby

#make sure you declare a group mask
TP_GROUPMASK = "1,*,*,*,*"

home := PR[1]
lpos := PR[2]
arc1 := PR[3]
arc2 := PR[4]

p1   := P[1]
p2   := P[2]
p3   := P[3]
p4   := P[4]

FINE := -1

#make sure to specify frame
use_uframe 1
use_utool 1

#save current location of the robot
get_linear_position(lpos)

#basic joint movement
joint_move.to(home).at(20, '%').term(FINE)

#linear move
linear_move.to(lpos).at(20, 'mm/s').term(100)

#circular move
joint_move.to(lpos).at(100, '%').term(FINE)
circular_move.mid(arc1).to(arc2).at(100, 'mm/s').term(100)

#arc move
arc_move.to(p1).at(200, 'mm/s').term(FINE)
arc_move.to(p2).at(200, 'mm/s').term(100)
arc_move.to(p3).at(200, 'mm/s').term(100)
arc_move.to(p4).at(200, 'mm/s').term(FINE)

Start_Offset := PR[5]
Stop_Offset := PR[6]
FrameOffset := PR[7]
ToolOffset := PR[8]

pr_num := AR[1]
#indirect position
linear_move.to(indirect('posreg', pr_num)).at(2000, 'mm/s').term(0)

#offsets
linear_move.to(p1).at(100, 'mm/s').term(100).offset(FrameOffset)
linear_move.to(p2).at(100, 'mm/s').term(100).tool_offset(ToolOffset)

#motion program call
linear_move.to(p1).at(100, 'mm/s').term(100).
      time_after(0.0, START_TOOL()).offset(Start_Offset)
linear_move.to(p2).at(100, 'mm/s').term(100).
      time_after(0.0, STOP_TOOL()).offset(Stop_Offset)

#run program before reaching pose (time based)
joint_move.to(p1).at(40, '%').term(FINE)
linear_move.to(p2).at(100, 'mm/s').term(100).
      time_before(0.5, PREP_NOZZLE())

#run program before reaching pose (distance based)
joint_move.to(p1).at(40, '%').term(FINE)
linear_move.to(p2).at(100, 'mm/s').term(100).
      distance_before(100, CHECK_STATE())

#coordinated motion
joint_move.to(p1).at(40, '%').term(FINE)
linear_move.to(p2).at(400, 'mm/s').term(100).coord
linear_move.to(p3).at(400, 'mm/s').term(FINE).coord

#Remote TCP
joint_move.to(p1).at(40, '%').term(FINE)
linear_move.to(p2).at(400, 'mm/s').term(100).acc(100).rtcp

#move through a 20mm corner distance
joint_move.to(p1).at(100, '%').term(FINE)
linear_move.to(p2).at(1000,'mm/s').term(100).acc(100).cd(20)
linear_move.to(p3).at(1000,'mm/s').term(FINE)

# corner region (radius). Move through 20mm radius
joint_move.to(p1).at(100, '%').term(FINE)
linear_move.to(p2).at(1000,'mm/s').corner_region(20)
linear_move.to(p3).at(1000,'mm/s').term(FINE)

#ellipical corner region (radius)
linear_move.to(p1).at(1000, 'mm/s').corner_region(5,10)

#extended velocity
joint_move.to(p1).at(20, '%').term(FINE).simultaneous_ev(50)
joint_move.to(p2).at(20, '%').term(FINE).independent_ev(50)

#continuous rotation speed
linear_move.to(p1).at(100, 'mm/s').term(FINE).continuous_rotation_speed(0)

#linear distance
linear_move.to(p1).at(100, 'mm/s').term(FINE).approach_ld(100)
linear_move.to(p2).at(100, 'mm/s').term(100).retract_ld(100)

#minimum rotational error
joint_move.to(p1).at(100, '%').term(FINE)
joint_move.to(p2).at(100, '%').term(FINE).mrot
joint_move.to(p3).at(100, '%').term(FINE)

#process speed optimization
joint_move.to(p1).at(100, '%').term(FINE)
linear_move.to(p2).at(500, 'mm/s').term(100).acc(120).process_speed(110)  #moves faster
linear_move.to(p3).at(500, 'mm/s').term(10).acc(50).process_speed(50)  #moves slower

#corner path used if linear distance is satisfied
linear_move.to(p1).at(1000, 'mm/s').corner_region(50)
linear_move.to(p2).at(100, 'mm/s').term(FINE).approach_ld(100)

#minimum rotation for wrist axes
joint_move.to(p1).at(100, '%').term(FINE).minimal_rotation
linear_move.to(p2).at(400, 'mm/s').term(FINE).acc(100).
        wrist_joint.
        mrot

# break motion depending on sensor response
break_flag := DI[1]

joint_move.to(p1).at(50, '%').term(FINE)
linear_move.to(p2).at(500, 'mm/s').term(100).break
wait_until(break_flag).after(300, 'ms')
linear_move.to(p3).at(500, 'mm/s').term(0)

#move through short motions
linear_move.to(p1).at(50, 'mm/s').term(100).acc(150).pth

```

### Touch sensing with robot

TP+
```ruby
namespace touchPose
  strt := PR[1]
  search_dist := PR[2]
  found := PR[3]
end

namespace sensor
  signal := DI[1]
  val    := AI[1]
  zerod  := DI[2]

  POLLING_RATE := 0.1
  SAMPLING_TIME := 0.4

  def sample(pin, time) : numreg
    t := R[150]
    sum := R[151]
    inc := R[152]
    
    t = 0
    sum = 0
    inc = 0
    while t < time
      sum += indirect('ai', pin)
      
      wait_for(POLLING_RATE, 's')
      inc += 1
      t += POLLING_RATE
    end

    return(sum/inc)
  end
end

sensor_reading := R[1]
i    := R[150]

FINE := -1

#get start position
get_linear_position(touchPose::strt)

#clear found pose
pos::clrpr(&touchPose::found)

if !sensor::signal
    warning('Sensor is not starting on a surface. Check sensor measurement.')
end

#skip condition when sensor read 0. Setup as a digital pin from sensor.
set_skip_condition sensor::zerod

i = 0
@find_zero
  i += 1

  #offset value. Assuming tool frame is pointing into the surface.
  case i
    when 1
      #initially move down 100mm.
      pos::clrpr(&touchPose::search_dist)
      touchPose::search_dist.z = 100
      
      #search for touch if not found go back to start of loop
      #On next iteration move from previous position
      linear_move.to(touchPose::strt).at(20, 'mm/s').term(FINE).
          tool_offset(touchPose::search_dist).
          skip_to(@find_zero)

      #if found jump label
      jump_to @found_zero
    when 2
      #next try moving up 100mm
      pos::clrpr(&touchPose::search_dist)
      touchPose::search_dist.z = -100

      #search for touch if not found go back to start of loop
      #On next iteration move from lpos
      linear_move.to(touchPose::strt).at(20, 'mm/s').term(FINE).
          tool_offset(touchPose::search_dist).
          skip_to(@find_zero, touchPose::strt)
      
      jump_to @found_zero
    when 3
      #next try moving down 500mm
      pos::clrpr(&touchPose::search_dist)
      touchPose::search_dist.z = 500

      #search for touch if not found go back to start of loop
      #save lpos position
      linear_move.to(touchPose::strt).at(50, 'mm/s').term(FINE).
          tool_offset(touchPose::search_dist).
          skip_to(@find_zero, touchPose::strt)
      
      jump_to @found_zero
    else
      # raise warning
      warning('Could not find surface after 4 iterations!')
  end

jump_to @end

@found_zero
  get_linear_position(touchPose::found)

  #sample sensor
  wait_for(100, "ms") # make sure robot isnt moving
  sensor_reading = sensor::sample(&sensor::val, sensor::SAMPLING_TIME)

jump_to @end

@end
```

##  Positions

### Setting positions

**..note::** This section is currently in development, and replacing the old method.

Current modifiers are:

* pose
* joints
* xyz
* orient
* config
* offset

A default pose named `default` should be specified in full before
setting position variables, or else the default pose of 
```
default.group(1).pose -> [0,0,0,0,0,0]
default.group(1).config -> ['N', 'B', 'D', 0, 0, 0]
```
will be used

Frames can be changed with the `use_utool` and `use_uframe` keywords.


TP+
```ruby
TP_GROUPMASK = "1,1,1,*,*"
TP_COMMENT = "test prog"

p := P[1..6]

tool := UTOOL[5]
frame := UFRAME[3]

use_utool tool
use_uframe frame

default.group(1).pose -> [0,0,0,90,0,-90]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]
default.group(2).joints -> [90,0]
default.group(3).joints -> [[500,'mm']]

#apprach
p1.group(1).pose -> [0,50,0,0,0,0]
#start
p2.group(1).xyz -> [0,50,100]
#move circle
p3.group(1).xyz -> [50,0,100]
p3.group(2).joints -> [90,90]

use_utool 1
use_uframe 1

p4.group(1).xyz -> [0,-50,100]
p4.group(2).joints -> [90,180]

p5.group(1).xyz -> [-50,0,100]
p5.group(1).orient -> [0,0,0]
p5.group(2).joints -> [90,-90]

p6.group(1).joints -> [0, 20, 90, 0 ,0 ,0]
```

LS
```fanuc
/POS
P[1:"p1"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 50.000 mm, Z = 0.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = -90.000 deg
   GP2:
  UF : 3, UT : 5,
  J1 = 90.000 deg,
  J2 = 0.000 deg
     GP3:
  UF : 3, UT : 5,
  J1 = 500.000 mm
  };
P[2:"p2"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 50.000 mm, Z = 100.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = -90.000 deg
   GP2:
  UF : 3, UT : 5,
  J1 = 90.000 deg,
  J2 = 0.000 deg
     GP3:
  UF : 3, UT : 5,
  J1 = 500.000 mm
  };
P[3:"p3"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 50.000 mm, Y = 0.000 mm, Z = 100.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = -90.000 deg
   GP2:
  UF : 3, UT : 5,
  J1 = 90.000 deg,
  J2 = 90.000 deg
     GP3:
  UF : 3, UT : 5,
  J1 = 500.000 mm
  };
P[4:"p4"]{
   GP1:
  UF : 1, UT : 1,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = -50.000 mm, Z = 100.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = -90.000 deg
   GP2:
  UF : 1, UT : 1,
  J1 = 90.000 deg,
  J2 = 180.000 deg
     GP3:
  UF : 1, UT : 1,
  J1 = 500.000 mm
  };
P[5:"p5"]{
   GP1:
  UF : 1, UT : 1,  CONFIG : 'F U T, 0, 0, 0',
  X = -50.000 mm, Y = 0.000 mm, Z = 100.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = -90.000 deg
   GP2:
  UF : 1, UT : 1,
  J1 = 90.000 deg,
  J2 = -90.000 deg
     GP3:
  UF : 1, UT : 1,
  J1 = 500.000 mm
  };
/END
```

Any unspecified positions declared will be automatically set to the default position.

TP+
```ruby
p := P[1..3]

default.group(1).pose -> [0, 0, 10500, 90, 0 ,0]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]
default.group(3).joints -> [[10500, 'mm']]
default.group(4).joints -> [0]

```

LS
```
/POS
P[1:"p1"]{
   GP1:
  UF : 0, UT : 0,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 0.000 mm, Z = 10500.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = 0.000 deg
   GP3:
  UF : 0, UT : 0,
  J1 = 10500.000 mm
     GP4:
  UF : 0, UT : 0,
  J1 = 0.000 deg
  };
P[2:"p2"]{
   GP1:
  UF : 0, UT : 0,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 0.000 mm, Z = 10500.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = 0.000 deg
   GP3:
  UF : 0, UT : 0,
  J1 = 10500.000 mm
     GP4:
  UF : 0, UT : 0,
  J1 = 0.000 deg
  };
P[3:"p3"]{
   GP1:
  UF : 0, UT : 0,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 0.000 mm, Z = 10500.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = 0.000 deg
   GP3:
  UF : 0, UT : 0,
  J1 = 10500.000 mm
     GP4:
  UF : 0, UT : 0,
  J1 = 0.000 deg
  };
/END
```

positions can be offset from the previous position using the `offset` modifier

```ruby
p := P[1..5]

use_uframe 3
use_utool 2

default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['N', 'U', 'T', 0, 0, 0]
default.group(2).joints -> [90, 0]

p1.group(1).pose -> [0, 80, 300, 90, 180, 0]

p2.group(1).xyz.offset -> [0, 10, 10]
p2.group(2).joints.offset -> [0, 10]

p3.group(1).xyz.offset -> [0, 10, 10]
p3.group(2).joints.offset -> [0, 10]

p4.group(1).orient.offset -> [0, 10, 10]
p4.group(2).joints.offset -> [0, 10]

p5.group(1).orient.offset -> [0, 10, 10]
p5.group(2).joints.offset -> [0, 10]
```

LS
```fanuc
/POS
P[1:"p1"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N U T, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 300.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
   GP2:
  UF : 3, UT : 2,
  J1 = 90.000 deg,
  J2 = 0.000 deg
  };
P[2:"p2"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N U T, 0, 0, 0',
  X = 0.000 mm, Y = 90.000 mm, Z = 310.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
   GP2:
  UF : 3, UT : 2,
  J1 = 90.000 deg,
  J2 = 10.000 deg
  };
P[3:"p3"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N U T, 0, 0, 0',
  X = 0.000 mm, Y = 100.000 mm, Z = 320.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
   GP2:
  UF : 3, UT : 2,
  J1 = 90.000 deg,
  J2 = 20.000 deg
  };
P[4:"p4"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N U T, 0, 0, 0',
  X = 0.000 mm, Y = 100.000 mm, Z = 320.000 mm,
  W = 90.000 deg, P = 190.000 deg, R = 10.000 deg
   GP2:
  UF : 3, UT : 2,
  J1 = 90.000 deg,
  J2 = 30.000 deg
  };
P[5:"p5"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N U T, 0, 0, 0',
  X = 0.000 mm, Y = 100.000 mm, Z = 320.000 mm,
  W = 90.000 deg, P = 200.000 deg, R = 20.000 deg
   GP2:
  UF : 3, UT : 2,
  J1 = 90.000 deg,
  J2 = 40.000 deg
  };
/END
```

### Position Assignment

Ranges can be assigned using

TP+
```ruby
p := P[1..6]

p1..p3 = p4..p6

```

A range can be assigned a single pose with

TP+
```ruby
p := P[1..6]

p2..p6 = p1

```

The rval range can be less than the lval range, where the unassociated poses will be assigned the last pose in the lval
range.

TP+
```ruby
p := P[1..6]

p1..p4 = p5..p6

```

Modifier for range assignment currently are:

TP+
```ruby
p := P[1..6]

p1..p3 = (p4..p6).reverse

```

 **WARNING** Including brackets around the range before the modifier is manditory.

 Ranges can also be speicified in declaration statements.

TP+
```ruby
p := P[1..5]
(p1..p5).group(1).pose -> [0, 80, 300, 90, 180, 0]
```

This will set positions p1 to p5 all to the same position specified.


Offsets with a position range will apply the offset sequentially through the range

TP+
```ruby
p := P[1..5]
use_uframe 3
use_utool 2

p1.group(1).pose -> [0, 80, 300, 90, 180, 0]

(p2..p5).group(1).xyz.offset -> [0, 0 ,10]
```

LS
```
/POS
P[1:"p1"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 300.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
};
P[2:"p2"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 310.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
};
P[3:"p3"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 320.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
};
P[4:"p4"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 330.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
};
P[5:"p5"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 340.000 mm,
  W = 90.000 deg, P = 180.000 deg, R = 0.000 deg
};
/END
```

### Coordinate Systems

position modifiers for converting between coordinate systems is also provided. Currently you can use

* `polar` : to convert from cylindrical space (theta, radius, z) to cartesian space
* `sphere` : to convert from spherical space (theta, rho, radius) to cartesian space

The modifier after the coordinate system must be `x`, `y`, or `z` to specify the z-axis of the space. For example, to trace a cylinder along the `x` axis you would use `p1.group(1).pose.polar.x -> [0, 80, 300, 0, 0, 0]`

The modifier `fix` will fix the position to the orientation specified. Without the `fix` modifier the position will align the orientation to the normal of the surface.

TP+
```ruby
p := P[1..4]
q := P[5..8]

use_uframe 3
use_utool 2

p1.group(1).pose.polar.z -> [0, 80, 300, 90, 180, 0]
p2.group(1).pose.polar.z -> [90, 80, 300, 90, 180, 0]
p3.group(1).pose.polar.z -> [180, 80, 300, 90, 180, 0]
p4.group(1).pose.polar.z -> [270, 80, 300, 90, 180, 0]

q5.group(1).pose.polar.z.fix -> [0, 80, 300, 180, 0, 0]
q6.group(1).pose.polar.z.fix -> [90, 80, 300, 180, 0, 0]
q7.group(1).pose.polar.z.fix -> [180, 80, 300, 180, 0, 0]
q8.group(1).pose.polar.z.fix -> [270, 80, 300, 180, 0, 0]
```

LS
```
/POS
P[1:"p1"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 300.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = 180.000 deg
};
P[2:"p2"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = -80.000 mm, Y = 0.000 mm, Z = 300.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = -90.000 deg
};
P[3:"p3"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = -0.000 mm, Y = -80.000 mm, Z = 300.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = -0.000 deg
};
P[4:"p4"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 80.000 mm, Y = -0.000 mm, Z = 300.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = 90.000 deg
};
P[5:"q5"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 300.000 mm,
  W = 180.000 deg, P = -0.000 deg, R = 0.000 deg
};
P[6:"q6"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = -80.000 mm, Y = 0.000 mm, Z = 300.000 mm,
  W = 180.000 deg, P = -0.000 deg, R = 0.000 deg
};
P[7:"q7"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = -0.000 mm, Y = -80.000 mm, Z = 300.000 mm,
  W = 180.000 deg, P = -0.000 deg, R = 0.000 deg
};
P[8:"q8"]{
   GP1:
  UF : 3, UT : 2,  CONFIG : 'N B D, 0, 0, 0',
  X = 80.000 mm, Y = -0.000 mm, Z = 300.000 mm,
  W = 180.000 deg, P = -0.000 deg, R = 0.000 deg
};
/END

```

The origin location of the coordinate system can be speicifed with the `origin` keyword

TP+
```ruby
p1 := P[1]
use_uframe 3
use_utool 2

p1.group(1).pose.origin -> [50, 50, 0, 0, 0, 0]
p1.group(1).pose.polar.z -> [0, 80, 300, 90, 180, 0]
```

**WARNING** origins must be specified by a list of six values. Using the `xyz` modifier also currently does not work. The modifier must be `pose`.


Offsets in a coordinate system also work

```ruby
p := P[1..5]
use_uframe 3
use_utool 2

default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]
default.group(2).joints -> [0]

p1.group(1).pose.polar.z -> [0, 80, 300, 90, 180, 0]
p1.group(2).joints -> [0]

#rotate 45 degrees each pose
(p2..p5).group(1).xyz.offset.polar.z -> [45, 0 ,0]
#keep tool straight
(p2..p5).group(2).joints.offset -> [-45]
```


### Assigning posregs

TP+
```ruby
foo := PR[1]
bar := PR[2]

#assign full position
foo = bar
foo = Pos::setxyz(500, 500, 0, 90, 0, 180) #Ka-Boost method

#assign a axis
foo.x = 5
foo.y = 10
foo.z = 4
foo.w = 0
foo.p = -90
foo.r = 90

foo.x = bar.x + 10
foo.x = indirect('pr', 5) + 5

#assign specific group
foo.group(1) = bar.group(1)
foo.group(2).x += 180
foo.group(2).y += 90

foo.group(1) = Pos::setxyz(500, 500, 0, 90, 0, 180) #Ka-Boost method
foo.group(2) = Pos::setjnt2(0, 20) #Ka-Boost method
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
 : ! assign full position ;
 : PR[1:foo]=PR[2:bar] ;
 : CALL POS_SETXYZ(500,500,0,90,0,180,1) ;
 : ! Ka-Boost method ;
 :  ;
 : ! assign a axis ;
 : PR[1,1:foo]=5 ;
 : PR[1,2:foo]=10 ;
 : PR[1,3:foo]=4 ;
 : PR[1,4:foo]=0 ;
 : PR[1,5:foo]=(-90) ;
 : PR[1,6:foo]=90 ;
 :  ;
 : PR[1,1:foo]=PR[2,1:bar]+10 ;
 : PR[1,1:foo]=PR[5]+5 ;
 :  ;
 : ! assign specific group ;
 : PR[GP1:1:foo]=PR[GP1:2:bar] ;
 : PR[GP2:1,1:foo]=PR[GP2:1,1:foo]+180 ;
 : PR[GP2:1,2:foo]=PR[GP2:1,2:foo]+90 ;
 :  ;
 : CALL POS_SETXYZ(500,500,0,90,0,180,1,1) ;
 : ! Ka-Boost method ;
 : CALL POS_SETJNT6(0,20,1,2) ;
 : ! Ka-Boost method ;
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

## Math

### Functions

LS
```ruby
foo := R[1]
val := R[2]
val2 := R[2]

val = 90

#trig
foo = SIN[val]
foo = COS[val]
foo = TAN[val]
foo = ATAN[val]
foo = ACOS[val]
foo = ASIN[val]

val = 1
val2 = 2
foo = ATAN2[val, val2]

#logrithms
val = 1
foo = LN[val]
foo = EXP[val]

#exponentials
  #power
val = 2
val2 = 4
val2 = LN[val2]
val = val*val2
val2 = EXP[val]
  #or with kaboost
val = Mth::pow(val2, val)

val = 2
foo = SQRT[val]

#integer math
val = -1
foo = ABS[val]
val = 5.5
foo = TRUNC[val]
foo = ROUND[val]

ret := R[3]
val = 20
val2 = 2
ret = val % val2 # modulus operator
ret = val // val2 #integer division
```

### Matrix Math

LS
```ruby
#matrix math
#with ka-boost
pr1 := PR[1]
pr2 := PR[2]

pr1 = Pos::mult(&pr1, &pr2)
pr1 = Pos::inv(&pr1)

pr1 = Pos::cross(&pr1, &pr2)
pr1 = Pos::dot(&pr1, &pr2)

pr2 = Pos::slcmult(&pr1, 10)
pr2 = Pos::slcdiv(&pr1, 2)

#convert pose to cartesian representation
tool := UTOOL[1]
pr1 = tool
pr1 = Pos::cnvcart(&pr1)

#create a frame
pr3 := PR[3]
prFrame := PR[4]
frame := UFRAME[1]
prFrame = Pos::frame(&pr1, &pr2, &pr3)
frame = prFrame
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
## String Manipulation

**..note::** Contains KaBoost Routines

TP+
```ruby
name := SR[1]
arg1 := AR[1]
arg2 := AR[2]

name = Str::set('PROGRAM')
call name(arg1, arg2)
```

LS
```fanuc
/PROG example_1
/MN
  : CALL STR_SET('PROGRAM',1) ;
  : CALL SR[1:name](AR[1],AR[2]) ;
/END
```

## Timers

TP+
```ruby
my_timer := TIMER[1]

start my_timer
stop  my_timer
reset my_timer
# restart short-cut
restart my_timer
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
 : TIMER[1]=START ;
 : TIMER[1]=STOP ;
 : TIMER[1]=RESET ;
 : ! restart short-cut ;
 : TIMER[1]=STOP ;
 : TIMER[1]=RESET ;
 : TIMER[1]=START ;
/END
```

## wait statments

TP+
```ruby
foo := R[1]

# automatic WAIT time-unit conversion
wait_for(1, 's')
wait_for(100, 'ms')

# wait_until for expression conditions
wait_until(foo>3)

# wait timeouts
wait_until(foo>3).timeout_to(@bar)

# automatically set $WAITTMOUT
wait_until(foo>3).timeout_to(@bar).after(5,'s')

@bar
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
 : ! automatic WAIT time-unit ;
 : ! conversion ;
 : WAIT 1.00(sec) ;
 : WAIT .10(sec) ;
 :  ;
 : ! wait_until for expression ;
 : ! conditions ;
 : WAIT (R[1:foo]>3) ;
 :  ;
 : ! wait timeouts ;
 : WAIT (R[1:foo]>3) TIMEOUT,LBL[100] ;
 :  ;
 : ! automatically set $WAITTMOUT ;
 : $WAITTMOUT=(500) ;
 : WAIT (R[1:foo]>3) TIMEOUT,LBL[100] ;
 :  ;
 : LBL[100:bar] ;
/END
```

## Preprocessor

> [!**NOTE**]
> For a full description of the preprocessor see the [Ppr documentation](https://github.com/civol/ppr).

### Define Macros

Macros can be used as text replacement during compilation. Say you have a workcell with a mechanism on group 2, however have another workcell with the same mechanism on group 3. Depending on which environment file you are building with, the respective group number will be used.

**Environment File 1**
```ruby
.def Positioner_Group :< 2
```

**Environment File 2**
```ruby
.def Positioner_Group :< 3
```

**Main file**
```ruby
pr1.group(Positioner_Group) = Pos::setxyz(0, 0, 0, 0, 0, 0)
```

### Conditional Inclusion

The block below will only insert `printnr(varz)` if the macro `DEBUG`
is defined in the tpp arguements. 

`tpp example.tpp -o example.ls -m "DEBUG=true"`

```ruby
.if :< (defined?(@DEBUG))
  printnr(varz)
.else
.endif
```

This can be used to print or log debugging information if enabled throughout a project.

>[!WARNING]
> The `.else` statement is currently required to make this work.

### File inclusion

File inclusion can be used as an alternative to imports, which will copy, paste, and evaluate the file contents to where it is declared

**main.tpp**
```ruby
.require :< "functions.tpp"

val1 = R[10]
val1 = func1(arg1, arg2)
```
**functions.tpp**
```ruby
def func1(a1, a2)
  return(a1*a2)
end
```

### Code Execution

Arbitrary ruby code can be ran and executed inside the `.def`, `.do`, or `.if` macros

>[!IMPORTANT]
> If a macro is being used inside of execution code you must use the **.assign** keyword and not the **.def** keyword. If also using macro for text replacement you must declare it as both an **.assign** and **.def** macro.

The following code will create a circular path in coordinated motion with a rotary. 

```ruby
use_utool 3
use_uframe 2

TP_GROUPMASK = "1,1,*,*,*"

default.group(1).pose -> [0,0,0,90,180,0]
default.group(1).config -> ['F','U','T', 0, 0, 0]
default.group(2).joints -> [0]


.assign RADIUS :< 80
.assign INCREMENTS :< 20
.assign DISTANCE :< 100

.do
  #define points
  :< "p := P[1..#{@INCREMENTS}]"

  #set first point
  :< "joint_move.to(p1).at(15, '%').term(-1)\n"

  inc = @INCREMENTS.to_i
  degree = 0
  for i in 1..inc do
    #get degree
    degree = 360*(i-1)/(inc-1)
    :< "p#{i}.group(1).pose.polar.z -> [#{(-1*degree).to_s}, #{@RADIUS.to_s}, #{@DISTANCE.to_s}, 90, 180, 0]\n"
    :< "p#{i}.group(2).joints -> [#{(degree).to_s}]\n"
    :< "arc_move.to(p#{i}).at(50, 'mm/s').term(#{(i == 1 || i == inc) ? '-1' : '100'}).coord\n"
  end
.end
```

```fortran
/PROG TEST41
/ATTR
COMMENT = "TEST41";
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP = 1,1,*,*,*;
/APPL
/MN
 : UTOOL_NUM=3 ;
 : UFRAME_NUM=2 ;
 :  ;
 :  ;
 :  ;
 :  ;
 : J P[1:p1] 15% FINE ;
 : A P[1:p1] 50mm/sec FINE COORD ;
 : A P[2:p2] 50mm/sec CNT100 COORD ;
 : A P[3:p3] 50mm/sec CNT100 COORD ;
 : A P[4:p4] 50mm/sec CNT100 COORD ;
 : A P[5:p5] 50mm/sec CNT100 COORD ;
 : A P[6:p6] 50mm/sec CNT100 COORD ;
 : A P[7:p7] 50mm/sec CNT100 COORD ;
 : A P[8:p8] 50mm/sec CNT100 COORD ;
 : A P[9:p9] 50mm/sec CNT100 COORD ;
 : A P[10:p10] 50mm/sec CNT100 COORD ;
 : A P[11:p11] 50mm/sec CNT100 COORD ;
 : A P[12:p12] 50mm/sec CNT100 COORD ;
 : A P[13:p13] 50mm/sec CNT100 COORD ;
 : A P[14:p14] 50mm/sec CNT100 COORD ;
 : A P[15:p15] 50mm/sec CNT100 COORD ;
 : A P[16:p16] 50mm/sec CNT100 COORD ;
 : A P[17:p17] 50mm/sec CNT100 COORD ;
 : A P[18:p18] 50mm/sec CNT100 COORD ;
 : A P[19:p19] 50mm/sec CNT100 COORD ;
 : A P[20:p20] 50mm/sec FINE COORD ;
 :  ;
 :  ;
/POS
P[1:"p1"]{
   GP1:
  UF : 2, UT : 3,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 80.000 mm, Z = 100.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = 180.000 deg
   GP2:
  UF : 2, UT : 3,
    J1 = 0.000 deg
    };
P[2:"p2"]{
   GP1:
  UF : 2, UT : 3,  CONFIG : 'F U T, 0, 0, 0',
  X = 24.721 mm, Y = 76.085 mm, Z = 100.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = 162.000 deg
   GP2:
  UF : 2, UT : 3,
    J1 = 18.000 deg
    };
P[3:"p3"]{
   GP1:
  UF : 2, UT : 3,  CONFIG : 'F U T, 0, 0, 0',
  X = 48.145 mm, Y = 63.891 mm, Z = 100.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = 143.000 deg
   GP2:
  UF : 2, UT : 3,
    J1 = 37.000 deg
    };
P[4:"p4"]{
   GP1:
  UF : 2, UT : 3,  CONFIG : 'F U T, 0, 0, 0',
  X = 66.323 mm, Y = 44.735 mm, Z = 100.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = 124.000 deg
   GP2:
  UF : 2, UT : 3,
    J1 = 56.000 deg
    };
  .
  . 
  .
  .
P[18:"p18"]{
   GP1:
  UF : 2, UT : 3,  CONFIG : 'F U T, 0, 0, 0',
  X = -49.253 mm, Y = 63.041 mm, Z = 100.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = -142.000 deg
   GP2:
  UF : 2, UT : 3,
    J1 = 322.000 deg
    };
P[19:"p19"]{
   GP1:
  UF : 2, UT : 3,  CONFIG : 'F U T, 0, 0, 0',
  X = -26.045 mm, Y = 75.641 mm, Z = 100.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = -161.000 deg
   GP2:
  UF : 2, UT : 3,
    J1 = 341.000 deg
    };
P[20:"p20"]{
   GP1:
  UF : 2, UT : 3,  CONFIG : 'F U T, 0, 0, 0',
  X = -0.000 mm, Y = 80.000 mm, Z = 100.000 mm,
  W = -90.000 deg, P = 0.000 deg, R = -180.000 deg
   GP2:
  UF : 2, UT : 3,
    J1 = 360.000 deg
    };
/END

```


## Environment Files

An environment file can be used to save a configuration of a robot workcell or a workstation.

**environment**
```ruby
#----------
#Constants
#----------
FINE  :=  -1
CNT  := 100
PI    := 3.14159

#----------
#Frames
#----------
world        := UFRAME[1]
frame        := UFRAME[2]
tool         := UTOOL[1]

#----------
#Laser IO
#----------
Laser_Enable         := DO[1]
Laser_Ready          := DI[2]
Laser_On             := DO[3]

Laser_Power         :=  AO[1]

#----------
# User IO
#----------
system_ready    := UO[2]
Prgm_Run        := UO[3]
Prgm_Pause      := UO[4]

#-----------
# HMI Flags
#-----------
Hmi_Start            := F[1]
Hmi_Stop             := F[2]
Hmi_Laser_Enable        := F[3]
Hmi_Laser_Disable       := F[4]

#----------
#Program Registers
#----------
program_name := SR[1]

Alarm_Reg       := R[1]
Mem_Tool_No     := R[2]
Mem_Frame_No    := R[3]

j := R[50]
passes := R[51]
l := R[52]
layers := R[53]


#----------
#Workstations
#----------

namespace Headstock
  frame := UTOOL[2]
  select := F[38]
  home := PR[3]
.def Headstock_GROUP :< 2
.def Headstock_DIRECTION :< -1
end

namespace Positioner
  frame := UTOOL[3]
  select := F[37]
  home := PR[4]
.def Positioner_GROUP :< 3
.def Positioner_DIRECTION :< 1
end

#----------
#EEF Tools
#----------
namespace Tool1
  frame := UTOOL[1]
  read_pin := AI[1]
  interupt_pin := DI[8]
  SEARCH_DIST := 10
  SEARCH_SPEED := 3
end

namespace Tool2
  frame := UTOOL[3]
  read_pin := AI[2]
  interupt_pin := DI[10]
  SEARCH_DIST := 50
  SEARCH_SPEED := 6
end

#----------
#LAM Parameters
#----------
namespace Lam
  power          := R[60]
  flowrate       := R[26]
  speed          := R[61]
  strt           := DO[3]
  enable         := DO[1]
end

# ----------
# local variables
# -----------
local         := R[250..300]
local         := PR[80..100]

```

Through the usage of the [Ka-Boost](https://github.com/kobbled/Ka-Boost) library, specifically the [hash-registers](https://github.com/kobbled/kl-hash-registers) package, you can manage the robot controllers register set, and register comments.

Envoking the `-k <filename>,<true|false>` option will produce a .kl file which is the environment file represented as a hash table. This file will clear the comments of your register set (and values if specified), and update the register comments with the names in the hash table.

<details>
  </br>

For example this would be the output karel file from the environment above:
```pascal
PROGRAM tppenv
%NOLOCKGROUP

-------macros
--change depending on size of environment file
%define HASH_SIZE 19

%define HASH_PROGRAM 'env'
%define HASHTABLE 'tbl'
---------------

%include register_types.klt
--include value type
%include hashenv.klt
hash_type_define(hashenv)
--create hash type
t_hash(hashname,hval_def,hashenv)

VAR
  tblProg : STRING[16]
  tblName : STRING[16]
  reg : hval_def
  tbl FROM env: ARRAY[HASH_SIZE] OF hashname
  b : BOOLEAN

%include hashreg.klh

%class hashenv('hash.klc','hashclass.klh','hashenv.klt')

BEGIN
  IF UNINIT(tblProg) THEN
    tblProg = HASH_PROGRAM
  ENDIF
  IF UNINIT(tblName) THEN
    tblName = HASHTABLE
  ENDIF

  --set hashreg object
  hashr__set_hash_table(tblProg, tblName)
  
  --clear registers
  hashr__clear_registers(DATA_REG, FALSE)
  hashr__clear_registers(DATA_POSREG, FALSE)
  hashr__clear_registers(DATA_STRING, FALSE)
  hashr__clear_registers(io_flag, FALSE)

  --clear hash table
  reg = hashr__nullenv
  b = hashenv__clear_table(tblProg, tblName, reg)

  --**insert environment variables into hash**
  -----------
    reg.typ = io_dout ; reg.id = 1
  b = hashenv__put('Laser_Enable', reg, tblProg, tblName)
    reg.typ = io_din ; reg.id = 2
  b = hashenv__put('Laser_Ready', reg, tblProg, tblName)
    reg.typ = io_dout ; reg.id = 3
  b = hashenv__put('Laser_On', reg, tblProg, tblName)
    reg.typ = io_anout ; reg.id = 1
  b = hashenv__put('Laser_Power', reg, tblProg, tblName)
    reg.typ = io_uopout ; reg.id = 2
  b = hashenv__put('system_ready', reg, tblProg, tblName)
    reg.typ = io_uopout ; reg.id = 3
  b = hashenv__put('Prgm_Run', reg, tblProg, tblName)
    reg.typ = io_uopout ; reg.id = 4
  b = hashenv__put('Prgm_Pause', reg, tblProg, tblName)
    reg.typ = io_flag ; reg.id = 1
  b = hashenv__put('Hmi_Start', reg, tblProg, tblName)
    reg.typ = io_flag ; reg.id = 2
  b = hashenv__put('Hmi_Stop', reg, tblProg, tblName)
    reg.typ = io_flag ; reg.id = 3
  b = hashenv__put('Hmi_Laser_Enable', reg, tblProg, tblName)
    reg.typ = io_flag ; reg.id = 4
  b = hashenv__put('Hmi_Laser_Disable', reg, tblProg, tblName)
    reg.typ = DATA_STRING ; reg.id = 1
  b = hashenv__put('program_name', reg, tblProg, tblName)
    reg.typ = DATA_REG ; reg.id = 1
  b = hashenv__put('Alarm_Reg', reg, tblProg, tblName)
    reg.typ = DATA_REG ; reg.id = 2
  b = hashenv__put('Mem_Tool_No', reg, tblProg, tblName)
    reg.typ = DATA_REG ; reg.id = 3
  b = hashenv__put('Mem_Frame_No', reg, tblProg, tblName)
    reg.typ = DATA_REG ; reg.id = 50
  b = hashenv__put('j', reg, tblProg, tblName)
    reg.typ = DATA_REG ; reg.id = 51
  b = hashenv__put('passes', reg, tblProg, tblName)
    reg.typ = DATA_REG ; reg.id = 52
  b = hashenv__put('l', reg, tblProg, tblName)
    reg.typ = DATA_REG ; reg.id = 53
  b = hashenv__put('layers', reg, tblProg, tblName)
    -----------

  --set comment registers
  hashr__set_comments

END tppenv
```

</details>

## Misc Statments

### MNU Access

TP+
```ruby
foo := R[1]

#adjust payload
use_payload(1,group(1))
use_payload(foo,group(2))

#jog override
use_override 50
use_override foo

#set frames
use_uframe foo
use_utool foo

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
 : ! adjust payload ;
 : PAYLOAD[GP1:1] ;
 : PAYLOAD[GP2:R[1:foo]] ;
 :  ;
 : ! jog override ;
 : OVERRIDE=50% ;
 : OVERRIDE=R[1:foo] ;
 :  ;
 : ! set frames ;
 : UFRAME_NUM=R[1:foo] ;
 : UTOOL_NUM=R[1:foo] ;
/END
```

### collision guard

TP+
```ruby
foo := R[1]
colguard_on 
adjust_colguard
adjust_colguard 80
colguard_off
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
 : COL DETECT ON ;
 : COL GUARD ADJUST ;
 : COL GUARD ADJUST 80 ;
 : COL DETECT OFF ;
/END
```

### tool application headers

TP+
```ruby
PAINT_PROCESS = {
  DEFAULT_USER_FRAME : 1,
  DEFAULT_TOOL_FRAME : 1,
  START_DELAY        : 0,
  TRACKING_PROCESS   : no
}
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
PAINT_PROCESS ;
  DEFAULT_USER_FRAME : 1 ;
  DEFAULT_TOOL_FRAME : 1 ;
  START_DELAY : 0 ;
  TRACKING_PROCESS : no ;
/MN
/END
```


