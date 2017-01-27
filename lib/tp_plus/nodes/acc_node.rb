module TPPlus
  module Nodes
    class AccNode < BaseNode
      def initialize(value)
        @value = value
      end

      def eval(context)
        val = @value.eval(context)
        case val
        when Integer
          "ACC#{val}"
        else
          "ACC #{val}"
        end
      end
    end
  end
end
