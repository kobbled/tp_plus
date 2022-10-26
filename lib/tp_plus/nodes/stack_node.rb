module TPPlus
  module Nodes
    class StackDefinitionNode < BaseNode
      attr_accessor :range

      def initialize(range)
        @range = range
      end

      def eval(context)
        $stacks.pack[@range.type.to_sym] = TPPlus::Stack.new(@range.range, @range.type)
        $stacks.pack[@range.type.to_sym].push

        nil
      end

    end
  end
end