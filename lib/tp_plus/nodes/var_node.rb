module TPPlus
  module Nodes
    class VarNode
      attr_reader :identifier
      def initialize(identifier)
        @identifier = identifier
      end

      def target_node(context)
        @target_node ||=  @identifier.upcase == @identifier ? context.get_constant(@identifier) : context.get_var(@identifier)
      end

      def requires_mixed_logic?(context)
        target_node(context).is_a?(IONode) && target_node(context).requires_mixed_logic?
      end

      def eval(context,options={})
        return target_node(context).eval(context) if @identifier.upcase == @identifier

        s = ""
        if options[:opposite]
          s += "!"
        end
        s + target_node(context).eval(context)
      end
    end
  end
end
