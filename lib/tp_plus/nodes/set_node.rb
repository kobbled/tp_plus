module TPPlus
  module Nodes
    class SetNode
      def initialize(type, target, value)
        @type   = type
        @target = target
        @value  = value
      end

      def eval(context)
        case @type
        when "set_uframe"
          "UFRAME[#{@target.eval(context)}]=#{@value.eval(context)}"
        else
          raise "Unsupported FANUC setter"
        end
      end
    end
  end
end
