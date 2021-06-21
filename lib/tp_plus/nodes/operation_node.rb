module TPPlus
  module Nodes
    class OperationNode < BaseNode
      def initialize(op, reg, reg2)
        @op = op
        @reg = reg
        @reg2 = reg2
      end

      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        true
      end

      def eval(context,options={})
        if @reg.is_a?(DigitNode)
          raise "Only registers can be used with built ins."
        end

        @reg2.nil? ? (return "#{@op}[#{@reg.eval(context)}]") : (return "#{@op}[#{@reg.eval(context)},#{@reg2.eval(context)}]")
      end
    end
  end
end