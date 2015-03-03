module TPPlus
  module Nodes
    class VarMethodNode
      attr_reader :identifier
      def initialize(identifier, method)
        @identifier = identifier
        @method = method || {}
      end

      def requires_mixed_logic?(context)
        node(context).requires_mixed_logic?(context)
      end

      def node(context)
        context.get_var(@identifier)
      end

      def eval(context,options={})
        node(context).eval(context,options.merge(@method))
      end
    end
  end
end
