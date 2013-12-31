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

      def eval(context)
        "#{prefix} #{@destination.eval(context)} #{speed_node.eval(context)} #{termination_node.eval(context)}"
      end
    end
  end
end
