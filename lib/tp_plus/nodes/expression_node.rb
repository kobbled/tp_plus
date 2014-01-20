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
          [@op, @left_op, @right_op].map { |op|
            op.requires_mixed_logic?(context)
          }.any?
      end

      def contains_expression?
        [@left_op, @right_op].map {|op| op.is_a? ExpressionNode }.any?
      end

      def with_parens(string, options={})
        return string unless options[:force_parens]

        "(#{string})"
      end

      def to_s(context, options={})
        if @op.bang?
          "!#{@left_op.eval(context)}"
        else
          "#{@left_op.eval(context)}#{@op.eval(context,options)}#{@right_op.eval(context)}"
        end
      end

      # TODO: I don't like this
      def eval(context,options={})
        options[:force_parens] = true if @grouped

        with_parens(to_s(context, options), options)
      end
    end
  end
end
