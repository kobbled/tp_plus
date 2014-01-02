module TPPlus
  module Nodes
    class RealNode
      def initialize(value)
        @value = value
      end

      def eval(context)
        ("%.2f" % @value).sub!(/^0/,'')
      end
    end
  end
end
