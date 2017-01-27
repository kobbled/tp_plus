module TPPlus
  module Nodes
    class ReturnNode < BaseNode
      def eval(context)
        "END"
      end
    end
  end
end
