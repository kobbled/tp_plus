module TPPlus
  module Nodes
    class StackDefinitionNode < BaseNode
      attr_accessor :range

      def initialize(type, range)
        @type = type
        @range = range
      end

      def eval(context)

        if (@type == 1)
          $stacks.pack[@range.type.to_sym] = TPPlus::Stack.new(@range.range, @range.type)
          $stacks.pack[@range.type.to_sym].push
        else
          $shared.pack[@range.type.to_sym] = TPPlus::Stack.new(@range.range, @range.type)
          $shared.pack[@range.type.to_sym].push
        end

        nil
      end

    end
  end
end