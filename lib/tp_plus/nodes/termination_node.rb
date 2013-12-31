module TPPlus
  module Nodes
    class TerminationNode
      def initialize(value)
        @value = value
      end

      def eval(context)
        "CNT#{@value.eval(context)}"
      end
    end
  end
end
