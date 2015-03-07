module TPPlus
  module Nodes
    class ParenExpressionNode
      def initialize(x)
        @x = x
      end

      def eval(context, options={})
        "(#{@x.eval(context, options)})"
      end
    end
  end
end
