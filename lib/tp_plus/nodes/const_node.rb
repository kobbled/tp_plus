module TPPlus
  module Nodes
    class ConstNode < BaseNode
      attr_accessor :comment
      attr_reader :id

      def initialize(value)
        @value = value
      end
    end
  end
end