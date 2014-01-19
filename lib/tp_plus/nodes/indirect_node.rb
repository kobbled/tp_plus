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
        else
          raise "Invalid indirect type"
        end
      end

      def eval(context)
        "#{string}[#{@target.eval(context)}]"
      end
    end
  end
end
