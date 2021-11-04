require_relative 'transform'

module TPPlus
    module Motion
        module Utilities
            extend self
            def is_digit_or_letter?(char, expected)
                if char.to_s.match?(/[FUTfutNBDnbd]/)
                    return expected == :char
                elsif char.to_s.match?(/[-?\d+]/)
                    return expected == :number
                else
                    return false
                end
            end

            def merge_components(comp_list1, comp_list2, add_or_mask = false)
              # if set pose components are not the same size as the default components
              # merge the absent components with default components
              # set add_or_mask? to either add together comp_list1 and comp_list2
              # or mask comp_list1 and comp_list2
              if comp_list1.length < comp_list2.length
                a = comp_list1
                if add_or_mask
                  a = [comp_list1, comp_list2[0..comp_list1.length-1]].transpose.map {|x| x.reduce(:+)}
                end

                comp_list_merge = (a << comp_list2[comp_list1.length..-1]).flatten
              else
                if add_or_mask
                  comp_list_merge = [comp_list1, comp_list2].transpose.map {|x| x.reduce(:+)}
                else
                  comp_list_merge = comp_list1.clone
                end
              end

              comp_list_merge
            end

            def merge_components_back(comp_list1, comp_list2, add_or_mask = false)
              # if set pose components are not the same size as the default components
              # merge the absent components with default components
              # set add_or_mask? to either add together comp_list1 and comp_list2
              # or mask comp_list1 and comp_list2
              if comp_list1.length < comp_list2.length
                a = comp_list1
                if add_or_mask
                  a = [comp_list1, comp_list2[comp_list1.length..-1]].transpose.map {|x| x.reduce(:+)}
                end

                comp_list_merge = (comp_list2[0..comp_list1.length-1] << a).flatten
              else
                if add_or_mask
                  comp_list_merge = [comp_list1, comp_list2].transpose.map {|x| x.reduce(:+)}
                else
                  comp_list_merge = comp_list1.clone
                end
              end

              comp_list_merge
            end

            def polar_to_cartesian(origin, pose, z_axis, fix_orient = false)
              #pose ordering (theta, r, z, theta_rot, r_rot, z_rot)
              #if !fix_orient use orientation to align to surface normal
              #if fix_orient fix orientation 

              origin_mat = xyzrpw_2_pose(origin)

              case z_axis
              when 'x'
                pose_vec =  [pose[2], 0, pose[1]]
                trans_vec = origin_mat * rotx(pose[0] * Math::PI/180) * transl(pose_vec)
                
                if fix_orient
                  trans_vec = trans_vec * rotx(-1 * pose[0] * Math::PI/180)
                end
              when 'y'
                pose_vec =  [0, pose[2], pose[1]]
                trans_vec = origin_mat * roty(pose[0] * Math::PI/180) * transl(pose_vec)
                
                if fix_orient
                  trans_vec = trans_vec * roty(-1 * pose[0] * Math::PI/180)
                end
              when 'z'
                pose_vec =  [0, pose[1], pose[2]]
                trans_vec = origin_mat * rotz(pose[0] * Math::PI/180) * transl(pose_vec)
                
                if fix_orient
                  trans_vec = trans_vec * rotz(-1 * pose[0] * Math::PI/180)
                end
              end

              trans_vec = trans_vec * rotz(pose[5]*Math::PI/180) * roty(pose[4]*Math::PI/180) * rotx(pose[3]*Math::PI/180)
              
              pose_2_xyzrpw(trans_vec)
            end

            def cartesian_to_polar(x, y, z)
              #Output as: radius, theta, z
              [Math.sqrt(x**2 + y**2), Math.atan2(y,x), z]
            end

            def spherical_to_cartesian(origin, pose, z_axis, fix_orient = false)
              #pose ordering (theta, rho, z, theta_rot, rho_rot, z_rot)
              origin_mat = xyzrpw_2_pose(origin)

              case z_axis
              when 1
                pose_vec =  [0, 0, pose[2]]
                trans_vec = origin_mat * rotz(pose[0] * Math::PI/180) * roty(pose[1] * Math::PI/180) * transl(pose_vec)
              when 2
                pose_vec =  [0, 0, pose[2]]
                trans_vec = origin_mat * rotz(pose[0] * Math::PI/180 + Math::PI) * rotx(pose[1] * Math::PI/180) * transl(pose_vec)
              when 3
                pose_vec =  [0, pose[2], 0]
                trans_vec = origin_mat * roty(pose[0] * Math::PI/180) * rotx(pose[1] * Math::PI/180) * transl(pose_vec)
              end
              
              pose_2_xyzrpw(trans_vec)
            end

            def cartesian_to_spherical(x, y, z)
              #Output as: radius, theta, phi
              [Math.sqrt(x**2 + y**2 + z**2), Math.atan2(y, x), Math.atan2(Math.sqrt(x**2 + y**2), z)]
            end
        end
    end
end