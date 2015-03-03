module TPPlus
  module Nodes
    class ParenExpressionNode
      def initialize(x)
        @x = x
      end

      def requires_mixed_logic?(context)
        @x.requires_mixed_logic?(context)
      end

      def eval(context, options={})
        "(#{@x.eval(context, options)})"
      end
    end
  end
end
