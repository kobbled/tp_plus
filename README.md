TP+
===

[![Build Status](https://travis-ci.com/kobbled/tp_plus.svg?branch=master)](https://travis-ci.org/onerobotics/tp_plus)


TP+ is a higher-level language abstraction that translates into FANUC TP. It features many useful utilities that makes creating TP programs easier:

* Functions and inline functions
* Importing numerous files
* Namespacing
* Variable declaration for registers, position registers, IO, etc.
* Local variables
* Readable motion statements
* Streamlined position declaration
* Position manipulation
* Build the same program for multiple controllers through the use of environment files and imports
* Managing Register sets on controller
* Register and Postion ranges for easy declaration of blocks of registers
* Automatic label numbering
* Improved looping
* Easier managment of numerous TP files
* Can be used with the package manager [Rossum](https://github.com/kobbled/rossum)

> This branch was forked from the archived repo [TP+](https://github.com/onerobotics/tp_plus)

> see [Features](#features) for a quick look at the features

> see [examples.md](examples.md) for an indepth introduction to TP+

> Test examples can be found in [./examples](https://github.com/kobbled/tp_plus/tree/master/examples) directory of this repository


<!-- TOC -->

- [TP+](#tp)
  - [Install](#install)
  - [Updating](#updating)
  - [Usage](#usage)
  - [Features](#features)
    - [Pose Declarations](#pose-declarations)
    - [Namespaces](#namespaces)
    - [Functions](#functions)
    - [Inline Functions](#inline-functions)
    - [Importing Files](#importing-files)
    - [Local Variables](#local-variables)
    - [Expressions in Arguments](#expressions-in-arguments)
    - [Environment Files](#environment-files)
  - [Documentation](#documentation)
  - [License](#license)

<!-- /TOC -->

Install
-----------

1. Install Ruby
2. Install git
3. Install bundler `gem install bundler`
4. Clone the repo `git clone https://github.com/kobbled/tp_plus.git`
5. Install dependencies with `bundle`
6. Build the parser and run the tests with `bundle exec rake`
7. Make sure all tests pass
8. Add full path of **./tp_plus/bin** to your environment path

```shell
set PATH=%PATH%;\path\to\tp_plus\bin
```

Updating
-----------

In a command prompt, or git shell run
```
git fetch && git pull
rake
```
**WARNING** : Make sure you run `rake` after git pull to update the racc parser, as this compilation is not tracked in the repo.

Usage
-----
print output to console:

```shell
tpp filename.tpp
```

print output to file (must be the same filename):

```shell
tpp filename.tpp -o filename.ls
```

interpret using an environment file:

```shell
tpp filename.tpp -e env.tpp
```

include folders:

```shell
tpp filename.tpp -i ../folder1 -i ../folder2
```

build karel hash table from environment file. The first argument is to specify the filename (without the extension) that the hash will be written to. The second argument specifies if you also want to clear the register values on execution of the karel program.

> [!**WARNING**]
> Setting to `true` will wipe the registers, position registers, and string registers from the controller

```shell
tpp filename.tpp -k 'karelFilename',false
```

See `tpp --help` for options.

> [!**INFO**]
> All of these options can be accessed through vscode using the [Fanuc TP-Plus Language Extension](https://marketplace.visualstudio.com/items?itemName=kobbled.fanuc-tp-plus)

> [!**INFO**]
> All of these options can be specified in the [Rossum](https://github.com/kobbled/rossum) package manager through the `package.json` file

Features
-----------

### Pose Declarations

<table>
<tr>
<td> <b>TP+</b> </td> <td> <b>TP</b> </td>
</tr>
<tr>
<td>

```ruby
TP_GROUPMASK = "1,*,*,*,*"
TP_COMMENT = "test prog"

p := P[1..6]

tool := UTOOL[5]
frame := UFRAME[3]

use_utool tool
use_uframe frame

#declare a default pose to set all positions to
#if they are not explicitly declared
default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
default.group(1).config -> ['F', 'U', 'T', 0, 0, 0]

#declare joint pose
p1.group(1).joints -> [180, 23.2, 90.5, 0, 60.8, -90.5]
joint_move.to(p1).at(30, '%').term(-1)

#declare position
p2.group(1).pose -> [0,50,100,0,90,0]
p2.group(1).config -> ['F', 'U', 'T', 0, 0, 0]

#independently set position and orientation
p3.group(1).xyz -> [0,30,0]
p3.group(1).orient -> [90,0,0]
p3.group(1).config -> ['F', 'U', 'T', 0, 0, 0]

arc_move.to(p2).at(50, 'mm/s').term(100)
arc_move.to(p3).at(50, 'mm/s').term(100)

#batch declare poses, as well as apply offsets
(p4..p6).group(1).xyz.offset -> [0, 0 ,50]
linear_move.to(p4).at(50, 'mm/s').term(-1)
linear_move.to(p5).at(30, 'mm/s').term(100)
linear_move.to(p6).at(30, 'mm/s').term(-1)
```

</td>
<td>

```fortran
/PROG TEST10
COMMENT = "test prog";
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 : UTOOL_NUM=5 ;
 : UFRAME_NUM=3 ;
 :  ;
 : ! declare joint pose ;
 : J P[1:p1] 30% FINE ;
 :  ;
 : ! declare position ;
 :  ;
 : ! independently set position and ;
 : ! orientation ;
 :  ;
 : A P[2:p2] 50mm/sec CNT100 ;
 : A P[3:p3] 50mm/sec CNT100 ;
 :  ;
 : ! batch declare poses, as well as ;
 : ! apply offsets ;
 : L P[4:p4] 50mm/sec FINE ;
 : L P[5:p5] 30mm/sec CNT100 ;
 : L P[6:p6] 30mm/sec FINE ;
/POS
P[1:"p1"]{
   GP1:
  UF : 3, UT : 5,
    J1 = 180.000 deg, J2 = 23.200 deg, J3 = 90.500 deg,
    J4 = 0.000 deg, J5 = 60.800 deg, J6 = -90.500 deg};
P[2:"p2"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 50.000 mm, Z = 100.000 mm,
  W = 0.000 deg, P = 90.000 deg, R = 0.000 deg};
P[3:"p3"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 30.000 mm, Z = 0.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = 0.000 deg};
P[4:"p4"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 30.000 mm, Z = 50.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = 0.000 deg};
P[5:"p5"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 30.000 mm, Z = 100.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = 0.000 deg};
P[6:"p6"]{
   GP1:
  UF : 3, UT : 5,  CONFIG : 'F U T, 0, 0, 0',
  X = 0.000 mm, Y = 30.000 mm, Z = 150.000 mm,
  W = 90.000 deg, P = 0.000 deg, R = 0.000 deg};
/END
```

</td>
</tr>
</table>

### Namespaces

<table>
<tr>
<td> <b>TP+</b> </td> <td> <b>TP</b> </td>
</tr>
<tr>
<td>

```ruby
namespace ns1
  VAL1 := 1
  VAL2 := 2
end

namespace ns2
  VAL1 := 3.14
  VAL2 := 2.72
end

def test()
  using ns1, ns2

  foo := R[1]
  bar := R[2]
  foostr := SR[3]

  foo = ns1::VAL1
  bar = ns1::VAL2

  foostr = Str::set(ns2::VAL1)
  foo = ns3::test2()
end
```

</td>
<td>

```fortran
/PROG TEST
COMMENT = "TEST";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 :  ;
 :  ;
 : R[1:foo]=1 ;
 : R[2:bar]=2 ;
 :  ;
 : CALL STR_SET(3.14,3) ;
 : CALL NS3_TEST2(1) ;
/END

```

</td>
</tr>
</table>

### Functions

<table>
<tr>
<td> <b>TP+</b> </td> <td> <b>TP</b> </td>
</tr>
<tr>
<td>

```ruby
namespace Math
  M_PI := 3.14159

  def arclength(ang, rad) : numreg
    using M_PI

    return(ang*rad*M_PI/180)
  end

  def arcangle(len, rad) : numreg
    using M_PI

    return(len/rad*180/M_PI)
  end
end

arclength := R[1]
arcangle := R[2]

arclength = Math::arclength(90, 85)
arcangle = Math::arclength(arclength, 85)
```

</td>
<td>

```fortran
/PROG TEST
COMMENT = "TEST";
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 : CALL MATH_ARCLENGTH(90,85,1) ;
 : CALL MATH_ARCLENGTH(R[1:arclength],85,2) ;
/POS
/END
```

```fortran
/PROG MATH_ARCANGLE
COMMENT = "MATH_ARCANGLE";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : R[AR[3]]=(AR[1]/AR[2]*180/3.14159) ;
 : END ;
/END
```

```fortran
/PROG MATH_ARCLENGTH
COMMENT = "MATH_ARCLENGTH";
DEFAULT_GROUP = *,*,*,*,*;
/MN
 : R[AR[3]]=(AR[1]*AR[2]*3.14159/180) ;
 : END ;
/END
```

</td>
</tr>
</table>


### Inline Functions

<table>
<tr>
<td> <b>TP+</b> </td> <td> <b>TP</b> </td>
</tr>
<tr>
<td>

```ruby
namespace Math
  M_PI := 3.14159

  inline def arclength(ang, rad) : numreg
    using M_PI

    return(ang*rad*M_PI/180)
  end

  inline def arcangle(len, rad) : numreg
    using M_PI

    return(len/rad*180/M_PI)
  end
end

arclength := R[1]

arclength = Math::arclength(90, 85)
```

</td>
<td>

```fortran
/PROG TEST
COMMENT = "TEST";
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 : ! inline Math_arclength ;
 :  ;
 : R[1:arclength]=(90*85*3.14159/180) ;
 : ! end Math_arclength ;
 :  ;
/POS
/END
```

</td>
</tr>
</table>

### Importing Files

<table>
<tr>
<td> <b>TP+</b> </td> <td> <b>TP</b> </td>
</tr>
<tr>
<td>

```ruby
import math_imp

arclength := R[30]
degress   := R[31]
radius    := R[32]

degress = 90
radius = 85

arclength = Math::arclength(degress, radius)
```

_math_imp.tpp_
```ruby
namespace Math
  M_PI := 3.14159

  inline def arclength(ang, rad) : numreg
    using M_PI

    return(ang*rad*M_PI/180)
  end

  inline def arcangle(len, rad) : numreg
    using M_PI

    return(len/rad*180/M_PI)
  end
end
```

</td>
<td>

```fortran
/PROG TEST
COMMENT = "TEST";
DEFAULT_GROUP = 1,*,*,*,*;
/MN
 :  ;
 : R[31:degress]=90 ;
 : R[32:radius]=85 ;
 :  ;
 : ! inline Math_arclength ;
 :  ;
 : R[30:arclength]=(R[31:degress]*R[32:radius]*3.14159/180) ;
 : ! end Math_arclength ;
 :  ;
/POS
/END
```

</td>
</tr>
</table>

### Local Variables

<table>
<tr>
<td> <b>TP+</b> </td> <td> <b>TP</b> </td>
</tr>
<tr>
<td>

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

</td>
<td>

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

</td>
</tr>
</table>

### Expressions in Arguments

<table>
<tr>
<td> <b>TP+</b> </td> <td> <b>TP</b> </td>
</tr>
<tr>
<td>

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

</td>
<td>

```fortran
/PROG TEST
COMMENT = "TEST";
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

</td>
</tr>
</table>

### Environment Files

You can save the robot controller configuration into an environment file. This can be swiched out depending on which robot you are using, and can be used to manage the register names on the controller (see: [examples.md](examples.md#environment-files))

> [!TODO]
> A preprocessor still needs to be added to TP+ in order to fully define a workcell/workstation in an environment file.

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
  GROUP := 2
  DIRECTION := -1
end

namespace Positioner
  frame := UTOOL[3]
  select := F[37]
  home := PR[4]
  GROUP := 3
  DIRECTION := 1
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

Documentation
----------

Build rdocs with:

```
rake rdoc
```

License
-------

TP+ is released under the [MIT License](http://www.opensource.org/licenses/MIT).
