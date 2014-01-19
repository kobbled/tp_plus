module TPPlus
  module Nodes
    class VarMethodNode
      def initialize(identifier, method)
        @identifier = identifier
        @method = method
      end

      def eval(context)
        # first try to find a namespace
        if namespace = context.get_namespace(@identifier)
          namespace.get_var(@method).eval(context)
        else
          context.get_var(@identifier).eval(context,method:@method)
        end
      end
    end
  end
end
