module TPPlus
  module Nodes
    class InlineConditionalNode
      attr_reader :condition_node
      def initialize(type, condition, block)
        @type           = type
        @condition_node = condition
        @block          = block
      end

      def condition_requires_mixed_logic?(context)
        @condition_node.is_a?(VarNode) ||
          @condition_node.is_a?(NamespacedVarNode) ||
          @condition_node.requires_mixed_logic?(context)
      end

      def block_requires_mixed_logic?(context)
        @block.requires_mixed_logic?(context)
      end

      def can_be_inlined?
        false
      end

      def condition(context,options={})
        options[:opposite] ||= @type == "unless"

        if condition_requires_mixed_logic?(context) || block_requires_mixed_logic?(context)
          "(#{@condition_node.eval(context, options)})"
        else
          @condition_node.eval(context, options)
        end
      end

      def eval(context)
        "IF #{condition(context)},#{@block.eval(context,mixed_logic:true)}"
      end
    end
  end
end
