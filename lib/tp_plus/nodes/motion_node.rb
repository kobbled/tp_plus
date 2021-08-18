module TPPlus
  module Nodes
    class MotionNode < BaseNode
      def initialize(type, mid, destination, modifiers)
        @type = type
        @mid = mid
        @destination = destination
        @modifiers = modifiers
      end

      def prefix
        case @type
        when "linear_move"
          "L"
        when "joint_move"
          "J"
        when "circular_move"
          "C"
        when "arc_move"
          "A"
        else
          raise "Unsupported motion"
        end
      end

      def speed_node
        @speed_node ||= @modifiers.select {|m| m.is_a? SpeedNode }.first
      end

      def termination_node
        @termination_node ||= @modifiers.select {|m| m.is_a? TerminationNode }.first
      end

      def actual_modifiers
        @actual_modifiers ||= @modifiers.reject {|m| m.is_a? SpeedNode}.reject {|m| m.is_a? TerminationNode }
      end

      def offset_modifiers
        @offset_modifiers ||= @modifiers.select {|m| m.is_a? OffsetNode}
      end

      def modifiers_string(context)
        strings_array = [""]
        return strings_array unless actual_modifiers.any?

        strings_array += actual_modifiers.map { |m| m.eval(context) }

        return strings_array

        # ..warning:: Removing gaurd for now
        # #add guard so that minimal rotation is not added into a linear move without
        # #the wrist joint modifier
        # if @type == "linear_move"
        #   if (strings_array[1].include? 'MROT') && !(strings_array[1].include? 'Wjnt')
        #     raise "Wrist Joint modifier is needed if minimal rotation is specified for a linear move."
        #   end
        # end
      end

      def offset_string(context)
        strings_array = [""]
        return strings_array unless actual_modifiers.any?

        strings_array += offset_modifiers.map { |m| m.eval(context) }

        return strings_array

      end
      
      def position_string(context)
        if @mid != nil
          "#{@mid.eval(context)}#{offset_string(context).join(" ")} \n  #{@destination.eval(context)}"
        else
          "#{@destination.eval(context)}"
        end
      end

      def speed_valid?(context)
        case @type
        when "linear_move", "circular_move", "arc_move"
          return true if speed_node.eval(context) == "max_speed"

          ["mm/sec"].include?(speed_node.units) or ["deg/sec"].include?(speed_node.units) or ["sec"].include?(speed_node.units)

        when "joint_move"
          return false if speed_node.eval(context) == "max_speed"

          ["%"].include? speed_node.units
        end
      end

      def eval(context)
        raise "Speed is invalid for motion type" unless speed_valid?(context)
        raise "Mid position not set" if @mid == nil && @type == "circular_move"

        "#{prefix} #{position_string(context)} #{speed_node.eval(context)} #{termination_node.eval(context)}#{modifiers_string(context).join(" ")}"
      end
    end
  end
end
