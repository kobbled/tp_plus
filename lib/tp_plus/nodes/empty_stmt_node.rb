module TPPlus
  module Nodes
    class EmptyStmtNode < BaseNode
      def eval(context, options={})
        ""
      end
    end
  end
end
