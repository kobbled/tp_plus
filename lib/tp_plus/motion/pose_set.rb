require_relative 'structs'

module TPPlus
  module Motion
    class PoseSet
      def initialize()
        @set = {}
        #track last position
        @last_pose = {:id => :p_default, :pose => Motion::DEFAULT_POSE.dup}
        @last_jpos = {:id => :p_default, :pose => Motion::DEFAULT_JPOS.dup}
      end

      def get_pose(id)
        raise "Pose (#{id}) not defined" if @set[id].nil?
        @set[id]
      end

      def set_pose(id, type, position)
        raise "Pose (#{id}) not defined" if @set[id].nil?
        if type == :jpos
          @set[id] = position.dup
        else
          @set[id] = position.dup
          @set[id].config = position.config.dup
        end
      end

      def get_last_pose(type)
        if type == :jpos
          @last_jpos[:joints]
        else
          @last_pose[:pose]
        end
      end

      def set_last_pose(id, type)
        raise "Pose (#{id}) not defined" if @set[id].nil?
        if type == :jpos
          @last_jpos[:id] = id
          @last_jpos[:joints] = @set[id].dup
        else
          @last_pose[:id] = id
          @last_pose[:pose] = @set[id].dup
        end
      end

      def push(pose)
        @set[pose.to_sym] = Motion::DEFAULT_POSE
      end

      def update(id, type, position)
        raise "Pose (#{id}) not defined" if @set[id].nil?

        set_pose(id, type, get_last_pose(type))
        #update pose parameter
        case type
          when :pose
            @set[id].coord = position[0..2]
            @set[id].orient = position[3..5]
          when :config
            @set[id].config.flips = position[0..2]
            @set[id].config.turns = position[3..5]
          when :jpos
            @set[id].joints = position
          when :xyz
            @set[id].coord = position
          when :orient
            @set[id].orient = position
        end
        #update last pose
        set_last_pose(id, type)
      end

      
    end
  end
end
