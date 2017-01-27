module TPPlus
  module Nodes
    class AbortNode < BaseNode
      def eval(context)
        "ABORT"
      end
    end
  end
end
