module TPPlus
  module Nodes
    class VarNode
      def initialize(identifier)
        @identifier = identifier
      end

      def eval(context)
        context.get_var(@identifier).eval(context)
      end
    end
  end
end
