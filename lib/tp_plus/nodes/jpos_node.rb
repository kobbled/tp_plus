module TPPlus
  module Nodes
    class JPOSNode
      def initialize(var)
        @var = var
      end

      def eval(context, options={})
        "#{@var.eval(context, options)}=JPOS"
      end
    end
  end
end
