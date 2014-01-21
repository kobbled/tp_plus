module TPPlus
  module Nodes
    class IndirectNode
      def initialize(type, target)
        @type = type
        @target = target
      end

      def string
        case @type
        when :position
          "P"
        when :position_register
          "PR"
        when :flag
          "F"
        else
          raise "Invalid indirect type"
        end
      end

      def requires_mixed_logic?(context)
        case @type
        when :flag
          true
        else
          false
        end
      end

      def eval(context,options={})
        s = "#{string}[#{@target.eval(context)}]"
        if options[:opposite]
          s = "!#{s}"
        end
        s
      end
    end
  end
end
