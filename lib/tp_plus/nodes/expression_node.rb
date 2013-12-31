module TPPlus
  module Nodes
    class ExpressionNode
      attr_reader :left_op, :op, :right_op
      def initialize(left_op, op, right_op)
        @left_op  = left_op
        @op       = op
        @right_op = right_op
      end

      def eval(context)
        "#{@left_op.eval(context)}#{@op}#{@right_op.eval(context)}"
      end
    end
  end
end
