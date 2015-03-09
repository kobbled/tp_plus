module TPPlus
  module Nodes
    class TerminationNode
      def initialize(value)
        @value = value
      end

      def eval(context)
        val = @value.eval(context)
        case val
        when Integer
          "CNT#{val}"
        else
          if val[0] == "R"
            "CNT #{val}"
          else
            "FINE"
          end
        end
      end
    end
  end
end
