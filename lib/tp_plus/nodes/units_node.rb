module TPPlus
  module Nodes
    class UnitsNode < BaseNode
      def initialize(s)
        @s = s
      end

      def eval(context)
        case @s
        when "mm/s"
          "mm/sec"
        when "%"
          "%"
        else
          raise "Unknown unit: #{@s}"
        end
      end
    end
  end
end
