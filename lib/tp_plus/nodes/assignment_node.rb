module TPPlus
  module Nodes
    class AssignmentNode
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end
    end
  end
end
