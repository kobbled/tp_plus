module TPPlus
  module Nodes
    class ExpressionNode
      attr_reader :left_op, :op, :right_op
      attr_accessor :grouped
      def initialize(left_op, op_string, right_op)
        @left_op  = left_op
        @op       = OperatorNode.new(op_string)
        @right_op = right_op
      end

      def requires_mixed_logic?(context)
        contains_expression? || @grouped || @op.requires_mixed_logic?(context)
      end

      def contains_expression?
        @left_op.is_a?(ExpressionNode) || @right_op.is_a?(ExpressionNode)
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
        options[:force_parens] = true if @grouped

        if @op.bang?
          "!#{left_paren(options)}#{@left_op.eval(context)}#{right_paren(options)}"
        else
          "#{left_paren(options)}#{@left_op.eval(context)}#{@op.eval(context,options)}#{@right_op.eval(context)}#{right_paren(options)}"
        end
      end
    end
  end
end
