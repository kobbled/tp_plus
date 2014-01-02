module TPPlus
  module Nodes
    class TerminationNode
      def initialize(value)
        @value = value
      end

      def eval(context)
        if @value.is_a? DigitNode
          "CNT#{@value.eval(context)}"
        else
          # for registers
          "CNT #{@value.eval(context)}"
        end
      end
    end
  end
end
