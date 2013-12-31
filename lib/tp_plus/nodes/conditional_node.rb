module TPPlus
  module Nodes
    class ConditionalNode
      def initialize(condition,true_block,false_block)
        @condition = condition
        @true_block = true_block
        @false_block = false_block
      end
    end
  end
end
