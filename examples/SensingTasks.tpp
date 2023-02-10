
namespace SensingTasks
    # sensing tasks

    def approach(tofApproach_angle, part2tof_dist, farCir)
        # perform proper robot motion to approach the tof sensor, until surface is at zero with respect to
        # the tof measure frame. This motion is only on the z-axis.
        
        TP_GROUPMASK = "1,*,*,*,*"
        APPROACH_FACTOR := 2     # factor to position component at and then move linear to approach tof
        
        FINE := -1

        # building target approach pose for the first time only
        # when correcting for the second time we use initial pose
        #if not len(self.initCloseTrgt):

        pr1 := LPR[]
        Pos::clrpr(&pr1)


        #joint move to approach tof        
        pr1 = Pos::setxyz(-1*part2tof_dist, 0, -1* APPROACH_FACTOR * farCir, tofApproach_angle, 0, 0)
        pr1 = Pos::setcfg('N U T, 0, 0, 0')
        joint_move.to(pr1).at(30, '%').term(FINE)

        #linear move to approach tof
        pr1 = Pos::setxyz(-1*part2tof_dist, 0, -1*farCir, tofApproach_angle, 0, 0)
        pr1 = Pos::setcfg('N U T, 0, 0, 0')
        linear_move.to(pr1).at(100, 'mm/s').term(100)  # move to init far target

    end

    
    def retract(down_dist, side_dist)
        # perform proper retraction robot motion 
        # with loaded workpiece in mind
        
        TP_GROUPMASK = "1,*,*,*,*"

        pr1 := LPR[]
        shift := LPR[]

        #linear move to move outwards from tof (downward)
        SensingTasks::moveDownward(down_dist, 50)
        SensingTasks::moveSideward(side_dist, 50)

    end

    def recordCircles(ppc, farCir_dist, closeCir_dist, farCenter, closeCenter)
        # record two circles centers

        TP_GROUPMASK = "1,*,*,*,*"

        #var
        theta           := LR[]
        circle          := LR[]
        s               := LR[]     # sign
        pt              := LR[]     # point
        rot             := LR[]     # rotation

        tof_point       := LPR[]     # tof reading
        p1              := LPR[]     # point 1
        p2              := LPR[]     # point 2
        p3              := LPR[]     # point 3
        farC            := LPR[]     # far circle center
        closeC          := LPR[]     # close circle center

        # position registers
        record_frame    := LPR[]
        shift           := LPR[]
        
        # params
        theta = 360 / ppc                 # step anlge between points
        
        # starting with the far circle
        for circle in (1 to 2)
            
            # get the direction of the rotation 
            # CW or CCW for each circle
            if (circle % 2) then
                s = -1
            else
                s =  1
            end
            
            for pt in (1 to ppc)
                
                # to skip rotating for the first point
                if pt == 1 then
                    rot = 0
                else
                    rot = theta
                end

                # rotate part by theta
                Pos::clrpr(&shift)
                shift = Pos::setxyz(0, 0, 0, 0, 0, s * rot)
                shift = Pos::setcfg('N U T, 0, 0, 0')
                
                Pos::clrpr(&record_frame)
                get_linear_position(record_frame)
                record_frame = Pos::mult(&record_frame, &shift)
                record_frame = Pos::setcfg('N U T, 0, 0, 0')

                # move to pose
                linear_move.to(record_frame).at(50, 'mm/s').term(100)
                #joint_move.to(record_frame).at(30, '%').term(FINE)
                
                # touch zero of tof, and return tcp pose wrt user frame
                tof_point = SensingTasks::touchZero()

                # inverse the pose to get point wrt tof frame
                tof_point = Pos::inv(&tof_point)
                
                # get point wrt to user frame
                # needs to do transformation wrt user frame
                case pt
                    when 1
                        p1 = tof_point
                    when 2
                        p2 = tof_point
                    when 3
                        p3 = tof_point
                end
                
                # move away before rotate
                SensingTasks::moveDownward(100,50)
            
            end

            # find center of circle
            case circle
                when 1
                    #farC = Gbr::crCtr3Pts(&p1, &p2, &p3)         # cirCen3Pts
                    
                    # temp for simulating tof sensor
                    farC = Pos::setxyz(23.44, -23.25, 566, 0, 0, 0)
                    
                when 2
                    #closeC = Gbr::crCtr3Pts(&p1, &p2, &p3)     # cirCen3Pts
                    
                    # temp for simulating tof sensor                    
                    closeC = Pos::setxyz(-19.7, 19.8, 70, 0, 0, 0)
            end
            
            # only for the second iteration move and flip dir
            if circle == 1 then

                # close recording position
                Pos::clrpr(&shift)
                shift = Pos::setxyz(0, 0, closeCir_dist, 0, 0, 0)
                shift = Pos::setcfg('N U T, 0, 0, 0')
                
                Pos::clrpr(&record_frame)
                get_linear_position(record_frame)
                record_frame = Pos::mult(&record_frame, &shift)
                record_frame = Pos::setcfg('N U T, 0, 0, 0')
                
                # move to the close circle
                linear_move.to(record_frame).at(50, 'mm/s').term(100)  # move to init far target
            end

        end
        
        # store info
        indirect('pr', farCenter) = farC
        indirect('pr', closeCenter) = closeC
    end


    def touchZero() : posreg
        namespace touchPose
            strt := PR[1]
            search_dist := PR[2]
            found := PR[3]
        
            strt = Pos::setcfg('N U T, 0, 0, 0')
            search_dist = Pos::setcfg('N U T, 0, 0, 0')
            found = Pos::setcfg('N U T, 0, 0, 0')
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

        TP_GROUPMASK = "1,*,*,*,*"
        
        shift := LPR[]
        temp_frame := LPR[]
        Pos::clrpr(&shift)
        Pos::clrpr(&temp_frame)
        
        Pos::clrpr(&touchPose::strt)
        Pos::clrpr(&touchPose::search_dist)
        Pos::clrpr(&touchPose::found)

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
                    touchPose::search_dist.x = 100
                    
                    #Pos::clrpr(&shift)
                    Pos::clrpr(&temp_frame)
                    get_linear_position(temp_frame)
                    temp_frame.x = temp_frame.x + 10

                    #search for touch if not found go back to start of loop
                    #On next iteration move from previous position
                    linear_move.to(temp_frame).at(50, 'mm/s').term(FINE)
                    #tool_offset(touchPose::search_dist).skip_to(@find_zero)

                    #temp section
                    jump_to @end
                  
            end

        jump_to @end

        @found_zero
        get_linear_position(touchPose::found)

        #sample sensor
        wait_for(100, "ms") # make sure robot isnt moving
        sensor_reading = sensor::sample(&sensor::val, sensor::SAMPLING_TIME)

        jump_to @end

        @end

        return(touchPose::found)
    end

    def correctFrame(curr_pose, farCenter, closeCenter) : posreg
    
        # correct tcp frame using two circles centers and the orginal tcp pose
        # The two circle ceneter should be wrt to tcp, and tcp pose should be wrt to user_frame
        # input: current_tcp, farCenter closeCenter (centers are wrt to user frame)
        # output: new_tcp

        TP_GROUPMASK = "1,*,*,*,*"

        #var
        axis_angle      := LPR[]
        axis            := LPR[]
        angle           := LR[]
        correction_axis := LR[]
        
        normal          := LPR[]
        p_point         := LPR[]
        p_normal        := LPR[]
        sect_point      := LPR[]
        
        farC            := LPR[]
        closeC          := LPR[]
        
        #temp
        temp            := LPR[]
        new_pose        := LPR[]

        # init
        correction_axis = 3
        new_pose = Pos::setxyz(0,0,0,0,0,0)
        new_pose = Pos::setcfg('N U T, 0, 0, 0')

        # transform centers to user frame
        farC = Pos::mult(&curr_pose, &farCenter)
        closeC = Pos::mult(&curr_pose, &closeCenter)

        #compute normals of the (far-close) line and tcp z vector wrt UF
        temp = Pos::sub(&farC, &closeC)
        normal = Gbr::norm(&temp)

        # get axis and angle of rotation
        axis_angle = Gbr::gtRtAx(curr_pose, correction_axis, &normal)   # 3 = > z axis
        
        axis.x  = axis_angle.x
        axis.y  = axis_angle.y
        axis.z  = axis_angle.z
        angle   = axis_angle.w

        # rotate tcp frame
        new_pose = Gbr::rtArAx(curr_pose, &axis, angle)
        
        # get vector of axis from pose
        p_normal = Gbr::gtUtAx(&new_pose, correction_axis)

        # update plane information
        p_point.x = new_pose.x
        p_point.y = new_pose.y
        p_point.z = new_pose.z

        # compute plane and line intersection
        sect_point = Gbr::lpIntr(farCenter, closeCenter, &p_point, &p_normal)

        # update tcp frame
        new_pose.x = sect_point.x
        new_pose.y = sect_point.y
        new_pose.z = sect_point.z

        # return new tcp frame
        return(new_pose)
    end

end