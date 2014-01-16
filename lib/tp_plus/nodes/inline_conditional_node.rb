module TPPlus
  module Nodes
    class InlineConditionalNode
      def initialize(type, condition, block)
        @type = type
        @condition = condition
        @block = block
      end

      # TODO: refactor.. this is super ugly
      def simple?(context)
        if @condition.is_a? ExpressionNode
          if @condition.left_op.is_a? VarNode
            return false if context.get_var(@condition.left_op.identifier).is_a? ArgumentNode
          end
          if @condition.right_op.is_a? VarNode
            return false if context.get_var(@condition.right_op.identifier).is_a? ArgumentNode
          end
        end

        @block.is_a? JumpNode
      end

      def condition(context,options={})
        options[:opposite] ||= @type == "unless"

        if @condition.is_a? VarNode
          "(#{@condition.eval(context, options)})"
        else
          @condition.eval(context, options)
        end
      end

      def eval(context)
        if simple?(context)
          "IF #{condition(context)},#{@block.eval(context)}"
        else
          "IF #{condition(context,force_parens: true)},#{@block.eval(context,mixed_logic:true)}"
        end
      end
    end
  end
end
