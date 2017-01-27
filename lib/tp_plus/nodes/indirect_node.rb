module TPPlus
  module Nodes
    class IndirectNode < BaseNode
      def initialize(type, target)
        @type   = type
        @target = target
      end

      def requires_mixed_logic?(context)
        return true if @type == :f

        false
      end

      def eval(context,options={})
        s = "#{@type.upcase}[#{@target.eval(context)}]"
        if options[:opposite]
          s = "!#{s}"
        end
        if options[:as_condition]
          s = "(#{s})"
        end
        s
      end
    end
  end
end
