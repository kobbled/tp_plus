module TPPlus
  module Nodes
    class PoseNode < BaseNode
      def initialize(id, modifier, position)
        @id = id.to_sym
        @modifier = modifier.to_sym
        @position = position
      end

      def eval(context)
      end
    end
  end
end
