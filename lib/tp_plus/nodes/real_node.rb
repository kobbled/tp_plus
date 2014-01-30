module TPPlus
  module Nodes
    class RealNode
      def initialize(value)
        @value = value
      end

      def requires_mixed_logic?(context)
        false
      end

      def eval(context,options={})
        ("%.2f" % @value).sub(/^0/,'')
      end
    end
  end
end
