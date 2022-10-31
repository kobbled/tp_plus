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
  frame := UFRAME[2]
  select := F[38]
  home := PR[3]
  GROUP := 2
  DIRECTION := -1
end

namespace Positioner
  frame := UFRAME[3]
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
