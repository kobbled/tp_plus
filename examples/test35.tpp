namespace Enum
  TYPE1 := 1
  TYPE2 := 2
  TYPE3 := 3
  TYPE4 := 4
end

inline def func1(type, prnum, val)
  using Enum

  TP_GROUPMASK = "1,*,*,*,*"

  Pos::clrpr(prnum)

  case type
    when Enum::TYPE1
      indirect('posreg', prnum).x = val
      indirect('posreg', prnum).y = val
      indirect('posreg', prnum).z = val
    when Enum::TYPE2
      indirect('posreg', prnum).x = val
    when Enum::TYPE3
      indirect('posreg', prnum).y = val
    when Enum::TYPE4
      indirect('posreg', prnum).z = val
  end
end

TP_GROUPMASK = "1,*,*,*,*"

var1 := R[1]
var2 := PR[2]
var3 := R[3]
flg1 := F[30]

if flg1
  var1 = 1
  var3 = 100
else
  var1 = 3
  var3 = 50
end

func1(var1, &var2, var3)