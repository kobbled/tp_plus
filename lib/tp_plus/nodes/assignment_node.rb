module TPPlus
  module Nodes
    class AssignmentNode
      attr_reader :identifier, :assignable
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end
    end
  end
end
