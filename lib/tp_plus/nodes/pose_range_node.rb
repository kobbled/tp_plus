module TPPlus
  module Nodes
    class PoseRangeNode < BaseNode
      def initialize(vars, mods, position)
        @vars = vars
        @mods = mods
        @position = position
      end

      def eval(context)
        @vars.name_range.each do |id|
          pose = PoseNode.new(VarMethodNode.new(id,@mods), @position)
          pose.eval(context)
        end
        nil
      end
    end
  end
end
