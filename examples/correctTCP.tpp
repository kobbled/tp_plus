# ********************
# TCP Correction
# --------------------
# Dial in part into 
# ********************
# for more calarification please refer to the tcp_correction.md notes

import SensingTasks

local := R[50..100]
local := F[30..80]
local := PR[10..60]

#constents
GRIPPER_DEPTH := 75
PPC := 3   # recorded points per circle
FINE := -1


    tcp_calib_frame     := R[200]

#variables
    part_rad            := LR[]
    farCir_dist         := LR[]
    closeCir_dist       := LR[]
    part2tof_dist       := LR[]
    centers             := LR[]
    starting_dist       := LR[]
    down_retract_dist   := LR[]
    side_retract_dist   := LR[]
    
    # flags
    correctTCP          := LF[]
    
    tool_ofset  := PR[100]
    base_gripper := PR[101]
    part_frame := PR[102]

    # prs
    crrHomej            := LPR[]
    farCenter           := LPR[]
    closeCenter         := LPR[]
    edge_dir            := LPR[]
    old_pose            := LPR[]
    curr_pose           := LPR[]
    new_pose            := LPR[]

    #temp 
    temp                := LPR[]

#end of variables


#user input:

    # workpiece information
    PART_DIA := 153
    PART_LEN := 576
    part_rad = PART_DIA/2

    # far and close circles positions
    FAR_DIST      := 10   #mm wrt part edge
    CLOSE_DIST    := 10   #mm wrt gripper edge

    # for approach target calculation
    farCir_dist = PART_LEN - (GRIPPER_DEPTH + FAR_DIST)
    closeCir_dist = farCir_dist - (GRIPPER_DEPTH + CLOSE_DIST)

    # robot pose approach
    CLEARANCE := 10               # initial clearance between part and tof with respect to measure frame
    TOFAPPROACH_ANGLE := 0        # with respect to tof measure frame
    part2tof_dist = PART_DIA/2 + CLEARANCE

    # robot pose retraction
    down_retract_dist = PART_DIA
    side_retract_dist = PART_LEN

    # init correction flag
    correctTCP = on

    # correction home
    #crrHome = Pos::setxyz(-320.319, -448.787, -2401.247, -90.608, 44.984, 90.038)
    crrHomej = Pos::setjnt6(0, -30.724, 7.858, 0, -97.858, 0)

#end of user input


#preprocessing section

    # getting robot ready3
    TP_GROUPMASK = "1,*,*,*,*"
    TP_COMMENT = "3D tcp correction"
    
    default.group(1).pose -> [0, 0, 0, 0, 0 ,0]
    default.group(1).config -> ['N', 'U', 'T', 0, 0, 0]
    
    zero_pos := P[1]
    safe_pos := PR[12]

    # move to crrHome
    joint_move.to(crrHomej).at(30, '%').term(FINE)

    #move to safe pose
    joint_move.to(safe_pos).at(30, '%').term(FINE)

    # clear tool offset
    Pos::clrpr(&tool_ofset)

    #check safe pos
    G0_SAFE_POS()

    #rotate J1 to 120 deg
    G1_ROTT_J1(120)

    G0_DOOR_OPEN()

    temp = base_gripper
    part_frame = temp

    # move into approach
    use_uframe tcp_calib_frame
    use_utool base_gripper

#end of perprocessing section

#approach tof
SensingTasks::approach(TOFAPPROACH_ANGLE, part2tof_dist, farCir_dist)

#initiate poses

#correction iteration
while correctTCP
    #any pose here is refered to the tcp_frame
    get_linear_position(old_pose)
    
    #correct TCP orientation
    #record two center circles centers
    SensingTasks::recordCircles(PPC, farCir_dist, closeCir_dist, &farCenter, &closeCenter)
    
    # get current pose
    Pos::clrpr(&curr_pose)
    get_linear_position(curr_pose)

    #correct frame orientation and position
    new_pose = SensingTasks::correctFrame(&curr_pose, &farCenter, &closeCenter)
        
end

#retraction move
SensingTasks::retract(down_retract_dist, side_retract_dist)