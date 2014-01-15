module TPPlus
  module Nodes
    class WaitUntilNode
      def initialize(expression)
        @expression = expression
      end

      def eval(context)
        "WAIT (#{@expression.eval(context)})"
      end
    end
  end
end
