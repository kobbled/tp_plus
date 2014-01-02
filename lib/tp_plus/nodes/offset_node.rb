module TPPlus
  module Nodes
    class OffsetNode
      def initialize(var)
        @var = var
      end

      def eval(context)
        if context.get_var(@var.identifier).is_a? PosregNode
          "Offset,#{@var.eval(context)}"
        else
          "VOFFSET,#{@var.eval(context)}"
        end
      end
    end
  end
end
