module TPPlus
  module Nodes
    class RegNode < BaseNode
      attr_accessor :comment
      attr_reader :id

      def initialize(id)
        @id = id
        @comment = ""
      end

      def setName(name)
        @comment = name
      end
    end
  end
end