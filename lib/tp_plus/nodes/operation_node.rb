module TPPlus
  module Nodes
    class OperationNode < BaseNode
      def initialize(op, reg)
        @op = op
        @reg = reg
      end

      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        true
      end

      def eval(context,options={})
        "#{@op}[#{@reg.eval(context)}]"
      end
    end
  end
end