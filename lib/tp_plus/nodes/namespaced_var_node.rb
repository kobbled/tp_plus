module TPPlus
  module Nodes
    class NamespacedVarNode
      attr_reader :identifier
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

      def target_node(context)
        constant? ? context.get_constant(@var_node.identifier) : context.get_var(@var_node.identifier)
      end

      def constant?
        @var_node.identifier.upcase == @identifier
      end

      def requires_mixed_logic?(context)
        target_node(context).is_a?(IONode) && target_node(context).requires_mixed_logic?
      end

      def with_parens(s, options)
        return s unless options[:as_condition]

        "(#{s})"
      end

      def eval(context,options={})
        return target_node(context).eval(context) if constant?

        s = ""
        if options[:opposite]
          s += "!"
        end
        with_parens(s + target_node(namespace(context)).eval(context), options)
      end
    end
  end
end
