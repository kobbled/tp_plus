module TPPlus
  module Nodes
    class UnitsNode
      def initialize(s)
        @s = s
      end

      def eval(context)
        case @s
        when "mm/s"
          "mm/sec"
        end
      end
    end
  end
end
