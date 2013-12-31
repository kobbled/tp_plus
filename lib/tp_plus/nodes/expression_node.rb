module TPPlus
  module Nodes
    class ExpressionNode
      attr_reader :left_op, :op, :right_op
      def initialize(left_op, op_string, right_op)
        @left_op  = left_op
        @op       = OperatorNode.new(op_string)
        @right_op = right_op
      end

      def eval(context,options={})
        "#{@left_op.eval(context)}#{@op.eval(context,options)}#{@right_op.eval(context)}"
      end
    end
  end
end
