module TPPlus
  module Nodes
    class RecursiveNode < BaseNode
      attr_accessor :block

      def initialize
        @block = []
      end

      def get_block
        @block
      end
    end
  end
end
