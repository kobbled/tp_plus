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
        false
      end

      def boolean_result?
        false
      end

      def eval(context,options={})
        if options[:opposite]
          options[:opposite] = false #VarNode.eval() with options[:opposite] will add a !
          @x.eval(context, options)
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
