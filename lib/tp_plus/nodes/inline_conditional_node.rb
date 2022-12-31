module TPPlus
  module Nodes
    class InlineConditionalNode < RecursiveNode
      def initialize(type, condition, block)
        super(condition)

        @type           = type
        @block          = block
      end

      def condition_requires_mixed_logic?(context)
        @condition[0].is_a?(VarNode) ||
          @condition[0].is_a?(NamespacedVarNode) ||
          @condition[0].requires_mixed_logic?(context)
      end

      def block_requires_mixed_logic?(context)
        @block.requires_mixed_logic?(context)
      end

      def eval_condition(context,options={})
        options[:opposite] ||= @type == "unless"

        if condition_requires_mixed_logic?(context) || block_requires_mixed_logic?(context)
          "(#{@condition[0].eval(context, options)})"
        else
          @condition[0].eval(context, options)
        end
      end

      def eval(context)
      end
    end
  end
end
