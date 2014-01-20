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
        contains_expression? ||
          @grouped ||
          @op.requires_mixed_logic?(context) ||
          @left_op.requires_mixed_logic?(context) ||
          @right_op.requires_mixed_logic?(context)
      end

      def contains_expression?
        @left_op.is_a?(ExpressionNode) || @right_op.is_a?(ExpressionNode)
      end

      def with_parens(string, options={})
        return string unless options[:force_parens]

        "(#{string})"
      end

      # TODO: I don't like this
      def eval(context,options={})
        options[:force_parens] = true if @grouped

        if @op.bang?
          "!#{with_parens(@left_op.eval(context),options)}"
        else
          with_parens("#{@left_op.eval(context)}#{@op.eval(context,options)}#{@right_op.eval(context)}", options)
        end
      end
    end
  end
end
