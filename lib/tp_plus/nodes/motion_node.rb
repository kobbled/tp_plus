module TPPlus
  module Nodes
    class MotionNode
      def initialize(type, destination, modifiers)
        @type = type
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

      def modifiers_string(context)
        return "" unless actual_modifiers.any?

        strings_array = [""] << actual_modifiers.map { |m| m.eval(context) }
        @modifiers_string = strings_array.join(" ")
      end

      def eval(context)
        "#{prefix} #{@destination.eval(context)} #{speed_node.eval(context)} #{termination_node.eval(context)}#{modifiers_string(context)}"
      end
    end
  end
end
