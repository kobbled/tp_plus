import test_import2

TP_GROUPMASK = "1,*,*,*,*"
TP_COMMENT = ""

FARCIR      := 10
CLOSECIR    := 10
CONST1 := 90
var1 := LR[]
var2 := LR[]

SET := 3
PART_DIA := 153
CLEARANCE := 0.03 

var1 = PART_DIA/2 + CLEARANCE

ns1::func1(CONST1, var1, var2)

ns1::func2(SET, var1, var2)