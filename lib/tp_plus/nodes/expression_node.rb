module TPPlus
  module Nodes
    class ExpressionNode
      attr_reader :left_op, :op, :right_op
      def initialize(left_op, op_string, right_op)
        @left_op  = left_op
        @op       = OperatorNode.new(op_string)
        @right_op = right_op
      end

      def left_paren(options={})
        return "" unless options[:force_parens]

        "("
      end

      def right_paren(options={})
        return "" unless options[:force_parens]

        ")"
      end

      # TODO: I don't like this
      def eval(context,options={})
        options[:force_parens] ||= false

        options[:force_parens] = true if @op.requires_mixed_logic?

        "#{left_paren(options)}#{@left_op.eval(context)}#{@op.eval(context,options)}#{@right_op.eval(context)}#{right_paren(options)}"
      end
    end
  end
end
