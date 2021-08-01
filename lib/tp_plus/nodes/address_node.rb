module TPPlus
  module Nodes
    class AddressNode < BaseNode
      attr_reader :id
      def initialize(id, ns = '')
        @id = id
        @namespace = ns
      end

      def requires_mixed_logic?(context)
        false
      end

      def node(context)
        if @id.is_a?(NamespacedVarNode)
          @ns = @id.namespace(context)
          @ns.get_var(@id.var_node.identifier)
        else
          context.get_var(@id.identifier)
        end
      end

      def eval(context,options={})
        node(context).id.to_s
      end
    end
  end
end
