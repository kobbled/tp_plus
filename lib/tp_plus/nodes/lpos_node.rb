module TPPlus
  module Nodes
    class LPOSNode
      def initialize(var)
        @var = var
      end

      def eval(context, options={})
        "#{@var.eval(context, options)}=LPOS"
      end
    end
  end
end
