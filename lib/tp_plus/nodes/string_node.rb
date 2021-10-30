module TPPlus
  module Nodes
    class StringNode < BaseNode
      attr_reader :comment, :string
      def initialize(s)
        @string = s
        @comment = ''
      end

      def setName(name)
        @comment = name
      end

      def eval(context)
        "'#{@string}'"
      end
    end
  end
end
