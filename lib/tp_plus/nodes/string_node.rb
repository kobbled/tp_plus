module TPPlus
  module Nodes
    class StringNode < BaseNode
      def initialize(s)
        @s = s
      end

      def eval(context)
        "'#{@s}'"
      end
    end
  end
end
