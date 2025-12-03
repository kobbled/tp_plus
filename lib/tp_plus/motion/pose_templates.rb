module TPPlus
    module Motion

        MAX_AXES = 6
        
        module Types
            POSE = :pose
            JOINTS = :joints
            COORD = :xyz
            ORIENT = :orient
            CONFIG = :config
            EXTUNITS = :extunits

            KEYS = [POSE, JOINTS, COORD, ORIENT, CONFIG, EXTUNITS]
        end

        module Modifiers
          OFFSET = :offset
          SYSTEM = :coord
          SPHERE = 'sphere'
          POLAR = 'polar'
          ORIGIN = 'origin'
          FIX = :fix
        end
        
        module HashTemplate
            CONFIG = {
                :flip => false,
                :up => false,
                :top => false,
                :turn_counts => [0, 0, 0]
            }

            AXES = {
                :x => 0.0,
                :y => 0.0,
                :z => 0.0,
                :w => 0.0,
                :p => 0.0,
                :r => 0.0
            }

            AXESEXT = {
              :x => 0.0,
              :y => 0.0,
              :z => 0.0,
              :w => 0.0,
              :p => 0.0,
              :r => 0.0,
              :e1 => nil,
              :e2 => nil,
              :e3 => nil
          }

            CARTESIAN = {
                :group => 1,
                :uframe => 1,
                :utool => 1,
                :config => CONFIG.dup,
                :components => AXES.dup
            }

            JOINT = {
                :group => 1,
                :uframe => 1,
                :utool => 1,
                :components => []  # component items should be formatted as
                                   # [0.0, 'mm'], or [0.0, 'deg']
            }

            COORD_MM = [0.0, 'mm']
            COORD_DEG = [0.0, 'deg']
    
            POSE = { :id => 1,
                :comment => "",
                :mask => []
            }
        end

        module LsTemplates

        end
    end
end