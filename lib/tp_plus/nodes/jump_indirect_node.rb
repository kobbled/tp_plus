module TPPlus
  module Nodes
    class JumpIndirectNode < JumpNode
      def initialize(indirect)
        @indirect = indirect
      end

      def requires_mixed_logic?(context)
        false
      end

      def can_be_inlined?
        true
      end

      def eval(context,options={})
        "JMP LBL[#{@indirect.eval(context)}]"
      end
    end
  end
end
