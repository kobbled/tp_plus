module TPPlus
  module Nodes
    class PoseNode < BaseNode
      def initialize(id, modifier, position)
        @id = id.to_sym
        @modifier = modifier.to_sym
        @position = position
      end

      def eval(context)
        context.pose_set.update(@id, @modifier, @position)
        ""
      end
    end
  end
end
