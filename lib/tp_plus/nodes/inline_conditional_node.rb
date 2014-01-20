module TPPlus
  module Nodes
    class InlineConditionalNode
      def initialize(type, condition, block)
        @type      = type
        @condition = condition
        @block     = block
      end

      def condition_requires_mixed_logic?(context)
        @condition.is_a?(VarNode) || @condition.requires_mixed_logic?(context)
      end

      def block_requires_mixed_logic?(context)
        @block.requires_mixed_logic?(context)
      end

      def condition(context,options={})
        options[:opposite] ||= @type == "unless"

        if condition_requires_mixed_logic?(context) || block_requires_mixed_logic?(context)
          "(#{@condition.eval(context, options)})"
        else
          @condition.eval(context, options)
        end
      end

      def eval(context)
        "IF #{condition(context)},#{@block.eval(context,mixed_logic:true)}"
      end
    end
  end
end
