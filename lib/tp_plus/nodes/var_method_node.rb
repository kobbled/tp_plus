module TPPlus
  module Nodes
    class VarMethodNode
      def initialize(identifier, method)
        @identifier = identifier
        @method = method
      end

      def eval(context)
        context.get_var(@identifier).eval(context,method:@method)
      end
    end
  end
end
