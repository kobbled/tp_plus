module TPPlus
  module Nodes
    class UnaryExpressionNode < BaseNode
      attr_reader :op, :x
      def initialize(op, x)
        @op = OperatorNode.new(op)
        @x = x
      end

      def grouped?
        false
      end

      def requires_mixed_logic?(context)
        true
      end

      def contains_expression?
        true
      end

      def boolean_result?
        false
      end

      def eval(context,options={})
        if options[:opposite]
          new_options = options.dup
          new_options.delete(:opposite) # VarNode.eval() with opposite will add a !
          @x.eval(context, new_options)
        elsif options[:disable_mixed_logic]
          options[:disable_mixed_logic] = false
          "#{@x.eval(context, options)}=OFF"
        else
          "#{@op.eval(context, options)}#{@x.eval(context, options)}"
        end
      end
    end
  end
end
