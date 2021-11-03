require "erb"
require_relative 'pose_templates'
require_relative 'utilities'

module TPPlus
    module Motion

      # %%%%%%%%%%%%%%%%%
      # CREATOR
      # %%%%%%%%%%%%%%%%%

      module PoseCreator
        class Creator
          def create(id, no)
            raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
          end

          def add(id, no)
            pose = create(id, no)

            return pose
          end
        end

        class Pose < Creator
          def create(id, no)
            pose = Motion::Pose::Pose.new(no, id)
            pose
          end
        end
      end

      # %%%%%%%%%%%%%%%%%
      # POSE GROUPS
      # %%%%%%%%%%%%%%%%%

      module GroupCreator
        class Creator
          attr_reader :group, :components, :config, :uframe, :utool
          def initialize(id, frame, tool, rep = [], config = [])
            @group = id
            @uframe = frame
            @utool = tool
            @components = rep
            @config = config
          end

          def set_pose(pose)
            @components = pose
            nil
          end

          def set_frame(f)
            @uframe = f
            nil
          end

          def set_tool(f)
            @utool = f
            nil
          end

          def set_config(config)
            @config = config
            nil
          end

          def create
            raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
          end
        end

        class Cart < Creator
          def initialize(id, frame, tool, rep = [], config = [])
            super

            if rep
              set_pose(rep)
            end
            if config.empty?
              set_config(Motion::HashTemplate::CONFIG.clone)
            else
              set_config(config)
            end
          end

          def set_pose(pose)
            @components = pose

            if pose.is_a?(Array)
              raise "cartesian position needs an Array of #{Motion::MAX_AXES} values" if @components.length < Motion::MAX_AXES
              @components = Motion::HashTemplate::AXES.clone

              @components[:x] = pose[0]
              @components[:y] = pose[1]
              @components[:z] = pose[2]
              @components[:w] = pose[3]
              @components[:p] = pose[4]
              @components[:r] = pose[5]
            end

            nil
          end

          def set_config(config)
            if config.is_a?(Hash)
              raise "configuration hash is not a Motion::HashTemplate::CONFIG" unless config.key?(:flip) && config.key?(:turn_counts)
              @config = config
            end

            if config.is_a?(Array)
              format = [:char, :char, :char, :number, :number, :number]
              if config.zip(format).each { |c, f| Utilities.is_digit_or_letter?(c, f) }.all?
                config_hash = Motion::HashTemplate::CONFIG.clone
                config_hash[:flip] = true if config[0].upcase == "F"
                config_hash[:up] = true if config[1].upcase == "U"
                config_hash[:top] = true if config[2].upcase == "T"
                config_hash[:turn_counts] = config[3..5]

                @config = config_hash
              else
                raise "configuration array is not in the correct format: ['N', 'B', 'D', 0, 0, 0]"
              end
            end
            nil
          end
        end

        class Joint < Creator
          def initialize(id, frame, tool, rep = [], config = [])
            super

            if rep
              set_pose(rep)
            else
              raise "no coordinates are specified for this position"
            end
          end

          def set_pose(pose)
            @components = []
            pose.each do |x|
              if x.is_a?(Array)
                if x.length > 1
                  raise "unspecified unit for measure #{x[1]}" unless (x[1] == 'deg') || (x[1] == 'mm') 
                  @components.append([x[0], x[1]])
                else
                  @components.append([x[0], 'deg'])
                end
              else
                @components.append([x, 'deg'])
              end
            end
            nil
          end

        end

      end

      # %%%%%%%%%%%%%%%%%
      # POSE OBJECT
      # %%%%%%%%%%%%%%%%%

      module Pose
        class Pose
          attr_reader :id, :comment, :groups
          def initialize(id, comment)
            @id = id
            @comment = comment
            @groups = {}
          end

          def make
            raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
          end

          def add_group(frame, tool, type, grp_no = 1)
            case type 
            when Motion::Types::POSE, Motion::Types::COORD, Motion::Types::ORIENT
              grp = GroupCreator::Cart.new(grp_no, frame, tool)
            when Motion::Types::JOINTS
              grp = GroupCreator::Joint.new(grp_no, frame, tool)
            end
            @groups[grp_no] = grp
          end

          def add_group_pose(frame, tool, type, components, grp_no = 1)
            case type 
            when Motion::Types::POSE
              if !@groups.key?(grp_no) || (@groups[grp_no].is_a?(GroupCreator::Joint))
                @groups[grp_no] = GroupCreator::Cart.new(grp_no, frame, tool, components)
              else
                @groups[grp_no].set_pose(components)
              end
            when Motion::Types::COORD
              if components.length < Motion::MAX_AXES
                merge_components(components, Array.new(Motion::MAX_AXES, 0))
              end
              if !@groups.key?(grp_no)
                @groups[grp_no] = GroupCreator::Cart.new(grp_no, frame, tool, components)
              else
                @groups[grp_no].set_pose(components)
              end
            when Motion::Types::ORIENT
              if components.length < Motion::MAX_AXES
                merge_components_back(components, Array.new(Motion::MAX_AXES, 0))
              end
              if !@groups.key?(grp_no)
                @groups[grp_no] = GroupCreator::Cart.new(grp_no, frame, tool, components)
              else
                @groups[grp_no].set_pose(components)
              end
            when Motion::Types::CONFIG
              if !@groups.key?(grp_no)
                @groups[grp_no] = GroupCreator::Cart.new(grp_no, frame, tool, Array.new(6, 0), components)
              else
                @groups[grp_no].set_config(components)
              end
            when Motion::Types::JOINTS
              if !@groups.key?(grp_no) || (@groups[grp_no].is_a?(GroupCreator::Cart))
                @groups[grp_no] = GroupCreator::Joint.new(grp_no, frame, tool, components)
              else
                @groups[grp_no].set_pose(components)
              end
            end
            
            nil
          end
        end

      end

      # %%%%%%%%%%%%%%%%%
      # FACTORY
      # %%%%%%%%%%%%%%%%%

      module Factory
        class Pose
          include ERB::Util
          attr_accessor :poses

          TEMPLATE_FILE = File.join(File.dirname(__FILE__),"templates/ls.erb")

          def initialize(frame = 0, tool = 0, start = 1)
            @current_id = start
            @current_frame = frame
            @current_tool = tool
            @poses = {}
            @default_pose = PoseCreator::Pose.new.add(:default, 0)
            @last_pose = PoseCreator::Pose.new.add(:last, 0)
          end

          def add(id, no = @current_id)
            obj = PoseCreator::Pose.new
            pose = obj.add(id, no)
            @poses[id] = pose
            @current_id = no + 1

            nil
          end

          def set_pose(id, type, options={})
            unless (@default_pose.groups.length > 0)
              opt = {}
              opt[:components] = [0,0,0,0,0,0]
              set_default(Motion::Types::POSE, opt)
              warn 'default position not set! May give unintended results! Check position data before running!'
            end

            raise "pose identifier does not exist" unless @poses.has_key?(id)

            pose = @poses[id]

            #copy default into pose if no groups have been set
            if pose.groups.length == 0
              pose = copy_preset(pose, @default_pose)
            end
            end
            
            #merge components and default components together. Transform default components to a list
            case type
            when Motion::Types::POSE, Motion::Types::COORD
              options[:components] = Utilities.merge_components(options[:components], pose.groups[options[:group]].components.values, options[Motion::Modifiers::OFFSET])
            when Motion::Types::ORIENT
              options[:components] = Utilities.merge_components_back(options[:components], pose.groups[options[:group]].components.values, options[Motion::Modifiers::OFFSET])
            when Motion::Types::JOINTS
              options[:components] = Utilities.merge_components(options[:components], pose.groups[options[:group]].components.transpose[0], options[Motion::Modifiers::OFFSET])
            end

            add_group(pose, type, options)

            #set as last pose
            _ = copy_preset(@last_pose, pose)
          end

          def set_default(type, options={})
            add_group(@default_pose, type, options)
          end

          def set_tool(tool)
            @current_tool = tool
            if !@default_pose.groups.empty?
              @default_pose.groups.each do |k,v|
                v.set_tool(tool)
              end
            end
          end

          def set_frame(frame)
            @current_frame = frame
            if !@default_pose.groups.empty?
              @default_pose.groups.each do |k,v|
                v.set_frame(frame)
              end
            end
          end

          def copy_pose(lval, rval)
            raise "pose factory #{self} does not have a pose named #{key}" unless @poses.key?(lval.to_sym)
            raise "pose factory #{self} does not have a pose named #{key}" unless @poses.key?(rval.to_sym)
            
            @poses[rval.to_sym].groups.each do |k, v|
              @poses[lval.to_sym].groups[k] = v.clone
            end
          end

          def eval
            @poses.each do |k, v|
              if v.groups.empty?
                #copy defauly pose for poses unspecified
                v = copy_preset(v, @default_pose)
              end
            end

            template = ERB.new(File.read(TEMPLATE_FILE), nil, '-')
            
            template.result(binding)
          end

          private

          def add_group(pose, type, options={})
            if options.is_a?(Hash)
              if options.key?(:components)
                #add in components or a config
                if options[:group]
                  pose.add_group_pose(@current_frame, @current_tool, type, options[:components], options[:group])
                else
                  pose.add_group_pose(@current_frame, @current_tool, type, options[:components])
                end
              else
                if options[:group]
                  pose.add_group_pose(@current_frame, @current_tool, type, [], options[:group])
                else
                  pose.add_group_pose(@current_frame, @current_tool, type, [])
                end
                end
            else
              pose.add_group(@current_frame, @current_tool, type)
            end
          end

          def copy_preset(lval, rval)
            #copy default into pose if no groups have been set
            rval.groups.each do |k, v|
              lval.groups[k] = v.clone
            end

            lval
          end
          
        end
      end

    end
end