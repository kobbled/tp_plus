module TPPlus
  module Nodes
    class TerminatorNode < BaseNode
      def eval(context)
        nil
      end
    end
  end
end

# IF R[1:foo]<>1,JMP LBL[100] ;
# R[1:foo]=2 ;
# JMP LBL[101] ;
# LBL[100] ;
# R[1:foo]=1 ;
# LBL[101] ;
