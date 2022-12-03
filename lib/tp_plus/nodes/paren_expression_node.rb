module TPPlus
  module Nodes
    class ParenExpressionNode < ExpressionNode
      attr_reader :x

      def initialize(x)
        @x = x

        @func_exp = []
        contains_call?(@func_exp)
        @ret_var = []
        create_ret_var(@func_exp, @ret_var)
      end

      def requires_mixed_logic?(context)
        @x.requires_mixed_logic?(context)
      end

      def check_balance(s)
        if s[0] == '(' && s[-1] == ')'
          return true
        else
          return false
        end
      end

      def eval(context, options={})
        s = @x.eval(context, options)
        if !check_balance(s)
          "(#{s})"
        else
          s
        end
      end
    end
  end
end
