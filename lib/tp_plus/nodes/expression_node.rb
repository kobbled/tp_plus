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
            next if op.nil?
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

      def string_val(context, options={})
        if @op.bang?
          # this is for skip conditions, which do not
          # support mixed logic
          if options[:disable_mixed_logic]
            "#{@left_op.eval(context)}=OFF"
          else
            "#{@op.eval(context,options)}#{@left_op.eval(context)}"
          end
        else
          "#{@left_op.eval(context)}#{@op.eval(context,options)}#{@right_op.eval(context)}"
        end
      end

      def eval(context,options={})
        options[:force_parens] = true if @grouped

        with_parens(string_val(context, options), options)
      end
    end
  end
end
