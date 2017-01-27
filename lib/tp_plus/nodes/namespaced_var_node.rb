module TPPlus
  module Nodes
    class NamespacedVarNode < BaseNode
      attr_reader :namespaces
      def initialize(namespaces, var_node)
        @namespaces = namespaces
        @var_node   = var_node
      end

      def namespace(context)
        @context = context
        @namespaces.each do |ns|
          if @context.get_namespace(ns)
            @context = @context.get_namespace(ns)
          end
        end

        @context
      end

      def identifier
        @var_node.identifier
      end

      def target_node(context)
        @var_node.target_node(namespace(context))
      end

      def requires_mixed_logic?(context)
        @var_node.requires_mixed_logic?(namespace(context))
      end

      def eval(context,options={})
        @var_node.eval(namespace(context), options)
      end
    end
  end
end
