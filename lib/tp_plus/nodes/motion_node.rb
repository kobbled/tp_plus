module TPPlus
  module Nodes
    class MotionNode
      def initialize(type, destination, modifiers)
        @type = type
        @destination = destination
        @modifiers = modifiers
      end
    end
  end
end
