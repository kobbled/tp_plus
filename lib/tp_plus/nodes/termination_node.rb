module TPPlus
  module Nodes
    class TerminationNode < BaseNode
      def initialize(value)
        @value = value
      end

      def eval(context)
        case @value
        when DigitNode
          "CNT#{@value.eval(context)}"
        when VarNode
          if @value.constant?
            val = @value.eval(context)
            if val[0] == "(" # negative
              "FINE"
            else
              "CNT#{val}"
            end
          else
            "CNT #{@value.eval(context)}"
          end
        else
          raise "invalid term"
        end
      end
    end
  end
end
