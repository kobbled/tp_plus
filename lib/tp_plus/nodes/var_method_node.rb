module TPPlus
  module Nodes
    class VarMethodNode
      def initialize(identifier, method)
        @identifier = identifier
        @method = method
      end

      def requires_mixed_logic?(context)
        node(context).requires_mixed_logic?(context)
      end

      def node(context)
        if namespace(context)
          namespace(context).get_var(@method)
        else
          context.get_var(@identifier)
        end
      end

      def namespace(context)
        @namespace ||= context.get_namespace(@identifier)
      end

      def eval(context,options={})
        # first try to find a namespace
        if namespace(context)
          node(context).eval(context,options)
        else
          node(context).eval(context,options.merge(method:@method))
        end
      end
    end
  end
end
