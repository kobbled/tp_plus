module TPPlus
  module Nodes
    # for setting skip conditions
    class SetSkipNode < BaseNode
      def initialize(value)
        @value  = value
      end

      def eval(context)
        "SKIP CONDITION #{@value.eval(context, disable_mixed_logic: true)}"
      end
    end
  end
end
