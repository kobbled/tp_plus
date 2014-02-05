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
        if options[:as_string]
          ("%.2f" % @value).sub(/^0/,'')
        else
          @value
        end
      end
    end
  end
end
