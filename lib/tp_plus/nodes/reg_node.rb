module TPPlus
  module Nodes
    class RegNode < BaseNode
      attr_accessor :comment
      attr_reader :id

      def initialize(id)
        @id = id
        @comment = ""
      end
    end
  end
end