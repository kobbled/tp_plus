module TPPlus
  module Nodes
    class DefinitionNode
      def initialize(identifier,assignable)
        @identifier = identifier
        @assignable = assignable
      end

      def eval(context)
        context.add_var(@identifier, @assignable)
        nil
      end
    end
  end
end
