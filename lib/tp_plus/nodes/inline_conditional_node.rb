module TPPlus
  module Nodes
    class InlineConditionalNode
      def initialize(type, condition, block)
        @type = type
        @condition = condition
        @block = block
      end

      def simple?
        @block.is_a? JumpNode
      end

      def mixed_logicable?
        @block.is_a? AssignmentNode
      end

      def condition(context)
        @c ||= @condition.eval(context, opposite: @type == "unless")
      end

      def eval(context)
        if simple?
          "IF #{condition(context)},#{@block.eval(context)}"
        else
          "IF (#{condition(context)}),#{@block.eval(context)}"
        end
      end
    end
  end
end
